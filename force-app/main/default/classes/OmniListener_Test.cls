/* -----------------------------------------------------------------------------------------------------------------------
Name:       OmniListener_Test
Description:  This test class for AssociateServiceTagHandler #4640778
Date         Version   Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/08/2018     1.0     Roselin Hephzibah      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class OmniListener_Test {
    // This method creates the test data 
    @testSetup
    private static void setupTestData() {
        
        //create a test account
        Account acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        acnt.Industry='Fashion';
        acnt.Type='Customer';
        acnt.AccountNumber='1234567890';
        acnt.BUID__c='99';
        insert acnt;
        
        //create a test Product
        Product2 p=SRVS_CreateTestDataFactory.createProduct2();
        p.Product_Identifier__c='S360';
        p.External_Id__c = 'AH129';
        insert p;
        
        //create a test asset
        Asset ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
        ast.Name='Test Asset';
        ast.Product2Id=p.Id;
        ast.UsageEndDate = System.Today();
        insert ast;
        
        //create a test LiveChatVisitor
        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
        insert visitor;
        
       // create a LiveChatTranscript
        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
        lct.LiveChatButtonId = system.label.ECS_Chat_Button;
        insert lct;
       
       //Query a Service Channel
       ServiceChannel sc = [select Id from ServiceChannel where MasterLabel = 'Live Agent'];
        
      //User usr = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
      /*ServicePresenceStatus sps = [select Id from ServicePresenceStatus where MasterLabel = 'Ready'];
        
        userServicePresence usp = new userServicePresence();
        usp.UserId = usr.Id;
        usp.ServicePresenceStatusId = sps.Id;
        insert usp;*/
        
       //Create a AgentWork record
       AgentWork aw = SRVS_CreateTestDataFactory.createAgentWork();
       aw.ServiceChannelId = sc.Id;
       aw.WorkItemId = lct.Id;
       aw.UserId = userinfo.getUserId();
      	//aw.UserId = usr.id;
       insert aw;
        
        
       
        
        
    

    }
    
    @isTest static void OmniListenerTest() {
        
        
       
        User usr = new User();
        usr.Id = userinfo.getUserId();
        //User usr = [Select id from user limit 1];
       
        system.runAs(usr){
        Test.startTest();
        AgentWork aw = [select id from AgentWork limit 1];
       
        LiveChatTranscript lct = [select id from LiveChatTranscript limit 1];
          
        String sAssetNumber = OmniListener.queueCheck(aw.Id, lct.Id);
        String sAssetNumber1 = OmniListener.queueCheck(aw.Id, null);
        
      
        Test.stopTest(); 
        system.assertNotEquals(sAssetNumber,null);
        }
    }
        

}