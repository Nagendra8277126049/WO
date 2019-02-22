({
    doinitHelper: function(component,event){
        try {
            var action = component.get("c.fetchQueue");
            action.setParams({
                'SearchQueueKeyword': ''
            });
            component.find("Id_spinner").set("v.class" , 'slds-show');
            var workspaceAPI = component.find("workspace");
            var QueueName = component.get("v.TabName");
            workspaceAPI.getEnclosingTabId().then(function(tabId) {
                var focusedTabId = tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: QueueName
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:channel_programs"
                });
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log(state)
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var storeResponse = response.getReturnValue();
                    component.set("v.SearchAllQueueResult", storeResponse);  
                    console.log(storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    SearchQueueHelper: function(component, event) {
        try {
            var action = component.get("c.fetchQueue");
            var QueueKey= component.get("v.SearchQueueKeyword");
            action.setParams({
                'SearchQueueKeyword': component.get("v.SearchQueueKeyword")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse.length == 0) {
                        component.set("v.Message", true);
                        component.set("v.ShowSearchQueueTable", false);
                        component.set("v.ShowQueueTable", false);
                    } else {
                        component.set("v.Message", false);
                        component.set("v.ShowSearchQueueTable", true);
                        component.set("v.ShowQueueTable", false);
                    }
                    component.set("v.SearchQueueResult", storeResponse); 
                    console.log(storeResponse);
                }else if (state === "INCOMPLETE") {
                    alert('Response is Incompleted');
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) { alert("Error message: " + errors[0].message);
                                                            }
                    } else {
                        alert("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    openWindow : function(component, event) {
        try{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:QueueUserDetails",
                componentAttributes: {
                    QueueId : event.getSource().get("v.class"),
                    QueueName : event.getSource().get("v.value")
                    
                } 
                
            }); 
            evt.fire();
        }
        catch(Err){
        }
    },
})