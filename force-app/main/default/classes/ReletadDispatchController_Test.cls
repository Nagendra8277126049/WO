/* -----------------------------------------------------------------------------------------------------------------------
Name:       ReletadDispatchController_Test
Description: Unit Test class for ReletadDispatchController.cls - story# 4150193
Date         Version      Author          Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/30/2017    1.0     Farhan Yakkalur      Initial Release
01/08/2018    1.1     Surya K S            Changes are based on Code Review Defect 4378242
01/24/2018    1.2     Roselin Hephzibah    Changes are based on Code Review Defect 4561229 
10/30/2018     1.3     Rajesh Guru         Nov Release story-Story 5086637 & 5150078 (added  Live chat transcript)
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class ReletadDispatchController_Test {

    private static integer firstPage;
    private static integer scndPage;
    private static string pageSize;
    
    /* This method creates the test data */
    @testSetup    
    static void setupTestData() 
    {
        // Create a unique UserName
        /*String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = new User(Alias = 'auser', Email='adminuser@dell.com',
                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',
                  LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                  TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName);
        insert u;        
        acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');*/
		Test.startTest();
        Account acnt= SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert acnt;
        
        Asset ast =SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        insert ast;
        
        Contact con = SRVS_CreateTestDataFactory.createContactRecord(acnt);
        insert con;
        
        Case cse = SRVS_CreateTestDataFactory.createSingleCase(ast.Id,acnt.Id,con.Id);
        insert cse;
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        insert lct;

        Test.stopTest();
    }
    
    /* Test Method to for Dispatches by User */
    @isTest
    private static void UserDispatch_test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        firstPage = 1;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getUserSRDispatches(firstPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size() > 0, true);
        }
    }
    
    /* Test Method to for Dispatches by User */
    @isTest
    private static void UserDispatchPage_test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getUserSRDispatches(scndPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size() > 0, true);
        }
    }
     
    /* Test Method for Dispatches by Case */
    @isTest
    private static void reletadDispatchByCase_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        firstPage = 1;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Case c = [SELECT Id from Case LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatches (c.id, firstPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        } 
    }
    
    /* Test Method for Dispatches by Case */
    @isTest
    private static void reletadDispatchPageByCase_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Case c = [SELECT Id from Case LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatches (c.id, scndPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        }  
    }
        /* Test Method for Dispatches by LiveChatTranscript */
    @isTest
    private static void reletadDispatchPageByLiveChatTranscript_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            LiveChatTranscript LCT = [SELECT Id from LiveChatTranscript LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatches (LCT.id, scndPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        }  
    }
    
    
    /* Test Method for Dispatches by Asset */
    @isTest
    private static void reletadDispatchByAsset_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        firstPage = 1;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Asset a = [SELECT Id from Asset LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatches (a.id, firstPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        } 
    }
    @isTest
    private static void reletadDispatchByAssetFail_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        firstPage = 1;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Asset a = [SELECT Id from Asset LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatches (null, null, null);  
            Test.StopTest();
            System.AssertEquals(dispList,null);
        } 
    }
    /* Test Method for Dispatches by Asset */
    @isTest
    private static void reletadDispatchPageByAsset_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Asset a = [SELECT Id from Asset LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatches (a.id, scndPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        } 
    }

    
    /* Test Method for Dispacth Details by Case */
    @isTest
    private static void dispatchDetailsByCase_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        firstPage = 1;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Case c = [SELECT Id from Case LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatchDetails (c.id, firstPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        }
    }
    
    /* Test Method for Dispacth Details by Case */
    @isTest
    private static void dispatchDetailsPageByCase_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Case c = [SELECT Id from Case LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatchDetails (c.id, scndPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        }
    }
    /* Test Method for Dispatch Details by Asset */
    @isTest
    private static void dispatchDetailsByAsset_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        firstPage = 1;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Asset a = [SELECT Id from Asset LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatchDetails (a.id, firstPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        }  
    }
    /* Test Method for Dispatch Details by Asset */
    @isTest
    private static void dispatchDetailsPageByAsset_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Asset a = [SELECT Id from Asset LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatchDetails (a.id, scndPage, pageSize);
            Test.StopTest();
            System.AssertEquals(dispList.rltdDispatch.Size()>0,true);
        }  
    }
    /* Test Method for Dispatch Details by Asset */
    
    @isTest
    private static void dispatchDetailsExcpByAsset_Test()
    {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        scndPage = 2;
        pageSize = '10';
        System.RunAs(u){
            Test.StartTest();
            Asset a = [SELECT Id from Asset LIMIT 1];
            ReletadDispatchController.RelatedPagerWrapper dispList = new ReletadDispatchController.RelatedPagerWrapper();
            ReletadDispatchController.RelatedPagerWrapper dispList2 = new ReletadDispatchController.RelatedPagerWrapper();
            dispList = ReletadDispatchController.getRelatedDispatchDetails (a.id, scndPage, null);
            dispList2 = ReletadDispatchController.getRelatedDispatchDetails (null, scndPage, null);
            Test.StopTest();
            System.AssertNotEquals(dispList,null);
        }  
    }
}