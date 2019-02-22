({
	validate : function(cmp) {
		return cmp.find('toValidate').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
	},
    setError : function(cmp, error){
        cmp.set('v.type', 'error');
        cmp.set('v.message', error);
        cmp.set('v.errorMessage', 'True');
    },
    serializeItems : function(cmp){
        var list = cmp.get('v.ItemList');
        cmp.set('v.output', JSON.stringify(list));
    },
    getTaxesByCountry : function(component, onSuccess, onError, params){
        var action = component.get('c.GetTaxesByCountry');
        action.setParams(params);        
        action.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") 
                this.handleHttpResponse(response.getReturnValue(), onSuccess, onError);
            else onError(response.getError());
        });
        return action;
    },
    handleHttpResponse: function(response, onSuccess, onError){
        try {
            if (response.Status != 200)
                onError(response.Body);
            else
                onSuccess(response.Body);
        }
        catch (e) {
            onError(e);
        }
    },
    showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type, "key" : "action:announcement", "message": message
        });
        toastEvent.fire();
	}
})