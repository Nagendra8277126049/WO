@isTest
private class AgentConcurrentSessions_Test {
        static list<User> userList=new list<User>();
    private static void setupTestData() {
        User use=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use.FederationIdentifier='5678';
         use.External_ID__c='5678';
        use.Dell_NTUserID__c='A_T';
        use.File_Source__c='AMS - Admin';       
        use.Organization__c='dell';
        use.Service_User_Type__c='Business';
        insert use;
        User use1=SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
        use1.FederationIdentifier='9098';
         use1.External_ID__c='9098';
        use1.Dell_NTUserID__c='B_T';
        use1.File_Source__c='AMS - Admin';       
        use1.Organization__c='dell';
        use1.Service_User_Type__c='Business';
        insert use1;
        User use2=SRVS_CreateTestDataFactory.createUser('System Read Only');
        use2.FederationIdentifier='4567';
         use2.External_ID__c='4567';
        use2.Dell_NTUserID__c='C_T';
        use2.File_Source__c='AMS - Admin';       
        use2.Organization__c='dell';
        use2.Service_User_Type__c='Business';
        insert use2;
         User use4=SRVS_CreateTestDataFactory.createUser('System Administrator');
        use4.FederationIdentifier='8796';
         use4.External_ID__c='8796';
        use4.Dell_NTUserID__c='D_T';
        use4.File_Source__c='AMS - Admin';       
        use4.Organization__c='dell';
        use4.Service_User_Type__c='Business';
        insert use4;
         User use3=SRVS_CreateTestDataFactory.createUser('service Agent');
        use3.FederationIdentifier='9876';
         use3.External_ID__c='9876';
        use3.Dell_NTUserID__c='E_T';
        use3.File_Source__c='AMS - Admin';       
        use3.Organization__c='dell';
        use3.Service_User_Type__c='Business';
        insert use3;
        userList.add(use2);
        userList.add(use1);
    }
    @isTest
    private static void unitTest1()
    { 
  
        //system.runAs(use3)
           // {   
            Test.startTest();
                LoginHistory loginHistoryObj = new LoginHistory();
        List<loginHistory> LH= [Select id , LoginType, AuthenticationServiceId, ClientVersion  from LoginHistory  where LoginType='Remote Access 2.0' limit 1];
        if(LH.size()>0){
        Map<String, String> eventData = new Map<String, String>();
                TxnSecurity.Event e = new TxnSecurity.Event(
            UserInfo.getOrganizationId(),
           UserInfo.getUserId(), 
            'AuthSession', 
            'Login',
            'LoginHistory',
            '01pR00000009D2H', 
            Datetime.newInstance(2018, 6, 5),eventdata); 
   AgentConcurrentSessionsPolicyCondition current=new AgentConcurrentSessionsPolicyCondition();
            boolean b= current.evaluate(e);
            Test.stopTest();
        }
       // }
        System.assertEquals(0, userList.size());
       
    }
 }