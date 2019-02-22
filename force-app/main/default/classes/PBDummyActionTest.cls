/* -----------------------------------------------------------------------------------------------------------------------
Name:         PBDummyActionTest
Description:  Unit Test Class for PBDummyAction class -  Defect #4561229
Date         Version     Author                 Summary of Changes 
-----------  -------  -----------------        ------------------------------------------------------------------------------
01/23/2018     1.0     Srikanth Parvathareddy   Changes are based on utility class "SRVS_CreateTestDataFactory"         
-------------------------------------------------------------------------------------------------------------------------- */ 

@isTest
Private class PBDummyActionTest {
    
    //setting up test data
    private static user testUser=new user();
        private static List<ID> ids=new List<ID>();
    
    @testSetup
    private static void setUpData(){
        
        
        Account ac;
        Asset a;
        Contact con;
        
        //creating user test record
        testUser = SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
        
        //creating account test record
        ac=SRVS_CreateTestDataFactory.createSingleAccountRecord();
        insert ac;
        
        //creating asset test record
        a=SRVS_CreateTestDataFactory.createSingleAsset(ac.id);
        insert a;
        
        //creating contact test record
        con=SRVS_CreateTestDataFactory.createContactRecord(ac);
        insert con;
        
        //creating list of cases test records
        List<case> c=new List<case>();
        c=SRVS_CreateTestDataFactory.createMultipleCases(a.id,ac.id,con.id,3);
        insert c;
        for(case cse:c){
            ids.add(cse.id);
        }
    }
    
    // Unit Test Method
    @isTest 
    private static void PBtest()
    {
        setupData();
        system.runAs(testUser){
        test.startTest();
        PBDummyAction.getIds(ids);
        test.stopTest();
        system.assertEquals(3,ids.size()); 
        }    
    }    

}