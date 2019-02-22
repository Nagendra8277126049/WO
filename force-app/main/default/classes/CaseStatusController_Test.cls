/* --------------------------------------------------------------------------------------------------------------------
Name:         CaseStatusController_Test 
Description:  Test Class of CaseStatusController for Story 5820178 & 5820681
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  -------------------------------------------------------------------------------
12/30/2018     1.0     Brundha Rajkumar     Initial Release

------------------------------------------------------------------------------------------------------------------------ */  

@isTest
public class CaseStatusController_Test {
    
    @testSetup
    static void setupTestData() {
        Test.startTest();
        Account acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.AccountNumber='1234567';
        acnt.BUID__c='12345';
        insert acnt;
        
        Asset ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Status = 'Installed';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        insert ast;
        system.debug(ast);
        
        
        Group gp=SRVS_CreateTestDataFactory.createGroup();
        insert gp;
        
        Contact con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        system.debug(con);
        case caseRec = SRVS_CreateTestDataFactory.createSingleCase(ast.Id,acnt.Id,con.Id);
        caseRec.case_queue__C=gp.name;
        insert caseRec;
        system.debug(caseRec.Id);
        
        test.stopTest();
    }
    
    @isTest 
    private static void SubmitToQueue_Test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u){
            Test.startTest();  
            Case c = [SELECT Id from Case Limit 1];
            system.debug(c.Id);
            CaseStatusController.SubmitToQueue(c.id);
            Test.stoptest();
        }
    }
    @isTest 
    private static void StatusUpdateCancel_Test(){
        User u1 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            Case c = [SELECT Id from Case Limit 1];
            CaseStatusController.StatusUpdateCancel(c.id);
            Group gp1=SRVS_CreateTestDataFactory.createGroup();
            
            Test.stoptest();            
        }
    }
    @isTest 
    private static void StatusUpdateCancelException_Test(){
        User u1 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            CaseStatusController.StatusUpdateCancel('500101010101010');
            Test.stoptest();            
        }
    }
}