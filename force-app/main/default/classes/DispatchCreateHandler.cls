/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchCreatehHandler
Description:  This class contain method that handles work order creation - story #4316217
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/26/2018     1.0    Rodrigo Carpio       Initial Release
01/02/2019            Ruthirappan          GetAssetHoldValue Method to get Asset Hold Value from Asset Hold Status Custom Metadata
-------------------------------------------------------------------------------------------------------------------------- */

public class DispatchCreateHandler {

    @TestVisible public static List < ValidateReturnParts__x > MockAutovalidateParts = new List < ValidateReturnParts__x > ();
    public class RepeatDispatchWap {
        @AuraEnabled public Boolean ifAssetPurchasedRecently {
            get;
            set;
        }
        @AuraEnabled public String ServiceBUID {
            get;
            set;
        }
        @AuraEnabled public Boolean ifAssetHasRepeatDispatch {
            get;
            set;
        }
        @AuraEnabled public Integer recordsCount {
            get;
            set;
        }
        @AuraEnabled public Boolean invalidPPID {
            get;
            set;
        }

        public repeatDispatchWap() {
            ifAssetPurchasedRecently = false;
            ifAssetHasRepeatDispatch = false;
            recordsCount = 0;
            invalidPPID = false;
            ServiceBUID = '';
        }
    }

