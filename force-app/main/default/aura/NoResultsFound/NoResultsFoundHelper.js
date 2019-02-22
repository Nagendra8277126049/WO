({
	showToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : "\"" + component.get('v.IVR_Input') + "\"" +" "+ component.get('v.toastTitle') ,
            message: component.get('v.toastMsg'),
            duration:'10000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    handleCTAttrUpdate: function (component, event){
        var action = component.get("c.handleCTAttrForAssetUpdate");
         action.setParams({
            strCallTranscriptId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("State >>>> "+state);
            if (state == "SUCCESS")
                console.log("CTA API Calls requested");
            else
                console.log("Something went wrong");
        });
        $A.enqueueAction(action);
    }, 
    DisableTabClose : function(component, event) {
        var tabCheck = window.location.href;
        if (tabCheck.indexOf("Call_Transcript__c") > -1){
		var workspaceAPI = component.find("workspace");
        console.log("=======component.get======" + component.get("v.callTransRec.Case__c"));
        if(component.get("v.callTransRec.Case__c") == null){
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.disableTabClose({
                    tabId: focusedTabId,
                    disabled: true,
                    //closeable:false
                    
                })
                .then(function(tabInfo) {
                    console.log(tabInfo);
                })
                .catch(function(error) {
                    console.log(error);
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        else{
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.disableTabClose({
                    tabId: focusedTabId,
                    disabled: false,
                    //closeable:true
                })
                .then(function(tabInfo) {
                    console.log(tabInfo);
                })
                .catch(function(error) {
                    console.log(error);
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
	}
    }
})