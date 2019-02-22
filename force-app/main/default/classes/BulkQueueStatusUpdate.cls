/* -------------------------------------------------------------------------------------------------------------------------------
Name:         BulkQueueStatusUpdate
Description:  Used to update bulk Queue import status
----------------------------------------------------------------------------------------------------------------------------------
Date         Version    Author             		Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
02/12/2018   1.0      	Dhamodharan Duraisamy  	Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/

global class BulkQueueStatusUpdate {  
    @InvocableMethod
    public static void StatusUpdate(){
        List<BulkQueueAssignment__c> mynewlist =[select id, QueueName__c,Badge__c, Action__c, Status__c from BulkQueueAssignment__c
                                                 where status__c='Validation Success' and valid_record__c=true];
        String qName ;
        list<string > myfinallist = new list <string>();
        Map<string,BulkQueueAssignment__c>fedIdtoUploadUserMap = new map <string,BulkQueueAssignment__c>();
        
        for(BulkQueueAssignment__c  qa: mynewlist){
            fedIdtoUploadUserMap.put(qa.Badge__c, qa);
            qName = qa.QueueName__c;
        }        
        Map<String,Id> fedIdtoUserId  = new Map<String,Id>();
        for(user u : [select id,FederationIdentifier from user where FederationIdentifier in :fedIdtoUploadUserMap.keyset()]){
            fedIdtoUserId.put(u.FederationIdentifier,u.id);
            system.debug('User badge Id'+fedIdtoUserId);
        }
                
        String publicgroupId ;
        for(groupMember gp :  [select UserOrGroupId from groupMember where Group.Name = :qname]){                                                                      
            if(String.Valueof(gp.UserOrGroupId).startsWith('00G'))
                publicgroupId = gp.UserOrGroupId;                                                              
        }        
        set<Id> userIds=new set<id>();
        
        for(GroupMember gM :[SELECT UserOrGroupId, GroupId FROM GroupMember WHERE GroupId =:publicgroupId]){
            if(!String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                userIds.add(gm.UserOrGroupId );  
                
                system.debug('Users under the subgroup'+userIds);
            }   
        }        
        for(BulkQueueAssignment__c  qa: mynewlist){
            if(qa.Action__c == 'Add' ){
                if(userIds.contains(fedIdtoUserId.get(qa.badge__c))){
                    System.debug('fedIdtoUserId'+fedIdtoUserId.get(qa.badge__c));
                    qa.status__c = 'Success';
                    qa.Status_Check__c = true;
                	qa.comments__c = 'Successfully added user to the Queue';
                }
                else{
                    qa.status__c = 'Failed';
                    qa.Status_Check__c = true;
                    qa.comments__c = 'Unable to add user to the Queue';
                }
            }
            else{
               if(qa.Action__c == 'Remove' ){
                if(userIds.contains(fedIdtoUserId.get(qa.badge__c))){
                    System.debug('fedIdtoUserId'+fedIdtoUserId.get(qa.badge__c));
                    qa.status__c = 'Failed';
                    qa.Status_Check__c = true;
                    qa.comments__c = 'Unable to remove user from the Queue';
                }
                else{
                    qa.status__c = 'Success';
                    qa.Status_Check__c = true;
                    qa.comments__c = 'Successfully removed user from the Queue';
                }
            } 
            }
            myfinallist.add(JSON.serialize(qa)); 
        } 
        UPDATE    mynewlist;   
    }
}