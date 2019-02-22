/*
      Purpose:
            Rolls up custom "Standard Hours" field on project task to top of WBS.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/18/18
*/

public class ProjectTaskHandler {
    public static void handleProjectTasks(Map<Id, pse__Project_Task__c> ptNewMap, Map<Id, pse__Project_Task__c> ptOldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        Map<Id, pse__Project_Task__c> ptMap = isDelete ? ptOldMap : ptNewMap;
        Set<Id> parentTaskIds = collectParentTaskIds(ptMap, isInsert, isUpdate, isDelete, ptOldMap);
        if (!parentTaskIds.isEmpty()) {
            List<pse__Project_Task__c> parentTasks = queryParentTasks(parentTaskIds);
            List<pse__Project_Task__c> parentsToUpdate = new List<pse__Project_Task__c>();
            for (pse__Project_Task__c parentTask : parentTasks) {
                Decimal totalStandardHours = accumulateTotalStandardHours(parentTask);
                updateParentTask(totalStandardHours, parentTask, parentsToUpdate);
            }
            if (!parentsToUpdate.isEmpty()) {
                update parentsToUpdate;
            }
        }
    }


    public static void updateProjectSite(Map<Id, pse__Project_Task__c> ptNewMap, Boolean isUpdate, Boolean isBefore) {
        Map<Id, pse__Project_Task__c> ptMap = new Map<Id, pse__Project_Task__c>();
        if(isUpdate && isBefore){
            ptMap = ptNewMap;
        }
        Set<Id> projectId = new Set<Id>();
        for (pse__Project_Task__c pt : ptMap.values()) {
            projectId.add(pt.pse__Project__c);
        }
        List<Project_Site__c> projectSites = [
                SELECT Id, Site__c,Address_Type__c,Project__c
                FROM Project_Site__c
                WHERE Project__c IN :projectId AND (Address_Type__c = 'Install At Contact' OR Address_Type__c = 'Shipping')
        ];
        if(!projectSites.isEmpty()) {
            for (pse__Project_Task__c pt : ptMap.values()) {
                for (Project_Site__c ps : projectSites) {
                    if (pS.Address_Type__c == 'Install At Contact' && ps.Project__c == pt.pse__Project__c) {
                        pt.Project_Site__c = pS.Id;

                    } else if (pS.Address_Type__c == 'Shipping' && ps.Project__c == pt.pse__Project__c) {
                        pt.Project_Site__c = pS.Id;
                    }
                    continue;
                }
            }
        }
        //update

    }
    private static void updateParentTask(Decimal totalStandardHours, pse__Project_Task__c parentTask, List<pse__Project_Task__c> parentsToUpdate) {
        if (totalStandardHours != parentTask.PSA_Standard_Hours__c) {
            parentTask.PSA_Standard_Hours__c = totalStandardHours;
            parentsToUpdate.add(parentTask);
        }
    }

    private static Decimal accumulateTotalStandardHours(pse__Project_Task__c parentTask) {
        Decimal totalStandardHours = 0.0;
        for (pse__Project_Task__c childTask : parentTask.pse__Immediate_Sub_Tasks__r) {
            if (childTask.PSA_Standard_Hours__c != null) {
                totalStandardHours += childTask.PSA_Standard_Hours__c;
            }
        }
        return totalStandardHours;
    }

    private static List<pse__Project_Task__c> queryParentTasks(Set<Id> parentTaskIds) {
        List<pse__Project_Task__c> parentTasks = [
                SELECT
                        Name,
                        PSA_Standard_Hours__c,
                        pse__Hierarchy_Depth__c,
                        pse__Parent_Task__c, (
                        SELECT
                                Name,
                                PSA_Standard_Hours__c,
                                pse__Hierarchy_Depth__c,
                                pse__Parent_Task__c
                        FROM pse__Immediate_Sub_Tasks__r
                )
                FROM pse__Project_Task__c
                WHERE Id IN :parentTaskIds
        ];
        return parentTasks;
    }


    private static Set<Id> collectParentTaskIds(Map<Id, pse__Project_Task__c> ptMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Map<Id, pse__Project_Task__c> ptOldMap) {
        Set<Id> parentTaskIds = new Set<Id>();
        for (pse__Project_Task__c pt : ptMap.values()) {
            if (pt.pse__Parent_Task__c != null) {
                if (parentNeedsUpdate(isInsert, isUpdate, isDelete, pt, ptOldMap)) {
                    parentTaskIds.add(pt.pse__Parent_Task__c);
                }
            }
        }
        return parentTaskIds;
    }

    private static Boolean parentNeedsUpdate(Boolean isInsert, Boolean isUpdate, Boolean isDelete, pse__Project_Task__c pt, Map<Id, pse__Project_Task__c> ptOldMap) {
        return isInsert || isDelete ||
                (isUpdate && pt.PSA_Standard_Hours__c != ptOldMap.get(pt.Id).PSA_Standard_Hours__c);
    }
}