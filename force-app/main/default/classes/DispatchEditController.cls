/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchEditController
Description:  Controller Class for Dispatch_Edit_Panel Lightning Cmp - Story 5263685
--------------------------------------------------------------------------------------------------------------------------
Date         Version  Author             Summary of Change
-----------  -------  -----------------  ---------------------------------------------------------------------------------
08/28/2018     1.0    Harsha Reddy       Initial Release
08/28/2018     1.0    Rodrigo Carpio     Initial Release
09/30/2018     1.0    Dattaa1            Added Logic to handle GCC User Logic
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class DispatchEditController {
    public class CustomException extends Exception {}
    @AuraEnabled
    public static string updateWorkOrder(string recordId) {
        try {
            if (string.isNotBlank(recordId)) {
                List < WorkOrder > woList = new List < WorkOrder > ();
                List < DispatchPendingApproval__c > approvalList = new List < DispatchPendingApproval__c > ();
                woList = [SELECT Id, Status, WorkOrderNumber, RecordTypeId ,Dispatch_Country__c
                    FROM WorkOrder WHERE Id =: recordId LIMIT 1
                ];
                if (!woList.isEmpty() && woList.size() > 0) {
                    if (string.isNotBlank(woList[0].Status)) {
                        if (woList[0].Status.equalsIgnoreCase('Problem') || woList[0].Status.equalsIgnoreCase('Pending Review')) {
                        
                            if(woList[0].Dispatch_Country__c=='LATAM'){
                                woList[0].RecordTypeId = System.Label.Dispatch_Record_Type_LATAM_Create;
                            }else{
                            woList[0].RecordTypeId = System.Label.Dispatch_Record_Type_Create;
                            }
                            woList[0].status = 'Rework';
                            woList[0].Approved_Rejected__c ='Rejected';
                            woList[0].Approve_Reject_Reason__c ='Rejected from Problem or Pending Review';
							

                            approvalList = [SELECT Id, Approval_Status__c, Approval_Comments__c,
                                Approval_Reject_Date__c, Name, OwnerId, RecordTypeId
                                FROM DispatchPendingApproval__c
                                WHERE Approval_Status__c = 'Pending'
                                AND Work_Order__c =: recordId LIMIT 1000
                            ];

                            if (!approvalList.isEmpty() && approvalList.size() > 0) {
                                for (DispatchPendingApproval__c dPA: ApprovalList) {
                                    dPA.Approval_Status__c = 'Rejected';
                                    dPA.Approval_Reject_Date__c = system.now();
                                    dPA.Approval_Comments__c = 'Work Order is Updated';
                                    dPA.OwnerId = UserInfo.getUserId();
                                    dPA.Name = woList[0].WorkOrderNumber + ' - ' + 'Rejected';
                                    dPA.RecordTypeId = System.Label.DispatchApproval_ReordTypeId;
                                }
                            }

                            // Update Work Order Record
                            update woList[0];

                            // Update Work Order Pending Approval Records
                            if (!approvalList.isEmpty() && approvalList.size() > 0) {
                                update approvalList;
                            }

                        } else {
                            return 'Work Order can be Editable Only - When Status is Problem or Pending Review';
                        }
                    }
                }
            } else {
                throw new CustomException('Record Id Cannot be Blank');
            }
            return 'SUCCESS';
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchEditController', 'updateWorkOrder', 'Dispatch Management');
            string errorMessage = e.getMessage();
            return errorMessage;
        }
    }
    
    @AuraEnabled
    public static DispatchGccConfiguration.InstructionsWrapper GetInstructionsGCC(string recordId) {
        DispatchGccConfiguration.InstructionsWrapper instructionList= new DispatchGccConfiguration.InstructionsWrapper();
        try {
            if (string.isNotBlank(recordId)) {
                instructionList=DispatchGccConfiguration.GetInstructionsGCC(recordId);
            }
            else {
                throw new CustomException('Record Id Cannot be Blank');
            }
        }
        catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchEditController', 'GetDSPInstructions', 'Dispatch Management');
            string errorMessage = e.getMessage();
            return null;
        }
        return instructionList;
    }
    
    @AuraEnabled
    public static String UpdateWoAndInstructionGcc(String recordId,String actionType, DispatchInstruction__c dispatchInstruction) {
        string serverresponse='';
        try {
            if (string.isNotBlank(recordId) && string.isNotBlank(actionType) ) {
                serverresponse = DispatchGccConfiguration.UpdateWoAndInstructionGcc(recordId,actionType,dispatchInstruction);
            }
            else {
                throw new CustomException('Record Id Cannot be Blank');
            }
        }
        catch (Exception ex) {
            ExceptionHandler.logHandledExceptions(ex, 'DispatchEditController', 'UpdateWoAndInstructionGcc', 'Dispatch Management');
            String errorMessage = ex.getMessage();
            if(errorMessage.contains('EXCEPTION, ') && errorMessage.contains(':'))
            errorMessage = errorMessage.substringBetween('EXCEPTION, ',':');
            return errorMessage;
        }
        return serverresponse;
    }
}