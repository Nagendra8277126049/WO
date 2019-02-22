@istest
public class DispatchAutoPartSelection_Test
{
public static String partprice = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
    public static String partType = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
    public static String DefectiveComponent = '1233333333333333456789101010101010101010101010101010101010101010101010101010101010101010101016783863896398369836386398363896398639836398368936389638936893637879879879867858758758799999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999';
    public static String partcommodity = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
    public static String subcomponent = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
    public static String functionalDescription = 'Making the message length bigger to be on safer side...The messsage length should be greater than 255. So passing the message which should be greater than 255.....So framing the sentance to be greater than 255.......I think this should be enough for test method to pass ...................................................................................................................................................hopefully this should be enough';
    public static String partDescription = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010232133323221322423423432432432423423424243231010101678386389639836983638639836389639863983639836893638963893689363787987987986785875875878797987897896767856567453454675785674674648674646578476487';
    public static String fourhours = 'YYYYYYYY';
    public static String CRU = 'YYYYYYYYY';
    public static String FRU = 'YYYYYYYY';
    public static String SBUID = '12345678987654321234567890987763442414365366336372838372737393738635343937934554554554';
    public static String POF = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
    public static String RepairType = '12334343543546565888888888888888888888888888888888888888888888888888888888888888888888888888888888888899999999999999999999999999999999999999999999777777777777777777777777777777';
    public static String partnumber = '12333333333333334567891010101010101010101010101010101010101010101010101010101010101010101010167838638963983698363863983638963986398363983689363896389368936378798798798678587587587';
    
  @testSetup static void setup() {
        List < Account > accListList = DispatchTestSetupData.createAccountList();
        List < Asset > assetList = DispatchTestSetupData.createAssetList(accListList[0].id);
        List < Contact > conlist = DispatchTestSetupData.createContactList(accListList[0].id);
        List < Case > caselist = DispatchTestSetupData.createCaseList(accListList[0].id, assetList[0].id, conlist[0].id);
        List < WorkOrder > workOrderList = DispatchTestSetupData.createworkorderList(accListList[0].id, assetList[0].id, conlist[0].id, caselist[0].id);
        List < WorkOrderLineItem > workorderItemList = DispatchTestSetupData.createworkorderListItem(workOrderList[0].id, 'APS');      
    }
    
