public without sharing class AddGroupMember {

       @AuraEnabled
  Public static List<Group> getGroupmembers()
  {
        
            List<Group> g=[SELECT Id, Name, createdDate from Group WHERE Type ='Regular'];
       list<Group> glist = New List<Group>();
        for(Group gs : g){
            
            if(gs.Name != null) {
                glist.add(gs);
            }           
            
        }
        return glist;
    }
    
  
   @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, string groupid_s, string label_button) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        List<GroupMember> existingGroupMember = New List<GroupMember>();
        Set<string> idString = New Set<string>();
        Set<id> idGroup = new Set<id>();
		List < sObject > returnList = new List < sObject > ();
        system.debug(groupid_s + 'groupid_s>>');
        
     id groupsid;
     List<GroupMember> listSubGroup =  [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: groupid_s];
     if(listSubGroup.size()>0){
        
         for(GroupMember gM : listSubGroup){
             
             if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                 
                  idGroup.add(gM.UserOrGroupId);
             }
             
             
         }
         
         
     }
        
        
        existingGroupMember = [Select Id, UserOrGroupId From GroupMember Where GroupId =: idGroup];
        for(GroupMember grpmemb : existingGroupMember){
           
           idString.add(grpmemb.UserOrGroupId);
            
        }
        
        system.debug(idString + 'idString');
        String sQuery;
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        if(label_button == 'Add User'){
         sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND id NOT IN : idString order by createdDate DESC LIMIT 10';
            
         //sQuery =  'select id, Name from Group where Name LIKE: searchKey AND id NOT IN : idString order by createdDate DESC LIMIT 1';
        }else{
            
          sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND id IN : idString order by createdDate DESC LIMIT 5';    
            
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
 @auraEnabled  
 public static list<string> addUsers(String lstRecordId, string groupid, string buttonlabels) {
     list<string> lststr = new list<string>();
     //Get the subgroup of queue
     id groupsid;
     List<GroupMember> listSubGroup =  [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: groupid];
     if(listSubGroup.size()>0){
        
         for(GroupMember gM : listSubGroup){
             
             if(String.Valueof(gM.UserOrGroupId).startsWith('00G')){
                 
                 groupsid = gM.UserOrGroupId;
             }
             
             
         }
         
         
     }
     Set<id> idUser = New Set<id>();
     User usr = (user)JSON.deserialize(lstRecordId, user.class);
     system.debug(usr + 'addUsers>>' + groupid + 'groupid>>');
     List < user > userlist = new List < user > ();
     userlist.add(usr);
     List<GroupMember> GMlist = new List<GroupMember>();
      if(buttonlabels == 'Add User'){
     for(user userId: userlist){
            GroupMember gm = new GroupMember();
            gm.GroupId = groupsid;
            gm.UserOrGroupId = userId.id;
            gmList.add(GM);
        }
     if(gmList.size() > 0){
            insert gmList;
        }
      }else{
     
      //Removing user goes here
      for(user userId: userlist){
          idUser.add(userId.id);
      }
     List<GroupMember> ListGM  = [ Select Id from GroupMember where UserOrGroupID in :idUser and GroupId  =: groupsid];
          
		if(ListGM.size() > 0 )
		{
			delete ListGM;
		}
      }
     
  return lststr;
    
 }
@AuraEnabled
 public static List <Group> fetchGroup(String searchKeyWord) {
  String searchKey = '%' + searchKeyWord + '%';
  List < Group > returnList = new List < Group > ();
  List < Group > lstOfGroup =  [SELECT Id, Name, createdDate from Group WHERE Type = 'Queue' AND Name LIKE: searchKey LIMIT 500];
 
  for (Group grp: lstOfGroup) {
   returnList.add(grp);
  }
  return returnList;
 }

}