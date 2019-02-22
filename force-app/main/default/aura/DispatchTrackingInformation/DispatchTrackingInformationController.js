({
    doInit: function(component, event, helper) {
        try{
            //Call Helper
            helper.getResponses(component, event, helper);
        }catch(Err){
            helper.showToast(component,'Error', "Error Occured While Loading Lightning Component", "Error");
        }
    }
})