@isTest
private class DispatchTrackingInfoController_Test {
    
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static User u;
    private static Contact co;
    private static WorkOrder wo;
    private static WorkOrder wo1;
    private static Product2 prd;
    
    /* This method creates the test data */
    private static void setupTestData() {
        // Create a unique UserName
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
        /*u = new User(Alias = 'auser', Email='adminuser@dell.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',
                          LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
        insert u;*/
        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
        
        //create a test account
        acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');
        insert acnt;
        
        //create a new product
        prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
        insert prd;
        
        //create a test asset
        ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,
                        InstallDate = System.Today(),UsageEndDate = System.Today());
        insert ast;
        
        //create a test contact
        co = new Contact(Email = 'testtag@test.com',firstname = 'firstname', 
                         LastName = 'testtag',Accountid = acnt.id);
        insert co;
            
        //create a test case
        cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id, 
                       ContactId=co.Id);
        insert cse;
        
        //create a test work Order
        wo = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,City='Round Rock',State='Texas',
                            Country='United States',Region__c='1',PostalCode='78664',AdditionalContactId__c=co.id,CountryCode='US',
                            subject='testing Work Order',Street='Dell Way123');
        insert wo;
        
        //create a test work Order
        wo1 = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,
                            AdditionalContactId__c=co.id,City='Round Rock',Country='United States',Region__c='1',PostalCode='78664', CountryCode='US', state='Texas', Street='Dell Way123',
                            subject='testing Work Order');
        insert wo1;
        
        List<DispatchWaybill__c> dwbList = new List<DispatchWaybill__c>();
                        
        // insert 10 Way Bill Records  
        for (Integer i=0;i<10;i++) {
                            
            DispatchWaybill__c dwb = new DispatchWaybill__c();
                
            dwb.ISP_FSD_Carrier_Name__c='FEDEX';
            dwb.ISP_FSD_WayBill_Number__c= '100000000';
            dwb.ISP_FSD_WayBill_Direction__c= 'East';
            dwb.ISP_FSD_WayBill_Date__c= '05/28/2018';
            dwb.Work_Order__c = wo.Id;
                        
            dwbList.add(dwb);
        }
            
        insert dwbList;
        
        
    }

    private static testMethod void UseCase1_Test() {
        setupTestData();
        //system.runAs(u){
            Test.startTest();
                DispatchTrackingInfoController.trackInfoWrapper tWrap = DispatchTrackingInfoController.getTrackingInfoList(wo.Id);
            Test.stopTest();
            system.assertNotEquals(tWrap,null);
            system.assertEquals(tWrap.NoRecordsFound,false);
        //}
    }
    
    private static testMethod void UseCase2_Test() {
        setupTestData();
       // system.runAs(u){
            Test.startTest();
               DispatchTrackingInfoController.trackInfoWrapper tWrap = DispatchTrackingInfoController.getTrackingInfoList(wo1.Id);
            Test.stopTest();
            system.assertNotEquals(tWrap,null);
            system.assertEquals(tWrap.NoRecordsFound,true);
        //}
    }

}