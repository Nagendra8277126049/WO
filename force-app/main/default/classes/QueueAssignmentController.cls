/* -----------------------------------------------------------------------------------------------------------------------
Name:         QueueAssignmentController
Description:  Used to check all users assign to a particular queue and also add multiple users(15 at a time) to the Queue 
or remove multiple users from the queue.
-  Story #5498665 And Story #5562696 And Story #5562726
----------------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ----------------------------------------------------------------------------------
09/13/2018     1.0           Dhamodaran Duraisamy       Initial Release
----------------------------------------------------------------------------------------------------------------------------------*/
public without sharing class QueueAssignmentController {
    /*------------------------------------------------------------------------------------------------------- 
*Method Description-this method is used to fetch all the users assigned to a particular queue.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List <User> fetchSearchQueueUser(String SearchUserKeyword, String grpId) {
        try{
            string searchkey = '%'+ SearchUserKeyword + '%';
            List <User> returnList = new List <User> ();
            List <User> lstOfUser;
            List <String> lstOfSubGroup= new List <String> ();
            List <String> lstOfUserIds = new List <String> ();
            set <String> lstOfGrpIds = new set <String> ();
            List <GroupMember> lstOfGroupMember;
            List <GroupMember> lstOfSubGroupMember;
            Set<id> idGroup = new Set<id>();
            lstOfSubGroupMember =  [SELECT UserOrGroupId,Group.Name from GroupMember WHERE GroupId=: grpId LIMIT 500];
            if(lstOfSubGroupMember.size()>0){
            for(GroupMember gm : lstOfSubGroupMember){
                if(String.Valueof(gm.UserOrGroupId).startsWith('00G')){
                    idGroup.add(gm.UserOrGroupId);
                }
            }
            }
            lstOfGroupMember =  [SELECT Id,UserOrGroupId,GroupId from GroupMember WHERE GroupId  IN: idGroup LIMIT 500];
             if(lstOfGroupMember.size()>0){
            for(GroupMember gm : lstOfGroupMember){
                lstOfUserIds.add(gm.UserOrGroupId);
            }
             }
            if(string.isBlank(searchKey)){
                lstOfUser = [select id,name,federationIdentifier,userrole.name,Manager.name,profile.name from user where Id IN: lstOfUserIds and profile.name in ('Service Agent','Work Order Approver') order by name asc LIMIT 500];
            }
            else{
                lstOfUser = [select id,name, federationIdentifier,userrole.name,Manager.name,profile.name from user where Id IN: lstOfUserIds and (federationIdentifier like: searchkey or name like: searchkey)  and profile.name in ('Service Agent','Work Order Approver') order by name asc LIMIT 500];   	 
            }
            return lstOfUser;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    /*------------------------------------------------------------------------------------------------------- 
*Class Description-this wrapper class  is used to fetch all queues.
-----------------------------------------------------------------------------------------------------------------*/
    public class QueueInfo{
        @AuraEnabled public string publicGroupId;
        @AuraEnabled public string publicGroupName;
        @AuraEnabled public string queueType;
        @AuraEnabled public String publicGroupCreated;
        @AuraEnabled public Date CreatedDate;
        public QueueInfo(){
            publicGroupId='';
            publicGroupName=''; 
            publicGroupCreated ='';
            queueType = '';
        }
    }
    /*------------------------------------------------------------------------------------------------------- ------
*Method Description-this method is used to fetch all the queues and we can search on the basis of searchkeyword 
*also.queues displays with the queue icon like chat email and workorder.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List <QueueInfo> fetchQueue (String SearchQueueKeyword) {
        try{
            string searchkey = '%'+ SearchQueueKeyword + '%';
            List <Group> returnList = new List <Group> ();
            List <Group> lstOfGroup = new List<Group>();
            list <QueueInfo> QueueInfoList = new List<QueueInfo>();
            list <QueueSobject> lstqueueid; 
            QueueInfo pubGrpinfo;
            Map<Id,QueueInfo> channelMap = new Map<Id,QueueInfo>();
            Set<id> idQueue = new Set<id>();
            lstOfGroup = [select Id,Name,CreatedDate from Group where type='Queue' AND Name like:searchkey LIMIT 500];
            if(lstOfGroup.size()>0){
            for (Group u: lstOfGroup) {
                pubGrpinfo = new QueueInfo();
                pubGrpinfo.publicGroupId = u.Id;
                pubGrpinfo.publicgroupName = u.Name;
                pubGrpinfo.publicGroupCreated = u.CreatedDate.format('dd-MMM-YYYY');
                channelMap.put(u.Id,pubGrpinfo);
                idQueue.add(u.Id); 
            }
            }
            List <QueueSObject> queuetype = [SELECT QueueId, SobjectType, Queue.name FROM QueueSobject where  QueueId in: idQueue  LIMIT 5000];
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
                        QueueInfo tempObj = channelMap.get(ids);
                        tempObj.queueType = channelType;
                        QueueInfoList.add(tempObj);
                    }
                    else if(tempList.contains('LiveAgentSession') || tempList.contains('LiveChatTranscript')){
                        channelType = 'Chat';
                        QueueInfo tempObj = channelMap.get(ids);
                        tempObj.queueType = channelType;
                        QueueInfoList.add(tempObj);
                    }
                    else{
                        channelType = 'Email';
                        QueueInfo tempObj = channelMap.get(ids);
                        tempObj.queueType = channelType;
                        QueueInfoList.add(tempObj);
                    }
                }
            }
            return QueueInfoList;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        } 
    }
    /*------------------------------------------------------------------------------------------------------- 
*Class Description-this wrapper class is used to fetch all the users.
-----------------------------------------------------------------------------------------------------------------*/
    public class userinfo {
        @AuraEnabled public string UserId;
        @AuraEnabled public string UserName;
        @AuraEnabled public string UserEmail;
        public userinfo() {
            UserId = '';
            UserName = '';
            UserEmail = '';
        }
    }
    /*------------------------------------------------------------------------------------------------------- 
*Method Description-this method is used to fetch all the users assigned to a particular search queue.
-----------------------------------------------------------------------------------------------------------------*/
    //To get the list of users assigned to the searched queue
    @AuraEnabled
    public static List <User> fetchQueueUser(String grpId) {
        try{
            List <User> returnList = new List <User> ();
            List <User> lstOfUser;
            List <String> lstOfSubGroup= new List <String> ();
            List <String> lstOfUserIds = new List <String> ();
            set <String> lstOfGrpIds = new set <String> ();
            List <GroupMember > lstOfGroupMember;
            List <GroupMember > lstOfSubGroupMember;
            Set<id> idGroup = new Set<id>();
            lstOfSubGroupMember =  [SELECT UserOrGroupId,Group.Name from GroupMember WHERE GroupId=: grpId LIMIT 500];
            if(lstOfSubGroupMember.size()>0){
            for(GroupMember gm : lstOfSubGroupMember){
                if(String.Valueof(gm.UserOrGroupId).startsWith('00G')){
                    idGroup.add(gm.UserOrGroupId);
                }
            }
            }
            lstOfGroupMember =  [SELECT Id,UserOrGroupId,GroupId from GroupMember WHERE GroupId  IN: idGroup LIMIT 500];
            if(lstOfGroupMember.size()>0){
            for(GroupMember gm : lstOfGroupMember){
                lstOfUserIds.add(gm.UserOrGroupId);
            }
            }
            lstOfUser =  [select Id,Name from User where Id IN: lstOfUserIds LIMIT 500];
            return lstOfUser;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    /*------------------------------------------------------------------------------------------------------- 
*Method Description-this method is used to remove the users from single queue or from the list of queues.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List < String > RemoveUser(List <String> lstRecordId, String grpid) {
        try{
            list<string> lststr = new list<string>();
            List<GroupMember> listSubGroup =  [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: grpid LIMIT 500];
            if(listSubGroup.size()>0){            
                for(GroupMember gM : listSubGroup){
                    if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                        lststr.add(gM.UserOrGroupId);
                        system.debug('SubGroup Id >>'+lststr);
                    }
                }
            }
            List < String > oErrorMsg = new List < String > (); 
            List <Groupmember> lstofgm = [SELECT id FROM GROUPMEMBER WHERE groupid in: lststr and UserOrGroupId in:lstRecordId LIMIT 500];
            Database.DeleteResult[] DR_Dels = Database.delete(lstofgm, false);
            for (Database.DeleteResult dr: DR_Dels) {
                if (dr.isSuccess()) {
                    system.debug('Successfuly removed queue');
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
    /*----------------------------------------------------------------------------------------------------------------
*Method Description-this method is used to fetch the lookup users and only those users will come in this lookup 
*who is not having the access of that particular queue.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, List <User> lstofgm, String CloneId) {
        try{
            String searchKey = '%' + searchKeyWord + '%';
            List < sObject > returnList = new List < sObject > ();
            set <String>gmuserid= new set <String>();
            for (User usr: lstofgm)
            {
                gmuserid.add(usr.Id);
            }
            List<string> lstExcludeitems = new List<string>();
            for(sObject item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }
            List <User> lstOfRecords = [select id, Name from User where (Name LIKE: searchKey or federationIdentifier LIKE: searchKey) AND Id NOT IN: gmuserid AND isActive= true AND Id NOT IN : lstExcludeitems  AND Id != :CloneId AND profile.name in ('Service Agent','Work Order Approver') order by createdDate DESC limit 10];
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
    /*----------------------------------------------------------------------------------------------------------------
*Method Description-this method is used to add the users to a queue.
-----------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static void addusers(List <User> UserId,String grpid){
        try{
            List<User> lstuser = new List<User>();
            List<GroupMember> gmList = new List<GroupMember>();
            id groupid;
            List<GroupMember> listSubGroup =  [SELECT Id,UserOrGroupId FROM GroupMember WHERE GroupId =:grpid  LIMIT 500];
            if(listSubGroup.size()>0){            
                for(GroupMember gM : listSubGroup){
                    if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                        groupid=gM.UserOrGroupId;
                    }
                }
            }
            for (User usrid: UserId){
                GroupMember gm =new GroupMember();
                gm.GroupId= groupid;
                gm.UserOrGroupID = usrid.id;
                gmList.add(gm);
            }
            insert gmlist;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}