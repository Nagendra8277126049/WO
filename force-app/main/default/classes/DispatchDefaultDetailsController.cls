/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchDefaultDetailsController
Description:  This class contain method that handles get dispatch data controller - story #4346869 
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
05/03/2018     1.0    Rodrigo Carpio       Initial Release
06/03/2108     1.1    Harsha Reddy         Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
public without sharing class DispatchDefaultDetailsController {
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:         getServiceEvents
    Description:  this functions query service events related to work order id
    Date          Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    07/06/2018     1.0     Rodrigo Carpio      Initial Release
    26/07/2018     1.1     Prachi Thube        Defect 5385587 - queried fields to display on Service Event Section
    -------------------------------------------------------------------------------------------------------------------------- */    
    @AuraEnabled
    public static list<DispatchServiceEvent__c> getServiceEvents(Id workOrderId) {
        list<DispatchServiceEvent__c> serviceEventList = new list<DispatchServiceEvent__c>();
        serviceEventList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Reject_Reason__c, Service_Event__c, Event_DateTime__c, Event_Source__c, ISP_Engineer_Id__c, 
        DSP_Office_Id__c, DSP_Details__c, Reply_Code__c, Reply_Code_Description__c, Vendor_Transaction_DateTime__c, 
        Event_Code__c, CreatedDate FROM DispatchServiceEvent__c WHERE Work_Order__c =: workOrderId limit 100];
        return serviceEventList;
    }
    
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:         getDispatchDefaultRecord
    Description:  this functions query DispatchDefaults from given work order id
    Date          Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    05/21/2018     1.0     Bikram Bebarta      Initial Release
    06/31/2018     1.0     Harsha Reddy        Updated Code based on Code Review Defect
    07/16/2018     1.1     Harsha Reddy        Defect 5345225
    -------------------------------------------------------------------------------------------------------------------------- */
    
    @AuraEnabled
    public static DispatchDefWOWrapper getDispatchDefaultRecord(Id workOrderId) {
        
            DispatchDefWOWrapper dispatchDefaultWO = new DispatchDefWOWrapper();
            dispatchDefaultWO.GccUser=DispatchGccConfiguration.isGCCuser();
            //String DispatchDefaultRecordResult = '';
        
            list<DispatchDefaults__c> defaultList = new list<DispatchDefaults__c>();
            defaultList = [SELECT Id, selected_service_option__c, Service_Type__c, SpecialOptions__c, Service_Configurations__c,
                           Keep_Your_Components__c, KYHDOption__c, AD_Override__c, Work_Order__r.Epitome_FSD_Ref__c,Complete_Care_Option__c,
                           Work_Order__r.Alternate_Return_Address_Checkbox__c, Work_Order__r.Alternate_Return_Street__c,
                           Work_Order__r.Alternate_Return_City__c, Work_Order__r.Alternate_Return_State__c, Bill_To_Order_Number__c,
                           Work_Order__r.Alternate_Return_Postal_Code__c, Work_Order__r.Alternate_Return_Country__c, 
                           Work_Order__r.WorkOrderNumber, Work_Order__r.DLP__c, Work_Order__r.FSD_DSP_Selection__c, Work_Order__r.Service_Type__c,
                           Work_Order__r.Reason_for_repeat_Work_Order__c, Work_Order__r.ISPDispatchPPID__c, Work_Order__r.FSD_Transport_DLP__c,
                           Work_Order__r.ISPReportingFlag__c, Work_Order__r.ISPShippingMethod__c, Work_Order__r.CallType__c, Bill_To__c,
                           Work_Order__r.DPSType__c, Work_Order__r.DispatchNumber__c, Work_Order__r.DLP_Name__c, Work_Order__r.Status, Work_Order__r.Collect_DLP__c,Work_Order__r.Collect_DLP_Name__c, Work_Order__r.Sub_Status__c, Work_Order__r.CountryCode__c, LaborCountry__c, PartsCountry__c,DSP_Override_Request__c, Work_Order__r.DASP__c
                           FROM DispatchDefaults__c WHERE Work_Order__c =: workOrderId limit 1];
        
            if(defaultList != null && !defaultList.isEmpty()){
                
                //DispatchDefaultRecordResult = defaultList[0].id;
                //dispatchDefaultWO.dispatchDefaultId = defaultList[0].id;
                if(string.isNotEmpty(defaultList[0].Work_Order__r.ISPDispatchPPID__c)){ // Addded by Harsha - Defect 5345225
                    defaultList[0].Work_Order__r.ISPDispatchPPID__c = defaultList[0].Work_Order__r.ISPDispatchPPID__c.replaceAll(',','<br/>');   
                }
                dispatchDefaultWO.dispatchDefault = defaultList[0];
                
                list<DispatchInstruction__c> dispInstList = new list<DispatchInstruction__c>();
                dispInstList = [SELECT Id,Instruction__c,DSP_Override_Request__c,Service_Type__c,Type__c,Work_Order__c 
                                    FROM DispatchInstruction__c WHERE DSP_Override_Request__c = true AND Work_Order__c=:workOrderId Order By createdDate desc LIMIT 1];
                if(dispInstList != null && !dispInstList.isEmpty()){
                        
                     //DispatchDefaultRecordResult += '++++'+dispInstList[0].Instruction__c;
                     dispatchDefaultWO.instruction = dispInstList[0].Instruction__c;
                }
                if(defaultList[0].Work_Order__r.Status=='Problem'){
                    dispatchDefaultWO.GccUser=DispatchGccConfiguration.isGCCuser ();
                }
                /*DispatchDefaultRecordResult += '++++'+defaultList[0].Work_Order__r.Alternate_Return_Address_Checkbox__c
                +','+defaultList[0].Work_Order__r.Alternate_Return_Street__c
                +','+defaultList[0].Work_Order__r.Alternate_Return_City__c
                +','+defaultList[0].Work_Order__r.Alternate_Return_State__c
                +','+defaultList[0].Work_Order__r.Alternate_Return_Postal_Code__c
                +','+defaultList[0].Work_Order__r.Alternate_Return_Country__c;
                
                dispatchDefaultWO.addressCheckbox = defaultList[0].Work_Order__r.Alternate_Return_Address_Checkbox__c;
                dispatchDefaultWO.addressStreet = defaultList[0].Work_Order__r.Alternate_Return_Street__c;
                dispatchDefaultWO.addressCity = defaultList[0].Work_Order__r.Alternate_Return_City__c;
                dispatchDefaultWO.addressState = defaultList[0].Work_Order__r.Alternate_Return_State__c;
                dispatchDefaultWO.addressPostalCode = defaultList[0].Work_Order__r.Alternate_Return_Postal_Code__c;
                dispatchDefaultWO.addressCountry = defaultList[0].Work_Order__r.Alternate_Return_Country__c;
                dispatchDefaultWO.epitomeReferenceNo = defaultList[0].Work_Order__r.Epitome_FSD_Ref__c;*/
            }
            return dispatchDefaultWO;
    }
    public class DispatchDefWOWrapper{
        
        @Auraenabled public DispatchDefaults__c dispatchDefault;
        @Auraenabled public String instruction;
        @Auraenabled public Boolean GccUser;
        /*@Auraenabled public String dispatchDefaultId;
        @Auraenabled public workOrder workorder;
        @Auraenabled public Boolean addressCheckbox;
        @Auraenabled public String addressStreet;
        @Auraenabled public String addressCity;
        @Auraenabled public String addressState;
        @Auraenabled public String addressPostalCode;
        @Auraenabled public String addressCountry;
        @Auraenabled public String epitomeReferenceNo;*/
        
        public DispatchDefWOWrapper(){
            
            dispatchDefault = new DispatchDefaults__c();
            instruction ='';
            /*workOrder = new WorkOrder();
            dispatchDefaultId = '';
            instruction ='';
            addressCheckbox =false;
            addressStreet ='';
            addressCity ='';
            addressState ='';
            addressPostalCode ='';
            addressCountry='';
            epitomeReferenceNo = '';*/
        }
    }    
    
    public class SelectedPartsWrapper{
        
        @Auraenabled public WorkOrderLineItem woLineItem;
        @Auraenabled  public DispatchPartsOrderLine__c partsOrderLineItem;
    }
    
    public class ReturnedPartsWrapper{
        
        @Auraenabled public WorkOrderLineItem woLineItem;
        @Auraenabled  public DispatchPartsOrderLine__c partsOrderLineItem;
    }
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:         getSelectedParts
    Description:  This method query selected parts from given work order id
    Date          Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    05/30/2018     1.0     Bikram Bebarta      Initial Release
    06/31/2018     1.0     Harsha Reddy        Updated Code based on Code Review Defect
    07/12/2018     1.1     Prachi Thube        Req# 5223525 - queried new fields to display on Part Section
    -------------------------------------------------------------------------------------------------------------------------- */
    
    @AuraEnabled
    public static list<SelectedPartsWrapper> getSelectedParts(Id workOrderId) {
            list<SelectedPartsWrapper> selectedPartsWrapperList = new list<SelectedPartsWrapper>();
            list<WorkOrder> workorderList = new List<WorkOrder>();
            workorderList = [Select id, (Select Part__c, PartNumber__c,URLLInk__c, Part_Quantity__c,Defective_PPID__c, SelectionMethod__c,Reason_for_Advanced_Search__c,PartPrice__c,PartDescription__c, ISPOCBBacklogETA__c, ISPOCBMessage__c,Do_not_Sub__c From WorkOrderLineItems where Selected_Work_Order__c!=null), 
                                                        (Select ISP_Part__c, ISP_Qty__c, ISP_ETA_Date_Time__c, ISP_Description__c, ISP_Status__c, ISP_Attempted_Delivery_Date_Time__c, ISP_New_PPID__c,ISP_With_Carrier_Date_Time__c, ISP_Service_Tag__c,ISP_Waybill__c,ISP_Job_Number__c,ISP_COM_Date_Time__c,ISP_SHP_Date_Time__c ,ISP_OHP_Date_Time__c,ISP_POD_Signatory__c ,ISP_REC_Date_Time__c,ISP_FSD_HUB__c,ISP_Unit_Price__c,ISP_Type__c,Part__c From DispatchPartsOrderLines__r) 
                                                        From WorkOrder WHERE id = :workOrderId LIMIT 500];
            
            if(workorderList != null && !workorderList.isEmpty()){
                for(WorkOrder wo : workorderList){
                    if(wo.WorkOrderLineItems != null && !wo.WorkOrderLineItems.isEmpty()){
                        for(WorkOrderLineItem woLineItem : wo.WorkOrderLineItems){
                            SelectedPartsWrapper selectedPartsWap = new SelectedPartsWrapper();
                            selectedPartsWap.woLineItem = woLineItem;
                            // check if there is any DispatchPartsOrderLines
                            
                            if(wo.DispatchPartsOrderLines__r != null && !wo.DispatchPartsOrderLines__r.isEmpty()){
                                
                                for(DispatchPartsOrderLine__c partOrderLine : wo.DispatchPartsOrderLines__r){
                                    
                                    if(woLineItem.PartNumber__c == partOrderLine.ISP_Part__c){
                                        
                                        selectedPartsWap.partsOrderLineItem = partOrderLine;
                                        break;                              
                                    }
                                    else if ((partOrderLine.ISP_Type__c == 'REPLACEMENT') && (woLineItem.Id == partOrderLine.Part__c)){
                                        selectedPartsWap.partsOrderLineItem = partOrderLine;
                                        break; 
                                    } 
                                }
                            }
                            
                            selectedPartsWrapperList.add(selectedPartsWap);
                        }
                    }
                }
            }
            return selectedPartsWrapperList;
    }
    
    

        
       /*
        list<ReturnedPartsWrapper> returnedPartsWrapperList = new list<ReturnedPartsWrapper>();
            list<WorkOrder> workorderList = new List<WorkOrder>();
            workorderList = [Select id, (Select Part__c, PartNumber__c, Part_Quantity__c From WorkOrderLineItems where Selected_Work_Order__c!=null), 
                                                        (Select  ISP_Status__c,ISP_Part__c, ISP_Description__c, ISP_Qty__c,  ISP_Return_Date__c,  ISP_Service_Tag__c  From DispatchPartsOrderLines__r where ISP_Return_Date__c!= null and ISP_Status__c ='Returned') 
                                                        From WorkOrder WHERE id = :workOrderId LIMIT 500];
            
            if(workorderList != null && !workorderList.isEmpty()){
                for(WorkOrder wo : workorderList){
                    if(wo.WorkOrderLineItems != null && !wo.WorkOrderLineItems.isEmpty()){
                        for(WorkOrderLineItem woLineItem : wo.WorkOrderLineItems){
                            ReturnedPartsWrapper returnedPartsWap = new ReturnedPartsWrapper();
                            returnedPartsWap.woLineItem = woLineItem;
                            // check if there is any DispatchPartsOrderLines
                            
                            if(wo.DispatchPartsOrderLines__r != null && !wo.DispatchPartsOrderLines__r.isEmpty()){
                                
                                for(DispatchPartsOrderLine__c partOrderLine : wo.DispatchPartsOrderLines__r){
                                    
                                    if(woLineItem.PartNumber__c == partOrderLine.ISP_Part__c){
                                        
                                        returnedPartsWap.partsOrderLineItem = partOrderLine;
                                        break;                              
                                    }
                                    else if ((partOrderLine.ISP_Type__c == 'REPLACEMENT') && (woLineItem.Id == partOrderLine.Part__c)){
                                        selectedPartsWap.partsOrderLineItem = partOrderLine;
                                        break; 
                                    }
                                }
                            }
                            
                            returnedPartsWrapperList.add(returnedPartsWap);
                        }
                    }
                }
            }
            return returnedPartsWrapperList;
        */
    //Archana Giliyar; Added for GCC User Story
    @AuraEnabled
    public static Map < String, Map <String, String>> getProviderValues(String CountryCode, String ProviderType) {
    
        List<DispatchDSPDLP__c> DLP = new List<DispatchDSPDLP__c>([Select PartnerCode__c, PartnerName__c From
            DispatchDSPDLP__c where Active__c = true AND Type__c =: ProviderType AND CountryCode__c =: CountryCode limit 50]);
        List<DispatchDSPDLP__c> CollectDLP = new List<DispatchDSPDLP__c>();
        
        //if(CountryCode == 'CA'){
           CollectDLP = ([Select PartnerCode__c, PartnerName__c From
            DispatchDSPDLP__c where Active__c = true AND Type__c =: 'Collect DLP' AND CountryCode__c =: CountryCode limit 50]);  
        //}
                
        Map < String, String > sDLPMap      =   new Map < String, String > ();
        Map < String, String > sCollDLPMap  =   new Map < String, String > ();
        Map <String, Map <String, String>> sDLPProviderMap  =   new Map < String, Map<String, String>> ();
                for (DispatchDSPDLP__c sDLP: DLP) {
                            sDLPMap.put(sDLP.PartnerCode__c, sDLP.PartnerName__c);
                }
            
            if(CollectDLP != null )
            {
               for (DispatchDSPDLP__c sCDLP: CollectDLP) {
                        sCollDLPMap.put(sCDLP.PartnerCode__c, sCDLP.PartnerName__c); 
                }
                sDLPProviderMap.put ('CollectDLP', sCollDLPMap);
            }
            sDLPProviderMap.put ('DLP', sDLPMap);
            
        
        return  sDLPProviderMap; 
    }
    
    @AuraEnabled
    public static void UpdateDispatchAttributes(Id recordId, string DLPName, string DLPCode, string ColDLPName, string ColDLPCode, string DPSType, string CallType )
    {
        if(string.isNotBlank(recordId)){
            WorkOrder woUpd= new WorkOrder (Id=recordId);
            //List<WorkOrder> Dispatch = new List<WorkOrder>();
               
                if(DLPName != null)
                {
                    woUpd.DLP_Name__c          =   DLPName;
                    woUpd.DLP__c               =   DLPCode;
                }
                woUpd.Collect_DLP_Name__c  =   ColDLPName;
                woUpd.Collect_DLP__c       =   ColDLPCode;
                woUpd.DPSType__c           =    DPSType;
                woUpd.CallType__c          =    CallType;
                update woUpd;
            }
            
    }
    /*@AuraEnabled
    public static void UpdateDSPAttributes(String recordId, string DPSType)
    {
        if(string.isNotBlank(recordId) && string.isNotBlank(DPSType)){
            WorkOrder woUpd= new WorkOrder (Id=recordId,DPSType__c =DPSType );
            update woUpd;
        }
    }
    @AuraEnabled
    public static void UpdateCallTypeAttributes (String recordId, string CallType)
    {
        if(string.isNotBlank(recordId) && string.isNotBlank(CallType)){
            WorkOrder woUpd= new WorkOrder (Id=recordId,CallType__c =CallType);
            update woUpd;
        }
    }*/
    
    @AuraEnabled
    public static void updateDisprecord(Id recordID, Boolean DSPOverride)
    {
    DispatchDefaults__c  dd =[Select Id from DispatchDefaults__c where Work_order__c=:recordID limit 1];
    
    DispatchDefaults__c dispObject = new DispatchDefaults__c(Id = dd.id);
    dispObject.DSP_Override_Request__c= DSPOverride;
    try
    {
    update dispObject;
    }
    
    Catch(Exception e)
    {
    
    }
    
    }
    
}