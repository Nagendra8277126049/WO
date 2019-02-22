/* -----------------------------------------------------------------------------------------------------------------------
Name:       CaseWorkOrderApproverQueueMapping
Description:  This class contain method that handles Mapping Case Owner for Work Order Approval Process
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
07/31/2018     1.0    Harsha Reddy       Initial Release
07/31/2018     1.0    Rodrigo Carpio     Initial Release
-------------------------------------------------------------------------------------------------------------------------- */

public class CaseWorkOrderApproverQueueMapping {
    @InvocableMethod (label='CaseWorkOrderApproverQueueMapping')
    public static void ApproverQueueMapping(list<string> caseIdList){
        try{
            List<Case> UpdateCaseList = new List<Case>();
            List<Case> OwnerCaseList = new List<Case>();
            List<Case> CaseList = new List<Case>();
            set<Id> OwnerIdSet = new Set<Id>();
            CaseList = [SELECT Id, CaseNumber, OwnerId,ApprovalQueueName__c,Owner.Name FROM  Case WHERE Id=:caseIdList LIMIT 500];
            
            if(!CaseList.isEmpty()){
                for (Case cs: CaseList){
                    if(string.valueOf(cs.OwnerId).startsWith('00G')){
                        if(string.isNotEmpty(cs.Owner.Name)){
                            cs.ApprovalQueueName__c = cs.Owner.Name;   
                        }
                        UpdateCaseList.add(cs);
                    } else if(string.valueOf(cs.OwnerId).startsWith('005')){
                        OwnerIdSet.add(cs.OwnerId);
                        OwnerCaseList.add(cs);
                    } 
                }
                
                if(!OwnerIdSet.isEmpty() && OwnerIdSet.size()>0){        
                    Set<Id> groupMemberIdSet = new Set<Id>();
                    Map<Id,List<Id>> groupMemberMap = new Map<Id,List<Id>>();
                    Map<Id,List<String>> queueMap = new Map<Id,List<String>>(); 
                    
                    for(GroupMember gm: [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:OwnerIdSet AND Group.Type='Regular' ORDER BY Group.DeveloperName ASC NULLS LAST LIMIT 5000]){
                        groupMemberIdSet.add(gm.GroupId);
                        if(groupMemberMap.containsKey(gm.UserOrGroupId)){
                            List<Id> groupIds = groupMemberMap.get(gm.UserOrGroupId);
							groupIds.add(gm.GroupId);
                       		groupMemberMap.put(gm.UserOrGroupId,groupIds); 
                        } else{
                            groupMemberMap.put(gm.UserOrGroupId,new List<Id>{gm.GroupId});
                        }
                    }
                    
                    if(!groupMemberIdSet.isEmpty() && groupMemberIdSet.size()>0){
                        for(GroupMember ql : [SELECT Group.DeveloperName,UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:groupMemberIdSet AND Group.type='Queue' ORDER BY Group.DeveloperName ASC NULLS LAST LIMIT 5000]){
                            if(queueMap.containsKey(ql.UserOrGroupId)){
                                List<String> queueNames = queueMap.get(ql.UserOrGroupId);
                                if(!queueNames.isEmpty()){
                                	queueNames.add(ql.Group.DeveloperName);
                                    queueMap.put(ql.UserOrGroupId,queueNames);
                                }
                            } else {
                                queueMap.put(ql.UserOrGroupId,new List<String>{ql.Group.DeveloperName});
                            }
                        }   
                    }
                    
                    if(!queueMap.isEmpty() && queueMap.size()>0){
                        for (Case cs:OwnerCaseList){
                            if(groupMemberMap.containsKey(cs.OwnerId)){
                                for(Id i :groupMemberMap.get(cs.OwnerId)){
                                    if(queueMap.containsKey(i)){
                                        List<String> queueList = queueMap.get(i);
                                        if(!queueList.isEmpty()){
                                            if(queueList[0] != null){
                                            	cs.ApprovalQueueName__c = queueList[0];
                                    			UpdateCaseList.add(cs);
                                        		break;    
                                            }  
                                        }
                                    }
                                }
                            }
                        }   
                    }
                }
            }
            
            if(!UpdateCaseList.isEmpty() && UpdateCaseList.size()>0){
                update UpdateCaseList;
            }
        } catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'CaseWorkOrderApproverQueueMapping','ApproverQueueMapping','Dispatch Management');
        }
    }
}