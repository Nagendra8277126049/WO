/* -----------------------------------------------------------------------------------------------------------------------
Name:         CollaborateInternalChatTest
Description:  this is test class  CollaborateInternalChat apex class for   Story 5086637 & 5150078
Date          Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
09/024/2018     1.0     Rajesh Guru    Initial Release

-------------------------------------------------------------------------------------------------------------------------- */ 

@isTest
public class CollaborateInternalChatTest{
    
    testmethod static void testCollaborateInternalChat(){
        // creation of test data
        Queueid__mdt objConfig = new Queueid__mdt();
        objConfig.buttonid__c = System.Label.CollaborateInternalChat_Buttonid;
        objConfig.Label = 'Test';
        
        
        
        Case objCase = new Case();
        objCase.Subject = 'Test Subject';
        objCase.Description = 'Test Description';
        insert objCase;
        
        Prev_Value__c p= new  Prev_Value__c ();
        p.Value__c= '12';
        
        //calling methods for test coverage
        //  CollaborateInternalChat.fetchUser();
        //  CollaborateInternalChat.fetchCaseNumber(objCase.Id);
        CollaborateInternalChat.getOptions();
        CollaborateInternalChat.decimalToBinary(25);
        CollaborateInternalChat.base64ToBits('AB');
        Case c = new Case();
        CollaborateInternalChat.getDependentMap(c, 'Collaborate_Role__c','Collaborate_Reason__c');
        CollaborateInternalChat.getSelectedValue();
        CollaborateInternalChat.saveSelectedValuee('123');
   
        
        
        CollaborateInternalChat.PicklistEntryWrapper obj = new CollaborateInternalChat.PicklistEntryWrapper();
        obj.active = 'test';
        obj.value = 'test';
        obj.defaultValue = 'test';
    }
}