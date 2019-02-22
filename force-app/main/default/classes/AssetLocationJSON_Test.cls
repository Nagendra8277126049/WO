/* -----------------------------------------------------------------------------------------------------------------------
Name:         AssetLocationJSON_Test.apx
Description:  Unit Test Class - for Code Coverage - AssetLocationJSON.cls
      
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author                 Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/20/2017     1.0        Sri Harsha Gangi Reddy        Initial Release
01/09/2018     1.1        Surya Subramanian             Chaneges are based on Code Review Defect 4378242
01/22/2018     1.2        Srikanth Parvathareddy        Changes are based on utility class "SRVS_CreateTestDataFactory"
01/24/2018     1.3     	  Sonia Sharaff     	        Changes are based on defect 4561229
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class AssetLocationJSON_Test {
   
    /* Testing for Positive Scenario */  
    @isTest
    private static void testParse() {
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u) {
             
            String json = '{'+
                '\"AddressLine3\":              null        ,'+
                '\"AddressLine2\":              \"AP\"      ,'+
                '\"AddressLine1\":              \"TEST\"  ,'+
                '\"ServiceTag\":     \"APNONT1\"       ,'+
                '\"State\":               null        ,'+
                '\"AddressLine4\":              \"TEST\"  ,'+
                '\"Country\":         \"KTK:BANGALORE\"         ,'+
                '\"PostalCode\":    \"560066\"            ,'+
                '\"City\":  \"WHITE FIELD\"'+
                '},'+
                '\"MessageHeader\":  '+
                '{'+
                '\"ReturnMessaging\":  '+
                '{'+
                '\"Type\":               \"SUCCESS\"         ,'+
                '\"Details\":            \"100000, Operation successful. \"             ,'+
                '\"Message\":        \"Operation completed successfully\"       ,'+
                '\"Code\":               \"100\"'+
                '}'+
                '}'+
                '}';
            AssetLocationJSON obj = AssetLocationJSON.parse(json);
            System.assert(obj != null);
        }
    }
   
     /* Testing for Negative Scenario */  
    @isTest
  private static void testException() {
        User u1 = SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u1) {
            String json = ' ';
            AssetLocationJSON obj = AssetLocationJSON.parse(json);
            System.assertEquals(obj, null);
        }
    }   
}