/* -----------------------------------------------------------------------------------------------------------------------
  Name:       Dispatch_LineItemEditControllerTest
  Description:  Unit Test Class for Dispatch_LineItemEditController.cls - 
  ----------------------------------------------------------------------------------------------------------------------------
  Date         Version          Author             Summary of Changes 
  -----------  -------  ------------------------  ------------------------------------------------------------------------------
  24/4/2018     1.0       Megha Bhardwaj              Initial Release
  -------------------------------------------------------------------------------------------------------------------------- */

@isTest
public class Dispatch_LineItemEditControllerTest{
    
    @TestSetUp
    public static void createTestData(){
    
         List<Account> accListList = DispatchTestSetupData.createAccountList();
         List<Asset>   assetList = DispatchTestSetupData.createAssetList(accListList[0].id);
         List<Contact>  conlist = DispatchTestSetupData.createContactList(accListList[0].id);
         List<Case>  caselist = DispatchTestSetupData.createCaseList(accListList[0].id,assetList[0].id,conlist[0].id);
         List<WorkOrder> workOrderList = DispatchTestSetupData.createworkorderList(accListList[0].id,assetList[0].id,conlist[0].id,caselist[0].id);
         List<WorkOrderLineItem> workorderItemList = DispatchTestSetupData.createworkorderListItem(workOrderList[0].id,'APS');
    }
    
    public static testMethod void fetchworkOrderLineItemTest(){
       
        List<WorkOrderLineItem> lineItemList = [Select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,
                                                            WorkOrderId,Selected_Work_Order__c,ServiceBUID__c, ServiceTag__c,Valid_Parts__c,Validate_Parts_Response__c, Quantity, Part_Quantity__c from workorderlineitem limit 1 ];
        Dispatch_LineItemEditController.fetchworkOrderLineItem(lineItemList[0].id);
        Dispatch_LineItemEditController.validateWorkOrderLineItem(lineItemList[0]); 
        Dispatch_LineItemEditController.saveLineItem(lineItemList[0]);
        delete lineItemList;
        Dispatch_LineItemEditController.fetchworkOrderLineItem('00432233444dfc');
        WorkOrderLineItem lineItem;
        Dispatch_LineItemEditController.validateWorkOrderLineItem(lineItem);
        Dispatch_LineItemEditController.saveLineItem(lineItem);
    }
}