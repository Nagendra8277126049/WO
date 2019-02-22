/* -----------------------------------------------------------------------------------------------------------------------
Name:       AccidentalDamageController
Description:  Makes OData call to external system and fetches the Entitlements Accidental Damage Details
                to display this information in Lightning Component - AccidentalDamage.cmp - Story #4559894
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
02/19/2018     1.0     Rodrigo Carpio       	Initial Release
09/17/2018     1.1     Harsha Reddy         	DEFECT 5610886 
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class AccidentalDamageController {
    
    /*Wrapper Class*/
    public with sharing class AccidentalDamagePagerWrapper {
        //@AuraEnabled public Integer page {get;set;}
        //@AuraEnabled public Boolean next {get; set;}
        //@AuraEnabled public Boolean previous {get; set;}
        @AuraEnabled public String serviceResponse {get; set;}
        @AuraEnabled public String serviceCode {get;set;}
        @AuraEnabled public List<AccidentalDamageListWrapper> detailsADList {get;set;}
    }
    
    /* Wrapper Class*/
    public with sharing class AccidentalDamageListWrapper {
        @AuraEnabled public string limitEligible {get;set;}
        @AuraEnabled public String adCount {get;set;}
        @AuraEnabled public String overrideCount {get;set;}
        @AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
        @AuraEnabled public String dispatchDate {get;set;}
        @AuraEnabled public String contractYear {get;set;}
    }

    @AuraEnabled
    public static AccidentalDamagePagerWrapper getAccidentalDamageDetails (Id recordId) {
        try{
            string assetName = '';
            string responseCode = '';
            string userName = '';
            
            List <EntitlementADDetails__x> listAD = new List<EntitlementADDetails__x>();
            List<AccidentalDamageListWrapper> objADPagerList = new List<AccidentalDamageListWrapper>();
            AccidentalDamagePagerWrapper objADPager = new AccidentalDamagePagerWrapper();
            
            system.debug('getAccidentalDamageDetails start');

            //get object name using recordId   

            if(recordId.getsobjecttype().getDescribe().getName().equals('Asset')){
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('Case')){
                assetName = [SELECT Asset.Name FROM Case WHERE Id = :recordId LIMIT 1].Asset.Name;
            }
            else if(recordId.getsobjecttype().getDescribe().getName().equals('LiveChatTranscript')){
                assetName = [SELECT Asset__r.Name FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].Asset__r.Name;
            }
            
            //query for Dell Badge ID -stored in Federation ID field
            userName = [select FederationIdentifier from user where id=:userinfo.getuserid() LIMIT 1].FederationIdentifier;
            
            if (string.isNotBlank(assetName)) {
                
                if(!Test.isRunningTest()) {
                    listAD = [SELECT LimitEligible__c, ADCount__c, OverRideCount__c, StartDate__c, EndDate__c, DispatchDate__c, ContractYear__c, ResponseCode__c, ResponseMessage__c
                                      FROM EntitlementADDetails__x WHERE ServiceTag__c = :AssetName AND UserId__c =:userName  LIMIT 100];
                }
                else
				{
                    listAD.add(new EntitlementADDetails__x(LimitEligible__c='1',
                                                           ADCount__c='1',	
                                                           OverRideCount__c='1',
                                                           StartDate__c = DateTime.parse('05/22/2022 11:46 AM'),
                                                           EndDate__c=DateTime.parse('05/22/2022 11:46 AM'),
                                                           DispatchDate__c=DateTime.parse('05/22/2022 11:46 AM'),
                                                           ContractYear__c='2022',
                                                           ResponseCode__c='100',ResponseMessage__c='MSG1234'));
                    
                    listAD.add(new EntitlementADDetails__x(LimitEligible__c='2',
                                                           ADCount__c='2',	
                                                           OverRideCount__c='2',
                                                           StartDate__c = DateTime.parse('05/22/2012 11:46 AM'),
                                                           EndDate__c=DateTime.parse('05/22/2012 11:46 AM'),
                                                           DispatchDate__c=DateTime.parse('05/22/2042 11:46 AM'),
                                                           ContractYear__c='2023',
                                                           ResponseCode__c='100',ResponseMessage__c='MSG1234'));
                    
                    listAD.add(new EntitlementADDetails__x(LimitEligible__c='3',
                                                           ADCount__c='3',	
                                                           OverRideCount__c='3',
                                                           StartDate__c = DateTime.parse('05/22/2014 11:46 AM'),
                                                           EndDate__c=DateTime.parse('05/22/2014 11:46 AM'),
                                                           DispatchDate__c=DateTime.parse('05/22/2062 11:46 AM'),
                                                           ContractYear__c='2024',
                                                           ResponseCode__c='100',ResponseMessage__c='MSG1234'));
                }
				
            }
            if (listAD.size()>0 && !listAD.isEmpty()){
                    responseCode = listAD[0].ResponseCode__c;
                    objADPager.serviceCode = responseCode;
                    objADPager.serviceResponse = listAD[0].ResponseMessage__c;
                
                	if (responseCode.equals('100')){

                        AccidentalDamageListWrapper elmntAD;
                        
                        for(EntitlementADDetails__x elmAD : listAD) {
                            elmntAD = new AccidentalDamageListWrapper();
                             
                            elmntAD.limitEligible = elmAD.LimitEligible__c;
                            elmntAD.adCount = elmAD.ADCount__c;
                            elmntAD.overrideCount = elmAD.OverRideCount__c;
                            elmntAD.contractYear = elmAD.ContractYear__c;
                            
                            //Start Date
                            if(elmAD.StartDate__c!=null){
                                elmntAD.startDate = elmAD.StartDate__c.formatGMT('MM/dd/yyyy'); //// Added By Harsha - DEFECT 5610886
                                // Commented By Harsha - DEFECT 5610886
                                /*
                                string sDate = elmAD.StartDate__c.format();
                        	    Integer sIndex = sDate.lastIndexOf('/');
                        	    elmntAD.startDate = sDate.subString(0,sIndex+5);
								*/
                        	}
                            
                            //End Date
                            if (elmAD.EndDate__c!=null){
                                elmntAD.endDate = elmAD.EndDate__c.formatGMT('MM/dd/yyyy'); //// Added By Harsha - DEFECT 5610886
                                // Commented By Harsha - DEFECT 5610886
                                /*
                                string eDate = elmAD.EndDate__c.format();
                        	    Integer eIndex = eDate.lastIndexOf('/');
                        	    elmntAD.endDate = eDate.subString(0,eIndex+5);
								*/
                            }

                            //dispatchDate
                            if (elmAD.DispatchDate__c!=null){
								elmntAD.dispatchDate = elmAD.DispatchDate__c.formatGMT('MM/dd/yyyy'); // Added By Harsha - DEFECT 5610886
                                // Commented By Harsha - DEFECT 5610886
								/*
                                string dDate = elmAD.DispatchDate__c.format();
                        	    Integer dIndex = dDate.lastIndexOf('/');
                        	    elmntAD.dispatchDate = dDate.subString(0,dIndex+5);
								*/
                        	}
                            
                            objADPagerList.add(elmntAD);
                        }
                        
                        objADPager.detailsADList = objADPagerList;
                    }
            }
            return objADPager;
        }catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'AccidentalDamageController','getAccidentalDamageDetails','EntitleManagement');
            return null;
        }	
    }
}