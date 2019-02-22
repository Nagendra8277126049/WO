/* --------------------------------------------------------------------------------------------------------------------
Name:         CollaborateInternalCase_Test 
Description:  Test Class of  CollaborateInternalCase for Story 5820178 & 5820681
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  -------------------------------------------------------------------------------
12/30/2018     1.0     Brundha Rajkumar     Initial Release

------------------------------------------------------------------------------------------------------------------------ */  


@isTest
public class CollaborateInternalCase_Test {
    private static Account  acnt;
    private static Asset ast;
    private static Contact con;
    private static Case caseRec;
    private static Group gp;
    @testSetup
    static void setupTestData() {
        Test.startTest();
        acnt = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.AccountNumber='1234567';
        acnt.BUID__c='12345';
        insert acnt;
        
        ast = SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Status = 'Installed';
        ast.InstallDate = System.Today();
        ast.UsageEndDate = System.Today();
        insert ast;
        
        con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        
        
        gp=SRVS_CreateTestDataFactory.createGroup();
        insert gp;
        caseRec = SRVS_CreateTestDataFactory.createSingleCase(ast.Id,acnt.Id,con.Id);
        caseRec.case_queue__c='a';
        insert caseRec;
        test.stopTest();
    }
    
    @isTest 
    private static void createCase_Test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        Case c = [SELECT Id from Case Limit 1];
        Account a = [SELECT Id from Account Limit 1];
        Asset asset = [SELECT Id from Asset Limit 1];
        Contact co = [SELECT Id from Contact Limit 1];
        Group g = [SELECT Id,Name from Group Limit 1];
        system.runAs(u){
            Test.startTest();            
            CollaborateInternalCase.createCase('supportTeam',g.Name,'reason','description','caseTitle',false,c.Id,a.Id,co.Id,asset.Id);
            CollaborateInternalCase.getOptions('Consumer L3');
            CollaborateInternalCase.getOptions('Consumer');
            CollaborateInternalCase.getCurrentUser();
            Test.stoptest();
        }
    }
    
}