public class UserAssignmentController {
    //METHOD TO SEARCH FOR USERS:-
    public class userinfo {
		@AuraEnabled public string UserName;
        @AuraEnabled public string UserManagerName;
        @AuraEnabled public string UserRole;
        @AuraEnabled public string UserProfile;
        @AuraEnabled public string UserBadge;
        public userinfo() {
            UserName = '';
            UserManagerName = '';
            UserRole = '';
            UserProfile = '';
            UserBadge='';
        }
    }
    @AuraEnabled
    public static List < userinfo > fetchUser(String UserId) {
        //String searchKey = '%' + SearchUserKeyword + '%';
        List < User > returnList = new List < User > ();
        system.debug('Input'+UserId);
        List < User > lstOfUser = [select Name,Manager.name,UserRole.name,Profile.Name,FederationIdentifier from User WHERE Id =: UserId LIMIT 500];
        system.debug('List of User -->'+lstOfUser);
        list<userinfo> userinfoList = new List<userinfo>();
  		userinfo usrinfo;
            for (User usr: lstOfUser) {
                usrinfo = new userinfo();
               	usrinfo.UserName = usr.Name;
                usrinfo.UserManagerName = usr.Manager.Name;
                usrinfo.UserRole = usr.UserRole.name;
                usrinfo.UserProfile = usr.Profile.Name;
                usrinfo.UserBadge = usr.FederationIdentifier;
                userinfoList.add(usrinfo);
                system.debug('Return List'+userinfoList);
            }
        return userinfoList;
    }

}