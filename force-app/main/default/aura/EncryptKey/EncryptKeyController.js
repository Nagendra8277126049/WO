({
	encryptKey : function(component, event, helper) {
       	var pKey=component.get("v.privateKey");
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var action=component.get("c.getEncryptedValue");
        action.setParams({
            			"pKey":pKey
                         });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                component.set("v.cryptoKey",response.getReturnValue()[0]);
                component.set("v.encryptedKey",response.getReturnValue()[1]);
            }
            else
                console.log("Error occured during get");
            $A.util.addClass(spinner, "slds-hide");
            });  
		$A.enqueueAction(action);
	}
                           
})