    public static testMethod void insertAndReturnWorkOrderLItestMethodforexistingworklineitems() {
    //User u30=SRVS_CreateTestDataFactory.createUser('System Administrator');
    Case c =[Select  id,Service_Tag__c from Case where status='In Progress' limit 1];
    WorkOrder w = [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
        
            Test.startTest();
                WorkOrderLineItem updatedworkorderItemList = [Select id from WorkOrderLineItem where Line_Item_Type__c ='APS'  limit 1] ;
                updatedworkorderItemList.Selected_By_user__c = false;
                updatedworkorderItemList.Line_Item_Type__c = 'APS';
                update updatedworkorderItemList;
            
                AutoSelectPartController.insertAndReturnWorkOrderLI(w.id, c.Service_Tag__c, w.AddressBUID__c);
            Test.stopTest();
        
    
    }
    
    public static testMethod void insertAndReturnWorkOrderLItestMethod() {
                //User u30=SRVS_CreateTestDataFactory.createUser('System Administrator');
                Case c =[Select  id,Service_Tag__c from Case where status='In Progress' limit 1];
                WorkOrder w = [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
                    NextGenAutoPartsSelection__x mockrequest = new NextGenAutoPartsSelection__x();
        mockrequest.PartNumber__c = '1234';
        mockrequest.PartPrice__c = '1234';
        mockrequest.PartType__c = 'type';
        mockrequest.ResponseCode__c = '100';
        mockrequest.PartCommodity__c = 'HARD DRIVE';

        
        NextGenAutoPartsSelection__x mockrequest1 = new NextGenAutoPartsSelection__x();
        mockrequest1.PartNumber__c = '1234';
        mockrequest1.PartPrice__c = '1234';
        mockrequest1.PartType__c = 'type';
        mockrequest1.ResponseCode__c = '100';
        mockrequest1.PartCommodity__c = 'HARD DRIVE';
        mockrequest1.DefectiveComponent__c = 'Test';
        mockrequest1.PartDescription__c = 'Test';
        
        NextGenAutoPartsSelection__x mockrequest2 = new NextGenAutoPartsSelection__x();
        mockrequest2.PartNumber__c = partnumber;
        mockrequest2.PartPrice__c = partprice ;
        mockrequest2.PartType__c = partType;
        mockrequest2.ResponseCode__c = '100';
        mockrequest2.PartCommodity__c = partcommodity;
        mockrequest2.DefectiveComponent__c = DefectiveComponent;
        mockrequest2.PartDescription__c = partDescription;
        
        NextGenAutoPartsSelection__x mockrequest3 = new NextGenAutoPartsSelection__x ();
                            mockrequest3.ResponseCode__c ='-103';
                            mockrequest3.ResponseMessage__c ='testing';
                            
                           
                        Test.startTest();
                                 AutoSelectPartController.MockAutoParts.add(mockrequest3);
                            
                            AutoSelectPartController.insertAndReturnWorkOrderLI(w.id, c.Service_Tag__c, w.AddressBUID__c);
                            
                            AutoSelectPartController.MockAutoParts.clear();
                            
                        AutoSelectPartController.MockAutoParts.add(mockrequest);
                AutoSelectPartController.MockAutoParts.add(mockrequest1);
                AutoSelectPartController.MockAutoParts.add(mockrequest2);
                
                        
                            AutoSelectPartController.insertAndReturnWorkOrderLI(w.id, c.Service_Tag__c, w.AddressBUID__c);
                            AutoSelectPartController.addAutoCFIPart(w, 'TestCallType');
                            
                            
                            
                            
                            
                            
                            
                        Test.stopTest();
                    
                
                }
                
                
        public static testmethod void FindSelectedPartstestMethodforSelectedUserequalsfalse() {

        
                   // User u25=SRVS_CreateTestDataFactory.createUser('System Administrator');
                    Case c =[Select  id,Service_Tag__c from Case where status='In Progress' limit 1];
                    WorkOrder w = [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
                   
                        Test.startTest();
                            WorkOrderLineItem updatedworkorderItemList = [Select id from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1];
                            updatedworkorderItemList.Selected_By_user__c = false;
                            update updatedworkorderItemList;
                            List < String > selectedparts = new List < String > ();
                            selectedparts.add('test');
                            AutoSelectPartController.FindSelectedParts(selectedparts, w.id);
                        Test.stopTest();
        }
        
              public static testmethod void FindSelectedPartstestMethod() {

        WorkOrder w = [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
        
        //User u29=SRVS_CreateTestDataFactory.createUser('System Administrator');
        
            Test.startTest();
                List < String > selectedparts = new List < String > ();
                selectedparts.add('HARD DRIVE');
                AutoSelectPartController.FindSelectedParts(selectedparts, w.id);
            Test.stopTest();
        
    }
    
    
    public static testmethod void saveSelectedPartstestMethod() {
        
        WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
        List < WorkOrderLineItem > workorderItemList  = new List<WorkOrderLineItem>([Select id,Selected_Work_Order__c,Work_Order_Id_Text__c,Reason_for_Advanced_Search__c ,PartCommodity__c,WorkOrderId,Selected_By_user__c from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1]);
       List<WorkOrderLineItem> wolistItem = new List<WorkOrderLineitem>();
        
        
            Test.startTest();
                AutoSelectPartController.saveSelectedParts(workorderItemList, 'APS', null,false);
                w.Entitlement_Details__c='Data Recovery';
                update w;
        
                List < WorkOrderLineItem > updatedWorkOrderLineItemlist = DispatchTestSetupData.createworkorderListItem(w.id, 'APS');
                AutoSelectPartController.saveSelectedParts(updatedWorkOrderLineItemlist, 'APS', null,false);
                
                for(WorkOrderLineItem  wo : updatedWorkOrderLineItemlist)
                {
                wo.PartCommodity__c='BATTERY';
                wolistItem.add(wo);
                }
                update wolistItem;
                 AutoSelectPartController.saveSelectedParts(wolistItem, 'APS', null,false);
                
            Test.stopTest();
        
        
    }
    
    public static testMethod void validateSelectedPartstestMethod() {
        
         WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
         
          List < WorkOrderLineItem > workorderItemList  = new List<WorkOrderLineItem>([Select id,PartNumber__c,Selected_Work_Order__c,Work_Order_Id_Text__c,Reason_for_Advanced_Search__c ,PartCommodity__c,WorkOrderId,Selected_By_user__c from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1]);
        
        DispatchDefaults__c dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',
                            PO_Number__c='18458',selected_service_option__c='Available-24x5',OutOfWarranty__c = False, 
                            Service_Configurations__c='XPS Notebooks',SpecialOptions__c='test',Bill_To__c='Customer',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,BasicEntitlement__c=True,
                            OrderNumber__c='124563',Work_Order__c=w.id , AD_Override__c='CSAT', AvailableOptions__c='-',KYHDOption__c=true);
        insert dd;
        
        ValidatePartsBooked__x mockrequest = new ValidatePartsBooked__x();
        mockrequest.PartNumber__c = '1245454534';
        mockrequest.ResponseCode__c = '100';
        mockrequest.ResponseMessage__c = 'type';
        mockrequest.PartsInventoryStatus__c='PART_UNAVAILABLE';
        
                ValidatePartsBooked__x mockrequest1 = new ValidatePartsBooked__x();
        mockrequest1.PartNumber__c = '1245454534';
        mockrequest1.ResponseCode__c = '100';
        mockrequest1.ResponseMessage__c =functionalDescription ;
        mockrequest1.ReturnQuantity__c='34';
        mockrequest1.PartDescription__c=functionalDescription;
        mockrequest1.Price__c=functionalDescription;
        mockrequest1.ItemExists__c='test';
        mockrequest1.AltPartFlag__c='nn';
        mockrequest1.BacklogETA__c='test';
        mockrequest1.PartsInventoryStatus__c='PART_NOT_FOUND';
        
        
        
        
        User u24=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u24){
            Test.startTest();
                AutoSelectPartController.MockAutovalidateParts.add(mockrequest);
                AutoSelectPartController.MockAutovalidateParts.add(mockrequest1);
                
        
                AutoSelectPartController.validateSelectedParts(workorderItemList, true, 'MPS',false);
        
                List < WorkOrderLineItem > updatedworkorderItemList = new List < WorkOrderLineItem > ();
                List < WorkOrderLineItem > newworkorderItemList = new List < WorkOrderLineItem > ([Select id from WorkOrderLineItem where id =: workorderItemList[0].id]);
                for (WorkOrderLineItem wl: newworkorderItemList) {
                    wl.Selected_By_user__c = false;
                    updatedworkorderItemList.add(wl);
                }
        
                update updatedworkorderItemList;
        
                AutoSelectPartController.validateSelectedParts(updatedworkorderItemList, true, 'MPS',false);
        
                delete updatedworkorderItemList;

                AutoSelectPartController.validateSelectedParts(updatedworkorderItemList, true, 'MPS',false);
            Test.stopTest();
        }
    }
    
    public static testMethod void validateSelectedPartstestMethodforAPS() {
       
       WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
         
          List < WorkOrderLineItem > workorderItemList  = new List<WorkOrderLineItem>([Select id,PartNumber__c,Selected_Work_Order__c,Work_Order_Id_Text__c,Reason_for_Advanced_Search__c ,PartCommodity__c,WorkOrderId,Selected_By_user__c from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1]);
        
        DispatchDefaults__c dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',
                            PO_Number__c='18458',selected_service_option__c='Available-24x5',OutOfWarranty__c = False, 
                            Service_Configurations__c='XPS Notebooks',SpecialOptions__c='test',Bill_To__c='Customer',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,BasicEntitlement__c=True,
                            OrderNumber__c='124563',Work_Order__c=w.id , AD_Override__c='CSAT', AvailableOptions__c='-' );
        insert dd;
        
        NextGenPartToShip__x mockrequest = new NextGenPartToShip__x();
        mockrequest.PartNumber__c = '1234';
        mockrequest.ResponseCode__c = '100';
        mockrequest.ResponseMessage__c = 'Testing the response message';
        mockrequest.BacklogETA__c = 'test';
        mockrequest.PartsInventoryStatus__c = 'PART_NOT_FOUND';
    
        NextGenPartToShip__x mockrequest1 = new NextGenPartToShip__x();
        mockrequest1.PartNumber__c = '1234';
        mockrequest1.ResponseCode__c = '100';
        mockrequest1.ResponseMessage__c = 'Testing the response message';
        mockrequest1.BacklogETA__c = 'test';
        mockrequest1.PartsInventoryStatus__c = 'PART_UNAVAILABLE';
        
        NextGenPartToShip__x mockrequest2 = new NextGenPartToShip__x();
        mockrequest2.PartNumber__c = '1234';
        mockrequest2.ResponseCode__c = '100';
        mockrequest2.ResponseMessage__c = 'Testing the response message';
        mockrequest2.BacklogETA__c = 'test';
        mockrequest2.PartsInventoryStatus__c = 'PART_UNAVAILABLE';
         mockrequest2.PartPrice__c = 'Y';
        mockrequest2.PartType__c = 'test';
        mockrequest2.DefectiveComponent__c = 'ttt';
        mockrequest2.Commodity__c = 'YY';
        mockrequest2.SubComponent__c = 'yyy';
        mockrequest2.PartDescription__c = 'uuu';
        mockrequest2.FunctionalDescription__c = 'yyy';
        mockrequest2.FourHour__c = 'ooo';
        mockrequest2.CustomerReplaceableUnit__c = 'y';
        mockrequest2.FieldReplaceableUnit__c = 'i';
        mockrequest2.ServiceBUID__c = 'UUU';
        
        NextGenPartToShip__x mockrequest3 = new NextGenPartToShip__x();
        mockrequest3.PartNumber__c = '5678';
        mockrequest3.ResponseCode__c = '100';
        mockrequest3.ResponseMessage__c = 'Testing the response message';
        mockrequest3.BacklogETA__c = 'test';
        mockrequest3.PartsInventoryStatus__c = 'PART_UNAVAILABLE';
         mockrequest3.PartPrice__c = 'Y';
        mockrequest3.PartType__c = 'test';
        mockrequest3.DefectiveComponent__c = 'ttt';
        mockrequest3.Commodity__c = 'YY';
        mockrequest3.SubComponent__c = 'yyy';
        mockrequest3.PartDescription__c = 'uuu';
        mockrequest3.FunctionalDescription__c = 'yyy';
        mockrequest3.FourHour__c = 'ooo';
        mockrequest3.CustomerReplaceableUnit__c = 'y';
        mockrequest3.FieldReplaceableUnit__c = 'i';
        mockrequest3.ServiceBUID__c = 'UUU';
        
       NextGenPartToShip__x mockrequest4 = new NextGenPartToShip__x();
        mockrequest4.PartNumber__c = '1234';
        mockrequest4.ResponseCode__c = '100';
        mockrequest4.ResponseMessage__c = 'Testing the response message';
        mockrequest4.BacklogETA__c = 'test';
        mockrequest4.PartsInventoryStatus__c = 'PART_UNAVAILABLE';
         mockrequest4.PartPrice__c = 'Y';
        mockrequest4.PartType__c = 'test';
        mockrequest4.DefectiveComponent__c = 'ttt';
        mockrequest4.Commodity__c = 'YY';
        mockrequest4.SubComponent__c = 'yyy';
        mockrequest4.PartDescription__c = partDescription;
        mockrequest4.FunctionalDescription__c = functionalDescription;
        mockrequest4.FourHour__c = 'ooo';
        mockrequest4.CustomerReplaceableUnit__c = 'y';
        mockrequest4.FieldReplaceableUnit__c = 'i';
        mockrequest4.ServiceBUID__c = 'UUU';
        
        
        
       
            Test.startTest();
                AutoSelectPartController.MockAutoNextGenPart.add(mockrequest);
                AutoSelectPartController.MockAutoNextGenPart.add(mockrequest1);
                 AutoSelectPartController.MockAutoNextGenPart.add(mockrequest2);
                 AutoSelectPartController.MockAutoNextGenPart.add(mockrequest3);
                 
                AutoSelectPartController.validateSelectedParts(workorderItemList, true, 'APS',false);
                
                workorderItemList[0].Selected_By_user__c= false;
                
                AutoSelectPartController.validateSelectedParts(workorderItemList, true, 'APS',false);
                
            Test.stopTest();
        
    }
    
    public static testMethod void getSelectedPartstestMethod() {
    
    WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
    List<workOrderLineItem> wolistItem = new List<WorkOrderLineItem>([Select id,Selected_By_user__c from WorkOrderLineItem where Selected_By_user__c=true and WorkOrderId=:w.id limit 5]);
    List<workOrderLineItem> upwolistItem = new List<WorkOrderLineItem>();
    
    for(workOrderLineItem  wl : wolistItem)
    {
    wl.Selected_By_user__c=false; 
    upwolistItem.add(wl);
    }
    update upwolistItem;
    List<Id> wids = new List<id>();
    Set<Id> widset= new Set<Id>();
    wids.add(w.id);
    widset.add(w.id);
    AutoSelectPartController.getSelectedParts(w.id);
    AutoSelectPartController.deleteworkorderLineItems(wids);
    AutoSelectPartController.getserviceType(w.id);
    AutoSelectPartController.deleteParts(widset,upwolistItem);
    }
    
     public static testMethod void validateSelectedPartstestMethodforelseBlock() {
        
         WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
         
          List < WorkOrderLineItem > workorderItemList  = new List<WorkOrderLineItem>([Select id,PartNumber__c,Selected_Work_Order__c,Work_Order_Id_Text__c,Reason_for_Advanced_Search__c ,PartCommodity__c,WorkOrderId,Selected_By_user__c from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1]);
        
        DispatchDefaults__c dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',
                            PO_Number__c='18458',selected_service_option__c='Available-24x5',OutOfWarranty__c = False, 
                            Service_Configurations__c='XPS Notebooks',SpecialOptions__c='test',Bill_To__c='Customer',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,BasicEntitlement__c=True,
                            OrderNumber__c='124563',Work_Order__c=w.id , AD_Override__c='CSAT', AvailableOptions__c='-',KYHDOption__c=true);
        insert dd;
        
        ValidatePartsBooked__x mockrequest = new ValidatePartsBooked__x();
        mockrequest.PartNumber__c = '1245454534';
        mockrequest.ResponseCode__c = '100';
        mockrequest.ResponseMessage__c = 'type';
        mockrequest.PartsInventoryStatus__c='PART_UNAVAILABLE';
        User u24=SRVS_CreateTestDataFactory.createUser('System Administrator');
        system.runAs(u24){
            Test.startTest();
                AutoSelectPartController.MockAutovalidateParts.add(mockrequest);
                AutoSelectPartController.validateSelectedParts(workorderItemList, true, 'MPS',false);
        
               
            Test.stopTest();
        }
    }   
public static testMethod void validateSelectedPartstestMethodforAPSforCatchBlock() {
       
       WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
         
          List < WorkOrderLineItem > workorderItemList  = new List<WorkOrderLineItem>([Select id,PartNumber__c,Selected_Work_Order__c,Work_Order_Id_Text__c,Reason_for_Advanced_Search__c ,PartCommodity__c,WorkOrderId,Selected_By_user__c from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1]);
        
        DispatchDefaults__c dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',
                            PO_Number__c='18458',selected_service_option__c='Available-24x5',OutOfWarranty__c = False, 
                            Service_Configurations__c='XPS Notebooks',SpecialOptions__c='test',Bill_To__c='Customer',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,BasicEntitlement__c=True,
                            OrderNumber__c='124563',Work_Order__c=w.id , AD_Override__c='CSAT', AvailableOptions__c='-' );
        insert dd;
        
