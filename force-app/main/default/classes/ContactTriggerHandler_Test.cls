/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       ContactTriggerHandler_Test
Description:      For ContactTriggerHandler Apex Class
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/25/2018     1.0         Surya Subramanian         Initial Release
01/25/2018     1.1         Srikanth Parvathareddy    Changes are based on Code Review Defect #4561229
03/13/2018	   1.3		   Srikanth P			     System.runas() included  - Defect #4777313	
-------------------------------------------------------------------------------------------------------------------------- 
*/
@isTest
private class ContactTriggerHandler_Test {
    
    //Method to setup test data
    @testSetup static void setUpData() {
        
        //create a test account record
        Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act;
        Account act1 = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act1;
        //create a list of contact test records
        List<contact> ct=SRVS_CreateTestDataFactory.createMultipleContactRecords(act,3);
        ct[1].Account_Id__c=ct[0].AccountId;
        ct[2].Account_Id__c=ct[0].AccountId;
        insert ct;
        contact c1= new contact(FirstName = 'test1', LastName = 'lastName',country_code__c= 'USA & Canada (1)',Primary_Phone__c='1234567890', accountId = act.id);
        insert c1; 
        c1.accountId=act1.id;
        update c1;
        contact c2= new contact(FirstName = 'test1', LastName = 'lastName',country_code__c= 'USA & Canada (1)',email='noemail@dell.com', accountId = act.id);
		insert c2;
    }
    
    //Method for before insert unit test
    @isTest
    private static void beforeinsert_test(){
        User u1=SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
        system.runAs(u1){
        Test.startTest();
        List<contact> cts=[select id,AccountId,Account_Id__c from contact limit 3];
        List<contact> ct=[select id,AccountId,Account_Id__c from contact where FirstName='test1' limit 1];    
        Test.stopTest();
        system.assertEquals(3,cts.size());
        }    
    }
    
    //Method for before update unit test
    @isTest
    private static void beforeupdate_test(){
        User u2=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u2){
        Test.startTest();
        List<contact> cs=[select id,AccountId,Account_Id__c from contact limit 3];
        for(integer i=0;i<cs.size();i++)
        {
               if(cs[i].AccountId!=cs[i].Account_Id__c)
               {
                   cs[i].Account_Id__c=cs[i].AccountId;
               }  
        }   
        ContactTriggerHandler.beforeUpdate(cs);
        Test.stopTest();
        system.assertEquals(3,cs.size());
    }
    } 
}