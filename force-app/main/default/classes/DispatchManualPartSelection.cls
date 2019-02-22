/*======================================================================================================================+
|  HISTORY                                                                  
|                                                                           
|  DATE            DEVELOPER                     WR/DEFECT            DESCRIPTION                               
|  ====            =========                     =========            =========== 
| 05/04/2018       Bikram/Hanumanth/Dattaa1      4913343              Dispatch: Manual Parts Selection & Add - List of Defective Components.
| 05/04/2018       Bikram/Hanumanth/Dattaa1      4976665              Part description not populated
| 01/30/2018       Harsha Reddy                  6122287              DEFECT 6122287
+======================================================================================================================*/
/*======================================================================================================================+
|  Test Class(es) Covering this class                                                                   
|      DispatchManualPartSelection_Test
|      DispatchTestSetupData
+======================================================================================================================*/
public class DispatchManualPartSelection {

    public class ManualCommodityWrapper {
        @Auraenabled public Boolean isSelected;
        @Auraenabled public String PartCommodityDef;
        @Auraenabled public String PartCommodityPof;
        @Auraenabled public String responseMessage;
    }
    public class CommodityPartsWrapper {
        @Auraenabled public Boolean isSelected;
        @Auraenabled public WorkOrderLineItem WorkOrderLineItemVal;
        @Auraenabled public String MessageBody;
    }
    //this will hold the selected manualReason values
    public with sharing class manualReasonWrap {
        @AuraEnabled public String selectedManualReason {
            get;
            set;
        }
        @AuraEnabled public List < string > selectedManualReasonList {
            get;
            set;
        }
        public manualReasonWrap() {
            selectedManualReason = '';
            selectedManualReasonList = new List < string > ();
        }
    }

    /*public class CommodityPartsWrapper
    {
    @Auraenabled public Boolean isSelected;
    @Auraenabled  public String partNumber;     
    @Auraenabled  public String partDescription;    
    @Auraenabled  public String partNumberDescription;
    @Auraenabled  public String commodityName;
    }*/

    public class ValidatedPartWrapper {
        @Auraenabled public Boolean isValidated;
        @Auraenabled public String partNumber;
        @Auraenabled public String responseMessage;
    }
    @TestVisible public static List < ReplacementParts__x > MockAutovalidateParts = new List < ReplacementParts__x > (); //This List will mock the creation of External Object Data for ReplacementParts
    @TestVisible public static List < validateReturnParts__x > MockvalidateParts = new List < validateReturnParts__x > (); //This List will mock the creation of External Object Data for validateReturnParts.
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getCommodities
    Description:  this functions makes a call to maestro to validate selected parts/PPID
    Input: recordId - work order record identifier
    recordId - work order record identifier
    partNumberPPID - part information           
    Output: list of commodity
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    04/07/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    /*@Auraenabled
    public static list<ValidatedPartWrapper> validatePartsBooked(Id workOrderId, Id workOrderLineItemId, string partNumberPPID)
    
    {
    try {
    list<ValidatedPartWrapper> validateWrapper = new list<ValidatedPartWrapper> ();    
    
    List<ValidatePartsBooked__x> validatedParts = new List<ValidatePartsBooked__x>();
    validatedParts = [SELECT ResponseCode__c, ResponseMessage__c FROM ValidatePartsBooked__x WHERE 
    AddressBUID__c = '2020' AND PartNumber__c = '9159M' AND OrderQuantity__c = '1' AND ServiceTag__c = 'BKRBJ72' 
    AND ISOCountryCode__c = 'CH' AND State__c = 'Ticino' AND City__c = 'Preonzo' AND PostalCode__c = '6523' 
    AND Billable__c = 'Y' AND KYHD__c = 'N' AND CompleteCare__c = 'N' AND KoreanMonitorRequest__c = 'N' 
    AND SanbaoFlag__c ='N' AND Category__c = 'Y' AND ServiceLevel__c = 'Next Business Day' AND ServiceHours__c = '8x5' 
    AND SystemClassification__c = 'Notebook' AND ServiceType__c = 'Parts and Labor' LIMIT 50000];     
    
    system.debug(validatedParts);
    
    return validateWrapper;
    }
    catch(exception e){
    ExceptionHandler.logHandledExceptions(e,'DispatchManualPartSelection','validatePartsBooked','Dispatch Management');
    return null;
    }
    }*/

