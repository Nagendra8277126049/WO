({
    doInitHelper: function(component) {
        try {
            component.set("v.HideSpinner",true);
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
                    //if (result != null && result != undefined) {
                    if(!$A.util.isUndefinedOrNull(result) && !$A.util.isEmpty(result)) {
                        component.set('v.response',response.getReturnValue());
                        console.log("v.response>>>"+JSON.stringify(response.getReturnValue()));
                        //var sGCCUserAccess	= 	response.getReturnValue().dispatchDefault.Work_Order__r.GCCUserAccess__c;
                        var sStatus			=	response.getReturnValue().dispatchDefault.Work_Order__r.Status;
                        var sSubStatus		=	response.getReturnValue().dispatchDefault.Work_Order__r.Sub_Status__c;
                        var sCountryCode	=	response.getReturnValue().dispatchDefault.Work_Order__r.CountryCode__c;
                        var GccUser 		=	response.getReturnValue().GccUser;
                        console.log(sSubStatus);
                        if(!$A.util.isUndefinedOrNull(sStatus) && sStatus == "Problem" && GccUser && ( $A.util.isEmpty(sSubStatus) ||(!$A.util.isUndefinedOrNull(sSubStatus) && (sSubStatus.toLowerCase().indexOf("pudo assignment failure") == -1  && sSubStatus.toLowerCase().indexOf("box assignment failure") == -1 ) ) ) ){
                            component.set('v.EditDLP', "true");
                            //if(sCountryCode == "CA" || sCountryCode == "JP"){
                                component.set('v.EditCollectDLP', "true");
                            //}
                            component.set('v.EditDPS', true);
                            component.set('v.woSubStatus', sSubStatus);
                            if(!$A.util.isUndefinedOrNull(response.getReturnValue().dispatchDefault.Work_Order__r.DPSType__c)){
                                component.set('v.DPSType', response.getReturnValue().dispatchDefault.Work_Order__r.DPSType__c);
                            }
                            if(!$A.util.isUndefinedOrNull(response.getReturnValue().dispatchDefault.Work_Order__r.CallType__c)){
                                component.set('v.CallType', response.getReturnValue().dispatchDefault.Work_Order__r.CallType__c);
                            }
                            if(!$A.util.isUndefinedOrNull(sCountryCode) && (sCountryCode!="US" && sCountryCode!="CA") ){
                                component.set('v.EditCallType', true);
                            }
                        }
                        
                    } else {
                        this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"),"Error");
                    }
                } else {
                    this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"),"Error");
                }
            });
            component.set("v.HideSpinner",false);
            action.setStorable();
            $A.enqueueAction(action);
        } catch (Err) {
            component.set("v.HideSpinner",false);
            this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"),"Error");
        }
    },
    
    //To toast 
    showToastHelper: function(component, title, message, type) {
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
    
    OpenDLPEditHelper: function(component){
        if(component.get("v.EditDLP") && component.get("v.response.GccUser")){
            var CountryCode 	= 	component.get("v.response.dispatchDefault.Work_Order__r.CountryCode__c");
            var oldDLPCode		=	component.get("v.response.dispatchDefault.Work_Order__r.DLP__c");
            var oldColDLPValue	=	component.get("v.response.dispatchDefault.Work_Order__r.Collect_DLP_Name__c");
            var action 			= 	component.get("c.getProviderValues");
            
            action.setParams({
                CountryCode: CountryCode,
                ProviderType:	"DLP"
                
            });
            action.setCallback(this, function(response) {
                component.set("v.HideSpinner",false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    console.log("result>>>"+result);
                    var arr 		= [];
                    var sColDLParr 	= [];
                    arr.push({value:"", label:"--None--"});
                    sColDLParr.push({value:"", label:"--None--"});
                    for(var key in result)
                    {
                        if(key == "DLP")
                            for(var i in result[key])
                            {
                                var selected=false;
                                if(!$A.util.isUndefinedOrNull(oldDLPCode) && !$A.util.isUndefinedOrNull(i) && i.toLowerCase().indexOf(oldDLPCode.toLowerCase())!= -1 ){
                                    selected = true;
                                    component.set("v.LogisticsProviderOptionsValue", i);
                                }
                                //arr.push({value:result[key][i], label:i});
                                arr.push({value:i, label:result[key][i], selected: selected});
                            }    
                        console.log(arr);
                        if(key == "CollectDLP")
                            for(var i in result[key])
                            {
                                var selected=false;
                                if(!$A.util.isUndefinedOrNull(oldColDLPValue) && !$A.util.isUndefinedOrNull(result[key][i]) && result[key][i].toLowerCase().indexOf(oldColDLPValue.toLowerCase())!= -1 ){
                                    selected = true;
                                    component.set("v.CollectDLPOptionsValue", i);
                                }
                                //sColDLParr.push({value:result[key][i], label:i});
                                sColDLParr.push({value:i, label:result[key][i], selected: selected});
                            }
                        $A.util.removeClass(component.find("PartsDLP"), "slds-show");
                        $A.util.addClass(component.find("PartsDLP"), "slds-hide");
                        $A.util.removeClass(component.find("Cmp"), "slds-hide");
                        $A.util.addClass(component.find("Cmp"), "slds-show");
                        $A.util.removeClass(component.find("SaveBun"), "slds-hide");
                        $A.util.addClass(component.find("SaveBun"), "slds-show");
                        if(component.get("v.EditCollectDLP") == "true")
                        {
                            $A.util.removeClass(component.find("CollectDLP"), "slds-show");
                            $A.util.addClass(component.find("CollectDLP"), "slds-hide");
                            $A.util.removeClass(component.find("CollectDLPEditMode"), "slds-hide");
                            $A.util.addClass(component.find("CollectDLPEditMode"), "slds-show");
                        }    
                        
                    }
                    if(!$A.util.isUndefinedOrNull(result) && !$A.util.isEmpty(result)) {
                        component.set('v.LogisticsProviderOptions',arr);
                        component.set('v.CollectDLPOptions',sColDLParr);
                    } 
                } else {
                    this.showToast(component,'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageLoadingComponent"),"Error");
                }
            });
            action.setStorable();
            $A.enqueueAction(action);
        }
        
    },
    
    closeModalHelper: function(component){
        
        this.CollapseEditMode(component);  
        
    },
    
    CollapseEditMode: function(component){
        
        $A.util.removeClass(component.find("PartsDLP"), "slds-hide");
        $A.util.addClass(component.find("PartsDLP"), "slds-show");
        $A.util.removeClass(component.find("Cmp"), "slds-show");
        $A.util.addClass(component.find("Cmp"), "slds-hide");
        $A.util.removeClass(component.find("SaveBun"), "slds-show");
        $A.util.addClass(component.find("SaveBun"), "slds-hide");
        $A.util.removeClass(component.find("CollectDLPEditMode"), "slds-show");
        $A.util.addClass(component.find("CollectDLPEditMode"), "slds-hide");
        $A.util.removeClass(component.find("CollectDLP"), "slds-hide");
        $A.util.addClass(component.find("CollectDLP"), "slds-show");
        component.set("v.EditDPSMode", false);
        component.set("v.EditCallTypeMode", false);
        component.set("v.errorMessage", null);
    },
    saveRecordValidationHelper:function(component){
        var sStatus			=	component.get("v.response.dispatchDefault.Work_Order__r.Status");
        var sSubStatus		=	component.get("v.response.dispatchDefault.Work_Order__r.Sub_Status__c");
        var GccUser 		=	component.get("v.response.GccUser");
        var errorMessage	=	null;
        var DPSType			=	component.get("v.DPSType");
        var	CallType		=	component.get("v.CallType");
        if(!$A.util.isUndefinedOrNull(sStatus) && sStatus == "Problem" && GccUser ){
            if(!$A.util.isUndefinedOrNull(sSubStatus) && (sSubStatus.toLowerCase().indexOf("dlp assignment failure") != -1 ) ){
                var DLPCode 	    = 	component.get("v.LogisticsProviderOptionsValue");
                if( $A.util.isEmpty(DLPCode)){
                    errorMessage = "Please select DLP";
                    //component.set("v.errorMessage", "Please select DLP");
                }
            }
            else if(!$A.util.isUndefinedOrNull(sSubStatus) && (sSubStatus.toLowerCase().indexOf("dps type failure") != -1 ) && $A.util.isEmpty(DPSType) ){
                errorMessage = "Please provide DPS Type";
            }
                else if(!$A.util.isUndefinedOrNull(sSubStatus) && (sSubStatus.toLowerCase().indexOf("call type failure") != -1 ) && component.get("v.EditCallType") && $A.util.isEmpty(CallType) ){
                    errorMessage = "Please provide Call Type";
                }
            if(!$A.util.isUndefinedOrNull(errorMessage) && !$A.util.isEmpty(errorMessage)){
                component.set("v.errorMessage", errorMessage);
            }
            else{
                this.saveRecordHelper(component);
            }
        }
    },
    saveRecordHelper: function(component){
        
        var DLPCode 	    = 	component.get("v.LogisticsProviderOptionsValue");
        var oldDLPValue		=	component.get("v.response.dispatchDefault.Work_Order__r.DLP_Name__c");
        var action 			= 	component.get("c.UpdateDispatchAttributes");
        var DLPOptions		=	component.get("v.LogisticsProviderOptions");
        var DLPIndx			=	DLPOptions.findIndex(item => item.value == DLPCode)
        var DLPSelected		=   DLPIndx >= 0? DLPOptions[DLPIndx].label: null;
        var CountryCde		=	component.get("v.response.dispatchDefault.Work_Order__r.CountryCode__c");
        var CDLPCode 		= 	component.get("v.CollectDLPOptionsValue");
        var oldCDLPValue	=	null;
        var CDLPOptions		=	null;
        var CDLPIndx		=	null;
        var CDLPSelected	=	null;
        var oldDPSType		=	component.get("v.response.dispatchDefault.Work_Order__r.DPSType__c");
        var oldCallType		=	component.get("v.response.dispatchDefault.Work_Order__r.CallType__c");
        var DPSType			=	component.get("v.DPSType");
        var	CallType		=	component.get("v.CallType");
        if(!$A.util.isUndefinedOrNull(CDLPCode) && !$A.util.isUndefinedOrNull(CountryCde) && CountryCde=="CA")
        {   
            oldCDLPValue	=	component.get("v.response.dispatchDefault.Work_Order__r.Collect_DLP__c");
            CDLPOptions		=	component.get("v.CollectDLPOptions");
            CDLPIndx		=	CDLPOptions.findIndex(item => item.value == CDLPCode);
            CDLPSelected	=   CDLPIndx >= 0? CDLPOptions[CDLPIndx].label: null;
            
        }
        if(oldDLPValue != DLPSelected || oldCDLPValue != CDLPSelected || oldDPSType!=DPSType || oldCallType!=CallType  ){
            action.setParams({
                recordId	: component.get("v.recordId"),
                DLPName 	: DLPSelected,
                DLPCode 	: DLPCode,
                ColDLPName	: CDLPSelected,
                ColDLPCode	: CDLPCode,
                DPSType 	: component.get("v.DPSType"),
                CallType 	: component.get("v.CallType")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if(state == "SUCCESS")
                {   
                    component.set("v.response.dispatchDefault.Work_Order__r.DLP_Name__c", DLPSelected);   
                    component.set("v.response.dispatchDefault.Work_Order__r.Collect_DLP_Name__c", CDLPSelected);
                    component.set("v.response.dispatchDefault.Work_Order__r.DPSType__c", DPSType);
                    component.set("v.response.dispatchDefault.Work_Order__r.CallType__c", CallType);
                    this.fireAppEvent(component);
                }
            });
            $A.enqueueAction(action);
        }
        this.CollapseEditMode(component); 
    },
    handleOpenDSPEditHelper : function(component,event){
        if(component.get("v.EditDPS") && component.get("v.response.GccUser")){
            component.set("v.EditDPSMode", true);
        }
    },
    handleOpenCallTypeEditHelper : function(component,event){
        if(component.get("v.EditCallType") && component.get("v.response.GccUser")){
            component.set("v.EditCallTypeMode", true);
        }
    },
    //will be used to fire the appEvent
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