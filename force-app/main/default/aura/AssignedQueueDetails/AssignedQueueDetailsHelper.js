({
    initializeHelper : function(component,event,UserId) {
        var action = component.get("c.fetchUserqueue");
        action.setParams({
            'SearchQueueKeyword': '',
            'usrId': UserId
        });
        // Tab Name
        var workspaceAPI = component.find("workspace");
        var TabName = component.get("v.UserName");
        workspaceAPI.getEnclosingTabId().then(function() {
            // var focusedTabId = tabId;
            workspaceAPI.setTabLabel({
                //    tabId: focusedTabId,
                label: TabName 
            });
            workspaceAPI.setTabIcon({
                //  tabId: TabName,
                icon: "standard:user"
            });
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var storeResponse = response.getReturnValue();
                //var Queuecount = storeResponse.size();
               // component.set("Queuecount", Queuecount);
               // if (Queuecount == 0)
                //{
                //    component.set("v.isClone", false);
                //}
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.isClone", false);
                    component.set("v.isSelect", false);
                }
                else{
                    var QueueId = response.getReturnValue(QueueId);
                // set searchResult list with return value from server.
                component.set("v.QueueResult", storeResponse);
                console.log(storeResponse);
                component.set("v.ListOfQueue", QueueId);
                //component.set("v.ListOfQueue", QueueId);
                console.log('Assigned Queues'+ QueueId);
                    component.set("v.isClone", true);
                    component.set("v.isSelect", true);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    SearchQueueHelper: function(component, event,UserId) {
        var action = component.get("c.fetchUserqueue");
        // Check for Search Keyword
        var QueueKey= component.get("v.SearchQueueKeyword");
        action.setParams({
            'SearchQueueKeyword': component.get("v.SearchQueueKeyword"),
            'usrId': UserId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                    component.set("v.ShowQueueTable", false);
                    component.set("v.ShowSearchQueueTable", false);
                } else {
                    component.set("v.Message", false);
                    component.set("v.ShowSearchQueueTable", true);
                    component.set("v.ShowQueueTable", false);
                }
                component.set("v.NumberofUsers", storeResponse.length);
                component.set("v.SearchQueueResult", storeResponse); 
                
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
    },
    deleteSelectedHelper: function(component, event, deleteRecordsIds,UserId) {
        //call apex class method
        var action = component.get('c.RemoveUser');
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "lstRecordId": deleteRecordsIds,
            'usrId': UserId
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(state);
                if (response.getReturnValue() != '') {
                    // if getting any error while delete the records , then display a alert msg/
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
                
                // call the onLoad function for refresh the List view    
                // this.onLoad(component, event);
                var workspaceAPI = component.find("workspace");
                workspaceAPI.refreshTab({
                    //tabId: focusedTabId,
                    includeAllSubtabs: true
                });
            }
        });
        $A.enqueueAction(action);
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
    OpenQueueModelHelper: function(component,event,UserId){
        component.set("v.isOpen", true);
       /* var action = component.get("c.fetchUserqueue");
        action.setParams({
            'SearchQueueKeyword' : '',
            'usrId': UserId
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var QueueId = response.getReturnValue(QueueId);
                //component.set("v.ListOfQueue", QueueId);  
            }
        });
        $A.enqueueAction(action); */
    },
    CloseModalHelper: function(component, event, helper) {
        component.set("v.isOpen", false);
         //component.set("v.isConf", false);
         var workspaceAPI = component.find("workspace");
         workspaceAPI.refreshTab({
             //tabId: focusedTabId,
             includeAllSubtabs: true
         });   
    }, 
    CloneUserhelper : function(component, event,selectedusers,CloneId ) {
        var action = component.get('c.clonequeueuser');
        //alert(selectedqueue);
        action.setParams({
            "UserId" : selectedusers,
            "CloneId" : CloneId            
        });
        action.setCallback(this, function(response) {
            //alert(response.getState());
            var state = response.getState();
            console.log(state);
            //component.set("v.isOpen", false);
            //alert(response);
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
            // call the onLoad function for refresh the List view    
            var workspaceAPI = component.find("workspace");
            workspaceAPI.refreshTab({
                //tabId: focusedTabId,
                includeAllSubtabs: true
            });
        });
        $A.enqueueAction(action);
    },
    AddQueuehelper : function(component, event,selectedqueue,UserId ) {
        
        var action = component.get('c.Addqueue');
        //alert(selectedqueue);
        action.setParams({
            "grpid" : selectedqueue,
            "usrId" : UserId
        });
        action.setCallback(this, function(response) {
            //alert(response.getState());
            var state = response.getState();
            //alert(response);
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
            // call the onLoad function for refresh the List view    
            var workspaceAPI = component.find("workspace");
            workspaceAPI.refreshTab({
                //tabId: focusedTabId,
                includeAllSubtabs: true
            });
        });
        $A.enqueueAction(action);
    },
})