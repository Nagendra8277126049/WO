({
    doinitHelper: function(component,event,QueueId){
        try {
            var action = component.get("c.fetchsearchuser");
            action.setParams({
                'SearchUserKeyword': '',
                'isAsc': component.get("v.isAsc"),
                'isSort':component.get("v.isSort"),
            });
            component.find("Id_spinner").set("v.class" , 'slds-show');
            var workspaceAPI = component.find("workspace");
            var TabName = component.get("v.TabName");
            workspaceAPI.getEnclosingTabId().then(function(tabId) {
                var focusedTabId = tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: TabName 
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:user",
                });
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var storeResponse = response.getReturnValue();
                    console.log('User Load on Queue click'+storeResponse);
                    component.set("v.UserResult", storeResponse);
                    component.set("v.ShowUserTable", true);
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    sortManagerHelper: function(component, event, sortField,isAsc) { 
        try {
            var currentDir = component.get("v.arrowDirection");
            if (currentDir == 'arrowdown') {
                component.set("v.arrowDirection", 'arrowup');
                component.set("v.isAsc", true);
                component.set("v.isSort", true);
            } else {
                component.set("v.arrowDirection", 'arrowdown');
                component.set("v.isAsc", false);
                component.set("v.isSort", true);
            }
            this.doinitHelper(component, event);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
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
    SearchUserHelper: function(component, event) {
        try {
            var action = component.get("c.fetchsearchuser");
            var UserKey= component.get("v.SearchUserKeyword");
            action.setParams({
                'SearchUserKeyword': component.get("v.SearchUserKeyword"),
                'isAsc': component.get("v.isAsc"),
                'isSort':component.get("v.isSort")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse.length == 0) {
                        component.set("v.Message", true);
                        component.set("v.ShowSearchUserTable", false);
                        component.set("v.ShowUserTable", false);
                    } else {
                        component.set("v.Message", false);
                        component.set("v.ShowSearchUserTable", true);
                        component.set("v.ShowUserTable", false);
                    }
                    component.set("v.SearchUserResult", storeResponse); 
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
})