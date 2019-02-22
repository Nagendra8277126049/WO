({
	getOrderLineItem : function(component, page) {
		try{
            var action = component.get("c.getItems");
            var recID = component.get("v.recordId");
            var pageSize = $A.get("$Label.c.OrderLineItemsPageSize");
            component.set("v.Spinner", true);
            action.setParams({
                "recordID": recID,
                "PageKey": page,
                "PageSize": pageSize
            });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if(state=="SUCCESS"){
                    var result = response.getReturnValue();
                    if (result!=null || result!=undefined){
                        component.set("v.orderItems", result.orderLine);
                        component.set("v.serviceTag", result.serviceTag);
                        component.set("v.next", result.next);
                        component.set("v.previous", result.previous);
                        component.set("v.page", result.page);
                    }
                    else{
                        component.set("v.orderItems", null);
                        component.set("v.serviceTag", null);
                        this.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
                    }
                }
                
                else if (status === "INCOMPLETE") {
                        //console.log("No response from server or client is offline.");
                        this.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
                }
                
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log("Error message: " + errors[0].message);
                            this.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
                        }
                    } else {
                        //console.log("Unknown error");
                        this.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
                    }
                }
                component.set("v.Spinner", false);
                component.set("v.alerts", true);
            });
            $A.enqueueAction(action);
        }catch(Err){
           	console.log(Err);
            this.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
        }
	},

	openURL: function(component, partNumber) {
        try{
            var AssetTag = component.get("v.serviceTag");
            var navUrl = $A.get("$Label.c.Part_URL_OrderLine");
            var vfUrl =  navUrl +'='+ AssetTag + '&partNumber=' + partNumber;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": vfUrl
            });
            urlEvent.fire();
        }catch(Err){
            //console.log(Err);
            this.showToast(component,'Error','Unable to Open URL', "Error");
        }
    },
    
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
    
    buttonLogic: function(component, direction){
        try{
	        var page = component.get("v.page") || 1; 
    	  	page = direction === "Previous" ? (page - 1) : (page + 1);  
      		this.getOrderLineItem(component, page);
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.OrderLineItemsErrorMessage"), "Error");
        }
    },
})