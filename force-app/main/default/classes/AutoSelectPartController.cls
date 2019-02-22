/*======================================================================================================================+
|  HISTORY                                                                  
|                                                                           
|  DATE            DEVELOPER                  WR/DEFECT        DESCRIPTION                               
|  ====            =========                 =========        =========== 
| 05/04/2018       Prakhar/Megha/Dattaa1     4338412          Auto Parts Selection - List of Pof and Defective Components.
| 05/04/2018       Prakhar/Megha/Dattaa1     4905886          Dispatch: Auto Parts Selection - Get Parts
+======================================================================================================================*/
/*======================================================================================================================+
|  Test Class(es) Covering this class                                                                  
|      DispatchautoPartSelection_Test                                                                         
|      DispatchTestSetupData
+======================================================================================================================*/

public class AutoSelectPartController
{
    
    @TestVisible public static List<NextGenPartToShip__x> MockAutoNextGenPart= new List<NextGenPartToShip__x>();
    @TestVisible public static List<ValidatePartsBooked__x> MockAutovalidateParts= new List<ValidatePartsBooked__x>();//This List will mock the creation of External Object Data for validateParts
    @TestVisible public static List<NextGenAutoPartsSelection__x> MockAutoParts= new List<NextGenAutoPartsSelection__x>();//This List will mock the creation of External Object Data
    //public static String serviceTag;
    //public static String addressBUID;
    //public static String workOrderId;
    Public static List<workOrder> workOrderDetails= new List<workOrder>();
    
