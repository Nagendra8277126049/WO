/* -----------------------------------------------------------------------------------------------------------------------
Name:       GetAssetLocation
Description:  Makes Rest-API call to external system and fetches the Asset Location
Display this information in Lightning Component - AssetLocation.cmp - story #34169915
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Sri Harsha Gangi Reddy      Initial Release
04/26/2018     1.1     Srikanth Parvathareddy      Updated from REST to ODATA service - Story #5039107
-------------------------------------------------------------------------------------------------------------------------- */

public with sharing class GetAssetLocation {
    
    /*Wrapper Class */
    public with sharing class AssetLocationWrapper{
        @AuraEnabled public string AddressLine1;
        @AuraEnabled public string AddressLine2;
        @AuraEnabled public string AddressLine3;
        @AuraEnabled public string AddressLine4; 
        @AuraEnabled public string City;
        @AuraEnabled public string Country;
        @AuraEnabled public string PostalCode;
        @AuraEnabled public string State;
        
    }
    
   
    /* -----------------------------------------------------------------------------------------------------------------------
Name:       GetAssetLocation
Description:  This Makes Rest-API call to external system and fetches the Asset Location
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes         
-----------  -------  ------------------------  ------------------------------------------------------------------------------
11/17/2017     1.0     Sri Harsha Gangi Reddy      Initial Release
04/26/2018     1.1     Srikanth Parvathareddy      Quieries Asset Location Info from External Object - AssetLocation__x (ODATA Service)
-------------------------------------------------------------------------------------------------------------------------- */
    @AuraEnabled
    public static List<AssetLocationWrapper> ReqAssetLocation(Id recordId) { 
        try{
            string assetName = '';
            
            //AssetName using recordID
            
            if(recordId.getsobjecttype().getDescribe().getName().equals('Asset')){
                assetName = [SELECT Name FROM Asset WHERE Id = :recordId LIMIT 1].Name;
            }
            
            List<AssetLocationWrapper> AstLocation = new List<AssetLocationWrapper>();
            List<AssetLocationResponse__x> AstLocList = new List<AssetLocationResponse__x>();
            if (assetName != null) {
                if(!Test.isRunningTest()){
                    AstLocList = [SELECT ServiceTagId__c, AddressLine1__c, AddressLine2__c,AddressLine3__c, AddressLine4__c, City__c, State__c, Country__c,PostalCode__c
                                  FROM AssetLocationResponse__x WHERE ServiceTagId__c = :AssetName LIMIT 1];
                } else {
                    
                    AstLocList.add(new AssetLocationResponse__x(ServiceTagId__c='STAG1234', AddressLine1__c='12490 S APOPKA VINELAND RD',AddressLine2__c='',AddressLine3__c='',
                                                                AddressLine4__c='',City__c='ORLANDO', State__c='FL', Country__c='US',PostalCode__c='56261210'
                                                               ));
                    AstLocList.add(new AssetLocationResponse__x(ServiceTagId__c='STAG1234', AddressLine1__c='EGL PARK',AddressLine2__c='DOMLUR',AddressLine3__c='INDIRANAGAR',
                                                                AddressLine4__c='',City__c='BANGALORE', State__c='KN', Country__c='IND',PostalCode__c='560121'
                                                               ));
                    AstLocList.add(new AssetLocationResponse__x(ExternalId='1234',ServiceTagId__c='STAG1234', AddressLine1__c='INFY PARK',AddressLine2__c='PHASE-1',AddressLine3__c='ECITY',
                                                                AddressLine4__c='',City__c='BANGALORE', State__c='KN', Country__c='IND',PostalCode__c='560100'
                                                               ));
                }
                if (AstLocList.size()>0){
                    
                    AssetLocationWrapper Astwp;
                    for(AssetLocationResponse__x AL : AstLocList) {
                        Astwp = new AssetLocationWrapper();
                        
                        // AddressLine Items
                        
                        if (AL.AddressLine1__c!=null){
                            Astwp.AddressLine1 = AL.AddressLine1__c;
                            Astwp.AddressLine2 = AL.AddressLine2__c;
                            
                            if(AL.AddressLine3__c!=null){
                                Astwp.AddressLine3 = AL.AddressLine3__c;
                                Astwp.AddressLine4 = AL.AddressLine4__c;
                            }
                            
                            // City Details
                            Astwp.City = AL.City__c;
                            
                            //State Details
                            Astwp.State = AL.State__c;
                            
                            //Country Details
                            Astwp.Country = AL.Country__c;
                            
                            //PostalCode Details
                            Astwp.PostalCode = AL.PostalCode__c;
                            
                            AstLocation.add(Astwp);
                        }
                    }
                }
            }
            
            return AstLocation;
        } catch(exception e){
            ExceptionHandler.logHandledExceptions(e,'GetAssetLocation','ReqAssetLocation','AssetLocation');
            return null;
        }
        
    }
}