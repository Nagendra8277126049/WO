({
    openWindow : function(component, event, helper) {
        var recID = component.get("v.recordId");
        helper.showSpinner(component, event, helper);
        helper.FetchAsset(component,recID);
	}
})