    public class AutoSelectPartWrapper
    {
        @Auraenabled public Boolean isSelected;
        @Auraenabled  public String PartCommodityDef;
        @Auraenabled  public String PartCommodityPof;
        @Auraenabled  public String responseMessage;
    }
    /*
workorderLineItemWrapper will be used as a container for the list of parts
*/
    public class workorderLineItemWrapper{
        @Auraenabled public Boolean isSelected;
        @Auraenabled  public WorkOrderLineItem WorkOrderLineItemVal;
        @Auraenabled  public String responseMessage;
        
    }
    @AuraEnabled
    public static String getserviceType(Id workOrderId){
        if(workOrderId!=null){
            list<workOrder>workOrderDetails=[select id,Service_Type__c from workOrder where id=:workOrderId];
            //list<DispatchDefaults__c>dispatchDetails=[select id,Service_Type__c from DispatchDefaults__c where Work_Order__c =:workOrderId limit 1];
            if(!workOrderDetails.isempty() && workOrderDetails[0].Service_Type__c!=null){
                return workOrderDetails[0].Service_Type__c;
            }
        }
        return null;
    }
    /*
insertAndReturnWorkOrderLI will be invoked from the Lightning component c:DispatchAutoPartSelection
insertAndReturnWorkOrderLI Method will consume WorkOrder Id and related attributes and insert Work Order Line Items for the first time
External Odata call to NextGenAutoPartsSelection__X
return the list of Commodity
*/
    @AuraEnabled
    public static List<AutoSelectPartWrapper> insertAndReturnWorkOrderLI(String workOrderIds, String serviceTag, String addressBUID){
        
        List<WorkOrderLineItem> workorderLineItemList= new List<WorkOrderLineItem>();//list of all WorkOrderLineItems for this WorkOrder
        List<WorkOrderLineItem> existingWorkOrderLineItemList= new List<WorkOrderLineItem>();
        List<AutoSelectPartWrapper> autoselectwraplist= new List<AutoSelectPartWrapper>();//this list will be returned
        Set<string> uniqueCommoditiesSet=new Set<string>();//unique set of commodities
        Boolean doOdataCall=true;
        
        if(workorderIds!=null && workorderIds!='' ){
            existingWorkOrderLineItemList=[Select Id,Line_Item_Type__c,PartNumber__c,PointsOfFailure__c,PartCommodity__c,Selected_By_user__c,DefectiveComponent__c from WorkOrderLineItem where WorkOrderId=:workorderIds and Line_Item_Type__c='APS' limit 50000];//add all the fields that needs to be diplayed in UI here
        }
        
        if(!existingWorkOrderLineItemList.isempty()){
            for(WorkOrderLineItem wrl: existingWorkOrderLineItemList){
                if(wrl.Line_Item_Type__c==System.Label.Dispatch_APS && !wrl.Selected_By_user__c){
                    doOdataCall=false;
                    break;
                }
            }
        }
        
        List<WorkOrder> wolist = new List<WorkOrder>([Select CountryCode__c,Asset.Name,DPS_BUID__C from WorkOrder where Id=:workOrderIds limit 1]);
        
        if(doOdataCall){
            try
            {
                List<NextGenAutoPartsSelection__x>partsList=new List<NextGenAutoPartsSelection__x>();
                //if(!Test.isRunningTest()){
                    //partsList=[select PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c from NextGenAutoPartsSelection__X where ServiceTag__c='7PLB342' and ServiceBUID__c='3696' and FourHour__c='' and CountryCode__c='US'];// hardcoded values for data availablablites
                    partsList=(!MockAutoParts.isEmpty()) ? MockAutoParts :[select PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,SubComponent__c,PartDescription__c,FunctionalDescription__c,FourHour__c,CustomerReplaceableUnit__c,FieldReplaceableUnit__c,
                                                                           ServiceBUID__c,PointsOfFailure__c,ResponseCode__c,ResponseMessage__c,DefectiveComponent__c,RepairType__c from NextGenAutoPartsSelection__X where ServiceTag__c=:wolist[0].Asset.Name and ServiceBUID__c=:woList[0].DPS_BUID__C 
                                                                           and FourHour__c='N' and CountryCode__c=:woList[0].CountryCode__c LIMIT 50000];// hardcoded values for FourHour__c,CountryCode__c data availablablites
                //}
                /*
                if(Test.isRunningTest()){
                    partsList.addall(MockAutoParts);
                }
                */
                if(!partsList.isempty()){
                    List<WorkOrder> workorderlist = new List<workOrder>();
                    workorderlist=[Select ID,AssetId,CFI_Exists__c from WorkOrder where Id=:workOrderIds LIMIT 1];
                    
                    for(NextGenAutoPartsSelection__x nextGen :partslist)
                    {
                        if(nextGen.ResponseCode__c=='100' && nextGen.DefectiveComponent__c!=null){
                            WorkOrderLineItem objWorkorderLineItem = new WorkOrderLineItem();
                            objWorkorderLineItem.WorkOrderId = workOrderIds;
                            objWorkorderLineItem.AssetId=workorderlist[0].AssetId;
                            objWorkorderLineItem.CFI_on_Work_Order__c = workorderlist[0].CFI_Exists__c;
                            if(nextGen.PartNumber__c!=null && nextGen.PartNumber__c!='' && nextGen.PartNumber__c.length()>127){
                                objWorkorderLineItem.PartNumber__c = nextGen.PartNumber__c.substring(0,127);
                            }
                            else{
                                objWorkorderLineItem.PartNumber__c = nextGen.PartNumber__c;
                            }
                            if(nextGen.PartPrice__c!=null && nextGen.PartPrice__c!='' && nextGen.PartPrice__c.length()>127){
                                objWorkorderLineItem.PartPrice__c = nextGen.PartPrice__c.substring(0,127);
                            }
                            else{
                                objWorkorderLineItem.PartPrice__c = nextGen.PartPrice__c;
                            }
                            if(nextGen.PartType__c!=null && nextGen.PartType__c!='' && nextGen.PartType__c.length()>127){
                                objWorkorderLineItem.PartType__c = nextGen.PartType__c.substring(0,127);
                            }
                            else{
                                objWorkorderLineItem.PartType__c = nextGen.PartType__c;
                            }
                            if(nextGen.DefectiveComponent__c!=null && nextGen.DefectiveComponent__c!='' && nextGen.DefectiveComponent__c.length()>255){
                                objWorkorderLineItem.DefectiveComponent__c = nextGen.DefectiveComponent__c.substring(0,255).replace(',','').replace('\'',' ').replace('"',' ');
                            }
                            else{
                                if(nextGen.DefectiveComponent__c!=null){
                                    objWorkorderLineItem.DefectiveComponent__c = nextGen.DefectiveComponent__c.replace(',','').replace('\'',' ').replace('"',' ') ;
                                }
                            }
                            if(nextGen.PartCommodity__c!=null && nextGen.PartCommodity__c!='' && nextGen.PartCommodity__c.length()>127){
                                objWorkorderLineItem.PartCommodity__c = nextGen.PartCommodity__c.substring(0,127).replaceall(',','');
                            }
                            else{
                                objWorkorderLineItem.PartCommodity__c = nextGen.PartCommodity__c;
                            }
                            if(nextGen.SubComponent__c!=null && nextGen.SubComponent__c!='' && nextGen.SubComponent__c.length()>127){
                                objWorkorderLineItem.SubComponent__c = nextGen.SubComponent__c.substring(0,127);
                            }
                            else{
                                objWorkorderLineItem.SubComponent__c = nextGen.SubComponent__c;
                            }
                            if(nextGen.PartDescription__c!=null && nextGen.PartDescription__c!='' && nextGen.PartDescription__c.length()>254){
                                objWorkorderLineItem.PartDescription__c = nextGen.PartDescription__c.substring(0,254);
                            }
                            else{
                                objWorkorderLineItem.PartDescription__c = nextGen.PartDescription__c;
                            }
                            if(nextGen.FunctionalDescription__c!=null && nextGen.FunctionalDescription__c!='' && nextGen.FunctionalDescription__c.length()>254){
                                objWorkorderLineItem.FunctionalDescription__c = nextGen.FunctionalDescription__c.substring(0,254);
                            }
                            else{
                                objWorkorderLineItem.FunctionalDescription__c = nextGen.FunctionalDescription__c;
                            }
                            if(nextGen.FourHour__c!=null && nextGen.FourHour__c!='' && nextGen.FourHour__c.length()>4){
                                objWorkorderLineItem.FourHour__c = nextGen.FourHour__c.substring(0,4);
                            }
                            else{
                                objWorkorderLineItem.FourHour__c = nextGen.FourHour__c;
                            }
                            if(nextGen.CustomerReplaceableUnit__c!=null && nextGen.CustomerReplaceableUnit__c!='' && nextGen.CustomerReplaceableUnit__c.length()>4){
                                objWorkorderLineItem.CustomerReplaceableUnit__c = nextGen.CustomerReplaceableUnit__c.substring(0,4);
                            }
                            else{
                                objWorkorderLineItem.CustomerReplaceableUnit__c = nextGen.CustomerReplaceableUnit__c;
                            }
                            if(nextGen.FieldReplaceableUnit__c!=null && nextGen.FieldReplaceableUnit__c!='' && nextGen.FieldReplaceableUnit__c.length()>4){
                                objWorkorderLineItem.FieldReplaceableUnit__c  = nextGen.FieldReplaceableUnit__c.substring(0,4) ;
                            }
                            else{
                                objWorkorderLineItem.FieldReplaceableUnit__c  = nextGen.FieldReplaceableUnit__c;
                            }
                            if(nextGen.ServiceBUID__c !=null && nextGen.ServiceBUID__c !='' && nextGen.ServiceBUID__c.length()>78){
                                objWorkorderLineItem.ServiceBUID__c = nextGen.ServiceBUID__c.substring(0,78);
                            }
                            else{
                                objWorkorderLineItem.ServiceBUID__c = nextGen.ServiceBUID__c;
                            }
                            if(nextGen.RepairType__c !=null && nextGen.RepairType__c !='' && nextGen.RepairType__c.length()>78){
                                objWorkorderLineItem.RepairType__c = nextGen.RepairType__c.substring(0,78);
                            }
                            else{
                                objWorkorderLineItem.RepairType__c = nextGen.RepairType__c;
                            }
                            objWorkorderLineItem.Line_Item_Type__c=System.Label.Dispatch_APS;
                            objWorkorderLineItem.SelectionReason__c='';
                            if(nextGen.PointsOfFailure__c!=null && nextGen.PointsOfFailure__c!='' && nextGen.PointsOfFailure__c.length()>127){
                                objWorkorderLineItem.PointsOfFailure__c=nextGen.PointsOfFailure__c.substring(0,127);
                            }
                            else{
                                objWorkorderLineItem.PointsOfFailure__c=nextGen.PointsOfFailure__c;
                            }
                            //objWorkorderLineItem.ServiceTag__c = nextGen.ServiceTag__c;
                            //objWorkorderLineItem.External_Id__c=String.valueof(workOrderIds).substring(0,15)+'_'+nextGen.PartNumber__c;
                            objWorkorderLineItem.External_Id__c=String.valueof(workOrderIds)+nextGen.PartNumber__c;
                            
                            workorderLineItemList.add(objWorkorderLineItem);
                        }
                    }
                    if(workorderLineItemList.isempty()){
                        AutoSelectPartWrapper a=  new AutoSelectPartWrapper();
                        a.isSelected = false;
                        a.PartCommodityDef=null;
                        a.PartCommodityPof=null;
                        a.responseMessage=partslist[0].ResponseMessage__c ;
                        autoselectwraplist.add(a);
                        return autoselectwraplist;
                    }
                }
            }
            catch(exception ex){
                List<AutoSelectPartWrapper> autoselectwraplisterror = errormethod(ex);
                return autoselectwraplisterror;
            }
        }  
        if(!workorderLineItemList.isempty()){
            try{
                
                //Database.upsert(workorderLineItemList, workorderLineItem.External_Id__c.getDescribe().getSObjectField(),false);
                //upsert workorderLineItemList External_Id__c;
                //
                AsyncCreateParts aCP = new AsyncCreateParts(workorderLineItemList);
                Id jobId = system.enqueueJob(aCP);
            }
            catch(exception ex){
               
                return errormethod(ex);
            }
            
        }
        if(!existingWorkOrderLineItemList.isempty()){
            workorderLineItemList.addall(existingWorkOrderLineItemList);
        }
        if(!workorderLineItemList.isempty()){
            for(workorderLineItem wo : workorderLineItemList){
                if(!uniqueCommoditiesSet.contains(wo.DefectiveComponent__c)){
                    AutoSelectPartWrapper a=  new AutoSelectPartWrapper();
                    a.isSelected = false;
                    a.PartCommodityDef=wo.DefectiveComponent__c;
                    a.responseMessage=System.Label.Dispatch_success ;
                    autoselectwraplist.add(a);
                    uniqueCommoditiesSet.add(wo.DefectiveComponent__c);
                }
            }
            
        }
        return autoselectwraplist;
    }
    /*
FindSelectedParts will be invoked from the Lightning component c:DispatchAutoPartSelection
FindSelectedParts Method will consume WorkOrder Id and selected Commodities
Need to check if already selected parts there.
return the list of parts
*/
    @AuraEnabled
    public static List<workorderLineItemWrapper> FindSelectedParts(List<string>selectedList, string WorkOrderId){
      
        List<workorderLineItemWrapper> workorderLineItemWraplist= new List<workorderLineItemWrapper>();
        List<workorderLineItem> existingWorkOrderLineItem=new List<workorderLineItem>();
        List <workorderLineItem> partslist =new List <workorderLineItem>();
        
        if(WorkOrderId!=null && WorkOrderId!=''){
            if(!selectedList.isempty()){
                partslist= [select Id,PartNumber__c,PartPrice__c,PartType__c,URLLink__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,External_Id__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,FieldReplaceableUnit__c,WorkOrderId,Selected_Work_Order__c,ServiceBUID__c,ServiceTag__c,Valid_Parts__c,Part_Quantity__c,Validate_Parts_Response__c,Return_Qty__c,ItemExists__c,Image_Url__c,DefectiveComponent__c,InventoryStatus__c,Line_Item_Type__c,Warning_Message__c, CFI_on_Work_Order__c from workorderLineItem where WorkOrderId=:WorkOrderId and DefectiveComponent__c in :selectedList and Line_Item_Type__c in ('APS','APS-Also ship') order by PartCommodity__c LIMIT 50000];
                
                for(workOrderLineItem wrl: partslist){
                    workorderLineItemWrapper a=  new workorderLineItemWrapper();
                    a.isSelected = wrl.Selected_By_user__c;
                    a.WorkOrderLineItemVal=wrl;
                    workorderLineItemWraplist.add(a);
                }
            }
            
        }
        return workorderLineItemWraplist;
    }
    /*
    validateSelectedParts will be invoked from the Lightning component c:DispatchAutoPartSelection
    validateSelectedParts will validate the selected line Items and check the flag Valid_Parts__c, for valid parts
    */
    @AuraEnabled
    public static List<workorderLineItemWrapper> validateSelectedParts(List<workorderLineItem>selectedParts, Boolean EditRec, String callType, Boolean addCFIAutoPart){
       
        List<workorderLineItemWrapper> selectedWorkorderLineItemWraplist= new List<workorderLineItemWrapper>();
        List<DispatchDefaults__c>defaultValues =new List<DispatchDefaults__c>();
        //List<WorkorderLineItem> objWorkorderLineItemList=new List<WorkorderLineItem>();//save parts//-Commented by Harsha  - [Jan 8th 2019]
        Set<string>selectedPartsPartNumber=new Set<string>();
        Set<Id>alsoShipId=new Set<Id>();
        
        if(!selectedParts.isempty()){
            //storing the part Number of the existing Parts
            for(WorkorderLineItem wol: selectedParts){
                selectedPartsPartNumber.add(wol.PartNumber__c);
            }
            defaultValues = [SELECT Id, Service_Options_Picklist_values__c,Billable__c, Entitlement_Details__c, Service_Type__c, PO_Number__c, selected_service_option__c, OutOfWarranty__c,
                             category__c, Service_Configurations__c, SpecialOptions__c, Bill_To__c, Keep_Your_Components__c, DSP_Override_Request__c,AD_Override__c,
                             AvailableCoverages__c,AvailableOptions__c,CompleteCareOption__c,AD_Coverage_Flag__c,Complete_Care_Option__c,OrderNumber__c, Work_Order__r.KYHD__c,
                             Bill_To_Order_Number__c,KYHDOption__c,PartsCountry__c, BUID__c, ServiceHours__c, LaborCountry__c, ServiceLevel__c, Default_Service_Type__c,Work_Order__r.City,Work_Order__r.State,
                             Work_Order__r.SLAStartDate__c, Work_Order__r.SLAEndDate__c, Work_Order__r.Service_Option__c, Work_Order__r.Country, Work_Order__r.PostalCode,Work_Order__r.CountryCode,
                             Work_Order__r.WorkOrderNumber,Work_Order__r.ServiceTag__c,Work_Order__r.CityCalc__c, Work_order__r.StateCalc__c
                             FROM DispatchDefaults__c
                             WHERE Work_Order__c =: selectedParts[0].workOrderId LIMIT 1
                            ];
            
            if(workOrderDetails.isempty() ){
                
                workOrderDetails=[Select Id, Entitlement_Details__c,KYHD__c, Out_of_Warranty__c,Ground_Shipment_Flag__c,CountryCode,Override_Ground_Shipment__c,CFI_Exists__c from workOrder where Id= :selectedParts[0].WorkOrderId Limit 1 ];
            }
           
            if(callType=='MPS'){
                for(workorderLineItem wl: selectedParts){
                    if(wl.Selected_By_user__c){
                        
                        //wl.Selected_Work_Order__c=wl.WorkOrderId;
                        try{
                            list<ValidatePartsBooked__x> validatedParts = new list<ValidatePartsBooked__x>();
                            
                           if(!Test.isRunningTest()){
                                if(wl.ServiceBUID__c != null &&  wl.ServiceBUID__c != '' &&  wl.PartNumber__c != null &&  wl.PartNumber__c != ''
                                   &&  wl.Part_Quantity__c != null &&  wl.Part_Quantity__c != '' &&  wl.ServiceTag__c != null && wl.ServiceTag__c != '' && defaultValues !=null){
                                       //validatedParts = [SELECT ItemExists__c, PartNumber__c,ReturnQuantity__c, ValidPart__c, ResponseCode__c, ResponseMessage__c,PartsInventoryStatus__c FROM ValidatePartsBooked__x WHERE AddressBUID__c = :wl.ServiceBUID__c AND PartNumber__c = :wl.PartNumber__c  AND OrderQuantity__c =:wl.Part_Quantity__c AND ServiceTag__c =:wl.ServiceTag__c limit 1];
                                       validatedParts = (!MockAutovalidateParts.isEmpty()) ? MockAutovalidateParts : [SELECT ItemExists__c,PartsInventoryStatus__c, PartNumber__c,ReturnQuantity__c, ValidPart__c,BacklogETA__c, TrainingURL__c, RepairType__c, ResponseCode__c, ResponseMessage__c,AltPartFlag__c,PartDescription__c,Price__c
                                                         FROM ValidatePartsBooked__x WHERE AddressBUID__c = :defaultValues[0].BUID__c AND PostalCode__c = :defaultValues[0].Work_Order__r.PostalCode  AND Billable__c =:defaultValues[0].Billable__c AND ServiceType__c=:defaultValues[0].Default_Service_Type__c  AND ISOCountryCode__c=:defaultValues[0].Work_Order__r.CountryCode AND SystemClassification__c= :defaultValues[0].SpecialOptions__c AND City__c=:defaultValues[0].Work_Order__r.CityCalc__c AND State__c= :defaultValues[0].Work_Order__r.State AND PartNumber__c=:wl.PartNumber__c AND  ServiceTag__c=:wl.ServiceTag__c AND OrderQuantity__c=:wl.Part_Quantity__c AND CompleteCare__c=:defaultValues[0].Complete_Care_Option__c ? 'Y' : 'N'  AND KYHD__c = :defaultValues[0].Work_Order__r.KYHD__c ? 'Y' : 'N' AND ServiceHours__c =: defaultValues[0].ServiceHours__c AND ServiceLevel__c= : defaultValues[0].ServiceLevel__c];
                                      }
                                else{
                                    workorderLineItemWrapper a=  new workorderLineItemWrapper();
                                    a.isSelected =false;
                                    a.WorkOrderLineItemVal=null;
                                    a.responseMessage= 'Insufficient data. Please populate Service BUID, Part Number, Quantity and Service Tag on the dispatch record.';
                                    selectedWorkorderLineItemWraplist.add(a);
                                    return selectedWorkorderLineItemWraplist;
                                }
                           }  
                            
                            if(Test.isRunningTest()){
                                validatedParts.addall(MockAutovalidateParts);
                            }
                            
                            
                            /*else{
validatedParts = [SELECT ItemExists__c,PartsInventoryStatus__c, PartNumber__c,ReturnQuantity__c, ValidPart__c,BacklogETA__c, ResponseCode__c, ResponseMessage__c
FROM ValidatePartsBooked__x 
WHERE AddressBUID__c = :defaultValues[0].BUID__c AND PostalCode__c = :defaultValues[0].Work_Order__r.PostalCode  
AND Billable__c =:defaultValues[0].Billable__c AND ServiceType__c=:defaultValues[0].Default_Service_Type__c  AND ISOCountryCode__c=:defaultValues[0].Work_Order__r.CountryCode 
AND SystemClassification__c= :defaultValues[0].SpecialOptions__c AND City__c=:defaultValues[0].Work_Order__r.City AND State__c= :defaultValues[0].Work_Order__r.State 
AND PartNumber__c=:wl.PartNumber__c AND  ServiceTag__c=:wl.ServiceTag__c AND OrderQuantity__c=:wl.Part_Quantity__c AND CompleteCare__c=:defaultValues[0].Complete_Care_Option__c ? 'Y' : 'N' 
AND KYHD__c = :defaultValues[0].Work_Order__r.KYHD__c ? 'Y' : 'N' AND ServiceHours__c =: defaultValues[0].ServiceHours__c AND ServiceLevel__c= : defaultValues[0].ServiceLevel__c
];
//AND AltPartFlag__c ='Y' AND ServiceHours__c='24x7' AND ServiceLevel__c='4 Hour' ReturnQuantity__c='1' AND CompleteCare__c=:defaultValues[0].Complete_Care_Option__c AND KYHD__c='N'

}*/
                            
                            
                            if(!validatedParts.isempty() ){
                                
                                if(validatedParts[0].ResponseCode__c=='100'){
                                    wl.Valid_Parts__c=true;
                                    wl.Validate_Parts_Response__c = validatedParts[0].ResponseMessage__c;
                                    wl.ItemExists__c=validatedParts[0].ItemExists__c;
                                    wl.ISP_Training_URL__c = validatedParts[0].TrainingURL__c;
                                    wl.RepairType__c = validatedParts[0].RepairType__c;
                                    
                                    if(validatedParts[0].ReturnQuantity__c!=null && validatedParts[0].ReturnQuantity__c!='')
                                        wl.Return_Qty__c=Integer.valueOf(validatedParts[0].ReturnQuantity__c);
                                    else
                                        wl.Return_Qty__c=0;
                                    wl.Valid_Parts__c=true;
                                    
                                    if(validatedParts[0].ResponseMessage__c.length() >254)
                                        wl.Validate_Parts_Response__c = validatedParts[0].ResponseMessage__c.substring(0,254);
                                    else
                                        wl.Validate_Parts_Response__c = validatedParts[0].ResponseMessage__c;
                                    if( String.isempty(wl.PartDescription__c )){    
                                        if(validatedParts[0].PartDescription__c !=null && validatedParts[0].PartDescription__c !='' && validatedParts[0].PartDescription__c.length()>254)
                                            wl.PartDescription__c = validatedParts[0].PartDescription__c.substring(0,254);
                                        else
                                            wl.PartDescription__c = validatedParts[0].PartDescription__c;
                                    }
                                    if( String.isempty(wl.PartPrice__c )){
                                        if(validatedParts[0].Price__c !=null && validatedParts[0].Price__c !='' && validatedParts[0].Price__c.length()>128)
                                            wl.PartPrice__c = validatedParts[0].Price__c.substring(0,128);
                                        else
                                            wl.PartPrice__c = validatedParts[0].Price__c;
                                    }
                                    if(validatedParts[0].ItemExists__c!=null && validatedParts[0].ItemExists__c!='')
                                        wl.ItemExists__c=validatedParts[0].ItemExists__c;
                                    else
                                        wl.ItemExists__c='N';
                                    if(validatedParts[0].ReturnQuantity__c!=null && validatedParts[0].ReturnQuantity__c!='')
                                        wl.Return_Qty__c=Integer.valueOf(validatedParts[0].ReturnQuantity__c);
                                    else
                                        wl.Return_Qty__c=0;
                                    if(validatedParts[0].AltPartFlag__c !=null && validatedParts[0].AltPartFlag__c !='' && validatedParts[0].AltPartFlag__c.length()>1)
                                        wl.Use_Alt_Part_Flag__c = validatedParts[0].AltPartFlag__c.substring(0,1);
                                    else
                                        wl.Use_Alt_Part_Flag__c = validatedParts[0].AltPartFlag__c;
                                    if(validatedParts[0].BacklogETA__c!=null && !string.valueof(validatedParts[0].BacklogETA__c).containsignorecase('null')){
                                        wl.BacklogETA__c=validatedParts[0].BacklogETA__c;
                                    }
                                    if(validatedParts[0].PartsInventoryStatus__c ==''){
                                        wl.InventoryStatus__c='PART_AVAILABLE';
                                    }
                                    wl.Warning_Message__c=null;
                                    if((validatedParts[0].PartsInventoryStatus__c !=null && validatedParts[0].PartsInventoryStatus__c !='')){
                                       
                                        wl.InventoryStatus__c=validatedParts[0].PartsInventoryStatus__c;
                                        if(wl.InventoryStatus__c!=null && wl.InventoryStatus__c!='' && wl.InventoryStatus__c.containsignorecase('PART_NOT_FOUND')){
                                            wl.Warning_Message__c='Part '+wl.PartNumber__c+' status is unknown, and the work order may be affected.';
                                        }
                                        if(wl.InventoryStatus__c!=null && wl.InventoryStatus__c!='' && wl.InventoryStatus__c.containsignorecase('PART_UNAVAILABLE')){
                                            
                                            wl.Warning_Message__c='Part '+ wl.PartNumber__c +' status is unavailable, and the work order may be affected.';
                                        }
                                    }
                                    if(!workOrderDetails.isempty()){
                                        
                                        if (!workOrderDetails[0].Out_of_Warranty__c) // DEFECT 5207765
                                        {    
                                            if(((wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && (wl.PartCommodity__c.containsIgnoreCase('HARD DRIVE') || wl.PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE'))) || (wl.SubComponent__c!=null && wl.SubComponent__c!='' && (wl.SubComponent__c.containsIgnoreCase('HARD DRIVE') || wl.SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE')))) ){
                                                
                                                if(workOrderDetails[0].KYHD__c){
                                                    if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('T0909')) || string.isBlank(wl.Warning_Message__c) )
                                                        wl.Warning_Message__c+=' | Part Numbers T0909 & D2359 will be added automatically.';
                                                }
                                                if(workOrderDetails[0].Entitlement_Details__c!=null && workOrderDetails[0].Entitlement_Details__c!='' && workOrderDetails[0].Entitlement_Details__c.containsIgnoreCase('Data Recovery')){
                                                    if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('P980X')) || string.isBlank(wl.Warning_Message__c) )
                                                        wl.Warning_Message__c+=' | Part Number P980X will be added automatically.';
                                                }
                                                if(workOrderDetails[0].Entitlement_Details__c!=null && workOrderDetails[0].Entitlement_Details__c!='' && workOrderDetails[0].Entitlement_Details__c.containsIgnoreCase('Data Destruction')){
                                                    if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('U705H')) || string.isBlank(wl.Warning_Message__c) )
                                                        wl.Warning_Message__c+=' | Part Number U705H will be added automatically.';
                                                }
                                            }
                                        }
                                        
                                    }
                                    if(wl.Warning_Message__c!=null && wl.Warning_Message__c!=''){
                                        wl.Warning_Message__c=wl.Warning_Message__c.replace('null','');
                                    }
                                }
                            }
                        }
                        catch(exception ex){
                           
                            if(ex.getmessage().length() > 254)
                                wl.Validate_Parts_Response__c =ex.getmessage().substring(0,254);
                            else
                                wl.Validate_Parts_Response__c =ex.getmessage(); 
                            workorderLineItemWrapper a=  new workorderLineItemWrapper();
                            a.isSelected =false;
                            a.WorkOrderLineItemVal=null;
                            a.responseMessage=ex.getmessage();
                            selectedWorkorderLineItemWraplist.add(a);
                            return selectedWorkorderLineItemWraplist;
                        }
                        workorderLineItemWrapper a=  new workorderLineItemWrapper();
                        a.isSelected = wl.Selected_By_user__c;
                        a.WorkOrderLineItemVal=wl;
                        a.responseMessage=System.Label.Dispatch_success;
                        selectedWorkorderLineItemWraplist.add(a);
                    }
                    else {
                        wl.Selected_Work_Order__c=null;
                    }
                }
            }
            //change for APS starts
            else{
                system.debug('addCFIAutoPart ###'+addCFIAutoPart);
                for(workorderLineItem wl: selectedParts){
                    if(wl.Selected_By_user__c){
                        
                        //wl.Selected_Work_Order__c=wl.WorkOrderId;
                        try{
                            list<NextGenPartToShip__x > validatedParts = new list<NextGenPartToShip__x>();
                            if(!Test.isRunningTest()){
                                validatedParts = (!MockAutoNextGenPart.isEmpty()) ? MockAutoNextGenPart : [SELECT AlsoShip__c,AltPartFlag__c,AssetAge__c,AssociatedPartNumber__c,BacklogETA__c,BasePart__c,Billable__c,City__c,Commodity__c,CompleteCare__c,CountryCode__c,CustomerReplaceableUnit__c,DefectiveComponent__c,DisplayUrl,EndOfLife__c,ExternalId,FieldReplaceableUnit__c,FourHour__c,FunctionalDescription__c,Id,ISPSanbaoFlag__c,KoreaMonitorRequest__c, KYHD__c,LastOnHandUpdate__c,LoggedUser__c,Options__c,OriginalPartNumber__c,PartDescription__c,PartNumber__c,PartPrice__c,PartsInventoryStatus__c,PartType__c,PostalCode__c,ReasonCode__c,RepairTime__c,RepairType__c,ResponseCode__c,ResponseMessage__c,ROHS__c,SelectionReason__c,ServiceBUID__c,ServiceHours__c,ServiceKit__c,ServiceLevel__c,ServiceSubType__c,ServiceTag__c,State__c,SubComponent__c,SystemClassification__c,TechSupportMessage__c,TechSupportOrderable__c,TrainingURL__c,ValidPart__c  FROM NextGenPartToShip__x WHERE ServiceBUID__c = :defaultValues[0].BUID__c  AND ServiceHours__c =: defaultValues[0].ServiceHours__c AND Billable__c =:defaultValues[0].Billable__c AND SystemClassification__c= :defaultValues[0].SpecialOptions__c AND City__c=:defaultValues[0].Work_Order__r.CityCalc__c AND ServiceLevel__c= : defaultValues[0].ServiceLevel__c AND State__c= :defaultValues[0].Work_Order__r.StateCalc__c AND CompleteCare__c=:defaultValues[0].Complete_Care_Option__c ? 'Y' : 'N' AND PartNumber__c=:wl.PartNumber__c AND OriginalPartNumber__c = :wl.PartNumber__c AND ServiceTag__c=:defaultValues[0].Work_Order__r.ServiceTag__c AND ServiceSubType__c=:defaultValues[0].Service_Type__c AND CountryCode__c = :defaultValues[0].Work_Order__r.CountryCode];
                            }
                            if(Test.isRunningTest())
                            {
                                validatedParts.addall(MockAutoNextGenPart); 
                            }
                            
                            if(!validatedParts.isempty() ){
                                
                                if(validatedParts[0].ResponseCode__c=='100'){
                                    for( NextGenPartToShip__x  valparts : validatedParts){
                                        if(valparts.PartNumber__c==wl.PartNumber__c){
                                            wl.Valid_Parts__c=true ;
                                            wl.Validate_Parts_Response__c = validatedParts[0].ResponseMessage__c;
                                            wl.ItemExists__c='Y';
                                            wl.ISP_Training_URL__c = validatedParts[0].TrainingURL__c;
                                            wl.RepairType__c = validatedParts[0].RepairType__c;
                                            
                                            if(validatedParts[0].ResponseMessage__c.length() >254)
                                                wl.Validate_Parts_Response__c = valparts.ResponseMessage__c.substring(0,254);
                                            else
                                                wl.Validate_Parts_Response__c = valparts.ResponseMessage__c;
                                            if(valparts.AltPartFlag__c !=null && valparts.AltPartFlag__c !='' && valparts.AltPartFlag__c.length()>1)
                                                wl.Use_Alt_Part_Flag__c = valparts.AltPartFlag__c.substring(0,1);
                                            else
                                                wl.Use_Alt_Part_Flag__c = valparts.AltPartFlag__c;
                                            if(valparts.BacklogETA__c!=null && !string.valueof(valparts.BacklogETA__c).containsignorecase('null')){
                                                wl.BacklogETA__c=valparts.BacklogETA__c;
                                            }
                                            if( String.isempty(wl.PartDescription__c )){
                                                if(valparts.PartDescription__c !=null && valparts.PartDescription__c !='' && valparts.PartDescription__c.length()>254)
                                                    wl.PartDescription__c = valparts.PartDescription__c.substring(0,254);
                                                else
                                                    wl.PartDescription__c = valparts.PartDescription__c;
                                            }
                                            if( String.isempty(wl.PartPrice__c )){
                                                if(valparts.PartPrice__c !=null && valparts.PartPrice__c !='' && valparts.PartPrice__c.length()>128)
                                                    wl.PartPrice__c = valparts.PartPrice__c.substring(0,128);
                                                else
                                                    wl.PartPrice__c = valparts.PartPrice__c;
												
																											   
                                            }
                                            if((valparts.PartsInventoryStatus__c !=null && valparts.PartsInventoryStatus__c !='')){
                                                
                                                wl.InventoryStatus__c=valparts.PartsInventoryStatus__c;
                                                if(wl.InventoryStatus__c!=null && wl.InventoryStatus__c!='' && (wl.InventoryStatus__c.containsignorecase('PART_NOT_FOUND') || wl.InventoryStatus__c.containsignorecase('DISABLED'))){
                                                    if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('unknown')) || string.isBlank(wl.Warning_Message__c) )
                                                        wl.Warning_Message__c+=' | Part '+wl.PartNumber__c+' status is unknown, and the work order may be affected.';
                                                }
                                                if(wl.InventoryStatus__c!=null && wl.InventoryStatus__c!='' && wl.InventoryStatus__c.containsignorecase('PART_UNAVAILABLE')){
                                                    if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('unavailable')) || string.isBlank(wl.Warning_Message__c) )
                                                        wl.Warning_Message__c+=' | Part '+ wl.PartNumber__c +' status is unavailable, and the work order may be affected.';
                                                }
                                            }
                                            
                                            if(!workOrderDetails.isempty()){
                                              
                                                if (!workOrderDetails[0].Out_of_Warranty__c) // DEFECT 5207765
                                                {    
                                                    if(((wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && (wl.PartCommodity__c.containsIgnoreCase('HARD DRIVE') || wl.PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE'))) || (wl.SubComponent__c!=null && wl.SubComponent__c!='' && (wl.SubComponent__c.containsIgnoreCase('HARD DRIVE') || wl.SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE')))) ){
                                                        
                                                        if(workOrderDetails[0].KYHD__c){
                                                            if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('T0909')) || string.isBlank(wl.Warning_Message__c) )
                                                                wl.Warning_Message__c+=' | Part Numbers T0909 & D2359 will be added automatically.';
                                                        }
                                                        if(workOrderDetails[0].Entitlement_Details__c!=null && workOrderDetails[0].Entitlement_Details__c!='' && workOrderDetails[0].Entitlement_Details__c.containsIgnoreCase('Data Recovery')){
                                                            if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('P980X')) || string.isBlank(wl.Warning_Message__c) )
                                                                wl.Warning_Message__c+=' | Part Number P980X will be added automatically.';
                                                        }
                                                        if(workOrderDetails[0].Entitlement_Details__c!=null && workOrderDetails[0].Entitlement_Details__c!='' && workOrderDetails[0].Entitlement_Details__c.containsIgnoreCase('Data Destruction')){
                                                            if((!string.isBlank(wl.Warning_Message__c) && !wl.Warning_Message__c.containsignorecase('U705H')) || string.isBlank(wl.Warning_Message__c) )
                                                                wl.Warning_Message__c+=' | Part Number U705H will be added automatically.';
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            if(wl.Warning_Message__c!=null && wl.Warning_Message__c!=''){
                                                wl.Warning_Message__c=wl.Warning_Message__c.replace('null','');
                                            }
                                            workorderLineItemWrapper a=  new workorderLineItemWrapper();
                                            a.isSelected = wl.Selected_By_user__c;
                                            a.WorkOrderLineItemVal=wl;
                                            a.responseMessage=System.Label.Dispatch_success;
                                            selectedWorkorderLineItemWraplist.add(a);
                                        }
                                        else{
                                            if(!selectedPartsPartNumber.contains(valparts.PartNumber__c))
                                            {
																												 
                                                WorkOrderLineItem objWorkorderLineItem = new WorkOrderLineItem();
                                                objWorkorderLineItem.WorkOrderId = wl.WorkOrderId;
                                                objWorkorderLineItem.Part_Quantity__c='1';
                                                //objWorkorderLineItem.Selected_Work_Order__c = wl.WorkOrderId;
                                                //objWorkorderLineItem.Work_Order_Id_Text__c= String.valueOf(wl.WorkOrderId);
                                                objWorkorderLineItem.AssetId=wl.AssetId;
                                                if(valparts.PartNumber__c!=null && valparts.PartNumber__c!='' && valparts.PartNumber__c.length()>127){
                                                    objWorkorderLineItem.PartNumber__c = valparts.PartNumber__c.substring(0,127);
                                                }
                                                else{
                                                    objWorkorderLineItem.PartNumber__c = valparts.PartNumber__c;
                                                }
                                                if(valparts.AltPartFlag__c !=null && valparts.AltPartFlag__c !='' && valparts.AltPartFlag__c.length()>1)
                                                    wl.Use_Alt_Part_Flag__c = valparts.AltPartFlag__c.substring(0,1);
                                                else
                                                    wl.Use_Alt_Part_Flag__c = valparts.AltPartFlag__c;
                                                if(valparts.PartPrice__c!=null && valparts.PartPrice__c!='' && valparts.PartPrice__c.length()>127){
                                                    objWorkorderLineItem.PartPrice__c = valparts.PartPrice__c.substring(0,127);
                                                }
                                                else{
                                                    objWorkorderLineItem.PartPrice__c = valparts.PartPrice__c;
                                                }
																											   
                                                if(valparts.PartType__c!=null && valparts.PartType__c!='' && valparts.PartType__c.length()>127){
                                                    objWorkorderLineItem.PartType__c = valparts.PartType__c.substring(0,127);
                                                }
                                                else{
                                                    objWorkorderLineItem.PartType__c = valparts.PartType__c;
                                                }
                                                if(valparts.DefectiveComponent__c!=null && valparts.DefectiveComponent__c!='' && valparts.DefectiveComponent__c.length()>255){
                                                    objWorkorderLineItem.DefectiveComponent__c = valparts.DefectiveComponent__c.substring(0,255).replace(',','').replace('\'',' ').replace('"',' ');
                                                }
                                                else{
                                                    if(valparts.DefectiveComponent__c!=null){
                                                        objWorkorderLineItem.DefectiveComponent__c = valparts.DefectiveComponent__c.replace(',','').replace('\'',' ').replace('"',' ') ;
                                                    }
                                                }
                                                if(valparts.Commodity__c!=null && valparts.Commodity__c!='' && valparts.Commodity__c.length()>127){
                                                    objWorkorderLineItem.PartCommodity__c = valparts.Commodity__c.substring(0,127).replaceall(',','');
                                                }
                                                else{
                                                    objWorkorderLineItem.PartCommodity__c = valparts.Commodity__c;
                                                }
                                                if(valparts.SubComponent__c!=null && valparts.SubComponent__c!='' && valparts.SubComponent__c.length()>127){
                                                    objWorkorderLineItem.SubComponent__c = valparts.SubComponent__c.substring(0,127);
                                                }
                                                else{
                                                    objWorkorderLineItem.SubComponent__c = valparts.SubComponent__c;
                                                }
                                                if(valparts.PartDescription__c!=null && valparts.PartDescription__c!='' && valparts.PartDescription__c.length()>254){
                                                    objWorkorderLineItem.PartDescription__c = valparts.PartDescription__c.substring(0,254);
                                                }
                                                else{
                                                    objWorkorderLineItem.PartDescription__c = valparts.PartDescription__c;
                                                }
                                                if(valparts.FunctionalDescription__c!=null && valparts.FunctionalDescription__c!='' && valparts.FunctionalDescription__c.length()>254){
                                                    objWorkorderLineItem.FunctionalDescription__c = valparts.FunctionalDescription__c.substring(0,254);
                                                }
                                                else{
                                                    objWorkorderLineItem.FunctionalDescription__c = valparts.FunctionalDescription__c;
                                                }
                                                if(valparts.FourHour__c!=null && valparts.FourHour__c!='' && valparts.FourHour__c.length()>4){
                                                    objWorkorderLineItem.FourHour__c = valparts.FourHour__c.substring(0,4);
                                                }
                                                else{
                                                    objWorkorderLineItem.FourHour__c = valparts.FourHour__c;
                                                }
                                                if(valparts.CustomerReplaceableUnit__c!=null && valparts.CustomerReplaceableUnit__c!='' && valparts.CustomerReplaceableUnit__c.length()>4){
                                                    objWorkorderLineItem.CustomerReplaceableUnit__c = valparts.CustomerReplaceableUnit__c.substring(0,4);
                                                }
                                                else{
                                                    objWorkorderLineItem.CustomerReplaceableUnit__c = valparts.CustomerReplaceableUnit__c;
                                                }
                                                if(valparts.FieldReplaceableUnit__c!=null && valparts.FieldReplaceableUnit__c!='' && valparts.FieldReplaceableUnit__c.length()>4){
                                                    objWorkorderLineItem.FieldReplaceableUnit__c  = valparts.FieldReplaceableUnit__c.substring(0,4) ;
                                                }
                                                else{
                                                    objWorkorderLineItem.FieldReplaceableUnit__c  = valparts.FieldReplaceableUnit__c;
                                                }
                                                if(valparts.ServiceBUID__c !=null && valparts.ServiceBUID__c !='' && valparts.ServiceBUID__c.length()>78){
                                                    objWorkorderLineItem.ServiceBUID__c = valparts.ServiceBUID__c.substring(0,78);
                                                }
                                                else{
                                                    objWorkorderLineItem.ServiceBUID__c = valparts.ServiceBUID__c;
                                                }
                                                objWorkorderLineItem.Line_Item_Type__c='APS-Also ship';
                                                //objWorkorderLineItem.External_Id__c=String.valueof(wl.WorkOrderId).substring(0,15)+'_'+valparts.PartNumber__c;                
                                                if(valparts.BacklogETA__c!=null && !string.valueof(valparts.BacklogETA__c).containsignorecase('null')){
                                                    objWorkorderLineItem.BacklogETA__c=valparts.BacklogETA__c;
                                                }
                                                if(valparts.PartsInventoryStatus__c ==''){
                                                    objWorkorderLineItem.InventoryStatus__c='PART_AVAILABLE';
                                                }
                                                objWorkorderLineItem.Warning_Message__c='Also Ship Parts added for '+wl.PartNumber__c;
                                                if((valparts.PartsInventoryStatus__c !=null && valparts.PartsInventoryStatus__c !='')){
                                                    
                                                    objWorkorderLineItem.InventoryStatus__c=valparts.PartsInventoryStatus__c;
                                                    if(objWorkorderLineItem.InventoryStatus__c!=null && objWorkorderLineItem.InventoryStatus__c!='' && objWorkorderLineItem.InventoryStatus__c.containsignorecase('PART_NOT_FOUND')){
                                                        
                                                        objWorkorderLineItem.Warning_Message__c+=' | Part '+objWorkorderLineItem.PartNumber__c+' status is unknown, and the work order may be affected.';
                                                    }
                                                    if(objWorkorderLineItem.InventoryStatus__c!=null && objWorkorderLineItem.InventoryStatus__c!='' && objWorkorderLineItem.InventoryStatus__c.containsignorecase('PART_UNAVAILABLE')){
                                                        
                                                        objWorkorderLineItem.Warning_Message__c+=' | Part '+ objWorkorderLineItem.PartNumber__c +' status is unavailable, and the work order may be affected.';
                                                    }
                                                }                                            
                                                if(wl.Warning_Message__c!=null && wl.Warning_Message__c!=''){
                                                    wl.Warning_Message__c=wl.Warning_Message__c.replace('null','');
                                                }
                                                //workorderLineItemWrapper a=  new workorderLineItemWrapper();
                                                //a.isSelected = objWorkorderLineItem.Selected_By_user__c;
                                                //a.WorkOrderLineItemVal=objWorkorderLineItem;
                                                //a.responseMessage=System.Label.Dispatch_success;
                                                //selectedWorkorderLineItemWraplist.add(a);
                                                //objWorkorderLineItemList.add(objWorkorderLineItem); -Commented by Harsha  - [Jan 8th 2019]
                                                
                                                // Added By Harsha  - [Jan 8th 2019] - Starts Here
                                                objWorkorderLineItem.Selected_By_user__c = true;
                                               	objWorkorderLineItem.External_Id__c=String.valueof(wl.WorkOrderId).substring(0,15)+'_'+valparts.PartNumber__c;                                               
                                                workorderLineItemWrapper a=  new workorderLineItemWrapper();
                                                a.isSelected = objWorkorderLineItem.Selected_By_user__c;
                                                a.WorkOrderLineItemVal=objWorkorderLineItem;
                                                a.responseMessage=System.Label.Dispatch_success;
                                                selectedWorkorderLineItemWraplist.add(a);
                                                selectedPartsPartNumber.add(valparts.PartNumber__c);
                                                //Added by Harsha  - [Jan 8th 2019] - Ends Here
                                            }
                                        }
                                    }       
                                }
                            }
                        }
                        catch(exception ex){
                          	selectedWorkorderLineItemWraplist.clear();
                            if(ex.getmessage().length() > 254)
                                wl.Validate_Parts_Response__c =ex.getmessage().substring(0,254);
                            else
                                wl.Validate_Parts_Response__c =ex.getmessage(); 
                            workorderLineItemWrapper a=  new workorderLineItemWrapper();
                            a.isSelected =false;
                            a.WorkOrderLineItemVal=null;
                            a.responseMessage=ex.getmessage();
                            selectedWorkorderLineItemWraplist.add(a);
                            return selectedWorkorderLineItemWraplist;
                        }
                    }
                    else {
                        wl.Selected_Work_Order__c=null;
                    }
                }
            }
            //Commented by Harsha  - [Jan 8th 2019] - Starts Here
            //aps change ends
            /*
            //inserting the also ship parts to get the Id
            try{
                //Database.Update(selectedParts,true);
                if(!objWorkorderLineItemList.isempty()){
                    List<Database.UpsertResult> updateResults = Database.upsert(objWorkorderLineItemList, workorderLineItem.External_Id__c.getDescribe().getSObjectField(),false);
                    for(Database.UpsertResult upd : updateResults){
                        if(upd.isSuccess()){
                            alsoShipId.add(upd.getId());
                        }
                    }
                    if(!alsoShipId.isempty()){
                        List<workorderLineItem> alsoShipLineItems=[select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,External_Id__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,FieldReplaceableUnit__c,WorkOrderId,Selected_Work_Order__c,ServiceBUID__c,ServiceTag__c,Valid_Parts__c,Part_Quantity__c,Validate_Parts_Response__c,Return_Qty__c,ItemExists__c,Image_Url__c,DefectiveComponent__c,InventoryStatus__c,Line_Item_Type__c,Warning_Message__c from workorderLineItem where Id in :alsoShipId order by PartCommodity__c LIMIT 50000];
                        if(!alsoShipLineItems.isempty()){
                            for(workorderLineItem wl : alsoShipLineItems ){
                                wl.Selected_By_user__c=true;
                                workorderLineItemWrapper a=  new workorderLineItemWrapper();
                                a.isSelected = wl.Selected_By_user__c;
                                a.WorkOrderLineItemVal=wl;
                                a.responseMessage=System.Label.Dispatch_success;
                                selectedWorkorderLineItemWraplist.add(a);
                            }
                        }
                    }
                }
            }
            catch(exception ex){
                
                selectedWorkorderLineItemWraplist.clear();
                workorderLineItemWrapper a=  new workorderLineItemWrapper();
                a.isSelected = false;
                a.WorkOrderLineItemVal=null;
                a.responseMessage=ex.getmessage();
                selectedWorkorderLineItemWraplist.add(a);
                return selectedWorkorderLineItemWraplist;
            }
			*/
            //Commented by Harsha  - [Jan 8th 2019] - Ends Here
        }
        
        // Added Newly
        if(!selectedWorkorderLineItemWraplist.isEmpty() && selectedWorkorderLineItemWraplist.size()>0 && !callType.equalsIgnoreCase(System.Label.Dispatch_MPS)) {
            List<workorderLineItem> selectPartList = new List<workorderLineItem>();
            for (workorderLineItemWrapper wOLine : selectedWorkorderLineItemWraplist) {
                if(wOLine.WorkOrderLineItemVal != null) {
                    if(wOLine.WorkOrderLineItemVal.Selected_By_user__c) {
                        selectPartList.add(wOLine.WorkOrderLineItemVal);
                    }
                }
            }
            
            if(!selectPartList.isEmpty() && selectPartList.size()>0) {
                string response = saveSelectedParts(selectPartList,callType,'',addCFIAutoPart);
                if(!String.isNotBlank(response) || !response.containsIgnoreCase(System.Label.Dispatch_success)) {
                    selectedWorkorderLineItemWraplist.clear();
                    workorderLineItemWrapper a=  new workorderLineItemWrapper();
                    a.isSelected = false;
                    a.WorkOrderLineItemVal=null;
                    a.responseMessage=response;
                    selectedWorkorderLineItemWraplist.add(a);
                    return selectedWorkorderLineItemWraplist;
                }
            }
        }
        // Added Newly
        return selectedWorkorderLineItemWraplist;
    }
    /*
saveSelectedParts will be invoked from the Lightning component c:DispatchAutoPartSelection
saveSelectedParts will save the selected line Items to Work Order Line Items.
*/
    @AuraEnabled
    public static string saveSelectedParts(List<workorderLineItem>selectedParts,string callType, string manualSelectReason, Boolean autoAddCFIPart){
        set<Id> workOrderIdSet=new set<Id>();
        Boolean addInfoPartsCheck=false;
        Boolean groundShipMentCheck=false;
        String groundShipMentvalue='';
        list<workorderLineItem>finalSelectParts=new list<workorderLineItem>();
        list<workorderLineItem>addInfoParts=new list<workorderLineItem>();
        workorderLineItem hardDriveParts;
        list<workorderLineItem>listDeleteParts=new list<workorderLineItem>();
        
        if(!selectedParts.isempty()){
            if(workOrderDetails.isempty()){
                workOrderDetails=[Select Id, Entitlement_Details__c,KYHD__c, Out_of_Warranty__c,Ground_Shipment_Flag__c,CountryCode,Override_Ground_Shipment__c,CFI_Exists__c from workOrder where Id= :selectedParts[0].WorkOrderId Limit 1 ];
            }
            for(workorderLineItem wl :selectedParts){
                //workOrderIdSet.add(wl.WorkOrderId);
                if(wl.Selected_By_user__c){
                    wl.Selected_Work_Order__c=wl.WorkOrderId;
                    wl.Work_Order_Id_Text__c= String.valueOf(wl.WorkOrderId);
                    if(manualSelectReason!=null && manualSelectReason!=''){
                        wl.Reason_for_Advanced_Search__c =manualSelectReason;
                    }
                    
                    //checking if there are any Hard Drive/SSD elements are there
                    if(((wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && (wl.PartCommodity__c.containsIgnoreCase('HARD DRIVE') || wl.PartCommodity__c.containsIgnoreCase('SOLID STATE DRIVE'))) || (wl.SubComponent__c!=null && wl.SubComponent__c!='' && (wl.SubComponent__c.containsIgnoreCase('HARD DRIVE') || wl.SubComponent__c.containsIgnoreCase('SOLID STATE DRIVE')))) ){
                        if(!addInfoPartsCheck){
                            addInfoPartsCheck=true;
                            hardDriveParts=wl;//Code Not bulkified Need to bulkify in later releases
                        }
                    }
                    if(wl.PartCommodity__c!=null && wl.PartCommodity__c!='' && wl.PartCommodity__c.containsIgnoreCase('BATTERY')){
                        groundShipMentCheck=true;
                    }
                    //commented by Prakhar Sinha for allowing the parts to be added irrespective of InventoryStatus
                    /*if(wl.InventoryStatus__c==null || (wl.InventoryStatus__c!=null && wl.InventoryStatus__c!='' && !wl.InventoryStatus__c.containsIgnoreCase('PART_UNAVAILABLE') ) ){
finalSelectParts.add(wl);
}*/
                    finalSelectParts.add(wl);
                    workOrderIdSet.add(wl.WorkOrderId);
                }
                else{
                    listDeleteParts.add(wl);
                }
            }
            
            if(addInfoPartsCheck){
                addInfoParts=AutoSelectPartController.ValidateInfoparts(hardDriveParts,callType,false);
                //addInfoParts.addall(DispatchPartInsertionHelper.getReplacementParts(hardDriveParts.WorkOrderId,hardDriveParts.AssetId,hardDriveParts.ServiceTag__c,hardDriveParts.ServiceBUID__c,null,'T0909'));
                //addInfoParts.addall(DispatchPartInsertionHelper.getReplacementParts(hardDriveParts.WorkOrderId,hardDriveParts.AssetId,hardDriveParts.ServiceTag__c,hardDriveParts.ServiceBUID__c,null,'D2359'));
                
            }
            if(groundShipMentCheck){
                groundShipMentvalue= AutoSelectPartController.ValidategroundShipment(workOrderDetails);
            }
            //MB: code changes for Nov Story:CFI
            system.debug('autoAddCFIPart ###'+autoAddCFIPart);
            system.debug('workOrderDetails ###'+workOrderDetails);
            if(autoAddCFIPart && null != workOrderDetails && workOrderDetails.size() > 0){
                  addAutoCFIPart(workOrderDetails[0],callType);
            }
            //MB: code changes finish here
            if(!addInfoParts.isempty()){
                for(workorderLineItem wl : addInfoParts){
                    wl.Selected_By_user__c=true;
                    wl.Selected_Work_Order__c=wl.WorkOrderId;
                    wl.Work_Order_Id_Text__c= String.valueOf(wl.WorkOrderId);
                }
                finalSelectParts.addall(addInfoParts);
            }
            // List<workOrder> workorderList =   updateWorkOrder(selectedParts);
            //List<workOrder> workorderList =   updateWorkOrder(selectedParts[0].WorkOrderId);
            try{
                
                Upsert finalSelectParts External_Id__c;
                
                if(!workOrderIdSet.isempty()){
                    AutoSelectPartController.deleteParts(workOrderIdSet,listDeleteParts);
                }
            }
            catch(exception ex){
                
                return ex.getmessage();
            }
            
            
        }
        string successvalue = System.Label.Dispatch_success;
        
        if(groundShipMentvalue!='' && groundShipMentvalue != null){
            successvalue =successvalue + groundShipMentvalue;
        }
        return successvalue;
    }
    /*
deleteParts  will be called from AutoSelectPartController.saveSelectedParts to delete Line Items
deleteParts will delete the non selected Line Items as soon as user finalise the Items.
*/
    //@future
    public static void deleteParts(set<Id>workOrderIdSet,List<workorderLineItem>listDeleteParts){
        
        if(!workOrderIdSet.isempty()){
            List<workorderLineItem>DeleteList=[Select id from workorderLineItem where WorkOrderId in :workOrderIdSet and Selected_By_user__c=false LIMIT 50000];
            
            if(!listDeleteParts.isempty()){
                DeleteList.addall(listDeleteParts);
            }
            if(!DeleteList.isempty()){
                try{
                    Database.Delete(DeleteList,true);
                    
                }
                catch(exception ex){
                    
                }
            }
        }
    }
    /*
deleteworkorderLineItems will be called from Process Builder 'DispatchDeleteWorkOrderLineItems'  to delete Line Items
deleteworkorderLineItems will delete all the Line Items as soon as Work Order Service Type changes to Labour Only.
*/
    @InvocableMethod(label='Delete Workorderlineitems' description='It will delete all the workorderline items for service type labor ')
    public static void deleteworkorderLineItems(List<ID> workId) {
        List<WorkOrderLineItem> workorderLineItemList = new List<WorkOrderLineItem>();
        workorderLineItemList=[select id from WorkOrderLineItem where WorkOrderId in : workId LIMIT 50000];
        if(!workorderLineItemList.isEmpty()){
            delete workorderLineItemList;
        }
    }   
    
    public static List<AutoSelectPartWrapper> errormethod(Exception ex)
    { 
        List<AutoSelectPartWrapper> autoselectwraplist = new List<AutoSelectPartWrapper>();
        AutoSelectPartWrapper a=  new AutoSelectPartWrapper();
        a.isSelected = false;
        a.PartCommodityDef=null;
        a.PartCommodityPof=null;
        a.responseMessage=ex.getmessage() ;
        autoselectwraplist.add(a);
        return autoselectwraplist;
    }
    
    /*public static  List<WorkOrder>  updateWorkOrder(Id recordId )
{

List<Id> workOrderIdSet= new List<Id>();
List<WorkOrderLineItem> selectedParts = new List<WorkOrderLineItem>();
selectedParts=[Select Id,PartCommodity__c,WorkOrderId from WorkOrderLineItem where WorkOrderId=:recordId and Selected_By_user__c=true];
List<WorkOrder> updateworkorderlist = new List<WorkOrder>();
String assetName='';
if(!selectedParts.isempty())
{
for(workorderLineItem wl : selectedParts)
{
if(wl.PartCommodity__c.equalsIgnoreCase('HARD DRIVE'))
{
workOrderIdSet.add(wl.WorkOrderId);
}
}

List<WorkOrder> recworkorderList= new List<WorkOrder>();
if(!workOrderIdSet.isEmpty())
{

assetName = [Select Id,Asset.name from WorkOrder where Id in : workOrderIdSet].Asset.name;
//assetName=[Select name from Asset where id=:recworkorderList[0].AssetId].name;
}

List<GetEntitlementDashboard__x> entitlementList= new List<GetEntitlementDashboard__x>();
if(assetName!=null)
{
entitlementList=[SELECT ServiceTagId__c, CurrentEntitlement__c, CurrentEntitlementEndDate__c, 
Position__c, RemainingDays__c, Status__c, Type__c
FROM GetEntitlementDashboard__x WHERE ServiceTagId__c =:assetName LIMIT 100];
}

if(!entitlementList.isempty())
{
for(GetEntitlementDashboard__x e : entitlementList)     
{

if(e.type__c.containsIgnoreCase('KYHD/KYC'))
{
WorkOrder wo = new WorkOrder();
wo.id= recordId;
wo.KYHD__c=true;
updateworkorderlist.add(wo);
}

}
return updateworkorderlist;
}
}
return updateworkorderlist;                 
} */
    /*
This Method will Insert the alerts and add info parts whenever necessary.
*/
    public static List<WorkOrderLineItem> ValidateInfoparts (WorkOrderLineItem hardDriveRec,string callType,Boolean KYHDFlagChangedTrue){
        
        List<WorkOrderLineItem> infoPartsList=new List<WorkOrderLineItem>();
        List<Dispatch_Alert__c> DispatchAlerts= new List <Dispatch_Alert__c >();
        if(hardDriveRec!=null && hardDriveRec.WorkOrderId!=null){
            
            if(workOrderDetails.isempty()){
                workOrderDetails=[Select Id, Entitlement_Details__c,KYHD__c, Out_of_Warranty__c,Ground_Shipment_Flag__c,CountryCode,Override_Ground_Shipment__c,CFI_Exists__c from workOrder where Id= :hardDriveRec.WorkOrderId Limit 1 ];
            }
            if(!workOrderDetails.isempty()){
                if (!workOrderDetails[0].Out_of_Warranty__c) // DEFECT 5207765
                {
                    if( KYHDFlagChangedTrue || workOrderDetails[0].KYHD__c ){
                        infoPartsList.addall(DispatchPartInsertionHelper.getInfoParts(hardDriveRec.WorkOrderId,hardDriveRec.AssetId,hardDriveRec.ServiceTag__c,hardDriveRec.ServiceBUID__c,null,'T0909','Part Numbers T0909 & D2359 were added automatically.',callType,false));
                        infoPartsList.addall(DispatchPartInsertionHelper.getInfoParts(hardDriveRec.WorkOrderId,hardDriveRec.AssetId,hardDriveRec.ServiceTag__c,hardDriveRec.ServiceBUID__c,null,'D2359','Part Numbers T0909 & D2359 were added automatically.',callType,false));
                        //DispatchAlerts.add(DispatchPartInsertionHelper.addAlertForWorkOrder(string.valueof(hardDriveRec.WorkOrderId),'Part Numbers T0909 & D2359 were added automatically.','KYHD Info Parts Hard Drive',false,'Info Parts for KYHD'));
                    }
                    if(workOrderDetails[0].Entitlement_Details__c!=null && workOrderDetails[0].Entitlement_Details__c!='' && workOrderDetails[0].Entitlement_Details__c.containsIgnoreCase('Data Recovery')){
                        infoPartsList.addall(DispatchPartInsertionHelper.getInfoParts(hardDriveRec.WorkOrderId,hardDriveRec.AssetId,hardDriveRec.ServiceTag__c,hardDriveRec.ServiceBUID__c,null,'P980X','Part Number P980X was added automatically.',callType,false));
                        DispatchAlerts.add(DispatchPartInsertionHelper.addAlertForWorkOrder(string.valueof(hardDriveRec.WorkOrderId),'Part Number P980X was added automatically.','Data Recovery Info Parts Hard Drive',false,'Info Parts for Data Recovery'));
                    }
                    if(workOrderDetails[0].Entitlement_Details__c!=null && workOrderDetails[0].Entitlement_Details__c!='' && workOrderDetails[0].Entitlement_Details__c.containsIgnoreCase('Data Destruction')){
                        infoPartsList.addall(DispatchPartInsertionHelper.getInfoParts(hardDriveRec.WorkOrderId,hardDriveRec.AssetId,hardDriveRec.ServiceTag__c,hardDriveRec.ServiceBUID__c,null,'U705H','Part Number U705H was added automatically.',callType,false));
                        DispatchAlerts.add(DispatchPartInsertionHelper.addAlertForWorkOrder(string.valueof(hardDriveRec.WorkOrderId),'Part Number U705H was added automatically.','Data Destruction Info Parts Hard Drive',false,'Info Parts for Data Destruction'));
                    }
                }
            }
        }
        if(!DispatchAlerts.isempty()){
            //Database.upsert(DispatchAlerts Alerts_Id__c,false);
            upsert DispatchAlerts Alerts_Id__c;
        }
        return infoPartsList;
    }
    
    
    /* -----------------------------------------------------------------------------------------------------------------------
Name:         getSelectedParts
Description:  This method query parts from given work order id
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
05/26/2018     1.0     Bikram Bebarta      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static list<WorkOrderLineItem> getSelectedParts(Id workOrderId) {
        list<WorkOrderLineItem> partsList= [SELECT Part_Quantity__c, Part__c, SLA__c, CRU_FRU__c, Selected_By_user__c FROM WorkOrderLineItem 
                                            WHERE WorkOrderId= :workOrderId AND Selected_Work_Order__c != null LIMIT 1000];
        return partsList;
    }
    
    public static string validateGroundShipMent(List<workOrder> workOrderDetails){
        try{
            List<DispatchDefaults__c>defaultValues =new List<DispatchDefaults__c>();
            List<Dispatch_Alert__c> DispatchAlerts= new List <Dispatch_Alert__c >();
            if(!workOrderDetails.isempty()){
                defaultValues = [SELECT Id, Service_Options_Picklist_values__c,BasicEntitlement__c,Billable__c, Entitlement_Details__c, Service_Type__c, PO_Number__c, selected_service_option__c, OutOfWarranty__c,
                                 category__c, Service_Configurations__c, SpecialOptions__c, Bill_To__c, Keep_Your_Components__c, DSP_Override_Request__c,AD_Override__c,
                                 AvailableCoverages__c,AvailableOptions__c,CompleteCareOption__c,AD_Coverage_Flag__c,Complete_Care_Option__c,OrderNumber__c, Work_Order__r.KYHD__c,
                                 Bill_To_Order_Number__c,KYHDOption__c,PartsCountry__c, BUID__c, ServiceHours__c, LaborCountry__c, ServiceLevel__c, Default_Service_Type__c,Work_Order__r.City,Work_Order__r.State,Work_Order__r.Product_Classification__c,
                                 Work_Order__r.SLAStartDate__c, Work_Order__r.SLAEndDate__c, Work_Order__r.Service_Option__c, Work_Order__r.Country, Work_Order__r.PostalCode,Work_Order__r.CountryCode,
                                 Work_Order__r.WorkOrderNumber,Work_Order__r.ServiceTag__c
                                 FROM DispatchDefaults__c
                                 WHERE Work_Order__c =: workOrderDetails[0].Id LIMIT 1
                                ];
                if(defaultValues !=NULL){
                    List<System_Classification__mdt> SystemClassificationList = [Select Id,MasterLabel,Type__c from System_Classification__mdt where Type__c ='Enterprise'];
                    Set <String> SystemClassificationSet = new Set<String>();
                    for(System_Classification__mdt scObj : SystemClassificationList){
                        SystemClassificationSet.add(scObj.MasterLabel);
                    }
                    if(Test.isRunningTest())
                    {
                       SystemClassificationSet.add('data');                    
                    }
                    
                    if(defaultValues[0].BasicEntitlement__c && !(SystemClassificationSet.contains(defaultValues[0].Work_Order__r.Product_Classification__c))){
                        //if (workOrderDetails[0].CountryCode=='US' || workOrderDetails[0].CountryCode=='CA')
                            workOrderDetails[0].Ground_Shipment_Flag__c=true;
                        try{
                            update workOrderDetails[0];
                            /*Akhil-Commenting
                            DispatchAlerts.add(DispatchPartInsertionHelper.addAlertForWorkOrder(string.valueof(workOrderDetails[0].Id),'This work order will be sent via Ground Shipment, because it includes a battery.','Ground Shipment Battery',false,'Ground Shipment'));
                            if(!DispatchAlerts.isempty()){
                                //Database.upsert(DispatchAlerts Alerts_Id__c,false);
                                upsert DispatchAlerts Alerts_Id__c;
                            }*/
                            return 'GROUNDSHIPMENT';
                        }
                        catch (exception ex){
                            ExceptionHandler.logHandledExceptions(ex,'AutoSelectPartController','workOrderDetails','Dispatch Management');
                           
                            return null;
                        }
                    }
                    
                }
            }
            return null;
        } catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AutoSelectPartController','workOrderDetails','Dispatch Management');
            return null;
        }
    }
    public static void addAutoCFIPart(workOrder workOrderDetails, string callType){
       
        List<WorkOrder> wolist =[select Id, AssetId, ServiceTag__c from WorkOrder where Id =: workOrderDetails.Id limit 1];
        
        if(null != wolist && wolist.size() > 0){
        
            List<workOrderLineItem> autoAddPartsList = DispatchPartInsertionHelper.getInfoParts(wolist[0].Id,wolist[0].AssetId,wolist[0].ServiceTag__c,null,null,'57906','Part Number 57906 was added automatically.',callType,true);
            
            if(null != autoAddPartsList && autoAddPartsList.size() > 0){
                insert autoAddPartsList;
                WorkOrderLineItemTriggerHelper.deleteCFIPart  = false;
                system.debug('autoAddPartsList###'+autoAddPartsList);
            }
        }
   }
   
   Public class AsyncCreateParts implements Queueable {
        @TestVisible private List<WorkOrderLineItem> workOrderLineItemList = new List<WorkOrderLineItem>();
        AsyncCreateParts(List<WorkOrderLineItem> workOrderLineItemList){
            this.workOrderLineItemList = workOrderLineItemList;
        }
       public void execute(QueueableContext context) {
           try{
               Database.UpsertResult[] results =  Database.upsert(workorderLineItemList, workorderLineItem.External_Id__c.getDescribe().getSObjectField(),false);
               ExceptionHandler.logHandledExceptions(results,'AsyncCreateParts','execute','Dispatch Management');
               return;
           } catch (Exception e){
               ExceptionHandler.logHandledExceptions(e,'AsyncCreateParts','execute','Dispatch Management');
           }
       }
   }
}