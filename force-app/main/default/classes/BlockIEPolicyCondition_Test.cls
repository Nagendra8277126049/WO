@isTest
public class BlockIEPolicyCondition_Test 
{
    static list<User> userList=new list<User>();
    public static void setupTestData() {
        User use1=SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
        use1.FederationIdentifier='9098';
         use1.External_ID__c='9098';
        use1.Dell_NTUserID__c='A_T';
        use1.File_Source__c='AMS - Admin';       
        use1.Organization__c='dell';
        use1.Service_User_Type__c='Business';
        insert use1;
        User use2=SRVS_CreateTestDataFactory.createUser('System Read Only');
        use2.FederationIdentifier='4567';
         use2.External_ID__c='4567';
        use2.Dell_NTUserID__c='B_T';
        use2.File_Source__c='AMS - Admin';       
        use2.Organization__c='dell';
        use2.Service_User_Type__c='Business';
        insert use2;
        userList.add(use2);
        userList.add(use1);
    }
    @isTest
    public static  void testIsNotIE() 
    { 
        User use3=SRVS_CreateTestDataFactory.createUser('service Agent');
        use3.FederationIdentifier='9876';
         use3.External_ID__c='9876';
        use3.Dell_NTUserID__c='C_T';
        use3.File_Source__c='AMS - Admin';       
        use3.Organization__c='dell';
        use3.Service_User_Type__c='Business';
        insert use3;
        system.runAs(use3)
        {
            Test.startTest(); 
            LoginHistory loginHistoryObj = new LoginHistory();
            Map<String, String> eventData = new Map<String, String>();
            TxnSecurity.Event e = new TxnSecurity.Event(
                UserInfo.getOrganizationId(),
                UserInfo.getUserId(), 
                'AuthSession', 
                'Login',
                'LoginHistory',
                '01pR00000009D2H', 
                Datetime.newInstance(2018, 6, 7),eventdata); 
            BlockIEPolicyCondition condition = new BlockIEPolicyCondition();
            boolean b= condition.evaluate(e);
            Test.stopTest(); 
        }
        System.assertEquals(0, userList.size());
    }
}