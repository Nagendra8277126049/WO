({
    // To Toast Error Message
  	showToast : function(component, title, message, type) {
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message, 
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
        }catch(Err){
           console.log(Err);
        }
    },
    
    submitHelper: function(component,event){
		try{
            $A.createComponent("c:Dispatch_Submit_Modal",
                {
                    "recordId": component.get("v.recordId")
                },
                function(newcomponent){                
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(newcomponent);
                        component.set("v.body", body);
                    }
                }
        	);
        }catch(Err){
           console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    
    cancelHelper:function(component,event){
        try{
            $A.createComponent("c:Dispatch_Cancel_Modal",
                {
                    "recordId": component.get("v.recordId")
                },
                function(newcomponent){                
                    if (component.isValid()) {
                        var body = component.get("v.body");
                        body.push(newcomponent);
                        component.set("v.body", body);
                    }
                }
        	);
        }catch(Err){
           console.log("Error While Open Modal  ===> "+Err); 
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
    }
})