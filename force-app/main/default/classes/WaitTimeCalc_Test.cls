/* -----------------------------------------------------------------------------------------------------------------------
Name:       WaitTimeCalc_Test 
Description: Test class for WaitTimeCalc class (Code coverage - 75%. The related API Class requires the admin, who is running the test
			  class, to be part of a queue, Ready in omni with ongoing chats to increase the coverage.)
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
02/05/2019     1.0       Roselin Hephzibah       Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
@isTest
public class WaitTimeCalc_Test {

    @isTest
    private static void calcWaitTime_Test(){
        User usr = new User();
        usr.Id = userinfo.getUserId();        
       
        system.runAs(usr){
            Test.startTest();
            Id buttonId = [Select id from LiveChatButton limit 1].Id;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/WaitTimeCalc'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            WaitTimeRequest reqst = new WaitTimeRequest();
            reqst.chatButtonId = buttonId;
            String JsonMsg=JSON.serialize(reqst);
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response = res;       
            WaitTimeCalc.calculateWaitTime();
        	Test.stopTest();
        }
            
        }
    @isTest
    private static void calcWaitTimeExcep_Test(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WaitTimeCalc'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        WaitTimeRequest reqst = new WaitTimeRequest();
        reqst.chatButtonId = '123';
        String JsonMsg=JSON.serialize(reqst);
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;       
        WaitTimeCalc.calculateWaitTime();
        Test.stopTest();
            
        }

    Public Class WaitTimeRequest{
        Public String chatButtonId;
    }

}