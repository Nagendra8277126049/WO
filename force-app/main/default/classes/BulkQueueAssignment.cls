/* -------------------------------------------------------------------------------------------------------------------------------
Name:         BulkQueueAssignment
Description:  Used to import bulk Queue users
----------------------------------------------------------------------------------------------------------------------------------
Date         Version    Author             		Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
02/12/2018   1.0      	Ayesha Shahab  			Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/

public class BulkQueueAssignment {
    @InvocableMethod
    public static void AddBulkUsers(List<Id> IncomingDataListIds){
        Map<String,Id> UserIdsMap = new Map<String,Id>();
        Map<String,Id> GroupMemeberIDsMap = new Map<String,Id>();
        Map<String,Id> Action = new Map<String,Id>();
        id groupid;
        List<String> lstr = new list<String>();
        List<String> deletelstr = new list <String>();
        List<GroupMember> gmList = new List<GroupMember>(); 
        set<String> QueueNameList = new set<String>();
        set<String> UserBadgeList = new set<String>();
        
        List<BulkQueueAssignment__c> BulkQueueAssignmentRecords =[select id, QueueName__c,Badge__c, Action__c from BulkQueueAssignment__c
                                                                  where BulkQueueAssignment__c.id in :IncomingDataListIds];
        try {
            for(BulkQueueAssignment__c qa: BulkQueueAssignmentRecords)
            {
                QueueNameList.add(qa.QueueName__c);
                UserBadgeList.add(qa.badge__c);   
            } 
            for(User u:[select  id, FederationIdentifier from user where FederationIdentifier IN:UserBadgeList]){
                UserIdsMap.put(u.FederationIdentifier, u.id);
            }
            List<Group> qlist = [select Id from Group where Type = 'Queue' and Name IN:QueueNameList];
            //Get the subgroup of queue
            List<GroupMember> listSubGroup =  [SELECT UserOrGroupId,group.name FROM GroupMember WHERE GroupId IN: qlist];                
            
            if(listSubGroup.size()>0){            
                for(GroupMember gM : listSubGroup){
                    if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                        groupid=gM.UserOrGroupId; 
                        
                        GroupMemeberIDsMap.put(gM.group.Name,groupid ); 
                    }                        
                }
            }  
            Map<Id,Id> lstgpm = new map<id,id>();
            for( GroupMember gvm :[SELECT id ,UserOrGroupId FROM GROUPMEMBER WHERE Groupid =: groupid]){
                lstgpm.put(gvm.UserOrGroupId,gvm.Id);
            }		
            for(BulkQueueAssignment__c qAdmin: BulkQueueAssignmentRecords){
                GroupMember gm =new GroupMember(); 
                gm.UserOrGroupID = UserIdsMap.get(qAdmin.Badge__c); 						
                gm.groupId = GroupMemeberIDsMap.get(qAdmin.QueueName__c);
                if(qAdmin.Action__c == 'Add' ){ 
                    lstr.add(JSON.serialize(gm));
                    
                }
                else if(qAdmin.Action__c == 'Remove' ){ 
                    if(lstgpm.get(gm.UserOrGroupID)!=null)
                        deletelstr.add(lstgpm.get(gm.UserOrGroupID));
                }   	
            }
        }
        
        catch(DMLException e)
        {
            ExceptionHandler.logHandledExceptions(e, 'BulkQueueAssignment','AddBulkUser','BulkQueueAssignment');
        }  
        AddFutureCall(lstr); 
        DeleteFutureCall(deletelstr); 
    }
    //Call future method for Add operation
    @future
    public static void AddFutureCall(list<String> lstr) {
        List<GroupMember> GroupMemberTrackerAddlist = new List<GroupMember>();
        for(String s:lstr )
        {
            GroupMemberTrackerAddlist.add((GroupMember) JSON.deserialize(s, GroupMember.class));
        } 
        if(!GroupMemberTrackerAddlist.isEmpty()) { 
            try {
                Database.SaveResult[] srList = Database.insert(GroupMemberTrackerAddlist, false); 
                
            }
            catch(DMLException e)
            {
                ExceptionHandler.logHandledExceptions(e, 'BulkQueueAssignment','AddBulkUser','doFutureCall');
            }   
        }
    }
    //Call future method for delete operation
    @future    
    public static void DeleteFutureCall(list<String> deletelstr) {
        List<String> GroupMemberTrackerdeletelist = new List<String>();
        for(String d :deletelstr )
        {
            GroupMemberTrackerdeletelist.add(d);
            
        }    
        if(!GroupMemberTrackerdeletelist.isEmpty()) { 
            try {
                
                Database.DeleteResult[] DR_Dels = Database.delete(GroupMemberTrackerdeletelist, false);
                
            }
            catch(DMLException e)
            {
                ExceptionHandler.logHandledExceptions(e, 'BulkQueueAssignment','AddBulkUser','DeleteFutureCall');
            } 
        }  
    } 
}