@isTest
public class WorkOrderTriggerHandler_Test
{
    @testSetup static void setup() {
        List < Account > accListList = DispatchTestSetupData.createAccountList();
        List < Asset > assetList = DispatchTestSetupData.createAssetList(accListList[0].id);
        List < Contact > conlist = DispatchTestSetupData.createContactList(accListList[0].id);
        List < Case > caselist = DispatchTestSetupData.createCaseList(accListList[0].id, assetList[0].id, conlist[0].id);
        List < WorkOrder > workOrderList = DispatchTestSetupData.createworkorderList(accListList[0].id, assetList[0].id, conlist[0].id, caselist[0].id);
        List < WorkOrderLineItem > workorderItemList = DispatchTestSetupData.createworkorderListItem(workOrderList[0].id, 'APS');      
       Address_Data_GCC__c indAdress = new Address_Data_GCC__c ();
        indAdress.Name='VILE PARLE WEST';
        indAdress.POSTCODE__c='400056';
        indAdress.COUNTRYCODE__c='IN';
        indAdress.STATENAME__c ='MRT:MUMBAI';
        insert indAdress;
        Address_Data_GCC__c ausAdress = new Address_Data_GCC__c ();
        ausAdress.Name='PUCKAPUNYAL MILPO';
        ausAdress.POSTCODE__c='3662';
        ausAdress.COUNTRYCODE__c='AU';
        ausAdress.STATENAME__c ='VIC';
        insert ausAdress;
        
        Address_Data__c  cityAdd = new Address_Data__c ();
        cityAdd.State_Name__c='ACRE';
        cityAdd.name='test';
        insert cityAdd;
        
         DispatchETMSetup__c etmItem = new DispatchETMSetup__c(ServiceType__c = 'Parts Only', Region__c = 'AP',
                SubRegion__c = 'Australia', MessageType__c = 'TradeComplianceUpdate',
                EventCode__c = 'VS', FileType__c = 'NA', OperationType__c = 'TRN', ProgressEvent__c = 'New',
                ActivityStatus__c = 'Work In Progress', LaborStatus__c = 'Acknowledged',
                PartsStatus__c = 'Cancelled');
                
                insert etmItem;
                
                  DispatchETMSetup__c etmItem1 = new DispatchETMSetup__c(ServiceType__c = 'Parts Only', Region__c = 'EMEA',
                SubRegion__c = 'Netherlands', MessageType__c = 'PartsOrderConfirmation',
                EventCode__c = 'VS', FileType__c = 'NA', OperationType__c = 'TRN', ProgressEvent__c = 'New',
                ActivityStatus__c = 'Work In Progress', LaborStatus__c = 'Acknowledged',PartsStatus__c = 'Cancelled');
                
                insert etmItem1;
                
                
          }
     
     
     public static testMethod void method1() 
     {
     
    
    List< WorkOrder>  w =  new List<WorkOrder>([Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 10]);
      User u1 = SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
       System.runas(u1)
       {
     w[0].CountryCode='AU';
     w[0].stateCode='NT';
     w[0].POSTalCODE='3662';
     w[0].MessageTypeID__c='PartsOrderCancelConfirmation';
     w[0].DPS_Region__c='AP';
     w[0].Service_Type__c='Parts Only';
     
     w[1].CountryCode='IN';
     w[1].StateCode='KA';
     w[1].POSTalCODE='400056';
     w[1].MessageTypeID__c='PartsOrderCancelConfirmation';
     w[1].DPS_Region__c='AP';
     w[1].Service_Type__c='Parts Only';
     
     w[4].CountryCode='IN';
     w[4].StateCode='KA';
     w[4].POSTalCODE='400056';
     w[4].MessageTypeID__c='PartsOrderCancelConfirmationRejection';
     w[4].Parts_Status__c='Acknowledged';
     w[4].DPS_Region__c='AP';
     w[4].Service_Type__c='Parts Only';
     
     
     w[5].CountryCode='IN';
     w[5].StateCode='KA';
     w[5].POSTalCODE='400056';
     w[5].MessageTypeID__c='BreakFixCancelConfirmation';
     w[5].DPS_Region__c='AP';
     w[5].Service_Type__c='Parts Only';
     
     
     w[6].CountryCode='AU';
     w[6].StateCode='NT';
     w[6].POSTalCODE='3662';
     w[6].MessageTypeID__c='TradeComplianceUpdate';
     w[6].DPS_Region__c='AP';
     w[6].DPS_Sub_Region__c = 'Australia';
     w[6].Service_Type__c='Parts Only';
     
     w[7].CountryCode='AU';
     w[7].StateCode='NT';
     w[7].POSTalCODE='3662';
     w[7].MessageTypeID__c='PartsOrderConfirmation';
     w[7].DPS_Region__c='AP';
     w[7].DPS_Sub_Region__c = 'Australia';
     w[7].Service_Type__c='Parts Only';
     
       
     w[2].MessageTypeID__c='ServiceCallConfirmation';
     w[2].Status='Open';
     w[2].DPS_Sub_Region__c='AMERICAS';
     w[2].DPS_Region__c='AMERICAS';
     w[2].Service_Type__c='Parts Only';
     w[2].Approval_Criteria_Met__c = '|| Test || Test || Test || Test ||';
     
     w[8].MessageTypeID__c='AdditionalPartRequest';
     w[8].Status='Open';
     w[8].DPS_Sub_Region__c='AMERICAS';
     w[8].DPS_Region__c='AMERICAS';
     w[8].Service_Type__c='Parts Only';
     
     w[3].DPS_Region__c='EMEA';
     w[3].DPS_Sub_Region__c='Netherlands';
     w[3].countryCode='NL';
     w[3].PostalCOde='1234';
     w[3].stateCOde='';
     w[3].MessageTypeID__c='PartsOrderConfirmation';
     w[3].Service_Type__c='Parts Only';
     
     List<WorkOrder> workorderlist = new List<WorkOrder>();
     workorderList.add(w[0]);
     workorderList.add(w[1]);
     workorderList.add(w[2]);
     workOrderList.add(w[3]);
     workOrderList.add(w[4]);
     workOrderList.add(w[5]);
     workOrderList.add(w[6]);
     workOrderList.add(w[7]);
     workOrderList.add(w[8]);
     
     update workorderlist;
     
     }
     
         
     }
   public static testMethod void method2() 
   {
    WorkOrder  w =  [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
    
    w.Dispatch_Country__c='LATAM';
    update w;
   
   }
   
   public static testMethod void method3() 
   {
   Case c=[Select Id,AssetId from Case where status='In Progress' limit 1];
   
    WorkOrder  wo = new WorkOrder();
    
    wo.Dispatch_Country__c='LATAM';
    
                        wo.CaseId=c.id;
                        wo.Assetid=c.AssetId;
                        wo.Address_Line_1__c = 'test';
                        wo.Address_Line_2__c = 'test';
                        wo.Address_Line_3__c = 'test';
                        wo.Address_Line_4__c = 'test';
                        wo.Country__c = 'Brazil';
                        wo.City__c = 'test';
                        wo.StateCode='AC';
                        wo.State='ACRE';
                        wo.Zip_Code__c = '1';
                        wo.CountryCode__c = 'BR';
                        wo.CountryCode='BR';
                        wo.StateCode__c = 'AC';
                        wo.Status='reWork';
                        
                        insert wo;
                        
                        Dispatch_Alert__c  dl1  = new Dispatch_Alert__c ();
        dl1.name='test1';
        dl1.Work_order__c= wo.id;
        dl1.Alert_Reason__c='Work Order has been rejected';
        
        insert dl1;
        WorkOrder w = new WorkOrder();
        w.status='Pending Review';
        w.id=wo.id;
        update w;
        
        
   
   }
   
   public static testMethod void method4() 
   {
      List< WorkOrder>  w =  new List<WorkOrder>([Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 3]);
      
        List < Customer_Reminder__c > crList = new List < Customer_Reminder__c > ();
        
         w[0].Ground_Shipment_Flag__c=true;
         w[0].Approval_Criteria_Met__c = '|| Test || Test || Test || Test ||';
         update w[0];
        Customer_Reminder__c cr = new Customer_Reminder__c ();
        cr.name='test';
        cr.Work_order__c= w[0].id;
        cr.Type__c ='Ground Shipment Flag';
        
        insert cr;
        
        Customer_Reminder__c cr1 = new Customer_Reminder__c ();
        cr.name='test1';
        cr1.Work_order__c= w[1].id;
        cr1.Type__c ='Override Ground Shipment';
        
        insert cr1;
        
        Dispatch_Alert__c  dl  = new Dispatch_Alert__c ();
        dl.Work_order__c= w[0].id;
        dl.Alert_Reason__c='Ground Shipment Battery Delete';
        
        insert dl;
        
        
        List<Id> wids= new List<Id>();
        wids.add(w[0].id);
        wids.add(w[1].id);
        
        WorkOrderTriggerHandler.deleteReminders(wids);
        
        
        
        
        
   }
  public static testMethod void method5() 
   {
      List< WorkOrder>  w =  new List<WorkOrder>([Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 3]);
      
       
        
         w[0].Ground_Shipment_Flag__c=true;
         w[0].status='Rework';
         w[0].Approval_Criteria_Met__c = '|| Test || Test || Test || Test ||';
         update w[0];
        
        
       
        w[1].CountryCode='AU';
     w[1].StateCode='NT';
     w[1].POSTalCODE='3662';
     w[1].MessageTypeID__c='TradeComplianceUpdate';
     w[1].DPS_Region__c='AP';
     w[1].DPS_Sub_Region__c = 'Australia';
     w[1].Service_Type__c='Parts Only';
     
     update w[1];
        
        
        
   } 
   

}