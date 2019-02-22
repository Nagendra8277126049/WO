/* -----------------------------------------------------------------------------------------------------------------------
Name:       BILAssetInformation
Description:  This class contains the BIL asset information structure #4640778
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
03/08/2018     1.0     Rodrigo Carpio          Initial Release
07/26/2018     1.1     Srikanth Parvathareddy  Changes are based on Defect #5374166 
-------------------------------------------------------------------------------------------------------------------------- */
public class BILAssetInformation {
    Public AssetDetails asset;
    Public AssetIdentifiers identifiers;
    
    public class AssetDetails {
        public string id  {get;set;} 
        public string serviceTag  {get;set;} 
        public string serialNumber {get;set;}
        public string manufacturerId {get;set;}
        public string manufacturerDescription {get;set;}
        public string expressServiceCode {get;set;}
        public string customerBuid {get;set;}
        public string customerNumber {get;set;}
        public string orderBuid {get;set;}
        public string orderNumber {get;set;}
        public string tieNumber {get;set;}
        public string sourceSiteId {get;set;}
        public string shipDate {get;set;}
        public string productCode {get;set;}
        public string productDescription {get;set;}
        public string productLineCode {get;set;}
        public string productLineDescription {get;set;}
        public string productLobCode {get;set;}
        public string productLobDescription {get;set;}
        public string localChannel {get;set;}
        public string orderCompanyNumber {get;set;}
        public string tiedToAssetFlag {get;set;}
        
    }
    
    public class AssetIdentifiers {
        public List<Identifiers> content {get;set;}
    }
    
    public class Identifiers {
        public string identifierTypeId;
        public string identifierTypeName;
        public string identifierValue;
    }
}