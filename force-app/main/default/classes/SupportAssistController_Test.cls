/*
******************************************************************************************************
Name:       SupportAssistController_Test.apxc
Description: Test class for Controller of Lightning component to display Support data stored in SATC through oData services
Story 4656242:SFDC Phase2: Display if there are any Diagnostics alerts on an Asset and Case Page

*******************************************************************************************************
Date         Version            Author                Summary of Changes 
*******************************************************************************************************
03/12/2018     1.0       	Amitabh Wankhede	         Initial Release
07-Jul-2018    1.1			Srikanth Parvathareddy       Story 5067671 :SA Changes on Asset Details and Diagnostic Tab
*******************************************************************************************************
*/

@isTest
public class SupportAssistController_Test {
    
    // This method creates the test data 
    @testSetup
    private static void setupTestData() {
        
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='CH3SL9S';
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test contact
        contact con=SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        //create a test case
        Case cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,con.id);
        cse.subject='Test Controller Acct Case';
        insert cse;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
        // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        lct.CaseId = cse.id;
        insert lct;
        
    }
    /* This method tests the SupportAssit LastCollectionDate by Asset */
    @isTest
    private static void getLastCollectionDate_Test(){
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u1) {
            Test.startTest();
            Asset a=[Select id, Name from Asset Limit 1];
            case c=[Select id from case Limit 1];
            LiveChatTranscript lt=[Select id from LiveChatTranscript Limit 1];
            SupportAssistController.LastCollectionAlertDateWrapper Lcdw= SupportAssistController.getLastCollectionDate(a.id);
            SupportAssistController.LastCollectionAlertDateWrapper casecdw= SupportAssistController.getLastCollectionDate(c.id);
            SupportAssistController.LastCollectionAlertDateWrapper Ltcdw= SupportAssistController.getLastCollectionDate(lt.id);
            Test.stopTest(); 
            system.assertEquals(Lcdw.LastCollectionDate,'05/22/2012 11:46 AM');
        }
    }
    
    /* This method tests the Exception by passing UserId */
    @isTest
    private static void getSupportAssistDateException_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            SupportAssistController.LastCollectionAlertDateWrapper Lcdw= SupportAssistController.getLastCollectionDate(u1.Id);     
            Test.stopTest();        
            system.assertNotEquals(Lcdw, null);
        }
    }
    
    /* This method tests the SupportAssit LastCollectionAlerts by Asset */
    @isTest
    private static void getLastCollectionAlerts_Test(){
        User u2=SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u2) {
            Test.startTest();
            Asset a=[Select id, Name from Asset Limit 1];
            case c=[Select id from case Limit 1];
            LiveChatTranscript lt=[Select id from LiveChatTranscript Limit 1];
            List<SupportAssistController.CollectionAlertsWrapper> caw= SupportAssistController.getLastCollectionAlerts(a.id);
            List<SupportAssistController.CollectionAlertsWrapper> caseaw= SupportAssistController.getLastCollectionAlerts(c.id);
            List<SupportAssistController.CollectionAlertsWrapper> ltaw= SupportAssistController.getLastCollectionAlerts(lt.id);
            Test.stopTest();   
            system.assertEquals(caw.size(),3);
        }
    }
    
    /* This method tests the Exception by passing UserId */
    @isTest
    private static void getSupportAssistAlertsException_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            List<SupportAssistController.CollectionAlertsWrapper> caw= SupportAssistController.getLastCollectionAlerts(u1.Id);     
            Test.stopTest();        
            system.assertNotEquals(caw, null);
        }
    }
    
    /* This method tests the DateNullPointerException*/
    @isTest
    private static void getSupportAssistDateNPException_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            SupportAssistController.LastCollectionAlertDateWrapper Lcdw= SupportAssistController.getLastCollectionDate(null);     
            Test.stopTest();        
            system.assertEquals(Lcdw, null);
        }
    }
    
        /* This method tests the AlertsNullPointerException*/
    @isTest
    private static void getSupportAssistAlertsNPException_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
            Test.startTest();
            List<SupportAssistController.CollectionAlertsWrapper> caw= SupportAssistController.getLastCollectionAlerts(null);     
            Test.stopTest();        
            system.assertEquals(caw, null);
        }
    }
}