({
    
    validateCaseFields: function(component, event, helper)
    {
        helper.validateCaseDetails(component, event, helper);
    },
    handleOnLoad : function(component, event, helper){
        var caseRec =component.get("v.callTranscriptRecord.Case__c");
        component.find("CaseDescription").set("v.value", component.get("v.caseDesc"));
        if(caseRec != null)
        {
            component.set("v.checkCase",true);
        }
    },
     handleLoad : function(component, event, helper){
        $A.util.addClass(component.find("CaseSubject"), "customRequired");
        $A.util.addClass(component.find("CaseDescription"), "customRequired");
        $A.util.addClass(component.find("CaseDisposition"), "customRequired");
    },
    handleSuccess : function(component, event, helper) {
        var callTranscriptId = component.get("v.recordId"); 
        console.log("======CallTransID===" + component.get("v.recordId"));
        var caseId = event.getParams().response.id;
        console.log('=====Created Case Id===='+caseId);
        helper.updateCallTranscript(component, caseId , callTranscriptId);
    },
    handleCancel : function(component, event, helper) {
       helper.closeModal(component, event); 
    },   
})