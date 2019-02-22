({
    initializeHelper: function(component,event,QueueId){
        try {
            component.find("Id_spinner").set("v.class" , 'slds-show');
            var action = component.get("c.fetchSearchQueueUser");
            action.setParams({
                'SearchUserKeyword' : '',
                'grpId': QueueId
            });
            var workspaceAPI = component.find("workspace");
            var TabName = component.get("v.QueueName");
            workspaceAPI.getEnclosingTabId().then(function() {
                
                workspaceAPI.setTabLabel({
                    label: TabName 
                });
                workspaceAPI.setTabIcon({
                    icon: "standard:channel_programs"
                });
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var storeResponse = response.getReturnValue();
                    component.set("v.SearchUserResult", storeResponse);
                    component.set("v.ShowUserTable", true);
                    if (storeResponse.length == 0) {
                        component.set("v.isSelect", false);
                    }
                    else if (storeResponse.length != 0){
                        
                        component.set("v.isSelect", true);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch(err){
            console.log(err);
        }    
    },
    OpenModalHelper: function(component,event,QueueId){
        try {
            component.set("v.isOpen", true);
            var action = component.get("c.fetchQueueUser");
            action.setParams({
                'grpId': QueueId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    console.log(storeResponse);
                    component.set("v.ListOfUser",storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    CloseModalHelper: function(component, event, helper) {
        try {
            component.set("v.isOpen", false);
            component.set("v.isConf", false);
            var workspaceAPI = component.find("workspace");
            workspaceAPI.refreshTab({
                includeAllSubtabs: true
            });  
        }
        catch(err){
            console.log(err);
        } 
    }, 
    adduserHelper: function(component, event,selectedusers,QueueId) {
        try{
            var action = component.get('c.addusers');
            action.setParams({
                "UserId" : selectedusers,
                "grpid" : QueueId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "User Added to the queue"
                    });
                    toastEvent.fire();
                }
                else if (state === "INCOMPLETE") {
                    alert('Response is Incompleted');
                }else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Unable to add user to the queue."
                    });
                    toastEvent.fire();
                }
                var workspaceAPI = component.find("workspace");
                workspaceAPI.refreshTab({
                    includeAllSubtabs: true
                });
            });
            $A.enqueueAction(action);
        }
        catch(err){
            console.log(err);
        }   
    },
    deleteSelectedHelper: function(component, event, deleteRecordsIds,QueueId) {
        try {
            var action = component.get('c.RemoveUser');
            action.setParams({
                "lstRecordId": deleteRecordsIds,
                "grpid" : QueueId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log(state);
                    if (response.getReturnValue() != '') {
                        alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Removed user from the queue"
                        });
                        toastEvent.fire();
                    }
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.refreshTab({
                        includeAllSubtabs: true
                    });
                }
            });
            $A.enqueueAction(action);
        }
        catch(err){
            console.log(err);
        }  
    }, 
    SearchUserHelper: function(component, event,QueueId) {
        try{
            var action = component.get("c.fetchSearchQueueUser");
            var QueueKey= component.get("v.SearchUserKeyword");
            action.setParams({
                'SearchUserKeyword': component.get("v.SearchUserKeyword"),
                'grpId': QueueId
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    console.log(storeResponse);
                    if (storeResponse.length == 0) {
                        component.set("v.Message", true);
                        component.set("v.ShowSearchUserTable", false);
                        component.set("v.ShowUserTable",false);
                    } else {
                        component.set("v.Message", false);
                        component.set("v.ShowSearchUserTable", true);
                        component.set("v.ShowUserTable", false);
                    }
                    component.set("v.SearchQueueUserResult", storeResponse); 
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
        catch(err){
            console.log(err);
        } 
    },
    openuserqueuehelper: function(component,event){
        try{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CloneQueueUser",
                componentAttributes: {
                    UserId : event.getSource().get("v.class"),
                    UserName : event.getSource().get("v.value")
                } 
            });
            evt.fire();
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.QueueAssignmentErrorMessage"), "Error");
        }
    },
})