/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       AssetTriggerHandler_Test
Description:           
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author                 Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/05/2017     1.0           Soniya Sharaff             Initial Release
01/22/2018     1.2        Sonia Sharaff                 Changes are based on SRVS_CreateTestDataFactory Class
-------------------------------------------------------------------------------------------------------------------------- 
*/

@isTest
private class AssetTriggerHandler_Test { 
    private static list<asset> lstAst=new list<asset>();                  
    
    //set up data
    @testSetup static void setUpData() {
        Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert act;
        Asset ast1 = SRVS_CreateTestDataFactory.createSingleAsset(act.id);
        Asset ast2 = SRVS_CreateTestDataFactory.createSingleAsset(act.id);
        Asset ast3 = SRVS_CreateTestDataFactory.createSingleAsset(act.id);
        insert ast1;
        ast2.Parent_Asset_Id__c=ast1.id;
        ast3.Parent_Asset_Id__c=ast1.id;
        lstAst.add(ast2);
        lstAst.add(ast3);  
        insert lstAst;
    }
    
    //before insert trigger test
    @isTest 
    private static void unitTestInsert()
    {
        Test.startTest();         
        List<Asset> AstLst1 = [SELECT Id from Asset Limit 5];        
        Test.stopTest();        
        System.assertEquals(3,AstLst1.size()); 
    } 
    
    //before update trigger test
    
    @isTest 
    private static void unitTestUpdate()
    {
        Test.startTest(); 
        List<Asset> AstLst2 = [SELECT Id,Parent_Asset_Id__c,parentId from Asset Limit 5];
        
        for(integer i=0;i<AstLst2.size();i++)
        {
            if(i+1!=AstLst2.size()){
                AstLst2[i+1].Parent_Asset_Id__c=AstLst2[i].id;
            }
        }
        
        //AstLst2[2].Parent_Asset_Id__c=AstLst2[1].id;           
        AssetTriggerHandler.beforeUpdate(AstLst2);  
        //update a;      
        Test.stopTest(); 
        System.assertEquals(3,AstLst2.size());
    } 
}