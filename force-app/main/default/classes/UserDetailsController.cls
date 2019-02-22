/* -----------------------------------------------------------------------------------------------------------------------
Name:         UserDetailsController
Description:  Used to check all the queues assign to a particular user and also add multiple queues to the user or remove
multiple queues from the user And also clone the queues assigned to a particular users to other users.
-  Story #5633752 And Story #5498701 And Story #5633741
----------------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
09/13/2018     1.0           Abhishek Pandey       Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/
public without sharing class UserDetailsController {
    /*------------------------------------------------------------------------------------------------------- 
*Class Description-this wrapper class is used to search user globally with the the particular search keyword.
-----------------------------------------------------------------------------------------------------------------*/
    public class SearchUserInfo{
        @AuraEnabled public string UserId;
        @AuraEnabled public string Username;
        @AuraEnabled public string Email;
        @AuraEnabled public string Role;
        @AuraEnabled public string FederationIdentifier;
        @AuraEnabled public string UserCreatedDate;
        @AuraEnabled public Date CreatedDate;
        @AuraEnabled public string Manager;
        @AuraEnabled public string Profile;
        public SearchUserInfo(){
            UserId='';
            Username=''; 
            UserCreatedDate =''; 
            Email ='';
            Role='';
            FederationIdentifier='';
            Manager='';
            Profile='';
        }
    }
    /*------------------------------------------------------------------------------------------------------- 
*Method Description-this method is used to fetch all user with manager name,role name fedaration id 
*and created date and it is fetching the users who is having service agentand work order profile and we are 
*using the specific search keyword to find the particular user and for page load, it will fetch all active
*users with above criteria.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List <SearchUserInfo> fetchsearchuser (String SearchUserKeyword, String UserId, boolean isAsc, Boolean isSort) {
        try{
            String searchKey = '%'+ SearchUserKeyword + '%';
            id UsrId = UserId;
            Boolean isAscn = isAsc;
            Boolean isSrt = isSort;
            List <User> lstOfUser;
            List <User> returnList = new List <User> ();
            if(string.isBlank(UsrId)){
                lstOfUser = [select Id,Name,Manager.Name,UserRole.Name,FederationIdentifier,CreatedDate,Profile.Name from User where (federationIdentifier like: searchkey or name like: searchkey) and isactive = true and profile.name in ('Service Agent','Work Order Approver') order by Name asc LIMIT 500];            
            }
            else {
                lstOfUser = [select Id,Name,Manager.Name,UserRole.Name,FederationIdentifier,CreatedDate,Profile.Name from User where id=:UsrId LIMIT 500];  
            }
            if(isSort) {
                if (isAsc) {
                    lstOfUser = [select Id,Name,Manager.Name,UserRole.Name,FederationIdentifier,CreatedDate,Profile.Name from User where (federationIdentifier like: searchkey or name like: searchkey) and isactive = true and profile.name in ('Service Agent','Work Order Approver') and Manager.Name != null order by Manager.Name asc LIMIT 500];      
                } else {
                    lstOfUser = [select Id,Name,Manager.Name,UserRole.Name,FederationIdentifier,CreatedDate,Profile.Name from User where (federationIdentifier like: searchkey or name like: searchkey) and isactive = true and profile.name in ('Service Agent','Work Order Approver') and Manager.Name != null order by Manager.Name desc LIMIT 500];
                }
            }       
            list <SearchUserInfo> SearchUserInfoList = new List<SearchUserInfo>();
            SearchUserInfo usrinfo;
            if(lstofUser.size()>0){
            for (User u: lstOfUser) {
                usrinfo = new SearchUserInfo();
                usrinfo.UserId = u.Id;
                usrinfo.UserName = u.Name;
                usrinfo.Manager = u.Manager.Name;
                usrinfo.Role = u.UserRole.Name;
                usrinfo.Profile = u.Profile.Name;
                usrinfo.FederationIdentifier=u.FederationIdentifier;
                usrinfo.UserCreatedDate = u.CreatedDate.format('dd-MMM-YYYY');
                SearchUserInfoList.add(usrinfo);
            }
            }
            return SearchUserInfoList;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        } 
    }
    
    public class UserQueueInfo{
        @AuraEnabled public string QueueName;
        @AuraEnabled public string queueType;
        @AuraEnabled public string QueueId;
        @AuraEnabled public string QueueCreatedDate;
        @AuraEnabled public Date CreatedDate;
        public UserQueueInfo(){
            QueueName='';
            QueueCreatedDate ='';
            QueueId ='';
            queueType='';
        }
    }
    /*------------------------------------------------------------------------------------------------------- 
*Method Description-this method is used to get the queues assigned to the particular users.so that if any
*selecting user he will get the name of all the queues assigned to that particular user.and its displaying the 
*queue icon also depending upon the queue type.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled    
    public static List <UserQueueInfo> fetchUserqueue(String SearchQueueKeyword, String usrId) {
        try{
            String searchKey = '%'+ SearchQueueKeyword + '%';
            List <Group> lstOfGroup;
            List <String> lstOfGroupIds = new List <String> ();
            List <String> lstOfUserIds = new List <String> ();
            List <Group > lstOfQueue;
            List <GroupMember > lstOfSubGroupId;
            list <UserQueueInfo> UserQueueInfoList = new List<UserQueueInfo>();
            Set<id> idGroup = new Set<id>();
            UserQueueInfo qinfo;
            Map<Id,UserQueueInfo> channelMap = new Map<Id,UserQueueInfo>();
            lstOfSubGroupId =  [SELECT GroupId from GroupMember WHERE UserOrGroupId=: usrId LIMIT 500];
            for(GroupMember gm : lstOfSubGroupId){
                idGroup.add(gm.GroupId); 
            }
            lstOfQueue =  [SELECT Id from Group WHERE Id IN (Select Groupid from GroupMember where userOrGroupId in : idGroup) LIMIT 500];
            for(Group q : lstOfQueue){
                lstOfGroupIds.add(q.Id);
            }
            if(string.isBlank(searchKey)){
                lstOfGroup =  [select Id,Name,CreatedDate from Group where Id IN: lstOfGroupIds ORDER BY NAME ASC LIMIT 500];
            }
            else{
                lstOfGroup =  [select Id,Name,CreatedDate from Group where Id IN: lstOfGroupIds and name like: searchKey ORDER BY NAME ASC LIMIT 500];
            }
            if(lstOfGroup.size()>0){
            for (Group u: lstOfGroup) {
                qinfo = new UserQueueInfo();
                qinfo.QueueId = u.Id;
                qinfo.QueueName = u.Name;
                qinfo.QueueCreatedDate = u.CreatedDate.format('dd-MMM-YYYY');
                channelMap.put(u.Id,qinfo);
                idGroup.add(u.Id);
            }
            }
            List <QueueSObject> queuetype = [SELECT QueueId, SobjectType, Queue.name FROM QueueSobject where  QueueId in: idGroup  LIMIT 5000];
            Map<Id,List<String>> tempMap = new Map<Id,List<String>>();
            for (QueueSObject qo: queuetype ){
                if(tempMap.containsKey(qo.QueueId)){
                    List<String> tempList = tempMap.get(qo.QueueId);
                    tempList.add(qo.SobjectType);
                    tempMap.put(qo.QueueId, tempList);
                    
                }else{
                    List<String> tempList = new List<String>();
                    tempList.add(qo.SobjectType);
                    tempMap.put(qo.QueueId, tempList);    
                }
            }
            for(Id ids : channelMap.keySet()){
                if(tempMap.containsKey(ids)){
                    List<String> tempList = tempMap.get(ids);
                    String channelType = '';
                    if(tempList.contains('DispatchPendingApproval__c') || tempList.contains('WorkOrder')){
                        channelType = 'WorkOrder';
                        UserQueueInfo tempObj = channelMap.get(ids);
                        tempObj.queueType = channelType;
                        UserQueueInfoList.add(tempObj);
                    }
                    else if(tempList.contains('LiveAgentSession') || tempList.contains('LiveChatTranscript')){
                        channelType = 'Chat';
                        UserQueueInfo tempObj = channelMap.get(ids);
                        tempObj.queuetype = channelType;
                        UserQueueInfoList.add(tempObj);
                    }
                    else{
                        channelType = 'Email';
                        UserQueueInfo tempObj = channelMap.get(ids);
                        tempObj.queueType = channelType;
                        UserQueueInfoList.add(tempObj);
                    }
                }
            }
            return UserQueueInfoList;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    /*----------------------------------------------------------------------------------------------------------------
*Method Description-this method is used to remove the particular user from list of queues or from a single queue.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List < String > RemoveUser(List <String> lstRecordId, String usrId) {
        try{
            list<string> lststr = new list<string>();
            List<GroupMember> listSubGroup =  [SELECT UserOrGroupId FROM GroupMember WHERE GroupId in: lstRecordId LIMIT 500];
            if(listSubGroup.size()>0){            
                for(GroupMember gM : listSubGroup){
                    if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                        lststr.add(gM.UserOrGroupId);
                    }
                }
            }
            
            List < String > oErrorMsg = new List < String > ();           
            List <Groupmember> lstofgm = [SELECT id FROM GROUPMEMBER WHERE groupid in: lststr and UserOrGroupId =:usrId LIMIT 500];
            Database.DeleteResult[] DR_Dels = Database.delete(lstofgm, false);
            for (Database.DeleteResult dr: DR_Dels) {
                if (dr.isSuccess()) {
                    
                } else {
                    
                    oErrorMsg.add('');
                    for (Database.Error err: dr.getErrors()) {
                        oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
            return oErrorMsg; 
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    /*--------------------------------------------------------------------------------------------------------- 
*Method Description-this method is used to add the user into list of queues or a single queue.
------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<String> Addqueue(List<Group> grpid, String usrId){
        try{
            list<String> lststr = new list<String>();
            Set<Id> listGroup = (new Map<Id,Group>(grpid)).keySet();
            List<GroupMember> listSubGroup =  [SELECT id,UserOrGroupId,group.name FROM GroupMember WHERE GroupId in: listGroup LIMIT 500];
            if(listSubGroup.size()>0){            
                for(GroupMember gM : listSubGroup){
                    if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                        lststr.add(gM.UserOrGroupId);
                    }
                }
            }
            List<Groupmember> gmList = new List<Groupmember>();
            List<Group> gid = [select id from group where id in: lststr LIMIT 500];
            if(gid.size()>0){
            for ( Group gm: gid){
                
                GroupMember gpm = new Groupmember();
                gpm.GroupId=gm.Id;
                gpm.UserOrGroupId=usrId;
                gmList.add(gpm);
            }
        }
            insert gmList;
            return lststr;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }
    /*------------------------------------------------------------------------------------------------------------ 
*Method Description-this method is used to fetch the lookup queues which is not assigned to the particular user
*it will only show the list of queues which user is not having that particular user assigned.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, String UserId) 
    {
        try{
            List <sObject> returnList = new List <sObject> ();
            String searchKey = '%' + searchKeyWord + '%';
            string type='Queue';
            set <String>gpid= new set <String>();
            List <String> lstOfGroupIds = new List <String> ();
            List <Group > lstOfQueue;
            List <GroupMember > lstOfSubGroupId;
            Set<id> idGroup = new Set<id>();
            lstOfSubGroupId =  [SELECT GroupId from GroupMember WHERE UserOrGroupId=: UserId LIMIT 500];
            if(lstOfSubGroupId.size()>0){
            for(GroupMember gm : lstOfSubGroupId){
                idGroup.add(gm.GroupId); 
            }
            }
            lstOfQueue =  [SELECT Id from Group WHERE Id IN (Select Groupid from GroupMember where userOrGroupId in : idGroup) LIMIT 500];
            if(lstOfQueue.size()>0){
            for(Group q : lstOfQueue){
                lstOfGroupIds.add(q.Id);
            }
            }
            List<string> lstExcludeitems = new List<string>();
            for(sObject item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }
            List <Group> lstOfRecords = [select id, Name from Group where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems and Id NOT IN : lstOfGroupIds and type=:type order by Name DESC limit 10];
            if(lstOfRecords.size()>0){
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            }
            return returnList;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    /*------------------------------------------------------------------------------------------------------------ 
*Method Description-This method is used to clone users selected from User Assignment screen.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    Public static List<String> clonequeueuser (List <User> UserId,  String CloneId){        
        try{
            list<String> lststr = new list<String>();
            id usrid;
            List <GroupMember > lstOfSubGroupId;
            Set<id> idGroup = new Set<id>();
            lstOfSubGroupId =  [SELECT GroupId from GroupMember WHERE UserOrGroupId=: CloneId LIMIT 500];
            if(lstOfSubGroupId.size()>0){ 
            for(GroupMember gm : lstOfSubGroupId){
                idGroup.add(gm.GroupId); 
            }
            }
            List <Group > lstOfQueue;
            List <String> lstOfGroupIds = new List <String> ();
            lstOfQueue =  [SELECT Id from Group WHERE Id IN (Select Groupid from GroupMember where userOrGroupId in : idGroup) LIMIT 500];
           if(lstOfQueue.size()>0){ 
            for(Group q : lstOfQueue){
                lstOfGroupIds.add(q.Id);
            } 
           }
            List<Group> listGroup =  [SELECT id FROM Group WHERE id in: lstOfGroupIds LIMIT 500];
            List<GroupMember> listSubGroup =  [SELECT id,UserOrGroupId,group.name FROM GroupMember WHERE GroupId in: listGroup LIMIT 500];
            Integer QueueCount = listSubGroup.size();
            if(listSubGroup.size()>0){            
                for(GroupMember gM : listSubGroup){
                    if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                        lststr.add(gM.UserOrGroupId);
                    }
                }
            }
            List<Groupmember> gmList = new List<Groupmember>();
            List<Group> gid = [select id from group where id in: lststr LIMIT 500];
            Set<Id> newset = (new Map<Id,User>(UserId)).keySet();
            List<User> usrlst = [select id from user where id in: newset LIMIT 500];
            if(usrlst.size()>0){
            for(sObject usr : usrlst ){
                usrid=usr.id;
                for (sObject gm: gid){
                    GroupMember gpm = new Groupmember();
                    gpm.GroupId=gm.Id;
                    gpm.UserOrGroupId=usrid;
                    gmList.add(gpm);
                }
            }
            }
            insert gmList;
            return null;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    } 
}