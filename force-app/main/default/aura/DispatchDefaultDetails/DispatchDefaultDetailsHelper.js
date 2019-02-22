({
	doInitHelper : function(component) {
		try {
            // Record Id
            var recId = component.get("v.recordId");
            var action = component.get("c.getDispatchDefaultRecord");
            action.setParams({
                //set RecordId
                workOrderId: recId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                     var result = response.getReturnValue();
                    component.set("v.response",result);
                    //response from Apex Controller
                      if(!$A.util.isUndefinedOrNull(result) && !$A.util.isEmpty(result)) {
                        var sStatus			=	response.getReturnValue().dispatchDefault.Work_Order__r.Status;
                        var sSubStatus		=	response.getReturnValue().dispatchDefault.Work_Order__r.Sub_Status__c;
                        var sCountryCode	=	response.getReturnValue().dispatchDefault.Work_Order__r.CountryCode__c;
                        var GccUser 		=	response.getReturnValue().GccUser;
                        var dspRequest     =   response.getReturnValue().dispatchDefault.DSP_Override_Request__c;  
                           if(!$A.util.isUndefinedOrNull(sStatus) && sStatus == "Problem" && GccUser && dspRequest){
                             
                               component.set("v.EditOverRide",true);
                               
                    } 
                                               
                         
                  } 
                }     
            });
            $A.enqueueAction(action);
        } catch (Err) {
            this.showToast(component, 'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"), "Error");
        }
	},
    
    //To toast 
    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            //"mode": "sticky",
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
    
    OpenEditformHelper : function(component, event)
    {
        component.set("v.EditOverRideMode",true);
        $A.util.removeClass(component.find("SaveBun"), "slds-hide");
        $A.util.addClass(component.find("SaveBun"), "slds-show");
    },
    
    closeModalhelper : function(component, event)
    {
        $A.util.removeClass(component.find("SaveBun"), "slds-show");
        $A.util.addClass(component.find("SaveBun"), "slds-hide");
        component.set("v.EditOverRideMode",false);
        
    },
    
    saveRecordHelper : function(component, event)
    {
        alert(JSON.stringify(component.get("v.Override")));
        var recId = component.get("v.recordId");
        var dspoverride= component.get("v.Override");
            var action = component.get("c.updateDisprecord");
            action.setParams({
                //set RecordId
                recordID: recId,
                DSPOverride : dspoverride
                
            });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    $A.util.removeClass(component.find("SaveBun"), "slds-show");
        $A.util.addClass(component.find("SaveBun"), "slds-hide");
        component.set("v.EditOverRideMode",false);
                    component.set("v.EditOverRide",false);
                    component.set("v.response.dispatchDefault.DSP_Override_Request__c",dspoverride);
                    //this.fireAppEvent(component);
                 } 
             
                  } 
                     
            );
        
            $A.enqueueAction(action);
    },
    
    fireAppEvent: function(component){
        var response= component.get("v.response");
        //firing the appevent from here
        var gccEvent = $A.get("e.c:DisPatchGCCUserCheckEvent");
        gccEvent.setParams({
            "GccUser" : response.GccUser,
            "woStatus" : response.dispatchDefault.Work_Order__r.Status,
            "woSubStatus" : response.dispatchDefault.Work_Order__r.Sub_Status__c,
            "woId": component.get("v.recordId"),
        });
        gccEvent.fire();
    }
})