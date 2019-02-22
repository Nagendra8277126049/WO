({
	handleRecordUpdated: function(component, event, helper) {
        try{
            var eventParams = event.getParams();
        	if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
                
			} 
        }catch(Err){
        	//console.log(Err);
        	helper.showToast(component,'Error', "Unable to Open URL", "Error");
        }
    }
})