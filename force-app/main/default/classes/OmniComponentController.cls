public with sharing class OmniComponentController {    
    
    @AuraEnabled
    public static Boolean isCurrentUserServiceAgent(){
        
        Id userId = UserInfo.getUserId();
        Id userProfileId = UserInfo.getProfileId();
       
        
        String serviceAgentProfileName = Label.Service_Agent_Profile;
        String dispatchApproverProfileName = Label.Dispatch_Approver_Profile;
        String supervisorPermissionName = Label.Chat_Supervisor_Permission_Set;
        
        Id supervisorPermissionId = [Select Id, Name from PermissionSet where Name = :supervisorPermissionName].Id;
        String userProfileName = [Select Id, Name from Profile where Id = :userProfileId].Name; 
       
         String userRoleName =[SELECT Id, UserRole.Name FROM User where Id=: UserInfo.getUserId()].UserRole.Name;
        /*
        Integer cnt = [SELECT count() FROM PermissionSetAssignment
                       WHERE PermissionSetId = :supervisorPermissionId AND AssigneeId = :userId];
		*/
        
        //if ((cnt == 0 && userProfileName == serviceAgentProfileName) 
       //if ((cnt == 0 && userProfileName == serviceAgentProfileName) 
        if ((userProfileName == serviceAgentProfileName 
            	|| userProfileName == dispatchApproverProfileName) && userRoleName != 'TS' ){
            return true;        
        }
            
        return false;
    }

}