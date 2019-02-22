({
    doinit: function(component, event, helper) {
        try {
            var QueueId = component.get("v.LstOfQueue");
            document.body.setAttribute('style', 'overflow: hidden;');
            helper.doinitHelper(component, event,QueueId);  
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    sortManager: function(component, event, helper) {
        try {
            component.set("v.selectedTabsoft", 'Manager');
            helper.sortManagerHelper(component, event, 'Manager');
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    openuserqueue: function(component, event, helper) {
        try {
            helper.openuserqueuehelper(component, event);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }  
    },
    SearchUser: function(component, event, helper) { 
        try {
            var getInputkeyWord = component.get("v.SearchUserKeyword");
            if(getInputkeyWord.length > 0){
                var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                helper.SearchUserHelper(component,event);
            }
            else{  
                component.set("v.SearchUserResult", null ); 
                component.set("v.Message", false);
                var forclose = component.find("searchRes");
                component.set("v.ShowSearchUserTable", false);
                component.set("v.ShowUserTable", true);
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            } 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
})