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
public class DispatchPartInsertionHelper {
    /*
        generic method to insert Info parts
    */
     /* -----------------------------------------------------------------------------------------------------------------------
    Name: getInfoParts
    Description:  this method makes the oData call to get information about parts for a searchText user has provided on the UI while searching for the parts
    Input: WorkOrderId - Id of the workorder record user is working on 
    assetId - asset record Id
    serviceTag - service tag which is being used
    addressBUID - address BUID value
    listCommodities - list of commodities  
    searchText - search message user has entered on the UI in order to search the parts
    warningMessage - warning message used to dispaly
    callType - call type being used 
    Output: list<WorkOrderLineItem> - list of workorderlineitems fetched        
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    24/04/2018     1.0    Datta1             Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */ 
    public static list<WorkOrderLineItem> getInfoParts(Id WorkOrderId, ID assetId, String serviceTag, String addressBUID, String[] listCommodities,String searchText,String warningMessage,String callType, Boolean autoAddCFIPart){
        try{
            list<WorkOrderLineItem> WorkOrderLineItemList = new list<WorkOrderLineItem>(); 
            
            if(autoAddCFIPart){
              List<WorkOrder> workorderlist = new List<workOrder>();
              workorderlist=[Select ID,AssetId from WorkOrder where Id=:workOrderId LIMIT 1]; 
                WorkOrderLineItem objWorkorderLineItem = new WorkOrderLineItem();
                objWorkorderLineItem.Selected_By_user__c=true;
                objWorkorderLineItem.Selected_Work_Order__c=WorkOrderId;
                 objWorkorderLineItem.Work_Order_Id_Text__c= String.valueOf(WorkOrderId);
                objWorkorderLineItem.WorkOrderId = WorkOrderId;
                objWorkorderLineItem.AssetId=workorderlist[0].AssetId;
                objWorkorderLineItem.PartCommodity__c = searchText;
                objWorkorderLineItem.Dont_delete_on_bulk_deletion__c = true;
                List<Work_Order_Auto_Parts__mdt> partToBeAutoAddedMetadata = [Select Id, DeveloperName, DESC_TEXT__c, Type__c, Value__c
                                                                                 from Work_Order_Auto_Parts__mdt LIMIT 49000];
                Map<String,Work_Order_Auto_Parts__mdt> partToBeAutoAddedMetadataMap = new Map<String,Work_Order_Auto_Parts__mdt>();
                for(Work_Order_Auto_Parts__mdt mdt : partToBeAutoAddedMetadata){
                  partToBeAutoAddedMetadataMap.put(mdt.Value__c,mdt);
                }
                if(!partToBeAutoAddedMetadataMap.isEmpty() && partToBeAutoAddedMetadataMap.containsKey(searchText)){
                    objWorkorderLineItem.PartNumber__c = partToBeAutoAddedMetadataMap.get(searchText).Value__c;
                    objWorkorderLineItem.PartType__c = partToBeAutoAddedMetadataMap.get(searchText).Type__c;
                    objWorkorderLineItem.PartDescription__c = partToBeAutoAddedMetadataMap.get(searchText).DESC_TEXT__c;
                  //objWorkorderLineItem.External_Id__c=string.valueof(WorkOrderId).substring(0,15)+'_'+partToBeAutoAddedMetadataMap.get(searchText).Value__c+;
              }
              objWorkorderLineItem.ServiceBUID__c = addressBUID;// need to check this mapping
                objWorkorderLineItem.Line_Item_Type__c='Auto CFI Part added with - Hard Drive/Solid State Drive'+'-'+callType;                
                objWorkorderLineItem.Warning_Message__c=warningMessage;
                workorderLineItemList.add(objWorkorderLineItem);
            }
            if(!autoAddCFIPart && searchText!=null && searchText!=''){
                List<validateReturnParts__x> validatedReturnPart=new List<validateReturnParts__x> ();
                try{
                    validatedReturnPart=[SELECT Commodity__c,FunctionalDescription__c,PartNumber__c,PartType__c,Price__c,ResponseCode__c,ResponseMessage__c,ServiceBUID__c,Subcomponent__c,FourHrsSLA__c,ValidPart__c,ItemExists__c//CRU__c,FRU__c, WarningMessage__c,
                                         FROM ValidateReturnParts__x WHERE PartNumber__c =:searchText and ServiceBUID__c=:addressBUID  LIMIT 5];
                }
                catch(exception ex){
                    return null;
                }
                if(Test.isRunningTest()){
                    list<validateReturnParts__x> validateReturnParts_MockRecList = new list<validateReturnParts__x>();
                    validateReturnParts__x validateReturnParts_MockRec = new validateReturnParts__x(ResponseCode__c = '100',PartNumber__c='testPartNumber-'+system.now());
                    validateReturnParts_MockRecList.add(validateReturnParts_MockRec);
                    validatedReturnPart.addall(validateReturnParts_MockRecList);
                }
                
                if(!validatedReturnPart.isempty() && validatedReturnPart[0].ValidPart__c!='false' ){
                    List<WorkOrder> workorderlist = new List<workOrder>();
                    workorderlist=[Select ID,AssetId from WorkOrder where Id=:workOrderId LIMIT 1]; 
                    for(validateReturnParts__x commodity :validatedReturnPart){
                        WorkOrderLineItem objWorkorderLineItem = new WorkOrderLineItem();
                        objWorkorderLineItem.WorkOrderId = WorkOrderId;
                        objWorkorderLineItem.AssetId=workorderlist[0].AssetId;
                        objWorkorderLineItem.PartNumber__c = commodity.PartNumber__c;
                        objWorkorderLineItem.PartPrice__c = commodity.Price__c;
                        objWorkorderLineItem.PartType__c = commodity.PartType__c;
                        objWorkorderLineItem.PartCommodity__c = commodity.Commodity__c;
                        objWorkorderLineItem.SubComponent__c = commodity.Subcomponent__c;
                        objWorkorderLineItem.PartDescription__c = '';//No mapping Found
                        objWorkorderLineItem.FunctionalDescription__c = commodity.FunctionalDescription__c;
                        objWorkorderLineItem.FourHour__c = commodity.FourHrsSLA__c;
                        //objWorkorderLineItem.CustomerReplaceableUnit__c = commodity.CRU__c;
                        //objWorkorderLineItem.FieldReplaceableUnit__c  = commodity.FRU__c;
                        objWorkorderLineItem.ServiceBUID__c = addressBUID;// need to check this mapping
                        objWorkorderLineItem.Line_Item_Type__c='Info Parts-Hard Drive'+'-'+callType;
                        objWorkorderLineItem.Warning_Message__c=warningMessage;
                        //objWorkorderLineItem.Selected_By_user__c=false;
                        //objWorkorderLineItem.ServiceTag__c = nextGen.ServiceTag__c;
                        //objWorkorderLineItem.External_Id__c=string.valueof(WorkOrderId).substring(0,15)+'_'+commodity.PartNumber__c;
                        objWorkorderLineItem.External_Id__c=string.valueof(WorkOrderId)+commodity.PartNumber__c;
                        workorderLineItemList.add(objWorkorderLineItem);
                    }
                }
                else{
                    if(!validatedReturnPart.isempty() && validatedReturnPart[0].ValidPart__c=='false' && validatedReturnPart[0].ItemExists__c=='N'){
                        return null;
                    }
                }
            } 
            return WorkOrderLineItemList;
         }
         Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchPartInsertionHelper','getInfoParts','getInfoParts');
            return null;
        }
    }
    /*
        This Method will add an alert for workOrder whenever required.
    */
      /* -----------------------------------------------------------------------------------------------------------------------
    Name: addAlertForWorkOrder
    Description:  this method inserts dispatch alert records for the supplied work order Id
    Input: WorkOrderIdVal - Id of the workorder record  
    alertDetails - details to be entered in the Alert_Details__c field of dispatch alert record
    alertReason - reason to be entered in the Alert_Reason__c field of dispatch alert record
    isBlocked - boolean parameter which will hold the value whether blocked__c field will be marked as true or false 
    AlertName - what name will be given to the dispatch alert record which is to be created  
    
    Output: Dispatch_Alert__c - list of workorderlineitems fetched        
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    24/04/2018     1.0    Datta1             Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */ 
    public static Dispatch_Alert__c addAlertForWorkOrder(string WorkOrderIdVal, String alertDetails, String alertReason, Boolean isBlocked, String AlertName){
        
        try{
            If(WorkOrderIdVal!=null && WorkOrderIdVal!=''){
                Dispatch_Alert__c dispacthAlert= new Dispatch_Alert__c ();
                dispacthAlert.Work_Order__c=(Id) WorkOrderIdVal;
                dispacthAlert.Alert_Details__c=alertDetails;
                dispacthAlert.Alert_Reason__c=alertReason;
                dispacthAlert.Blocked__c=isBlocked;
                dispacthAlert.Name=AlertName;
                if(WorkOrderIdVal!=null && string.valueof(WorkOrderIdVal).length()>=15){
                    dispacthAlert.Alerts_Id__c=string.valueof(WorkOrderIdVal).substring(0,15)+'_'+alertReason;
                }
                return dispacthAlert;
            }
            return null;
       }
       Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchPartInsertionHelper','addAlertForWorkOrder','addAlertForWorkOrder');
            return null;
        }
    }
}