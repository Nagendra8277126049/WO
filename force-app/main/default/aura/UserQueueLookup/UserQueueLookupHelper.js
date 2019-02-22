({
     searchHelper : function(component,event,getInputkeyWord,UserId) {
        var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : component.get("v.lstSelectedRecords"),
            'UserId' : UserId
        });
        
        //String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, List<Group> lstofgrp
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log("state" + state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //console.log("storeResponse" + state);
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse); 
            }
        });
        $A.enqueueAction(action);
    },
})