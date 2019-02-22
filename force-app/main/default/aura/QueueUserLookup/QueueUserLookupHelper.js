({
    searchHelper : function(component,event,getInputkeyWord,lstofgm) {
        try {
            var action = component.get("c.fetchLookUpValues");  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : component.get("v.objectAPIName"),
                'ExcludeitemsList' : component.get("v.lstSelectedRecords"),
                'lstofgm' : lstofgm,
                'CloneId' : component.get("v.CloneId")
            });    
            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Records Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    component.set("v.listOfSearchRecords", storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
        
    },
})