({
    doinit: function(component, event, helper) {
        try {
            var QueueId = component.get("v.RecordId");
            document.body.setAttribute('style', 'overflow: hidden;');
            helper.doinitHelper(component,event,QueueId);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    OpenImportWindow :  function(component, event, helper) {
        try {
           var myLink = $A.get("$Label.c.importlink");
           var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": myLink
            });
    urlEvent.fire();  
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    
    SearchQueue: function(component, event, helper) {
        try {
            var getInputkeyWord = component.get("v.SearchQueueKeyword");
            if(getInputkeyWord.length > 0){
                var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                helper.SearchQueueHelper(component,event);
            }
            else{  
                component.set("v.SearchQueueResult", null ); 
                component.set("v.Message", false);
                var forclose = component.find("searchRes");
                component.set("v.ShowSearchQueueTable", false);
                component.set("v.ShowQueueTable", true);
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            }
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },   
    SearchQueueUser: function(component, event, helper) {
        try {
            helper.openWindow(component, event);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
})