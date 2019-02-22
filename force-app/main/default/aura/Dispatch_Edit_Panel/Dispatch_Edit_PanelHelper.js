({
    handleEditHelper : function(component) {
        try{
            //turn on Spinner
            this.showSpinner(component);
            var action = component.get("c.updateWorkOrder");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(!$A.util.isEmpty(result)){
                        var resultUpp = result.toUpperCase();
                        if(resultUpp==="SUCCESS"){
                            // Refresh View
                            this.hideSpinner(component);
                            $A.get('e.force:refreshView').fire();
                        } else {
                            this.showToast(component,'ERROR',result,"Error");
                            this.hideSpinner(component);
                            $A.get('e.force:refreshView').fire();
                        }
                    } else {
                        // Toast Error Message to User
                        this.showToast(component,'ERROR','Error Occured While Updating Work Order Record',"Error");
                        // turn Off Spinner
                        this.hideSpinner(component);
                        $A.get('e.force:refreshView').fire();
                    }
                } else {
                    // Toast Error Message to User
                    this.showToast(component,'ERROR','Error Occured While Updating Work Order Record',"Error");
                    // turn Off Spinner
                    this.hideSpinner(component);
                }
            });
            $A.enqueueAction(action);
        } catch(Err){
            this.showToast(component,'ERROR','Error Occured While Updating Work Order Record : '+Err,"Error");
        }
    },
    
    // turn on spinner
    showSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    // turn off Spinner
    hideSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    // Toast message
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
    handleGccEventHelper: function(component,event){
        var CancelledAllowedStatus=["pending review","approved","cancellation request","problem","rework","open"];
        var GccUser = event.getParam("GccUser");
        var woStatus = event.getParam("woStatus");
        var woId = event.getParam("woId");
        var woSubStatus = event.getParam("woSubStatus");
        console.log("GccUser>>>"+GccUser);
        console.log("woStatus>>>"+woStatus);
        console.log("woId>>>"+woId);

        if(woId==component.get("v.recordId")){
            component.set("v.GCCUser",GccUser);
            component.set("v.woStatus",woStatus);
            component.set("v.woSubStatus",woSubStatus);
            if(!$A.util.isUndefinedOrNull(GccUser) && !$A.util.isUndefinedOrNull(woStatus) && GccUser && CancelledAllowedStatus.includes(woStatus.toLowerCase())){
                this.getInstructionsList(component);
            }
            //console.log("GccUser>>>"+component.get("v.GCCUser"));
            //console.log("GccUser>>>"+component.get("v.woStatus"));
        }
    },
    handleGCCCancelHelper : function(component,event){
        var CancelledAllowedStatus=["pending review","approved","cancellation request","problem","rework","open"];
        var woStatus=component.get("v.woStatus");
        if(!$A.util.isUndefinedOrNull(woStatus) && CancelledAllowedStatus.includes(woStatus.toLowerCase())){
            component.set("v.cancelClicked",true);
        	component.set("v.resubmitClicked",false);
        	component.set("v.displaymessage",null);
        }
        else{
            component.set("v.displaymessage","You are not allowed to cancel the Work Order at this status");
            component.set("v.cancelClicked",true);
        	component.set("v.resubmitClicked",false);
            component.set("v.cancellationReason.Instruction__c",null);
        }
        component.set("v.showModal",true);
    },
    handleGCCSubmitHelper : function(component,event){
        component.set("v.cancelClicked",false);
        component.set("v.resubmitClicked",true);
        var woSubStatus=component.get("v.woSubStatus");
        var DSPName=component.get("v.DSPName");
        var DLPName=component.get("v.DLPName");
        var CallType=component.get("v.CallType");
        var DpsType=component.get("v.DpsType");
        var DSPOverride = component.get("v.DSPOverride");
       
        if(!$A.util.isUndefinedOrNull(woSubStatus) && ((woSubStatus.toLowerCase().indexOf("dsp assignment needed") != -1 && DSPOverride == true) || woSubStatus.toLowerCase().indexOf("dsp assignment failure") != -1 ) && $A.util.isEmpty(DSPName) ){
            //console.log("1>>>");
            component.set("v.showModal",true);
            component.set("v.displaymessage","Please select DSP and resubmit the Work Order");
            return;
        }
        else
            if(!$A.util.isUndefinedOrNull(woSubStatus) && ((woSubStatus.toLowerCase().indexOf("dsp assignment needed") != -1 && DSPOverride == true ) || woSubStatus.toLowerCase().indexOf("dsp assignment failure") != -1 ) && !$A.util.isEmpty(DSPName) ){
                //component.set("v.displaymessage",null);
                //component.set("v.showModal",true);
                this.saveGccWO(component,"resubmit");
                console.log("2>>>");
            }
            else
                if(!$A.util.isUndefinedOrNull(woSubStatus) && woSubStatus.toLowerCase().indexOf("dlp assignment failure") != -1 && !$A.util.isEmpty(DLPName) ){
                    this.saveGccWO(component,"resubmit");
                    console.log("3>>>");
                }
                else
                    if(!$A.util.isUndefinedOrNull(woSubStatus) && woSubStatus.toLowerCase().indexOf("dlp assignment failure") != -1){
                        component.set("v.displaymessage","Please select DLP and resubmit the Work Order");
                        component.set("v.resubmitClicked",false);
                        component.set("v.cancelClicked",false);
                        component.set("v.showModal",true);
                        console.log("4>>>");
                        return;
                    }
                    else
                        if(!$A.util.isUndefinedOrNull(woSubStatus) && (woSubStatus.toLowerCase().indexOf("pudo assignment failure") != -1 ||woSubStatus.toLowerCase().indexOf("box assignment failure") != -1 )){
                            this.saveGccWO(component,"resubmit");
                            console.log("5>>>");
                        }
                        else
                            if(!$A.util.isUndefinedOrNull(woSubStatus) && woSubStatus.toLowerCase().indexOf("dps type failure") != -1 && !$A.util.isEmpty(DpsType)){
                                this.saveGccWO(component,"resubmit");
                                console.log("6>>>");
                            }
                            else
                                if(!$A.util.isUndefinedOrNull(woSubStatus) && woSubStatus.toLowerCase().indexOf("dps type failure") != -1){
                                    component.set("v.displaymessage","Please provide DPS Type and resubmit the Work Order");
                                    component.set("v.resubmitClicked",false);
                        			component.set("v.cancelClicked",false);
                                    component.set("v.showModal",true);
                                    console.log("7>>>");
                                    return;
                                }
                                else
                                    if(!$A.util.isUndefinedOrNull(woSubStatus) && woSubStatus.toLowerCase().indexOf("call type failure") != -1 && $A.util.isEmpty(CallType)){
                                        this.saveGccWO(component,"resubmit");
                                        console.log("8>>>");
                                    }
                                    else
                                        if(!$A.util.isUndefinedOrNull(woSubStatus) && woSubStatus.toLowerCase().indexOf("call type failure") != -1 ){
                                            component.set("v.displaymessage","Please provide Call Type and resubmit the Work Order");
                                            component.set("v.resubmitClicked",false);
                        					component.set("v.cancelClicked",false);
                                            component.set("v.showModal",true);
                                            console.log("9>>>");
                                            return;
                                        }
                                        else{
                                            component.set("v.displaymessage","You are not allowed to resubmit the Work Order at this stage");
                                            component.set("v.showModal",true);
                                            component.set("v.resubmitClicked",false);
                                            component.set("v.cancelClicked",false);
                                            console.log("10>>>");
                                        }
    },
    closeModalPopUpHandler : function(component){
        component.set("v.showModal",false);
    },
    getInstructionsList : function(component){
        //turn on Spinner
        this.showSpinner(component);
        var action = component.get("c.GetInstructionsGCC");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            // turn Off Spinner
            this.hideSpinner(component);
            var state = response.getState();
            var woStatus=component.get("v.woStatus");
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log("result from details>>>"+JSON.stringify(result));
                if(!$A.util.isUndefinedOrNull(result) && !$A.util.isUndefinedOrNull(result.InstructionsList) ){
                    for(var i=0; i<result.InstructionsList.length;i++){
                        /*if(!$A.util.isUndefinedOrNull(result.InstructionsList[i].DSP_Override_Request__c) && result.InstructionsList[i].DSP_Override_Request__c==true ){
                            component.set("v.dspOverrideReason",result.InstructionsList[i]);
                        }
                        else*/
                            if(!$A.util.isUndefinedOrNull(result.InstructionsList[i].Instruction_Identifier__c) && result.InstructionsList[i].Instruction_Identifier__c=='Cancellation Comments'){
                                component.set("v.cancellationReason",result.InstructionsList[i]);
                            }
                    }
                }
                /*if(!$A.util.isUndefinedOrNull(result.DspOverride) ){
                    component.set("v.dspOverride",result.DspOverride);
                }*/
                if(!$A.util.isUndefinedOrNull(result.DSPName) ){
                    component.set("v.DSPName",result.DSPName);
                }
                if(!$A.util.isUndefinedOrNull(result.DLPName) ){
                    component.set("v.DLPName",result.DLPName);
                }
                if(!$A.util.isUndefinedOrNull(result.CallType) ){
                    component.set("v.CallType",result.CallType);
                }
                if(!$A.util.isUndefinedOrNull(result.DpsType) ){
                    component.set("v.DpsType",result.DpsType);
                }
                
                if(!$A.util.isUndefinedOrNull(result.DpsType) ){
                    component.set("v.DpsType",result.DpsType);
                }
                
                if(!$A.util.isUndefinedOrNull(result.DspOverride) ){
                    component.set("v.DSPOverride",result.DspOverride);
                }
                
                component.set("v.EnableCancel",true);
                if(!$A.util.isUndefinedOrNull(woStatus) && woStatus.toLowerCase().indexOf("problem")!=-1 ){
                    component.set("v.EnableReSubmit",true);
                }
            }
            else{
                helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
                console.log("Err>>>"+Err);
            }
            
        });
        $A.enqueueAction(action);
    },
    handleResubmithelper : function(component){
        component.set("v.showModal",false);
        this.showSpinner(component);
        this.saveGccWO(component,"resubmit");
    },
    handleCancelHelper : function(component){
        component.set("v.showModal",false);
        this.showSpinner(component);
        this.saveGccWO(component,"cancel")
    },
    saveGccWO : function(component, actionType){
        var action= component.get("c.UpdateWoAndInstructionGcc");
        if(actionType=="resubmit"){
            action.setParams({
                recordId : component.get("v.recordId"),
                actionType : actionType,
                dispatchInstruction : null,
            });
        }
        else {
            action.setParams ({
                recordId : component.get("v.recordId"),
                actionType : actionType,
                dispatchInstruction : component.get("v.cancellationReason"),
            });
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                this.hideSpinner(component);
                if(!$A.util.isUndefinedOrNull(result) && result.toLowerCase().indexOf("success") ==-1 ){
                    this.showToast(component,'ERROR',response.getReturnValue() ,"Error");
                }
                $A.get('e.force:refreshView').fire();
                component.set("v.EnableReSubmit",false);
            }
            else {
                // Toast Error Message to User
                this.showToast(component,'ERROR','Error Occured While Updating Work Order Record',"Error");
                // turn Off Spinner
                this.hideSpinner(component);
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})