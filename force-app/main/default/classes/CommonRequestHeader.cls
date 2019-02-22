/* -----------------------------------------------------------------------------------------------------------------------
Name:       CommonRequestHeader
Description:  This class contain common RequestHeader structure that can be used in reponse initialization - application
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio      Initial Release
11/01/2018     1.1     Harsha Reddy        Code Review
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class CommonRequestHeader {
    public CommonSourceSystem SourceSystem;

    public CommonRequestHeader() {
        SourceSystem = new CommonSourceSystem();
    }

    public void SetDefaultValues() {
        List < User > UserList = new List < User > ();
        String sSystem = '';
        sSystem = label.SourceSystemName;
        if(String.isNotBlank(sSystem)){
            SourceSystem.name = sSystem;
        }
        UserList = [select FederationIdentifier from user where id =: userinfo.getuserid() LIMIT 1];
        if (!UserList.isEmpty() && UserList.size() > 0) {
            if (String.isNotBlank(UserList[0].FederationIdentifier)) {
                SourceSystem.userId = UserList[0].FederationIdentifier;
            }
        }
    }
    public with sharing class CommonSourceSystem {
        public String UserId; //123456
        public String Name; //SFDC
    }
}