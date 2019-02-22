({
    initHandler: function(component) {
        try {
            component.set("v.Spinner",true);
            // Record Id
            var recId = component.get("v.recordId");
            var action = component.get("c.checkApprovalCriteria");
            action.setParams({
                recordId: recId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //response from Apex Controller
                    if (!$A.util.isEmpty(result)) {
                        component.set("v.approvalWrapper", result);
                        var respM = result.responseMessage;
                        if (!$A.util.isEmpty(respM)) {
                            var respMUpp = respM.toUpperCase();
                            if (respMUpp === 'SUCCESS') {
                                if (result.autoApproveFlag || result.dspOverrideFlag) {
                                    component.set("v.autoApproved", true);
                                } else {
                                    component.set("v.autoApproved", false);
                                    component.set("v.arrcriteria", result.approvalCriteriaMessage);
                                }
                            } else if (respMUpp === 'FAILURE') {
                                this.showToast(component, 'ERROR', "Error occured in approval process.", "Error");
                            } else if (respMUpp === 'CALL TYPE FAILED') {
                                component.set("v.callTypeFailureFlag", true);
                            } else {
                                this.showToast(component, 'ERROR', "Error occured in approval process : " + respM, "Error");
                            }
                        }
                    }
                } else {
                    this.showToast(component, 'ERROR', "Error occured in approval process.", "Error");
                }
                component.set("v.Spinner",false);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            component.set("v.Spinner",false);
            this.showToast(component, 'ERROR', "Error occured in approval process.", "Error");
        }
    },
    closeMe: function(component) {
        // Refresh View
        $A.get("e.force:refreshView").fire();
        // Destroy Component
        component.destroy();
    },
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
    callApexToCreateRecord: function(component) {
        try {
            component.set("v.Spinner",true);
            // Record Id
            var approvalWrapper = component.get("v.approvalWrapper");
            var action = component.get("c.updateWorkOrderRecord");

            action.setParams({
                recordId: component.get("v.recordId"),
                approvalCriteria: approvalWrapper.approvalCriteriaMessage,
                QueueName: approvalWrapper.approvalQueueName,
                qMapId: approvalWrapper.qMapRecId,
                autoApprFlag: approvalWrapper.autoApproveFlag,
                dspOverrideFlag: approvalWrapper.dspOverrideFlag
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    var result = response.getReturnValue();

                    //response from Apex Controller
                    if (!$A.util.isEmpty(result)) {
                        var respMUpp = result;
                        if (respMUpp.toUpperCase() === 'SUCCESS') {
                            this.closeMe(component);
                        } else if (respMUpp.toUpperCase() === 'CALL TYPE FAILED') {
                            component.set("v.callTypeFailureFlag", true);
                        } else {
                            this.showToast(component, 'ERROR', "Error occured in approval process : " + result, "Error");
                        }
                    } else {
                        this.showToast(component, 'ERROR', "Error occured in approval process.", "Error");
                    }
                } else {
                    this.showToast(component, 'ERROR', "Error occured in approval process.", "Error");
                }
                component.set("v.Spinner",false);
            });
            $A.enqueueAction(action);
        } catch (Err) {
            component.set("v.Spinner",false);
            this.showToast(component, 'ERROR', "Error occured in approval process.  : " + Err, "Error");
        }
    }
})