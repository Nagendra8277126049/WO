/* -----------------------------------------------------------------------------------------------------------------------
Name:         AssetContactUpSert_Test
Description:  Test class for AssetContactUpSert.cls 
----------------------------------------------------------------------------------------------------------------------------
Date         Version  		  Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
12/08/2017     1.0     		Mohammed Farhan       Initial Release
01/17/2018     1.1     	   Surya Subramanian    Changes are based on Code Review Defect 4561213
01/22/2018     1.2     	   Surya Subramanian   	Changes are based on SRVS_CreateTestDataFactory Class
-------------------------------------------------------------------------------------------------------------------------- */

@isTest
private class AssetContactUpSert_Test {    
    
    private Static User u = SRVS_CreateTestDataFactory.createUser('System Administrator');
    
    @isTest
    private static void assetContactUpSert(){
 
        System.runAs(u){
            
            Account a1=SRVS_CreateTestDataFactory.createSingleAccountRecord();
            insert a1;
            
            Contact c1=SRVS_CreateTestDataFactory.createContactRecord(a1);
            insert c1;
                    
            Asset a=SRVS_CreateTestDataFactory.createSingleAsset(a1.Id);
            a.ContactId=c1.id;
            insert a;
            
            System.AssertEquals(a1.Id != null,true);
            System.AssertEquals(c1.Id != null,true);
            System.AssertEquals(a.Id != null,true);
        }
    }
}