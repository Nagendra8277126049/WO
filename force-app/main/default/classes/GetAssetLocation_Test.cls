/* -----------------------------------------------------------------------------------------------------------------------
Name:       GetAssetLocation_Test
Description:  Test class for GetAssetLocatin class - story #34169915
----------------------------------------------------------------------------------------------------------------------------
Date         Version        Author             		Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Sri Harsha Gangi Reddy      Initial Release
01/09/2018     1.1     Surya Subramanian           Chaneges are based on Code Review Defect 4378242
01/22/2018     1.2     Roselin Hephzibah       	   Changes are based on SRVS_CreateTestDataFactory Class
01/24/2018     1.3     Surya Subramanian           Changes are based on Code Review Defect 4561229
04/27/2018     1.4     Srikanth Parvathareddy      Updated from REST to ODATA service - Story #5039107
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class GetAssetLocation_Test {
    
    private static Account acnt;
    private static Contact con;
    private static Asset ast;
    
    /*
@method          : setupTestData
@description     : Unit test method to create test data
*/
    @testSetup
    static void setupTestData() {
        
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
        
    }
    
    /*
@method          : ReqAssetLocationByAsset_Test
@description     : Unit test method to Retrieve Asset Location from AssetLocationResponse__x using ODATA service.
*/
    
    @isTest
    private static void ReqAssetLocationByAsset_Test(){
        
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u){
            Test.startTest();
            Id astId=[select Id from Asset Limit 1].Id;
            List<GetAssetLocation.AssetLocationWrapper> AstLocation = GetAssetLocation.ReqAssetLocation(astId);
            Test.stopTest();
            System.assertEquals(AstLocation.size(),3); 
            System.assertEquals(AstLocation[2].City, 'BANGALORE');
        }
    }  
    
    /*
@method          : Exception_Test
@description     : Unit test method to test negative scenario.
*/
    
    @isTest
    private static void Exception_Test(){
        User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        System.runAs(u){
            Test.startTest();
            Id astId=[select Id from Asset Limit 1].Id;
            List<GetAssetLocation.AssetLocationWrapper> AstLocation = GetAssetLocation.ReqAssetLocation(null);
            Test.stopTest();
            System.assertNotEquals(null,3); 
        }
    }          
}