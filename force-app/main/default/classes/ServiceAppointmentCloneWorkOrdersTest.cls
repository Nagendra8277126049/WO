/*
      Purpose:
            Clone related work orders and work order skills from Service Appointment when status is 'Cannot Complete'
            
      Author    : Pawan Kumar
      Company   : OAC Services INC.
      Created   : 1/10/19

    =============================================================================================================
    Modification History:
    ----------------------------------------------------------------------------
    Name        Date        Company             Description
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
*/

@isTest
public class ServiceAppointmentCloneWorkOrdersTest 
{
    @testSetup
    static void setupData()
    {
        Trigger_Execution_Control__c triggerToggle = new Trigger_Execution_Control__c(
            Skip_Work_Order_Cloning__c = false
        );
        insert triggerToggle;
        
        Account Acc = new Account(
            name = 'Dell TestAccount'
        );
        insert Acc;
        
        Asset objAsset = new Asset(
            name='Dell TestAsset',
            AccountId= Acc.Id
        );
        insert objAsset;
        
        Contact objContact = new Contact(
            LastName='DellTest',
            FirstName='Test Contact',
            AccountId= Acc.Id,
            Country_Code__c = 'Bermuda (441)',
            email='DellTestContact@gmail.com',
            Primary_Phone__c='7584930578'
        );
        insert objContact;
        
        Case objCase = new Case(
            AccountId= Acc.Id,
            AssetId= objAsset.Id,
            ContactId= objContact.Id,
            status= 'In Progress',
            Priority= 'Low',
            Service_Tag__c='Dell Test'
        );
        insert objCase;
        
        WorkOrder objWorkOrder= new WorkOrder(
            AccountId = Acc.Id,
            AssetId = objAsset.Id,
            ContactId = objContact.Id,
            AddressBUID__c='2121',
            Entitlement_Details__c = 'KYHD',
            KYHD__c = true,
            City = 'Round Rock',
            Country = 'United States',
            State = 'Texas',
            Street = 'Dell Way123',
            PostalCode  = '78664'
        );
        insert objWorkOrder;
        
        Work_Order_Skill__c WOSkill = new Work_Order_Skill__c(
            Work_Order__c = objWorkOrder.Id,
            CurrencyIsoCode = 'USD'
        );
        insert WOSkill;
        
        ServiceAppointment objSA = new ServiceAppointment(
            ContactId = objContact.Id,
            ParentRecordId = Acc.Id,
            EarliestStartTime = system.now(),
            DueDate = system.now().addDays(5),
            Status = 'Scheduled',
            Work_Order__c = objWorkOrder.Id
        );
        insert objSA;
        
    }
    
    public static testMethod void ServiceAppointmentCloneWorkOrders()
    {
        ServiceAppointment objSA = [select Id,Status from ServiceAppointment where Work_Order__c != NULL];
        system.debug(objSA);
        objSA.Status = 'Cannot Complete';
        update objSA;
        
    }
}