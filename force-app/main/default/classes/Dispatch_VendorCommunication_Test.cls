@isTest
private class Dispatch_VendorCommunication_Test{
    private static Account acnt;
    private static Asset ast;
    private static Case cse;
    private static WorkOrder wo;
    private static Product2 prd;
    private static Contact co;
    private static DispatchInstruction__c dinst1;
    private static DispatchInstruction__c dinst2;
    private static List<DispatchInstruction__c>  dInstList;

    @isTest
    private static void dipatchVendorCommunicattionTest(){
        
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
        wo = new  WorkOrder(assetId=ast.id,accountId=acnt.id,contactId=co.id,caseId=cse.id,
                            AdditionalContactId__c=co.id,subject='test');
        insert wo;
        
        dinst1 = new DispatchInstruction__c(Work_Order__c=wo.id,Instruction__c='Good Service with Care',DSP_Override_Request__c=true, Vendor_Instructions__c = true);
        dinst2 = new DispatchInstruction__c(Work_Order__c=wo.id,Instruction__c='Good Service with Care',DSP_Override_Request__c=true, Vendor_Instructions__c = true); 
        dInstList = new List<DispatchInstruction__c>();
        dInstList.add(dinst1);
        dInstList.add(dinst2);  
        insert dInstList;       
        Dispatch_VendorCommunication.getDispatchList(wo.id);                    

    }      
}