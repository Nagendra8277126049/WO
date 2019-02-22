/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchGccConfiguration
Description:  This class contain method that handles get dispatch default operation call - story #4346869 
Date         Version  Author                 Summary of Changes 
-----------  -------  -----------------      ------------------------------------------------------------------------------
09/26/2018     1.0    Dattaa1/Archana        Initial Release
-------------------------------------------------------------------------------------------------------------------------- */
Public with sharing class DispatchGccConfiguration {

    /*Wrapper Class*/
    public with sharing class GccConfigWrapper {
        @AuraEnabled public Boolean GccUser {
            get;
            set;
        }
        @AuraEnabled public List < DSPOptionsWrapper > DSPOptionsWrap {
            get;
            set;
        }
    }
    /*Wrapper Class*/
    public with sharing class DSPOptionsWrapper {
        @AuraEnabled public String label {
            get;
            set;
        }
        @AuraEnabled public String value {
            get;
            set;
        }
    }
    /*Wrapper Class*/
    public with sharing class InstructionsWrapper {
        @AuraEnabled public List < DispatchInstruction__c > InstructionsList {
            get;
            set;
        }
        @AuraEnabled public Boolean DspOverride {
            get;
            set;
        }
        @AuraEnabled public String DSPName {
            get;
            set;
        }
        @AuraEnabled public String DLPName {
            get;
            set;
        }
        @AuraEnabled public String CallType {
            get;
            set;
        }
        @AuraEnabled public String DpsType {
            get;
            set;
        }
        @AuraEnabled public String ServerMessage {
            get;
            set;
        }
    }

    public class customException extends Exception {}

    /* this functions will check if the user is having GCCUser PermissionSet or not */
    public static Boolean isGCCuser() {
        List < PermissionSetAssignment > GCCPerUserCheck = new List < PermissionSetAssignment > ();
        GCCPerUserCheck = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'Work_Order_GCC_User' LIMIT 10];
        if (!GCCPerUserCheck.isempty() && GCCPerUserCheck.size() > 0 && GCCPerUserCheck != null) {
            return true;
        }
        return false;
    }

    /* this functions makes a call to maestor to pull the dispatch defaults information */
    @AuraEnabled
    public static GccConfigWrapper getGccConfigurations(Id workOrderId, String CountryCode) {
        try {
            List < DSPOptionsWrapper > DSPOptionsList = new List < DSPOptionsWrapper > ();
            GccConfigWrapper GccConfigReturnValue = new GccConfigWrapper();
            if (String.isnotempty(workOrderId)) {
                GccConfigReturnValue.GccUser = DispatchGccConfiguration.isGCCuser();
                if (string.isNotBlank(CountryCode)) {
                    List < DispatchDSPDLP__c > DispatchDSPList = new List < DispatchDSPDLP__c > ();
                    DispatchDSPList = [SELECT PartnerName__c, PartnerCode__c FROM DispatchDSPDLP__c where Active__c = true AND Type__c = 'DSP'
                        AND CountryCode__c =: CountryCode LIMIT 1000
                    ];
                    If(!DispatchDSPList.isempty() && DispatchDSPList.size() > 0) {
                        for (DispatchDSPDLP__c dsp: DispatchDSPList) {
                            if (String.isnotempty(dsp.PartnerName__c) && String.isnotempty(dsp.PartnerCode__c)) {
                                DSPOptionsWrapper dspwrap = new DSPOptionsWrapper();
                                dspwrap.label = dsp.PartnerName__c;
                                dspwrap.value = dsp.PartnerCode__c;
                                DSPOptionsList.add(dspwrap);
                            }
                        }
                    }
                }
                GccConfigReturnValue.DSPOptionsWrap = DSPOptionsList;
            } else {
                throw new customException('Input Parameters to Method are not valid');
            }
            return GccConfigReturnValue;
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchGccConfiguration', 'GetInstructionsGCC', 'Dispatch Management');
            return null;
        }
    }
    //
    @AuraEnabled
    public static void saveGccDSPUpdate(Id workOrderId, String DSPCode, String DSPName) {
        if (String.isnotempty(DSPCode) && String.isnotempty(DSPName)) {
            workOrder WorkOrderUpd = new workOrder(Id = workOrderId, DSPName__c = DSPName, DSP__c = DSPCode, FSD_DSP_Selection__c = 'Manual');
            Update WorkOrderUpd;
        }
    }

    public static DispatchGccConfiguration.InstructionsWrapper GetInstructionsGCC(string workOrderId) {
        DispatchGccConfiguration.InstructionsWrapper instructionWrap = new DispatchGccConfiguration.InstructionsWrapper();
        try {
            if (string.isNotBlank(workOrderId)) {
                List < DispatchInstruction__c > getInstruct = new List < DispatchInstruction__c > ();
                getInstruct = [SELECT Id, Work_Order__c, Name, Receiver__c, Type__c, Instruction__c, Instruction_Identifier__c, DSP_Override_Request__c FROM DispatchInstruction__c WHERE Work_Order__c =: workOrderId AND(DSP_Override_Request__c = true OR Instruction_Identifier__c = 'Cancellation Comments') LIMIT 1000];
                instructionWrap.InstructionsList = getInstruct;
                List < DispatchDefaults__c > defaultList = new List < DispatchDefaults__c > ();
                defaultList = [SELECT Id, DSP_Override_Request__c, Work_Order__r.DSPName__c, Work_Order__r.DLP_Name__c, Work_Order__r.CallType__c, Work_Order__r.DPSType__c FROM DispatchDefaults__c WHERE Work_Order__c =: workOrderId LIMIT 1];
                if (!defaultList.isempty() && defaultList.size() > 0) {
                    instructionWrap.DspOverride = defaultList[0].DSP_Override_Request__c;
                    instructionWrap.DSPName = defaultList[0].Work_Order__r.DSPName__c;
                    instructionWrap.DLPName = defaultList[0].Work_Order__r.DLP_Name__c;
                    instructionWrap.CallType = defaultList[0].Work_Order__r.CallType__c;
                    instructionWrap.DpsType = defaultList[0].Work_Order__r.DPSType__c;
                } else {
                    instructionWrap.DspOverride = false;
                }
                instructionWrap.ServerMessage = 'success';
            } else {
                throw new customException('Input Parameters to Method are not valid');
            }
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e, 'DispatchGccConfiguration', 'GetInstructionsGCC', 'Dispatch Management');
            string errorMessage = e.getMessage();
            instructionWrap = new DispatchGccConfiguration.InstructionsWrapper();
            instructionWrap.DspOverride = false;
            instructionWrap.ServerMessage = 'failure';
            return instructionWrap;
        }
        return instructionWrap;
    }
    public static String UpdateWoAndInstructionGcc(String workOrderId, String actionType, DispatchInstruction__c dispatchInstruction) {
        try {
            if (string.isNotBlank(workOrderId) && string.isNotBlank(actionType)) {
                if (actionType.equalsIgnoreCase('resubmit')) {
                    workOrder WorkOrderUpd = new workOrder(Id = workOrderId, Status = 'Approved', Sub_Status__c = '', Sub_Status_Last_Modified__c = null);
                    Update WorkOrderUpd;
                    // Submit Work order DEFECT 5680981
                    DispatchSubmissionProcess dsp = new DispatchSubmissionProcess(workOrderId);
                    Id jobId = system.enqueueJob(dsp);
                    // Submit Work order DEFECT 5680981
                }
                if (actionType.equalsIgnoreCase('cancel')) {
                    if (dispatchInstruction != null && dispatchInstruction.Id != null) {
                        update dispatchInstruction;
                    } else {
                        if (dispatchInstruction != null && string.isNotBlank(dispatchInstruction.Instruction__c)) {
                            dispatchInstruction.Instruction_Identifier__c = 'Cancellation Comments';
                            dispatchInstruction.Work_Order__c = workOrderId;
                            dispatchInstruction.Type__c = 'General Comment';
                            dispatchInstruction.Receiver__c = 'Internal';
                            dispatchInstruction.Vendor_Instructions__c = false;
                            // Create New Instruction record
                            insert dispatchInstruction;
                        }
                    }
                    workOrder WorkOrderUpd = new workOrder(Id = workOrderId, Status = 'Cancelled', Sub_Status__c = '', Sub_Status_Last_Modified__c = null);
                    Update WorkOrderUpd;
                }

            } else {
                throw new customException('EXCEPTION, Input Parameters to Method are not valid : End');
            }
            return 'success';
        } catch (Exception ex) {
            ExceptionHandler.logHandledExceptions(ex, 'DispatchGccConfiguration', 'UpdateWoAndInstructionGcc', 'Dispatch Management');
            String errorMessage = ex.getMessage();
            if (errorMessage.contains('EXCEPTION, ') && errorMessage.contains(':')) {
                errorMessage = errorMessage.substringBetween('EXCEPTION, ', ':');
            }
            return errorMessage;
        }
    }

    /* 
     * Created By : Harsha Gangi Reddy
     * Created Date: 10/04/2018
     * Requirement : STORY 5587160
     * Description : To check whether Current Date is in 5 business days from Entitlement Start Date
     *  Test Coverage : DispatchServiceProviderController_Test
     */
    @AuraEnabled(cacheable = true)
    public static boolean checkBussinessHourLogic(DateTime EntStartDate, String Country) {
        return DispatchServiceProviderController.checkIsFiveBusinessDays(EntStartDate, Country);
    }
}