       ValidatePartsBooked__x mockrequest = new ValidatePartsBooked__x();
        mockrequest.PartNumber__c = '1234';
        mockrequest.ResponseCode__c = '100';
        mockrequest.ResponseMessage__c = 'type';
        mockrequest.ValidPart__c = 'Y';
        mockrequest.ReturnQuantity__c = '$$';
        mockrequest.ResponseMessage__c = 'The messsage length should be greater than 255. So passing the message which should be greater than 255.....So framing the sentance to be greater than 255.......I think this should be enough for test method to pass....................................................................................................................................................hopefully this should be enough';
        mockrequest.ItemExists__c = 'Y';
        mockrequest.BacklogETA__c = 'test';
        mockrequest.PartsInventoryStatus__c = 'PART_NOT_FOUND';

            Test.startTest();
                  AutoSelectPartController.MockAutovalidateParts.add(mockrequest);
        
                AutoSelectPartController.validateSelectedParts(workorderItemList, true, 'MPS',false);
        
                
            Test.stopTest();
        
    }
    
    public static testMethod void validateSelectedPartstestMethodforMPSforCatchBlock() {
       
       WorkOrder w = [Select Id,AddressBUID__c,Entitlement_Details__c from WorkOrder where AddressBUID__c ='3696' limit 1];
         
          List < WorkOrderLineItem > workorderItemList  = new List<WorkOrderLineItem>([Select id,PartNumber__c,Selected_Work_Order__c,Work_Order_Id_Text__c,Reason_for_Advanced_Search__c ,PartCommodity__c,WorkOrderId,Selected_By_user__c from WorkOrderLineItem where Line_Item_Type__c ='APS' limit 1]);
        
        DispatchDefaults__c dd= new DispatchDefaults__c(Service_Options_Picklist_values__c='NextDay-8x5',Service_Type__c='Parts and Labor',
                            PO_Number__c='18458',selected_service_option__c='Available-24x5',OutOfWarranty__c = False, 
                            Service_Configurations__c='XPS Notebooks',SpecialOptions__c='test',Bill_To__c='Customer',
                            Keep_Your_Components__c=True,DSP_Override_Request__c=True,Bill_To_Order_Number__c='test Order Number',
                            AvailableCoverages__c='|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c=True,BasicEntitlement__c=True,
                            OrderNumber__c='124563',Work_Order__c=w.id , AD_Override__c='CSAT', AvailableOptions__c='-' );
        insert dd;
      NextGenPartToShip__x mockrequest1 = new NextGenPartToShip__x();
        mockrequest1.PartNumber__c = '5678';
        mockrequest1.ResponseCode__c = '100';
        mockrequest1.ResponseMessage__c = 'Testing the response message';
        mockrequest1.BacklogETA__c = 'test';
        mockrequest1.PartsInventoryStatus__c = 'PART_UNAVAILABLE';
        mockrequest1.PartPrice__c = partprice;
        mockrequest1.PartType__c = partType;
        mockrequest1.DefectiveComponent__c = DefectiveComponent;
        mockrequest1.Commodity__c = partcommodity;
        mockrequest1.SubComponent__c = subcomponent;
        mockrequest1.PartDescription__c = partDescription;
        mockrequest1.FunctionalDescription__c = functionalDescription;
        mockrequest1.FourHour__c = fourhours;
        mockrequest1.CustomerReplaceableUnit__c = CRU;
        mockrequest1.FieldReplaceableUnit__c = FRU;
        mockrequest1.ServiceBUID__c = SBUID;
        mockrequest1.BacklogETA__c = 'this string is going to be more than 80 characters long this is going to create an exception scenario  in validateSelectedParts methods so that the correponding catch block can be covered';

            Test.startTest();
                  AutoSelectPartController.MockAutoNextGenPart.add(mockrequest1);
                AutoSelectPartController.validateSelectedParts(workorderItemList, true, 'APS',false);
        
                
            Test.stopTest();
        
    }
    
    public static testMethod void insertAndReturnWorkOrderLItestMethodforCatchBlock() {
                //User u30=SRVS_CreateTestDataFactory.createUser('System Administrator');
                Case c =[Select  id,Service_Tag__c from Case where status='In Progress' limit 1];
                WorkOrder w = [Select Id,AddressBUID__c from WorkOrder where AddressBUID__c ='3696' limit 1];
                    NextGenAutoPartsSelection__x mockrequest = new NextGenAutoPartsSelection__x();
        mockrequest.PartNumber__c = '1234';
        mockrequest.PartPrice__c = '1234';
        mockrequest.PartType__c = 'type';
        mockrequest.ResponseCode__c = '100';
        mockrequest.PartCommodity__c = 'HARD DRIVE';
        
        NextGenAutoPartsSelection__x mockrequest1 = new NextGenAutoPartsSelection__x();
        mockrequest1.PartNumber__c = '1234';
        mockrequest1.PartPrice__c = '1234';
        mockrequest1.PartType__c = 'type';
        mockrequest1.ResponseCode__c = '100';
        mockrequest1.PartCommodity__c = 'HARD DRIVE';
        mockrequest1.DefectiveComponent__c = 'Test';
                  
                       Test.startTest();
                                 AutoSelectPartController.MockAutoParts.add(mockrequest);
                                 AutoSelectPartController.MockAutoParts.add(mockrequest1);
                            
                            AutoSelectPartController.insertAndReturnWorkOrderLI('', c.Service_Tag__c, w.AddressBUID__c);
                            
                        Test.stopTest();
                    
                
                }
}