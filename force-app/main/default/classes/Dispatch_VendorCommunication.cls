/*******************************************************************************************************
Name:          Dispatch_VendorCommunication
Description:   This class contains the method to fetch dispatch instruction for related workorder
Req #: 5049187
Test Class : Dispatch_VendorCommunication_Test
*******************************************************************************************************/
public with sharing class Dispatch_VendorCommunication{
 
    public  static List<DispatchInstruction__c> LstDispInt = new List<DispatchInstruction__c>();    
    @AuraEnabled    
    public static List<DispatchInstruction__c> getDispatchList(String WorkorderId){
               LstDispInt = [select id, Name, Work_Order__c from DispatchInstruction__c where Work_Order__c =: WorkorderId AND  Vendor_Instructions__c = TRUE ORDER BY CreatedDate DESC];
               return LstDispInt;
    }
}