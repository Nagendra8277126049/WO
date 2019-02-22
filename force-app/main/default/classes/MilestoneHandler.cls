public class MilestoneHandler {
   
    public static void handleMilestones(Map<Id,pse__Milestone__c> mNewMap, Map<Id,pse__Milestone__c> mOldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter){ 
        if ((isInsert || isUpdate) && isAfter) {
              if(mNewMap != null) verifyMilestonesCurrentProject(mNewMap, mOldMap, isInsert);
    	}
        
        if (isDelete && isBefore){
            //verify if milestone is Current
            checkIfMilestoneCurrent(mOldMap);
        }
   	}
    
    public static void checkIfMilestoneCurrent(Map<Id,pse__Milestone__c> mOldMap){
        for(pse__Milestone__c milestone : mOldMap.values()){
            if(milestone.Current__c) milestone.addError('The Milestone could not be deleted as this is marked as Current. Select "Current" option in another milestone to delete the option in this milestone.');
        }
    }
    
    public static void verifyMilestonesCurrentProject(Map<Id,pse__Milestone__c> mNewMap, Map<Id,pse__Milestone__c> mOldMap, Boolean isInsert){
        List<pse__Milestone__c> milestonesUpdate = new List<pse__Milestone__c>();
        
        for(pse__Milestone__c milestone : mNewMap.values()){
            //only when the milestone is new or the field 'current' was changed 
            if(isInsert || milestone.current__c != mOldMap.get(milestone.Id).current__c){ 
                //system.debug('Milestone: ' + milestone.Id + ' - Name: ' + milestone.Name + ' - Current: ' + milestone.Current__c); 
                List<pse__Milestone__c> milestonesCurrentProject = [SELECT Id, Name, Current__c 
                                                             FROM pse__Milestone__c 
                                                             WHERE pse__Project__c =: milestone.pse__Project__c
                                                             AND Id !=: milestone.Id //ignore Milestone current
                                                             AND Current__c = true];              
                if(milestone.Current__c){
                    //if have another Milestone Current, setting false (uncheck)
                    if(milestonesCurrentProject != null && !milestonesCurrentProject.isEmpty()){ 
                        for(pse__Milestone__c milestoneProj : milestonesCurrentProject){
                            milestoneProj.Current__c = false;  
                            milestonesUpdate.add(milestoneProj);
                        }
                    }
                }else{
                    //verify if exists one Milestone with Current = true (checked)
                    Boolean hasMilestoneCurrent = false;
                    for(pse__Milestone__c milestoneProj : milestonesCurrentProject){
                        if(milestoneProj.Current__c) { 
                            hasMilestoneCurrent = true;
                            break;
                        }  
                    }
                    
                    //if it doesn't exist, return a message to user and it cannot uncheck 
                    if(!hasMilestoneCurrent){
                        milestone.addError('The "current" option cannot be unchecked. Select "Current" option in another milestone to disable the option in this milestone.');
                    }
                } 
            }    
        }  
        
        if(!milestonesUpdate.isEmpty()){
            update milestonesUpdate;
        } 
    }
}