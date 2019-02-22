({
    doInit: function(component, event, helper) {
        try{ 
            helper.applycss(component);           
        }catch(Err){      
            helper.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },
    /*
    closeModal : function(component, event, helper) {
        try{
			helper.closeMe(component, event, helper);
        }catch(Err){            
            helper.showToast(component,'Error', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }      
	},
    */
    closeModal:function(component,event,helper){    
        try {
            //var cmpTarget = component.find('Modalbox');
            //var cmpBack = component.find('Modalbackdrop');        
            var cmpEvent = event.getSource();
            var whichContact = "";
            if (cmpEvent != null && cmpEvent !=undefined)
            {
                if(cmpEvent.getLocalId() == "mainConSaveBtn") {
                    helper.postUpdateRequest(component, event, helper);
                }
                else {
                    helper.closeMe(component, event, helper);
                }
              //  else{
              //      $A.util.removeClass(cmpBack,'slds-backdrop--open');
              //      $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
              //  }
                
                
            }
        }
        catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.AssetContactGetErrorMessage"), "Error");
        }
    },
})