    @Auraenabled
    public static list < ManualCommodityWrapper > getCommodities(Id recordId, Id assetId, string serviceTag, string addressBUID)
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       getCommodities
Description:  this functions makes a call to maestro to pull the commodities list
Input: recordId - work order record identifier
serviceTag - service tag name
addressBUID = address buid
Output: list of commodity
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
04/03/2018     1.0     Rodrigo Carpio      Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
    {
        list < ManualCommodityWrapper > commodityWrapper = new list < ManualCommodityWrapper > ();
        try {
            /*string responseCode;
            list<WorkOrderLineItem> workOrderLI = [SELECT PartCommodity__c FROM WorkOrderLineItem WHERE WorkOrderId = :recordId 
            AND ServiceTag__c = :serviceTag AND PartNumber__c = '' ];
            
            system.debug('workOrderLI ' + workOrderLI);
            if (workOrderLI.size()>0)
            {
            for(WorkOrderLineItem commodity :workOrderLI)
            {
            ManualCommodityWrapper itemWrapper =  new ManualCommodityWrapper();
            itemWrapper.isSelected = false;                
            itemWrapper.partCommodity = commodity.PartCommodity__c;                
            commodityWrapper.add(itemWrapper);
            system.debug('workOrderLI ' + itemWrapper);
            } 
            }
            else {*/
            list < GetCommodities__x > listObject = [select CommodityIDORDefectiveComponentID__c, CommodityORDefectiveComponent__c, ResponseCode__c, ResponseMessage__c
                from GetCommodities__x where ServiceTag__c =: serviceTag and AddressBUID__c =: addressBUID LIMIT 50000
            ];
            if (Test.isRunningTest()) {
                listObject = DispatchManualPartSelection_Test.getTestCommodities(DispatchManualPartSelection_Test.responseCode);
            }

            if (listObject.size() > 0) {
                list < WorkOrderLineItem > workItemListForCreate = new list < WorkOrderLineItem > ();
                if (listObject[0].ResponseCode__c == '100') {
                    //List<CommodityTypes__mdt> commodityList=[SELECT CommodityCategory__c,CommodityName__c FROM CommodityTypes__mdt];
                    //Set<String>DefectiveComponentSet=new Set<String>();
                    //Set<String>PartsOfFailureSet=new Set<String>();
                    /*for(CommodityTypes__mdt cmd:commodityList){
                        if(cmd.CommodityCategory__c!=null && cmd.CommodityCategory__c.containsIgnoreCase('Parts Of Failure') && cmd.CommodityName__c!=null){
                            PartsOfFailureSet.add(cmd.CommodityName__c.toLowerCase() );
                        }
                        else if(cmd.CommodityCategory__c!=null && cmd.CommodityCategory__c.containsIgnoreCase('Defective Component') && cmd.CommodityName__c!=null){
                            DefectiveComponentSet.add(cmd.CommodityName__c.toLowerCase() );
                        }
                    }*/
                    //System.debug('PartsOfFailureSet>>>'+PartsOfFailureSet);//comment the debugs once testing is completed
                    //System.debug('DefectiveComponentSet>>>'+DefectiveComponentSet);//comment the debugs once testing is completed

                    for (GetCommodities__x commodity: listObject) {
                        ManualCommodityWrapper itemWrapper = new ManualCommodityWrapper();
                        itemWrapper.isSelected = false;
                        itemWrapper.PartCommodityDef = commodity.CommodityORDefectiveComponent__c;
                        itemWrapper.responseMessage = System.Label.Dispatch_success;
                        commodityWrapper.add(itemWrapper);

                    }

                } else {
                    ManualCommodityWrapper itemWrapper = new ManualCommodityWrapper();
                    itemWrapper.isSelected = false;
                    itemWrapper.PartCommodityPof = null;
                    itemWrapper.PartCommodityDef = null;
                    itemWrapper.responseMessage = listObject[0].ResponseMessage__c;
                    commodityWrapper.add(itemWrapper);
                    //Database.SaveResult[] woList = Database.insert(workItemListForCreate, false);
                    //system.debug(woList);
                }
            }
            //}//end else

            return commodityWrapper;
        } catch (exception e) {
            ManualCommodityWrapper itemWrapper = new ManualCommodityWrapper();
            itemWrapper.isSelected = false;
            itemWrapper.PartCommodityPof = null;
            itemWrapper.PartCommodityDef = null;
            itemWrapper.responseMessage = e.getmessage();
            commodityWrapper.add(itemWrapper);
            ExceptionHandler.logHandledExceptions(e, 'DispatchManualPartSelection', 'getCommodities', 'Dispatch Management');
            return commodityWrapper;
        }

    }

