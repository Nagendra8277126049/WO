/* -----------------------------------------------------------------------------------------------------------------------
Name:         DispatchTrackingInfoController
Description:  This class contain method that returns the tracking information from DispatchWayBill for the workorder
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class DispatchTrackingInfoController {
    
    /*Wrapper Class*/
    public with sharing class trackInfoWrapper {
        @AuraEnabled public Boolean NoRecordsFound {get; set;}
        @AuraEnabled public List<trackWrap> tracKInfoList {get; set;}
    }
    
    /*Wrapper Class*/
    public with sharing class trackWrap {
        @AuraEnabled public string CarrierName {get; set;}
        @AuraEnabled public string WayBillNumber {get; set;}
        @AuraEnabled public string WayBillDirection {get; set;}
        @AuraEnabled public string WayBillDate {get; set;}
        @AuraEnabled public string WayBillURL {get; set;}
    }
    
    @AuraEnabled
    public static trackInfoWrapper getTrackingInfoList (Id recordId) {
        try{
            trackWrap tWrap;
            
            List<trackWrap> tWrapList = new List<trackWrap>();
            trackInfoWrapper tInfoWrapper = new trackInfoWrapper();
            
            List<DispatchWaybill__c> wayBillList = new List<DispatchWaybill__c>();
            
            wayBillList =  [SELECT Id,ISP_FSD_Carrier_Name__c,ISP_FSD_WayBill_Number__c,ISP_FSD_WayBill_Direction__c,ISP_FSD_WayBill_Date__c FROM DispatchWaybill__c WHERE Work_Order__c=:recordId LIMIT 200];
                            
            if(wayBillList.size()>0){
                
                set<String> setCarrierName = new set<String>();
                Map<String, Carrier_Information__mdt> mapCarrierInfo = new Map<String, Carrier_Information__mdt>();
                
                
                for (DispatchWaybill__c wayBill : wayBillList){
                    setCarrierName.add(wayBill.ISP_FSD_Carrier_Name__c);
                }
                
                for (Carrier_Information__mdt objCarrInfo : [SELECT Website__c,Carrier_Code__c FROM Carrier_Information__mdt WHERE Carrier_Code__c IN:setCarrierName LIMIT 200]){
                    mapCarrierInfo.put(objCarrInfo.Carrier_Code__c,objCarrInfo);
                }
                
                
                for (DispatchWaybill__c wayBill : wayBillList){
                    
                    tWrap= new trackWrap();
            
                    tWrap.WayBillURL = '';
                    
                    if(mapCarrierInfo.containsKey(wayBill.ISP_FSD_Carrier_Name__c)){
                        tWrap.WayBillURL = mapCarrierInfo.get(wayBill.ISP_FSD_Carrier_Name__c).Website__c;
                    }

                    /*
                    List<Carrier_Information__mdt> carrierInfo = new List<Carrier_Information__mdt>();                    
                    carrierInfo =  [SELECT Website__c FROM Carrier_Information__mdt WHERE Carrier_Code__c=:wayBill.ISP_FSD_Carrier_Name__c limit 1];
                    if (carrierInfo.size()>0)
                    	tWrap.WayBillURL = carrierInfo[0].Website__c;
                    */
                    tWrap.CarrierName = wayBill.ISP_FSD_Carrier_Name__c;
                    tWrap.WayBillNumber = wayBill.ISP_FSD_WayBill_Number__c;
                    tWrap.WayBillDirection = wayBill.ISP_FSD_WayBill_Direction__c;
                    tWrap.WayBillDate = wayBill.ISP_FSD_WayBill_Date__c;
                    
                    
                    tWrapList.add(tWrap);
                }
                //system.debug(tWrap);
                tInfoWrapper.NoRecordsFound = false;
                tInfoWrapper.tracKInfoList = tWrapList;
                
            } else {
                tInfoWrapper.NoRecordsFound = true;
            }
            
            return tInfoWrapper;

        } Catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'DispatchTrackingInfoController','getTrackingInfoList','Dispatch Management');
        	return null;
        }
    }
}