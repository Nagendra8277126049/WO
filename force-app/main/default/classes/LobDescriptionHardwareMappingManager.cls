public class LobDescriptionHardwareMappingManager {
    public static List<LOB_Hardware_Mapping__mdt> GetLobToHardware()
    {
        LOB_Hardware_Mapping__mdt[] LOBsToHardware = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, LOB_Description__c FROM LOB_Hardware_Mapping__mdt];
        return LOBsToHardware;
    }

}