public class RegionManager 
{
    public static pse__Region__c GetRegionByBUID(string BUID)
    {
       	BUID_to_Country_Mapping__mdt[] mapping = [SELECT BUID__c, ISO_Country_Code__c FROM BUID_to_Country_Mapping__mdt WHERE BUID__c =: BUID limit 1 ];	 
        
        if(mapping.size() == 0) {  return null; }
        
        pse__Region__c[] region = [SELECT Id, Active__c From pse__Region__c WHERE ISO_Country_Code__c =: mapping[0].ISO_Country_Code__c limit 1 ];
        
        if(region.size() == 0) {  return null; }
        
        return region[0];
    }
}