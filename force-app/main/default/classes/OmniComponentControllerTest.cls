@isTest
public class OmniComponentControllerTest {

    static testMethod void validateIsCurrentUserServiceAgentTrue(){
      User usr = SRVS_CreateTestDataFactory.createUser(Label.Service_Agent_Profile);   
        test.startTest();
        System.runAs(usr){
            System.assertEquals(true, OmniComponentController.isCurrentUserServiceAgent());
        }        
        test.stopTest();
    }
    static testMethod void validateIsCurrentUserServiceAgentFalse(){
      User usr = SRVS_CreateTestDataFactory.createUser('System Administrator');          
        test.startTest();
        System.runAs(usr){
            System.assertEquals(false, OmniComponentController.isCurrentUserServiceAgent());
        }        
        test.stopTest();
    }
    static testMethod void validateIsCurrentUserDispatchApproverTrue(){
      User usr = SRVS_CreateTestDataFactory.createUser(Label.Service_Agent_Profile);        
        test.startTest();
        System.runAs(usr){
            System.assertEquals(true, OmniComponentController.isCurrentUserServiceAgent());
        }        
        test.stopTest();
    }
}