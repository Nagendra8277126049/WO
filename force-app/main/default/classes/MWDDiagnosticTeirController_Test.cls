/**
*    @author Sri Harsha G
*    @date   19th Feb 19
*    @description  Test Class for MWDDiagnosticTeirController Class                            
*     
*     Modification Log:
*---------------------------------------------------------------------------------------------------------------
*       Developer             Date                Description
*---------------------------------------------------------------------------------------------------------------
*       Sri Harsha G       19th Feb 19         	Test Class for MWDDiagnosticTeirController Class - STORY 5240855 
*/
@isTest
private class MWDDiagnosticTeirController_Test {
	// This method creates the test data 
    @testSetup
    private static void setupTestData() {
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        insert u1;
    }
    
    @isTest
    private static void getSpecialIssues_Test(){
        User u1 = [SELECT Id FROM User LIMIT 1];
    	system.runAs(u1){
        	Test.startTest(); 
            MWDDiagnosticTeirController.mockedMWDDiagnosticTeir.add(new MWD_Diagnostic_Teir__mdt(Special_Issue__c='SIs1',Tier_1__c='t1',Tier_2__c='t21',Tier_3__c='t31',Reason_Code__c='rc1'));
            MWDDiagnosticTeirController.mockedMWDDiagnosticTeir.add(new MWD_Diagnostic_Teir__mdt(Special_Issue__c='SIs2',Tier_1__c='t2',Tier_2__c='t22',Tier_3__c='t32',Reason_Code__c='rc2'));
            MWDDiagnosticTeirController.mockedMWDDiagnosticTeir.add(new MWD_Diagnostic_Teir__mdt(Special_Issue__c='SIs3',Tier_1__c='t3',Tier_2__c='t23',Tier_3__c='t33',Reason_Code__c='rc3'));
            MWDDiagnosticTeirController.mockedMWDDiagnosticTeir.add(new MWD_Diagnostic_Teir__mdt(Special_Issue__c='SIs4',Tier_1__c='t4',Tier_2__c='t24',Tier_3__c='t34',Reason_Code__c='rc4'));
            List<MWD_Diagnostic_Teir__mdt> responseList = MWDDiagnosticTeirController.getSpecialIssues();
            Test.stopTest();
          	System.assertEquals(responseList.size(),4);
        }
    }
    
    @isTest
    private static void getSpecialIssues_Test1(){
        User u1 = [SELECT Id FROM User LIMIT 1];
    	system.runAs(u1){
        	Test.startTest(); 
			List<MWD_Diagnostic_Teir__mdt> responseList = MWDDiagnosticTeirController.getSpecialIssues();
            Test.stopTest();
          	System.assertEquals(responseList.size(),[SELECT Count() FROM MWD_Diagnostic_Teir__mdt LIMIT 100]);
        }
    }
}