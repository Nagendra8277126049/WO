/**
*    @author Sri Harsha G
*    @date   19th Feb 19
*    @description  Controller Class for mwdDiagnosticTierSpecialList LightningWebComponent                            
*     
*     Modification Log:
*--------------------------------------------------------------------------------------------------------------------------------------
*       Developer             Date                Description
*--------------------------------------------------------------------------------------------------------------------------------------
*       Sri Harsha G       19th Feb 19         	Controller Class for mwdDiagnosticTierSpecialList LightningWebComponent - STORY 5240855  
*/
public with sharing class MWDDiagnosticTeirController {
    @TestVisible private static List<MWD_Diagnostic_Teir__mdt> mockedMWDDiagnosticTeir = new List<MWD_Diagnostic_Teir__mdt>(); 
    @AuraEnabled (Cacheable = true)
    public static List<MWD_Diagnostic_Teir__mdt> getSpecialIssues(){
    	return (!mockedMWDDiagnosticTeir.isEmpty()) ? mockedMWDDiagnosticTeir : [SELECT Id,Special_Issue__c,Tier_1__c,Tier_2__c,Tier_3__c,Reason_Code__c,DeveloperName FROM MWD_Diagnostic_Teir__mdt ORDER BY Special_Issue__c ASC LIMIT 1000];
   	} 
}