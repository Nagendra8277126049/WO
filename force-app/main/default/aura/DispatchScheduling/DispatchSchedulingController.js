({
    doInit : function(component, event, helper)
    {
        try{
            helper.getSlots(component, event);
		}
		catch(Err){
           console.log(Err);
           //Toast Error Message to User
           helper.showToast(component,'Error', "Error Occured While Loading the Slots", "Error");
        } 
        
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    setCFSAttribute : function(component, event, helper)
    {
        try{
            alert(1);
            helper.setCFSAttribute(component, event);
		}
		catch(Err){
           console.log(Err);
           //Toast Error Message to User
           helper.showToast(component,'Error', "Error Occured While Loading the Slots", "Error");
        } 
        
    },
    
})