({
    
    onInit : function(component, event, helper) {                
                
        var action = component.get("c.isCurrentUserServiceAgent");              
        var isServiceAgent;
        
        action.setCallback(this, function(response) {
               var state = response.getState();            
            if (state === "SUCCESS") { 
                var isServiceAgent = response.getReturnValue();
                if (isServiceAgent == null || isServiceAgent == undefined){                    
                    helper.displayToast(component, 'error', 'Unable to login to Omni. Please login manually.');  
                }                 
            }            
            if (isServiceAgent){
                //Console.log('Entered here....');
                var omniAPI = component.find("omniToolkit");
                helper.checkCurrentOmniStatus(component, omniAPI, helper);                                            
            }
        });   
        
         $A.enqueueAction(action);      
    },
    
})