({
    selectRecord : function(component, event, helper){   
        try {
            // get the selected record from list  
            var getSelectRecord = component.get("v.oRecord");
            // call the event   
            var compEvent = component.getEvent("oSelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams({"recordByEvent" : getSelectRecord });  
            // fire the event  
            compEvent.fire();
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
})