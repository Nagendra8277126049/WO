/* -----------------------------------------------------------------------------------------------------------------------
Name:       CommonMessageHeader_Test
Description:  Test class for CommonMessageHeader class 
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/08/2017     1.0         Mohammed Farhan         Initial Release
01/22/2018     1.1     	   Surya Subramanian   	   Chaneges are based on Code Review Defect 4561213
01/24/2018     1.2         Roselin Hephzibah       Changes are based on Code Review Defect 4561229
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class CommonMessageHeader_Test {
    
    
    /*private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        u = new User(Alias = 'auser', Email='adminuser@dell.com',
                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',
                  LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                  TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName);
        insert u;
    }*/
    
    @isTest
    private static void CommonReturnMessaging1(){
		
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u){
            Test.startTest();
                CommonMessageHeader cmh= new CommonMessageHeader ();         
                //system.assertEquals(null,cmh.ReturnMessaging);
                CommonReturnMessaging cmnRtnMsg = new CommonReturnMessaging();
                cmnRtnMsg.type = 'Success'; //SUCCESS
                cmnRtnMsg.details = '100000, Operation successful';  //100000, Operation successful. 
                cmnRtnMsg.message = 'Operation completed successfully';//Operation completed successfully
                cmnRtnMsg.code = '100';  //100 
                
                cmh.ReturnMessaging = cmnRtnMsg;
                //system.assertEquals('Success',cmh.ReturnMessaging.type);
            Test.stopTest();
            //system.assertEquals(null,cmh.ReturnMessaging);
            system.assertEquals('Success',cmh.ReturnMessaging.type);
        }        
    }
}