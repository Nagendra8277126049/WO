/**********************************************************************
Name:  Einstein_CaseClassificAdminSettings
======================================================
======================================================
Purpose: Support class for EinsteinIntent_AdminController
-------                                               
This class is an adaptation of the class Einstein_CaseClassificAdminSettings adding 
configuration related with Accidental Damage
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
1.0   Rayana Alencar   2018-12-10      INITIAL DEVELOPMENT          CSR: 
***********************************************************************/

public class EinsteinIntent_AdminSettings {
	
    //Case Classification
    @AuraEnabled
    public String CCModel_ID {get; set;}
    @AuraEnabled
    public DateTime CCModelLastUpdate {get; set;}
	@AuraEnabled
    public String CCModelUpdatedBy {get; set;}
    
    //Accidental Damage Classification
    @AuraEnabled
    public String ADModel_ID{get; set;}
    @AuraEnabled
    public DateTime ADModelLastUpdate {get; set;}
	@AuraEnabled
    public String ADModelUpdatedBy {get; set;}
}