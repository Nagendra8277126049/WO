({
    doInit : function(component, event, helper) {
        try{
            helper.populateLineItemDetails(component, event, helper);
        }
        catch(Err){
            
        }
    },
    saveRecord : function(component, event, helper) {
        try{
            helper.saveRecordHelper(component, event, helper);
        }
        catch(Err){
            
        }
    },
    onQuantityChange : function(component, event, helper) {
        try{
            helper.validateQuantityChange(component, event, helper);
        }
        catch(Err){
            
        }
    },
    onCancelClick : function(component, event, helper) {
        try{
            helper.closeFocusedTabHelper(component, event, helper);
        }
        catch(Err){
            
        }
    },
    handleRecordUpdated : function(component, event, helper) {
        try{
        }
        catch(Err){
            
        }
    },
    onCheck: function(component, event, helper){
        var checkCmp = component.find("checkbox");
        console.log('=========', checkCmp.get("v.checked"));
        helper.saveDoNotSub(component, event, checkCmp.get("v.checked"));
    }
    
})