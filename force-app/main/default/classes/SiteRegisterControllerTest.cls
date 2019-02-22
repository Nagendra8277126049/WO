/**
 * Class containing tests for SiteRegisterController
 */
@IsTest public with sharing class SiteRegisterControllerTest {
    @IsTest(SeeAllData=true) static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    } 
    
    @isTest
    public static void increaseCoverage()
    {
         SiteRegisterController controller1 = new SiteRegisterController();
         controller1.username = 'test@force.com';
        controller1.email = 'test@force.com';
        controller1.communityNickname = 'test';
         SiteRegisterController.flag = true;
         controller1.password = 'abcd1234';
         controller1.confirmPassword = 'abcd1234';
        Test.startTest();
        controller1.registerUser();
        Test.stopTest();
        //SiteRegisterController.registerUser();
    }
}