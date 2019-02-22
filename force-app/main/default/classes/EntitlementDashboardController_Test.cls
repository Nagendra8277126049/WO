/*--------------------------------------------------------------------------------------------------------------------------
Name:         EntitlementDashboardController_Test
Description:  Test class for EntitlementDashboardController class - Story #4145473
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Sri Harsha Gangi Reddy       Initial Release
01/22/2018     1.1     Srikanth Parvathareddy       Changes are based on utility class "SRVS_CreateTestDataFactory"
01/24/2018     1.2     Srikanth Parvathareddy       Changes are based on Code Review Defect #4561229
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class EntitlementDashboardController_Test {

    private static integer firstPage;
    private static integer scndPage;
    private static string pageSize;
    
    // This method creates the test data 
    @testSetup
    private static void setupTestData() {
     
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        insert acnt;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
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
        insert lct;
      
       //create a test Call Transcript
         Call_Transcript__c callTransAttr=SRVS_CreateTestDataFactory.createcallTranscript();
         callTransAttr.Asset__c=ast.id;
         insert callTransAttr;
        
        //Create Work Order
        WorkOrder wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.Id,acnt.Id,con.Id,cse.Id);
        insert wo;
    }

    /* This method tests the entitlements by case */
    @isTest
    private static void getEntitlementsByCase_Test(){
        
        User u1=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u1){
          Test.startTest();
            case c=[Select id from case Limit 1];
          List<EntitlementDashboardController.EntitlementListWrapper> entlmntListWrapper = 
                              EntitlementDashboardController.getEntitlements(c.Id);    
            Test.stopTest();        
            system.assertEquals(entlmntListWrapper[0].entStatus, 'Active');
            system.assertEquals(entlmntListWrapper.size(), 3);
        }
    }
    
    /* This method tests the entitlements by Asset */
    @isTest
    private static void getEntitlementsByAsset_Test(){
        
        User u2=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u2){
          Test.startTest();
            Asset a=[Select id from Asset Limit 1];
          List<EntitlementDashboardController.EntitlementListWrapper> entlmntListWrapper = 
                         EntitlementDashboardController.getEntitlements(a.Id);    
            Test.stopTest();        
            system.assertEquals(entlmntListWrapper[0].entStatus, 'Active');
            system.assertEquals(entlmntListWrapper.size(), 3);
        }
    }
    
    /* This method tests the entitlements by LiveChatTanscript */
    @isTest
    private static void getEntitlementsByChatTran_Test(){
        User u3=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u3){
          Test.startTest();
            LivechatTranscript lc=[select id from LivechatTranscript Limit 1];
          List<EntitlementDashboardController.EntitlementListWrapper> entlmntListWrapper = 
                             EntitlementDashboardController.getEntitlements(lc.Id);    
            Test.stopTest();        
            system.assertEquals(entlmntListWrapper[0].entStatus, 'Active');
            system.assertEquals(entlmntListWrapper.size(), 3);
        }
    }

    /* This method tests the entitlement Details by Case - first Page */
    @isTest
    private static void getEntDetailsByCase_Test(){
        firstPage = 1;
        pageSize = '10';
        User u4=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u4){
          Test.startTest();
            case cs=[select id from case Limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
                              EntitlementDashboardController.getEntDetails(cs.Id, firstPage, pageSize);    
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
    
    /* This method tests the entitlement Details by Asset - first Page */
    @isTest
    private static void getEntDetailsByAsset_Test(){
        firstPage = 1;
        pageSize = '10';
        User u5=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u5){
          Test.startTest();
            Asset ae=[select id from Asset Limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
                          EntitlementDashboardController.getEntDetails(ae.Id, firstPage, pageSize);    
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
        
    /* This method tests the entitlement Details by Live Chat Transcript - second Page */
    @isTest
    private static void getEntDetailsByChatTrans_Test(){
        firstPage = 1;
        pageSize = '10';
        User u6=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u6){
          Test.startTest();
            LivechatTranscript lt=[select id from LivechatTranscript Limit 1];
            EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
                          EntitlementDashboardController.getEntDetails(lt.Id, firstPage, pageSize);    
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
    
        /* This method tests the entitlement Details by Case - second Page */
    @isTest
    private static void getEntDetailsPageByCase_Test(){
        scndPage = 2;
        pageSize = '10';
        User u7=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u7){
          Test.startTest();
            case ce=[select id from case limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
                              EntitlementDashboardController.getEntDetails(ce.Id, scndPage, pageSize);    
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
    
    /* This method tests the entitlement Details by Asset - second Page */
    @isTest
    private static void getEntDetailsPageByAsset_Test(){
        scndPage = 2;
        pageSize = '10';
        User u8=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u8){
          Test.startTest();
            asset at=[select id from asset limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
                          EntitlementDashboardController.getEntDetails(at.Id, scndPage, pageSize);    
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
    
    /* This method tests the entitlement Details by Work Order */
    @isTest
    private static void getEntDetailsByWorkOrder_Test(){
        firstPage = 1;
        pageSize = '10';
        User u9=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u9){
          Test.startTest();
          WorkOrder wo=[select id from WorkOrder Limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
                          EntitlementDashboardController.getEntDetails(wo.Id, firstPage, pageSize);  
            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }

    /* This method tests the entitlement Details by Call Transcript */
    @isTest
    private static void getEntDetailsByCallTranscript_Test(){
        firstPage = 1;
        pageSize = '10';
        User u9=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u9){
          Test.startTest();
          Call_Transcript__c callTransAttr  =[select id from Call_Transcript__c Limit 1];
          EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper = 
           EntitlementDashboardController.getEntDetails(callTransAttr.id, firstPage, pageSize);  
            EntitlementDashboardController.EntitlementPagerWrapper entlmntListWrapper1 = 
                          EntitlementDashboardController.getEntDetails(null, firstPage, pageSize);  

            Test.stopTest();
            system.assertEquals(entlmntListWrapper.entDetails[0].entType, 'BType1234');
            system.assertEquals(entlmntListWrapper.entDetails.size(), 3);
        }
    }
}