    @AuraEnabled
    public static RepeatDispatchWap checkRepeatDispatchInAsset(string caseId,String countryCode)
    /* 
       Description : Check if Asset is purchased recently and if there is any workorder has been created in last 28 days in Asset associated to the case.
       Author      : Bikram B
       Date        : 27th March, 2018
    */
    {
        try {

            RepeatDispatchWap dispatchwap = new RepeatDispatchWap();
            Integer recordsCount = 0;
            boolean ifAssetHasRepeatDispatch = false;
            if (!string.isBlank(caseId)) {
                //Integer lastNDays_AssetPurchasedDate = 30;
                //system.debug('Akhil++ inside checkRepeatDispatchInAsset');
                System.debug('Akhil++ CountryCode :'+ countryCode);
                Integer lastNDays_AssetPurchasedDate;
                if(countryCode<>NULL && !(String.isBlank(countryCode))){
                    //system.debug('Akhil++ inside checkRepeatDispatchInAsset CountryCode:'+countryCode);
                    List<Asset_Country__mdt> acList =[Select Invoice_Time__c,CountryCode__c from Asset_Country__mdt where CountryCode__c=:countryCode LIMIT 1];
                    if(acList<>NULL && acList.size()>0){
                        lastNDays_AssetPurchasedDate = (Integer) acList[0].Invoice_Time__c;
                    }
                }
                Integer lastNDays = 28;
                Date dispatchCreatedDateToCompare = Date.today().addDays(-1 * lastNDays);
                List < Case > csList = [select AssetId from
                    case where id = :
                        caseId LIMIT 1
                ];
                if (csList != null && !csList.isEmpty() && csList[0].AssetId != null) {
                    Asset assetRec = [select Asset_Age__c, Invoice_Date_New__c, Customer_BUID__c,
                        (select CreatedDate from workorders WHERE CreatedDate >=: dispatchCreatedDateToCompare and(status != 'Open'
                                and status != 'Cancelled')
                            //and status IN('Pending Review', 'Approved', 'Problem', 'Work In Progress', 
                            //              'Submitted', 'Awaiting Acknowledgement','Queued')
                        )
                        from Asset where id =: csList[0].AssetId LIMIT 1
                    ];

                    dispatchwap.ServiceBUID = assetRec.Customer_BUID__c;
                    // Check if the Asset is purchased within the last 30 days
                    if (assetRec.Invoice_Date_New__c != null) {
                        //system.debug('Akhil++ inside invoice date is not null:'+lastNDays_AssetPurchasedDate);
                        Integer numberofDays = assetRec.Invoice_Date_New__c.daysBetween(system.today());
                        if (lastNDays_AssetPurchasedDate<>NULL && countryCode<>NULL && numberofDays >= 0 && numberofDays <= lastNDays_AssetPurchasedDate) {
                            //system.debug('Akhil++ inside checkRepeatDispatchInAsset lastpurchasedDate:'+lastNDays_AssetPurchasedDate);
                            dispatchwap.ifAssetPurchasedRecently = true;
                        }
                    }

                    //else if(assetRec.workorders != null && !assetRec.workorders.isEmpty()){
                    //if(!dispatchwap.ifAssetPurchasedRecently && assetRec.workorders != null && !assetRec.workorders.isEmpty()){
                    if (assetRec.workorders != null && !assetRec.workorders.isEmpty()) {
                        ifAssetHasRepeatDispatch = true;
                        recordsCount = assetRec.workorders.size();
                        dispatchwap.ifAssetHasRepeatDispatch = ifAssetHasRepeatDispatch;
                        dispatchwap.recordsCount = recordsCount;
                    }
                }
            }
            return dispatchwap;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'CreateDispatchHandler', 'checkRepeatDispatchInAsset', 'Dispatch Management');
            return null;
        }
    }


    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld)
    /* 
       Description : Get picklist field values from given object and field name
       Author      : Bikram B
       Date        : 28th March, 2018
    */
    {
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();

        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }

    /*
    Description : Method to Validate the PPID and return part list
    */
    @AuraEnabled
    public static List < String > validatePPID(List < String > PPIDList, String ServiceBUID) {
        List < String > returnedList = new List < String > ();

        List < ValidateReturnParts__x > validatereturnparts = new List < ValidateReturnParts__x > ();
        List < String > PPIDStringList = new List < String > ();
        Map < String, String > PPIDpartmap = new Map < String, String > ();
        
        system.debug('PPIDList ===>  '+PPIDList);
        if (!PPIDList.IsEmpty()) {
            for (String str: PPIDList) {
                if (!PPIDpartmap.containskey(str.substring(3, 8))) {
                    PPIDpartmap.put(str.substring(3, 8).toUpperCase(), str);
                    PPIDStringList.add(str.substring(3, 8).toUpperCase());
                }
            }
        }

        system.debug('PPIDStringList  ===> '+PPIDStringList);
        system.debug('PPIDpartmap  ===> '+PPIDpartmap);
        
        Set < String > PPIDAllowedList = new Set < String > ();
        if (null != System.Label.Dispatch_PPID_Allowed) {
            for (String key: System.Label.Dispatch_PPID_Allowed.split(',')){
                PPIDAllowedList.add(key);   
            }
        }
        
        system.debug('PPIDAllowedList  ===> '+PPIDAllowedList);

        List < String > validatePPIDList = new List < String > ();
        
        for (String str: PPIDStringList) {
            if (!PPIDAllowedList.contains(str)) {
                validatePPIDList.add(str);
            }
        }
        system.debug('validatePPIDList ===>  '+validatePPIDList);
        String PPIDNumberstring = String.join(validatePPIDList, ',');
        
        try {
            if (PPIDpartmap != null && !PPIDpartmap.isEmpty() && String.isNotBlank(PPIDNumberstring)) {
                //validatereturnparts=[Select PartNumber__c,ResponseMessage__c,  ResponseCode__c,ValidPart__c,ItemExists__c from ValidateReturnParts__x where PartNumber__c in : PPIDpartmap.keySet() and ServiceBUID__c=:ServiceBUID]; 
                validatereturnparts = [Select PartNumber__c, ResponseMessage__c, ResponseCode__c, ValidPart__c, ItemExists__c, FunctionalDescription__c from ValidateReturnParts__x where PartNumber__c =: PPIDNumberstring and ServiceBUID__c =: ServiceBUID LIMIT 500];
            }
            if (Test.isRunningTest()) {
                validatereturnparts.addall(MockAutovalidateParts);
            }
            if (!validatereturnparts.isEmpty()) {
                for (ValidateReturnParts__x v: validatereturnparts) {
                    if (v.ResponseCode__c == '100') {
                        if ((v.FunctionalDescription__c == null || v.FunctionalDescription__c == 'null') && PPIDpartmap.containskey(v.PartNumber__c)) {
                            returnedList.add(PPIDpartmap.get(v.PartNumber__c));
                        }
                    } else {
                        returnedList.addall(PPIDList);
                        break;
                    }
                }
            }

            if (returnedList.isEmpty()) {
                returnedList.add('Success');
            }

            return returnedList;
        } Catch(Exception e) {
            String str = e.getMessage();
            returnedList.add(str);
            return returnedList;
        }

    }

    // Wrapper class for validating PPID Data

    /*  public class PPIDDataWrapper{
            @InvocableVariable(label='PPID Key')
            public Integer PPIDKey;
     
            @InvocableVariable(label='PPID Value')
            public String PPIDValue;
            
            @InvocableVariable(label='PPID Error')
            public String PPIDError;
        } */

  // Wrapper Class for Asset Hold Swagger Service
    public class AssetHoldWrapper {
        //@InvocableVariable(label = 'Asset Hold')
        //public String assetHold;

        @InvocableVariable(label = 'Asset Hold Message')
        public String assetHoldMessage;

        //@InvocableVariable(label = 'Asset Model')
        //public String assetModel;

        //@InvocableVariable(label = 'Response Code')
        //public String responseCode;
        
        //@InvocableVariable(label = 'CFI Number')
        //public String customFactoryIntNumber;
        
    }
    // Method to get Asset Hold Value from Asset Hold Status custom metadata
    @InvocableMethod(label = 'Asset Hold Status'
        description = 'Getting Asset Hold Value from Asset Hold Status custom metadata')
    public static List < AssetHoldWrapper > GetAssetHoldValue(list < string > AssetHoldStatus)
    /* 
       Description : Get Asset Hold Value
       Author      : Ruthirappan Nandagopal
       Date        : 1st Jan, 2019
    */
    {
        try {
            /*
            List < AssetHoldStatusResponse__x > assList = new List < AssetHoldStatusResponse__x > ();

            if (!Test.isRunningTest()) {
                assList = [SELECT ServiceTagId__c, AssetHoldStatus__c, ResponseCode__c, Model__c, customFactoryIntNumber__c FROM AssetHoldStatusResponse__x
                    WHERE ServiceTagId__c =: serviceTagList[0] LIMIT 1
                ];
                 
            } else {
                assList.add(new AssetHoldStatusResponse__x(AssetHoldStatus__c = '17', ResponseCode__c = '100'));
                assList.add(new AssetHoldStatusResponse__x(AssetHoldStatus__c = '10', ResponseCode__c = '100'));
                assList.add(new AssetHoldStatusResponse__x(AssetHoldStatus__c = '18', ResponseCode__c = '100'));
            }
            */
            List < AssetHoldWrapper > assWrapList = new List < AssetHoldWrapper > ();
            AssetHoldWrapper ast;

            // Populate map from SOQL query
            Map < string, Asset_Hold_Status__mdt > m = new Map < string, Asset_Hold_Status__mdt > ([SELECT MasterLabel, Asset_Hold_Value__c FROM Asset_Hold_Status__mdt WHERE WO_Creation_Not_Allowed__c = true LIMIT 50000]);
            Map < string, String > mapHoldStatus = new Map < string, String > ();
            // After populating the map, iterate through the map entries            
            for (string idKey: m.keyset()) {
                Asset_Hold_Status__mdt a = m.get(idKey);
                mapHoldStatus.put(a.MasterLabel, a.Asset_Hold_Value__c);
            }
            ast = new AssetHoldWrapper();
            for (String hold: AssetHoldStatus) {
                
                //ast.responseCode = hold.ResponseCode__c;
                //ast.assetHold = hold.AssetHoldStatus__c;
                //ast.assetModel = hold.Model__c;
                ast.assetHoldMessage = mapHoldStatus.get(hold);
                //ast.customFactoryIntNumber = hold.customFactoryIntNumber__c;
                assWrapList.add(ast);
            }

            return assWrapList;
        } catch (exception e) {
            ExceptionHandler.logHandledExceptions(e, 'CreateDispatchHandler', 'checkAssetHoldStatus', 'Dispatch Management');
            return null;
        }
    }
}