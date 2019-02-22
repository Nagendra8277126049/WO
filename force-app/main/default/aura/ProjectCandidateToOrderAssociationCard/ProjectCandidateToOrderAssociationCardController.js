({
    onInit: function(component, event, helper) {
        component.set("v.url", window.location.origin);
    },
    associate : function (component, event, helper)
    {
        /*var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
            type: 'info',
        	title: 'Under Development',
        	message: 'Feature under development, this button will associate the project with the Order soon.' 
        });
    	toastEvent.fire();*/
        
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : 'orderId',
                type : 'String',
                value : component.get('v.orderNumber')	
            },
            {
                name: 'projectId',
                type: 'String',
                value: component.get("v.proj.Id")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("IDS_Unassociate_Associate_Order_to_Project", inputVariables);
    },
    handleStatusChange : function (component, event) {
      if(event.getParam("status") === "FINISHED") {
          
         // Get the output variables and iterate over them
         var outputVariables = event.getParam("outputVariables");
         var resultOutput;
         if(outputVariables[0] != null && outputVariables[0].name === 'result')
         {
         	resultOutput = outputVariables[0];   
         }
         else if(outputVariables[1] != null && outputVariables[1].name === 'result')
         {
             resultOutput = outputVariables[1];
         }
                   
         if(resultOutput.name === 'result' && resultOutput.value === true)
         {
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
				"recordId": component.get('v.orderNumber'),
                "isredirect": "true"
			});
            urlEvent.fire();
         }
         //outputVar.value
         //outputVar.name
      }
   }
})