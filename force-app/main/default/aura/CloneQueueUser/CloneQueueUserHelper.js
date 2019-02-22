({
    UserDetailHelper : function(component,event,UserId) {
        try{
            var action = component.get("c.fetchsearchuser");
            action.setParams({
                'SearchUserKeyword' :'',
                'UserId' : UserId ,
                'isSort' : false
            });
            var workspaceAPI = component.find("workspace");
            var TabName = component.get("v.UserName");
            workspaceAPI.getEnclosingTabId().then(function() {
                workspaceAPI.setTabLabel({
                    label: TabName 
                });
                workspaceAPI.setTabIcon({
                    icon: "standard:user"
                });
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    component.set("v.UserResult", storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            console.log(Err);
        }
    },
    initializeHelper : function(component,event,UserId) {
        try{
            var action = component.get("c.fetchUserqueue");
            action.setParams({
                'SearchQueueKeyword': '',
                'usrId': UserId
            });
            var workspaceAPI = component.find("workspace");
            var TabName = component.get("v.UserName");
            workspaceAPI.getEnclosingTabId().then(function() {
                workspaceAPI.setTabLabel({
                    label: TabName 
                });
                workspaceAPI.setTabIcon({
                    icon: "standard:user"
                });
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var QueueId = response.getReturnValue(QueueId);
                    if (storeResponse != null){
                        component.set("v.isClone",true);
                        component.set("v.QueueResult", storeResponse);            
                        component.set("v.ListOfQueue", QueueId);
                    }
                    if (storeResponse.length == 0) {
                        component.set("v.isClone", false);
                        component.set("v.isSelect", false);
                    }
                    else{
                        component.set("v.isClone", true);
                        component.set("v.isSelect", true);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    OpenUserModalHelper: function(component,event,UserId){
        try{
            component.set("v.isOpen", true);
            var action = component.get("c.fetchsearchuser");
            action.setParams({
                SearchUserKeyword :''
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
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    CloseModalHelper: function(component, event, helper) {
        try{
            component.set("v.isOpen", false);
            var workspaceAPI = component.find("workspace");
            workspaceAPI.refreshTab({
                includeAllSubtabs: true
            }); 
        }
        catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    OpenAssignedQueuesHelper: function(component,event){
        try{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:AssignedQueueDetails",
                componentAttributes: {
                    UserId : component.get("v.UserId"),
                    UserName : component.get("v.UserName")
                } 
            });
            evt.fire();
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.QueueAssignmentErrorMessage"), "Error");
        }
    },
    CloneUserhelper : function(component, event,selectedusers,CloneId ) {
        try{
            var action = component.get('c.clonequeueuser');
            action.setParams({
                "UserId" : selectedusers,
                "CloneId" : CloneId            
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Successfully cloned user"
                    });
                    toastEvent.fire();
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Unable to clone user."
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
        catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },    
    AddQueuehelper : function(component, event,selectedqueue,UserId ) {
        try{
            var action = component.get('c.Addqueue');
            action.setParams({
                "grpid" : selectedqueue,
                "usrId" : UserId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.isQOpen", false);
                if (state === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Successfully added queues to user"
                    });
                    toastEvent.fire();
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Unable to add queues to the user."
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
        catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
    openWindow : function(component, event,helper) {
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
        }catch(Err){
            this.showToast(component,'Error', $A.get("$Label.c.QueueAssignmentErrorMessage"), "Error");
        }
    },
    deleteSelectedHelper: function(component, event, deleteRecordsIds,UserId) {
        try {
            var action = component.get('c.RemoveUser');
            action.setParams({
                "lstRecordId": deleteRecordsIds,
                'usrId': UserId
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
                            "message": "Successfully removed users from the queue"
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
        catch(Err){
            console.log("Error While Open Modal  ===> "+Err); 
        }
    },
})