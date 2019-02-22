/********************************************************************************************************
Name:       CaseDiagnosisStepsController_Test.apxc
Apex Controller: 
Description: Test Class for Lightning component to display eSupport data stored in Case fields 
				Story 4560890:SFDC Pilot Phase 2 :: Agent Console :: Need to capture the diagnosis steps

*******************************************************************************************************
Date         Version            Author                Summary of Changes 
*******************************************************************************************************
02/28/2018     1.0       	Amitabh Wankhede	         Initial Release
07/19/2018     1.1			Srikanth Parvathareddy       Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
********************************************************************************************************/
@isTest
public class CaseDiagnosisStepsController_Test {

    // This method creates the test data 
    @testSetup
    private static void setupTestData() {
        
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='CH3SL9S_123';
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject ='Test Controller Acct Case';
        insert cse;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
        // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        lct.CaseId = cse.id;
        insert lct;
        
    }
    
 /* This method tests the eSupportAlerts by Asset */  
    @isTest
    public static void searchForCase_Test(){
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u1) {
            Test.startTest();
            LiveChatTranscript lct = [Select Id from LiveChatTranscript Limit 1];
            list<CaseDiagnosisStepsController.ExternalDiagnosticResultsWrapper> extDiagChatTransList = CaseDiagnosisStepsController.searchForCase(lct.Id);
            system.assertEquals(extDiagChatTransList.size(), 3);
			
            Case cs = [Select id from Case Limit 1];
            list<CaseDiagnosisStepsController.ExternalDiagnosticResultsWrapper> extDiagCaseList = CaseDiagnosisStepsController.searchForCase(cs.Id);
            system.assertEquals(extDiagCaseList.size(), 3);
             
            Asset ast = [Select id from Asset Limit 1];
            list<CaseDiagnosisStepsController.ExternalDiagnosticResultsWrapper> extDiagAssetCaseList = CaseDiagnosisStepsController.searchForCase(ast.Id);
            system.assertEquals(extDiagAssetCaseList.size(), 3);      
        }
    }
    
     /* This method tests the exception in the controller*/  
    @isTest
    public static void searchForCaseException_Test(){
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u1) {
            Test.startTest();
            LiveChatTranscript lct = [Select Id from LiveChatTranscript Limit 1];
            list<CaseDiagnosisStepsController.ExternalDiagnosticResultsWrapper> extDiagChatTransList = CaseDiagnosisStepsController.searchForCase(null);
            system.assertEquals(extDiagChatTransList,null);
			
            Case cs = [Select id from Case Limit 1];
            list<CaseDiagnosisStepsController.ExternalDiagnosticResultsWrapper> extDiagCaseList = CaseDiagnosisStepsController.searchForCase(null);
            system.assertEquals(extDiagCaseList,null);
             
            Asset ast = [Select id from Asset Limit 1];
            list<CaseDiagnosisStepsController.ExternalDiagnosticResultsWrapper> extDiagAssetCaseList = CaseDiagnosisStepsController.searchForCase(null);
            system.assertEquals(extDiagAssetCaseList,null);      
        }
    }
}