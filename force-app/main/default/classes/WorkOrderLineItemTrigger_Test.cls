@isTest
public class WorkOrderLineItemTrigger_Test
{

@testSetup static void setup() 
{
        List < Account > accListList = DispatchTestSetupData.createAccountList();
        List < Asset > assetList = DispatchTestSetupData.createAssetList(accListList[0].id);
        List < Contact > conlist = DispatchTestSetupData.createContactList(accListList[0].id);
        List < Case > caselist = DispatchTestSetupData.createCaseList(accListList[0].id, assetList[0].id, conlist[0].id);
        List < WorkOrder > workOrderList = DispatchTestSetupData.createworkorderList(accListList[0].id, assetList[0].id, conlist[0].id, caselist[0].id);
        List < WorkOrderLineItem > workorderItemList = DispatchTestSetupData.createworkorderListItem(workOrderList[0].id, 'APS');    
}
   public static  testMethod void insertWorkOrderLineitems()
   {

             WorkOrder w= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
             WorkOrderLineItem wl=[Select Id,Selected_Work_Order__c from WorkOrderLineItem where WorKorderId=:w.id limit 1];
                 wl.Selected_Work_Order__c=w.id;
                 update wl;
                 Set<Id> workorderIds= new Set<Id>();
                 workOrderIds.add(w.id);
                 WorkOrderLineItemTriggerHelper.updateSequenceNumberHelper(workOrderIds);
              }   
                 
public static  testMethod void deleteWorkOrderLineitems()
   {

             
                WorkOrder w= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
             WorkOrderLineItem wl=[Select Id,Selected_Work_Order__c from WorkOrderLineItem where WorKorderId=:w.id limit 1];
                 wl.Selected_Work_Order__c=w.id;
                 update wl;
                 Set<Id> workorderIds= new Set<Id>();
                 workOrderIds.add(w.id);
                 
                 
                 Dispatch_Alert__c objAlert= new Dispatch_Alert__c();
                 objAlert.Alert_Details__c='Info Parts Hard Drive';
                 objAlert.Alert_Reason__c='Info Parts Hard Drive';
                 objAlert.Work_Order__c=w.id;
                 
                 insert objAlert;
                 
                 delete wl;             
    }
    
    public static testMethod void deleteWorkOrderLineItemswithDiffrentPart()
    
   {

             List<Account> accListList=DispatchTestSetupData.createAccountList();
                 List<Asset>   assetList= DispatchTestSetupData.createAssetList(accListList[0].id);
                 List<Contact>  conlist= DispatchTestSetupData.createContactList(accListList[0].id);
                 List<Case>  caselist = DispatchTestSetupData.createCaseList(accListList[0].id,assetList[0].id,conlist[0].id);
                 List<WorkOrder> workOrderList= DispatchTestSetupData.createworkorderList(accListList[0].id,assetList[0].id,conlist[0].id,caselist[0].id);
                 List<WorkOrderLineItem> workorderItemList=DispatchTestSetupData.createworkorderListItem(workOrderList[0].id,'Info Parts-Hard Drive');
                 workorderItemList[0].PartCommodity__c='SOLID STATE DRIVE';
                 workorderItemList[0].Line_Item_type__c='Info Parts-Hard Drive';
                 workorderItemList[0].Selected_Work_Order__c=workOrderList[0].id;
                 update workorderItemList[0];
                 
                 
                 
                 Dispatch_Alert__c objAlert= new Dispatch_Alert__c();
                 objAlert.Alert_Details__c='Info Parts Hard Drive';
                 objAlert.Alert_Reason__c='Info Parts Hard Drive';
                 objAlert.Work_Order__c=workOrderList[0].id;
                 
                 insert objAlert;
                 
                 delete workorderItemList[0];             
    }   
    
    public static testMethod void groundShipmentOnDeleteWorkOrderLineItem(){
                 
                
                 //List<WorkOrder> workOrderList= DispatchTestSetupData.createworkorderList(accListList[0].id,assetList[0].id,conlist[0].id,caselist[0].id);
                 WorkOrder w= [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
                 w.Ground_Shipment_Flag__c = true;
                 test.startTest();
                 update w;
                 test.stopTest();
                 
                 Dispatch_Alert__c dispAlert = new Dispatch_Alert__c(Alert_Reason__c='Ground Shipment Battery',Work_Order__c=w.Id);
                 insert dispAlert;
                 
                 List<WorkOrderLineItem> workorderItemList=DispatchTestSetupData.createworkorderListItem(w.id,'Battery');
                 workorderItemList[0].PartCommodity__c='Battery';
                 workorderItemList[0].Line_Item_type__c='Battery';
                 workorderItemList[0].Selected_Work_Order__c=w.id;
                 update workorderItemList[0];
                 delete workorderItemList[0];   
    }
}