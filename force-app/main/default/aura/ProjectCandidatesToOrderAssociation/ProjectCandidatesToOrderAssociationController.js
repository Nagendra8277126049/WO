({
	loadSuggestions : function(component, event, helper) 
    {
        var action = component.get("c.getProjectSuggestions");
               
        action.setParams({
            orderId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) 
        {
            var suggestions = data.getReturnValue();
            component.set("v.Projects", suggestions);
            helper.sort(component);
        });
        $A.enqueueAction(action);
		
	},
    
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    
    openModal: function(component,event,helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    
    createProject: function(component,event,helper) {
        var flow = component.find("createProject");
        var inputVariables = [
            {
                name : "orderid",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Create_Project_By_Order", inputVariables);
    },
    
    unassociateOrder: function(component,event,helper) {
        var flow = component.find("unassociateOrder");
        var inputVariables = [
            {
                name : "OrderId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("IDS_Unassociate_Order", inputVariables);
    },
    
    goToProject : function (component, event) {
             // Get the output variables and iterate over them
             var outputVariables = event.getParam("outputVariables");
             var outputVar;
             for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "projectId" && outputVar.value) {
                    var urlEvent = $A.get("e.force:navigateToSObject");
                    
                    urlEvent.setParams({
                        "recordId": outputVar.value,
                        "isredirect": "true"
                    });

                    urlEvent.fire();
                }
             }
       },
    
    gotoList : function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Order"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})