    @Auraenabled
    public static list < CommodityPartsWrapper > getReplacementParts(Id WorkOrderId, ID assetId, string serviceTag, string addressBUID, string[] listCommodities, string searchText)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getReplacementParts
    Description:  this functions makes a call to maestro to pull Replacement Parts list
    Input:  WorkOrderId - work order record identifier
    serviceTag - service tag name
    addressBUID = address buid
    listCommodities - list of commodities
    Output: list Commodity parts information
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    04/03/2018     1.0     Rodrigo Carpio      Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    {
        list < string > requestList = new list < string > ();
        list < CommodityPartsWrapper > partsWrapper = new list < CommodityPartsWrapper > ();
        list < WorkOrderLineItem > workorderLineItemReturnList = new list < WorkOrderLineItem > ();
        list < WorkOrderLineItem > workorderLineItemList = new list < WorkOrderLineItem > ();
        List < WorkOrderLineItem > existingWorkItemList = new list < WorkOrderLineItem > ();
        Set < String > existingListCommodities = new Set < String > ();


        if (!listCommodities.isempty()) {
            /*List<String>listCommoditiesUpperCase=New List<String>();
            for(string str :listCommodities){
                String str1=str.toUppercase();
            }*/
            existingWorkItemList = [select Id, CFI_on_Work_Order__c, PartNumber__c, PartPrice__c, PartType__c, PartCommodity__c, Selected_By_user__c, SubComponent__c, PartDescription__c, FourHour__c, CustomerReplaceableUnit__c, FunctionalDescription__c, WorkOrderId, Selected_Work_Order__c, ServiceBUID__c, ServiceTag__c, Valid_Parts__c, Validate_Parts_Response__c from workorderLineItem
                WHERE WorkOrderId =: WorkOrderId
                And Line_Item_Type__c = 'MPS'
                AND PartCommodity__c in: listCommodities
                AND Selected_By_user__c = false LIMIT 50000
            ];
            for(workorderlineitem woli : existingWorkItemList){
                system.debug('existingWorkItemList cfi exists on wo or not ###'+woli.CFI_on_Work_Order__c);
            }
            if (!existingWorkItemList.isempty()) {
                for (workorderLineItem wl: existingWorkItemList) {
                    existingListCommodities.add(wl.PartCommodity__c);
                }

            }
            try {
                if (!existingListCommodities.containsAll(listCommodities)) {
                    for (string commodityStr: listCommodities) {
                        //string commodityStrUppercase= commodityStr.toUppercase();
                        //system.debug('commodityStrUppercase>>>'+commodityStrUppercase);
                        list < ReplacementParts__x > listObject = [SELECT PartNumber__c, CommodityName__c, FunctionalDescription__c, FourHrsSLA__c, CRU__c, FRU__c, AddressBUID__c, ResponseCode__c, ResponseMessage__c FROM ReplacementParts__x
                            WHERE ServiceTag__c =: serviceTag
                            AND AddressBUID__c =: addressBUID AND CommodityName__c =: commodityStr LIMIT 50000
                        ];
                        if (Test.isRunningTest()) {

                            /* list<ReplacementParts__x> ReplacementParts_MockRecList = new list<ReplacementParts__x>();
                             ReplacementParts__x ReplacementParts_MockRec = new ReplacementParts__x(ResponseCode__c = '100');
                             ReplacementParts_MockRecList.add(ReplacementParts_MockRec);
                             listObject.addall(ReplacementParts_MockRecList);
                             */
                            //listObject = DispatchManualPartSelection_Test.getTestReplacementParts(DispatchManualPartSelection_Test.responseCode);
                            listObject.addall(MockAutovalidateParts);
                        }

                        if (listObject.size() > 0) {
                            List < WorkOrder > workorderlist = new List < workOrder > ();
                            workorderlist = [Select ID, CFI_Exists__c, AssetId from WorkOrder where Id =: workOrderId LIMIT 1];
                            if (listObject[0].ResponseCode__c == '100') {

                                for (ReplacementParts__x commodity: listObject) {
                                    WorkOrderLineItem objWorkorderLineItem = new WorkOrderLineItem();
                                    objWorkorderLineItem.WorkOrderId = WorkOrderId;
                                    objWorkorderLineItem.AssetId = workorderlist[0].AssetId;
                                    objWorkorderLineItem.CFI_on_Work_Order__c = workorderlist[0].CFI_Exists__c;
                                    if (commodity.PartNumber__c != null && commodity.PartNumber__c != '' && commodity.PartNumber__c.length() > 127) {
                                        objWorkorderLineItem.PartNumber__c = commodity.PartNumber__c.substring(0, 127);
                                    } else {
                                        objWorkorderLineItem.PartNumber__c = commodity.PartNumber__c;
                                    }
                                    objWorkorderLineItem.PartPrice__c = ''; //No mapping Found
                                    objWorkorderLineItem.PartType__c = ''; //No mapping Found
                                    if (commodity.CommodityName__c != null && commodity.CommodityName__c != '' && commodity.CommodityName__c.length() > 127) {
                                        objWorkorderLineItem.PartCommodity__c = commodity.CommodityName__c.substring(0, 127);
                                    } else {
                                        objWorkorderLineItem.PartCommodity__c = commodity.CommodityName__c;
                                    }
                                    objWorkorderLineItem.SubComponent__c = ''; //No mapping Found
                                    objWorkorderLineItem.PartDescription__c = ''; //No mapping Found
                                    if (commodity.FunctionalDescription__c != null && commodity.FunctionalDescription__c != '' && commodity.FunctionalDescription__c.length() > 254) {
                                        objWorkorderLineItem.FunctionalDescription__c = commodity.FunctionalDescription__c.substring(0, 254);
                                    } else {
                                        objWorkorderLineItem.FunctionalDescription__c = commodity.FunctionalDescription__c;
                                    }
                                    if (commodity.FourHrsSLA__c != null && commodity.FourHrsSLA__c != '' && commodity.FourHrsSLA__c.length() > 4) {
                                        objWorkorderLineItem.FourHour__c = commodity.FourHrsSLA__c.substring(0, 4);
                                    } else {
                                        objWorkorderLineItem.FourHour__c = commodity.FourHrsSLA__c;
                                    }
                                    objWorkorderLineItem.CustomerReplaceableUnit__c = commodity.CRU__c;
                                    objWorkorderLineItem.FieldReplaceableUnit__c = commodity.FRU__c;
                                    if (commodity.AddressBUID__c != null && commodity.AddressBUID__c != '' && commodity.AddressBUID__c.length() > 80) {
                                        objWorkorderLineItem.ServiceBUID__c = commodity.AddressBUID__c.substring(0, 79);
                                    } else {
                                        objWorkorderLineItem.ServiceBUID__c = commodity.AddressBUID__c;
                                    }
                                    objWorkorderLineItem.Line_Item_Type__c = System.Label.Dispatch_MPS;
                                    //objWorkorderLineItem.Selected_By_user__c=false;
                                    //objWorkorderLineItem.ServiceTag__c = nextGen.ServiceTag__c;
                                    if (commodity.PartNumber__c.length() > 127 && commodity.PartNumber__c != null && commodity.PartNumber__c != '') {
                                        //objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId).substring(0, 15) + '_' + commodity.PartNumber__c.substring(0, 80);
                                        objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId)+ commodity.PartNumber__c.substring(0, 80);
                                    } else {
                                        //objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId).substring(0, 15) + '_' + commodity.PartNumber__c;
                                        objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId)+ commodity.PartNumber__c;
                                    }
                                    workorderLineItemList.add(objWorkorderLineItem);
                                }
                            } else {
                                CommodityPartsWrapper itemWrapper = new CommodityPartsWrapper();
                                itemWrapper.isselected = false;
                                itemWrapper.WorkOrderLineItemVal = null;
                                itemWrapper.MessageBody = listObject[0].ResponseMessage__c;
                                partsWrapper.add(itemWrapper);
                            }
                        }
                    }
                }
            } catch (exception e) {
                ExceptionHandler.logHandledExceptions(e, 'DispatchManualPartSelection', 'getReplacementParts', 'Dispatch Management');
                CommodityPartsWrapper itemWrapper = new CommodityPartsWrapper();
                itemWrapper.isselected = false;
                itemWrapper.WorkOrderLineItemVal = null;
                itemWrapper.MessageBody = e.getmessage();
                partsWrapper.add(itemWrapper);
                return partsWrapper;
            }
        }
        if (searchText != null && searchText != '') {
            searchText = searchText.toUppercase();
            List < validateReturnParts__x > validatedReturnPart = new List < validateReturnParts__x > ();

            try {
                validatedReturnPart = [SELECT Commodity__c, FunctionalDescription__c, PartNumber__c, PartType__c, Price__c, ResponseCode__c, ResponseMessage__c, ServiceBUID__c, Subcomponent__c,
                    FourHrsSLA__c, ValidPart__c, ItemExists__c, WarningMessage__c, CRU__c, FRU__c
                    FROM ValidateReturnParts__x
                    WHERE PartNumber__c =: searchText and ServiceBUID__c =: addressBUID LIMIT 5
                ];
            } catch (exception ex) {
                CommodityPartsWrapper itemWrapper = new CommodityPartsWrapper();
                itemWrapper.isselected = false;
                itemWrapper.WorkOrderLineItemVal = null;
                itemWrapper.MessageBody = ex.getmessage();
                partsWrapper.add(itemWrapper);
                return partsWrapper;
            }


            if (Test.isRunningTest()) {
                /*list<validateReturnParts__x> validateReturnParts_MockRecList = new list<validateReturnParts__x>();
                validateReturnParts__x validateReturnParts_MockRec = new validateReturnParts__x(ResponseCode__c = '100',PartNumber__c='testPartNumber-'+system.now());
                validateReturnParts_MockRecList.add(validateReturnParts_MockRec);
                validatedReturnPart.addall(validateReturnParts_MockRecList);*/
                validatedReturnPart.addall(MockvalidateParts);
            }
            if (!validatedReturnPart.isempty() && validatedReturnPart[0].ValidPart__c != 'false') {
                List < WorkOrder > workorderlist = new List < workOrder > ();
                // Added CFI_Exists__c Field in SOQL Query - DEFECT 6122287 - Harsha Reddy
                workorderlist = [Select ID,CFI_Exists__c, AssetId from WorkOrder where Id =: workOrderId LIMIT 1];
                for (validateReturnParts__x commodity: validatedReturnPart) {
                    WorkOrderLineItem objWorkorderLineItem = new WorkOrderLineItem();
                    objWorkorderLineItem.WorkOrderId = WorkOrderId;
                    objWorkorderLineItem.AssetId = workorderlist[0].AssetId;
                    objWorkorderLineItem.CFI_on_Work_Order__c = workorderlist[0].CFI_Exists__c;//// Added by Harsha Reddy - DEFECT 6122287
                    if (commodity.PartNumber__c != null && commodity.PartNumber__c != '' && commodity.PartNumber__c.length() > 127) {
                        objWorkorderLineItem.PartNumber__c = commodity.PartNumber__c.substring(0, 127);
                    } else {
                        objWorkorderLineItem.PartNumber__c = commodity.PartNumber__c;
                    }
                    if (commodity.Price__c != null && commodity.Price__c != '' && commodity.Price__c.length() > 127) {
                        objWorkorderLineItem.PartPrice__c = commodity.Price__c.substring(0, 127);
                    } else {
                        objWorkorderLineItem.PartPrice__c = commodity.Price__c;
                    }
                    if (commodity.PartType__c != null && commodity.PartType__c != '' && commodity.PartType__c.length() > 127) {
                        objWorkorderLineItem.PartType__c = commodity.PartType__c.substring(0, 127);
                    } else {
                        objWorkorderLineItem.PartType__c = commodity.PartType__c;
                    }
                    if (commodity.Commodity__c != null && commodity.Commodity__c != '' && commodity.Commodity__c.length() > 127) {
                        objWorkorderLineItem.PartCommodity__c = commodity.Commodity__c.substring(0, 127);
                    } else {
                        objWorkorderLineItem.PartCommodity__c = commodity.Commodity__c;
                    }
                    if (commodity.Subcomponent__c != null && commodity.Subcomponent__c != '' && commodity.Subcomponent__c.length() > 127) {
                        objWorkorderLineItem.SubComponent__c = commodity.Subcomponent__c.substring(0, 127);
                    } else {
                        objWorkorderLineItem.SubComponent__c = commodity.Subcomponent__c;
                    }
                    //if(commodity.AddressBUID__c!=null && commodity.AddressBUID__c!=''){
                    objWorkorderLineItem.PartDescription__c = ''; //No mapping Found
                    //}
                    if (commodity.FunctionalDescription__c != null && commodity.FunctionalDescription__c != '' && commodity.FunctionalDescription__c.length() > 254) {
                        objWorkorderLineItem.FunctionalDescription__c = commodity.FunctionalDescription__c.substring(0, 254);
                    } else {
                        objWorkorderLineItem.FunctionalDescription__c = commodity.FunctionalDescription__c;
                    }
                    if (commodity.FourHrsSLA__c != null && commodity.FourHrsSLA__c != '' && commodity.FourHrsSLA__c.length() > 4) {
                        objWorkorderLineItem.FourHour__c = commodity.FourHrsSLA__c.substring(0, 4);
                    } else {
                        objWorkorderLineItem.FourHour__c = commodity.FourHrsSLA__c;
                    }
                    objWorkorderLineItem.CustomerReplaceableUnit__c = commodity.CRU__c;
                    objWorkorderLineItem.FieldReplaceableUnit__c = commodity.FRU__c;
                    objWorkorderLineItem.ServiceBUID__c = addressBUID; // need to check this mapping
                    objWorkorderLineItem.Line_Item_Type__c = System.Label.Dispatch_MPS;
                    //objWorkorderLineItem.Selected_By_user__c=false;
                    //objWorkorderLineItem.ServiceTag__c = nextGen.ServiceTag__c;
                    if (commodity.PartNumber__c != null && commodity.PartNumber__c != '' && commodity.PartNumber__c.length() > 127) {
                        //objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId).substring(0, 15) + '_' + commodity.PartNumber__c.substring(0, 80);
                        objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId)+ commodity.PartNumber__c.substring(0, 80);
                    } else {
                        //objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId).substring(0, 15) + '_' + commodity.PartNumber__c;
                        objWorkorderLineItem.External_Id__c = String.valueof(WorkOrderId)+ commodity.PartNumber__c;
                    }
                    workorderLineItemList.add(objWorkorderLineItem);
                }
            } else {
                if (!validatedReturnPart.isempty() && validatedReturnPart[0].ValidPart__c == 'false' && validatedReturnPart[0].ItemExists__c == 'N') {
                    CommodityPartsWrapper itemWrapper = new CommodityPartsWrapper();
                    itemWrapper.isselected = false;
                    itemWrapper.WorkOrderLineItemVal = null;
                    itemWrapper.MessageBody = System.Label.Dispatch_No_Results_found;
                    partsWrapper.add(itemWrapper);
                    return partsWrapper;
                }
            }

        }
        if (workorderLineItemList.size() > 0) {
            upsert workorderLineItemList External_Id__c;
        }
        //list<WorkOrderLineItem >workorderLineItemSelected=[Select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,WorkOrderId,Selected_Work_Order__c,ServiceBUID__c,ServiceTag__c,Valid_Parts__c,Validate_Parts_Response__c from workorderLineItem where WorkOrderId=:WorkOrderId and Line_Item_Type__c='MPS' and Selected_By_user__c=true];
        //commenting this block as we dont have to display the already selected parts.
        /*list<WorkOrderLineItem >workorderLineItemSelected=[Select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,External_Id__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FieldReplaceableUnit__c ,FunctionalDescription__c,WorkOrderId,Selected_Work_Order__c,ServiceBUID__c,ServiceTag__c,Valid_Parts__c,Part_Quantity__c,ItemExists__c,Validate_Parts_Response__c,Image_Url__c from workorderLineItem where WorkOrderId=:WorkOrderId and Line_Item_Type__c='MPS' and Selected_By_user__c=true LIMIT 50000];
        If(!workorderLineItemSelected.isempty()){
            workorderLineItemReturnList.addall(workorderLineItemSelected);
        }*/
        If(!listCommodities.isempty()) {
            //list<WorkOrderLineItem > workorderLineItemCommodities =[select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,WorkOrderId,Selected_Work_Order__c,ServiceBUID__c,ServiceTag__c,Valid_Parts__c,Validate_Parts_Response__c from workorderLineItem where WorkOrderId=:WorkOrderId and Line_Item_Type__c='MPS' and PartCommodity__c in :listCommodities and Selected_By_user__c=false];
            list < WorkOrderLineItem > workorderLineItemCommodities = [select Id, CFI_on_Work_Order__c,URLLInk__c,DefectiveComponent__c, PartNumber__c, PartPrice__c, PartType__c, PartCommodity__c, Selected_By_user__c, SubComponent__c, External_Id__c, PartDescription__c, FourHour__c, CustomerReplaceableUnit__c, FieldReplaceableUnit__c, FunctionalDescription__c, WorkOrderId, Selected_Work_Order__c, ServiceBUID__c, ServiceTag__c, Valid_Parts__c, Part_Quantity__c, ItemExists__c, Validate_Parts_Response__c, Image_Url__c from workorderLineItem where WorkOrderId =: WorkOrderId and Line_Item_Type__c = 'MPS'
                and PartCommodity__c in: listCommodities order by PartCommodity__c LIMIT 1000
            ];
            workorderLineItemReturnList.addall(workorderLineItemCommodities);
        }
        if (searchText != null && searchText != '') {
            //list<WorkOrderLineItem > workorderLineItemSearch =[select Id,PartNumber__c,PartPrice__c,PartType__c,PartCommodity__c,Selected_By_user__c,SubComponent__c,PartDescription__c,FourHour__c,CustomerReplaceableUnit__c,FunctionalDescription__c,WorkOrderId,Selected_Work_Order__c,ServiceBUID__c,ServiceTag__c,Valid_Parts__c,Validate_Parts_Response__c from workorderLineItem where WorkOrderId=:WorkOrderId and Line_Item_Type__c='MPS' and PartNumber__c =:searchText and Selected_By_user__c=false];
            list < WorkOrderLineItem > workorderLineItemSearch = [select Id, CFI_on_Work_Order__c, PartNumber__c,DefectiveComponent__c, URLLInk__c,PartPrice__c, PartType__c, PartCommodity__c, Selected_By_user__c, SubComponent__c, External_Id__c, PartDescription__c, FourHour__c, CustomerReplaceableUnit__c, FieldReplaceableUnit__c, FunctionalDescription__c, WorkOrderId, Selected_Work_Order__c, ServiceBUID__c, ServiceTag__c, Valid_Parts__c, Part_Quantity__c, ItemExists__c, Validate_Parts_Response__c, Image_Url__c from workorderLineItem where WorkOrderId =: WorkOrderId and Line_Item_Type__c = 'MPS'
                and PartNumber__c =: searchText LIMIT 1000
            ];
            workorderLineItemReturnList.addall(workorderLineItemSearch);
        }
        /*if(workorderLineItemList.isempty()){
            workorderLineItemList.addall(existingWorkItemList);
        }*/
        for (WorkOrderLineItem wl: workorderLineItemReturnList) {
            CommodityPartsWrapper itemWrapper = new CommodityPartsWrapper();
            itemWrapper.isselected = false;
            itemWrapper.WorkOrderLineItemVal = wl;
            itemWrapper.MessageBody = System.Label.Dispatch_success;
            partsWrapper.add(itemWrapper);
        }
        if (partsWrapper.isempty()) {
            CommodityPartsWrapper itemWrapper = new CommodityPartsWrapper();
            itemWrapper.isselected = false;
            itemWrapper.WorkOrderLineItemVal = null;
            itemWrapper.MessageBody = System.Label.Dispatch_No_Results_found;
            partsWrapper.add(itemWrapper);
        }
        return partsWrapper;
    }

    /*
    Name : validateSelectedParts
    Description : Method to validate the selected Parts based on CallType and return the validated LineItem list
    */
    @Auraenabled
    public static list < CommodityPartsWrapper > validateSelectedParts(List < workorderLineItem > selectedParts, string manualSelectReason, Boolean autoAddCFIPartForHardDrive) {
        // DEFECT 5462004 - Harsha -08/21/2018 - Added New Param - manualSelectReason
        
        List < CommodityPartsWrapper > validatedLineItemList = new List < CommodityPartsWrapper > ();
        List < AutoSelectPartController.workorderLineItemWrapper > autoselectwraplist = AutoSelectPartController.validateSelectedParts(selectedParts, false, 'MPS', autoAddCFIPartForHardDrive);

        //DEFECT 5462004 - Harsha -08/21/2018 - Starts Here
        List < workorderLineItem > selectPartList = new List < workorderLineItem > ();
        string responseMsg = ' ';
        //DEFECT 5462004 - Harsha -08/21/2018 - Ends Here

        if (!autoselectwraplist.isempty()) {

            for (AutoSelectPartController.workorderLineItemWrapper wlw: autoselectwraplist) {
                CommodityPartsWrapper cmd = new CommodityPartsWrapper();
                cmd.isSelected = wlw.isSelected;
                cmd.WorkOrderLineItemVal = wlw.WorkOrderLineItemVal;
                //cmd.MessageBody='';
                cmd.MessageBody = wlw.responseMessage; // DEFECT 5462004 - Harsha -08/21/2018
                validatedLineItemList.add(cmd);
                //DEFECT 5462004 - Harsha -08/21/2018 - Starts Here
                responseMsg = wlw.responseMessage;
                if (wlw.WorkOrderLineItemVal != null && wlw.responseMessage.equalsIgnoreCase(System.Label.Dispatch_success)) {
                    if (wlw.WorkOrderLineItemVal.Selected_By_user__c) {
                        selectPartList.add(wlw.WorkOrderLineItemVal);
                    }
                }
                // DEFECT 5462004 - Harsha -08/21/2018 - Ends Here
            }

            //DEFECT 5462004 - Harsha -08/21/2018 - Starts Here
            if (!selectPartList.isEmpty() && selectPartList.size() > 0) {
                string response = AutoSelectPartController.saveSelectedParts(selectedParts, System.Label.Dispatch_MPS, manualSelectReason,autoAddCFIPartForHardDrive);
                if (!string.isNotBlank(response) || !response.containsIgnoreCase(System.Label.Dispatch_success)) {
                    validatedLineItemList.clear();
                    CommodityPartsWrapper cmd = new CommodityPartsWrapper();
                    cmd.isSelected = false;
                    cmd.WorkOrderLineItemVal = null;
                    cmd.MessageBody = response;
                    validatedLineItemList.add(cmd);
                }
            }
            //DEFECT 5462004 - Harsha -08/21/2018 - Ends Here
        }
        return validatedLineItemList;
    }

    /*@AuraEnabled
    public static List<AutoSelectPartController.AutoSelectPartWrapper> insertAndReturnWorkOrderLI(String workOrderIds, String serviceTag, String addressBUID){
        List<AutoSelectPartController.AutoSelectPartWrapper> autoselectwraplist = AutoSelectPartController.insertAndReturnWorkOrderLI(workOrderIds,serviceTag,addressBUID);
        return autoselectwraplist;
    }*/
    /*
    Name: saveSelectedParts
    Description : Method to save the selected Part List on the workorder
    */
    /* Commented By Harsha - Defect DEFECT 5462004
    @AuraEnabled
    public static string saveSelectedParts(List < workorderLineItem > selectedParts, String callType, String manualSelectReason) {
        string returnsuccess = AutoSelectPartController.saveSelectedParts(selectedParts, 'MPS', manualSelectReason);
        return returnsuccess;
    }
    */

    /*
    Name : getManualSelectionReason
    Description : Method to fetch the Manual Selection reason
    */
    @AuraEnabled
    public static manualReasonWrap getManualSelectionReason(Id WorkOrderId) {
        manualReasonWrap manualReasonWrapInstance = new manualReasonWrap();
        Schema.DescribeFieldResult fieldResult = WorkOrderLineItem.Reason_for_Advanced_Search__c.getDescribe();
        List < Schema.PicklistEntry > pick_list_values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pe: pick_list_values) {
            manualReasonWrapInstance.selectedManualReasonList.add(pe.getValue());
        }
        return manualReasonWrapInstance;
    }
}