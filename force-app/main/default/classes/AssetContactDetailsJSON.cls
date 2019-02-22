/* -----------------------------------------------------------------------------------------------------------------------
Name:       AssetContactDetails
Description:  This class contain the data structure asset contacts details - story #4150193
Date         Version  Author                    Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
11/02/2017     1.0     Rodrigo Carpio           Initial Release
30/04/2018     1.1     Srikanth Parvathareddy   Story #4918471 - Contact Field Addition Due to BIL PCF Changes
-------------------------------------------------------------------------------------------------------------------------- */
global with sharing class AssetContactDetailsJSON {
    public AssetContactDetailsResponse assetContactDetails;// {get;set;} 
    public CommonMessageHeader messageHeader;// {get;set;}
    
    public with sharing class AssetContactDetailsResponse {
        public String serviceTag {get;set;} 
        public String primaryfirstName {get;set;} 
        public String primarylastName {get;set;} 
        public String primaryemail {get;set;} 
    //    public String primaryareaCode {get;set;} 
        public String primarycountryCode {get;set;} 
        public String primaryextension {get;set;} 
        public String primaryphoneNumber {get;set;} 
        public String primaryaddressType {get;set;} 
        public String secondaryFirstName {get;set;} 
        public String secondaryLastName {get;set;} 
        public String secondaryEmail {get;set;} 
    //    public String secondaryAreaCode {get;set;} 
        public String secondaryCountryCode {get;set;} 
        public String secondaryExtension {get;set;} 
        public String secondaryPhoneNumber {get;set;} 
        public String secondaryAddressType {get;set;} 
        public String tertiaryFirstName {get;set;} 
        public String tertiaryLastName {get;set;} 
        public String tertiaryEmail {get;set;} 
     //   public String tertiaryAreaCode {get;set;} 
        public String tertiaryCountryCode {get;set;} 
        public String tertiaryExtension {get;set;} 
        public String tertiaryPhoneNumber {get;set;} 
        public String tertiaryAddressType {get;set;}
    }
}