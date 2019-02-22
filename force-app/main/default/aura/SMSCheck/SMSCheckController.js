({
	 checkboxSelect: function(component, event, helper) {
         var caseId = component.get("v.rID"); 
         var action = component.get("c.check");
         action.setParams({
               'caseId' :caseId
          });
		action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") { 
                    console.log("errorDiv"+caseId);
                    if(response.getReturnValue() == "0") {
                       var cBox = component.find("checkbox");
                       cBox.set("v.value", false);
                       component.set("v.statusMsg", "Primary Phone Number is not SMS capable, Please update." );
                       // Primary Phone Number is not SMS capable, Please update.
                    	//document.getElementById("errorDiv"+caseId).innerHTML = '<span style="color: red;"><b>Please Update The Phone Number of Contact.</b></span>'
                		//document.getElementById("checkbox-5").checked = false;
                       // location.reload();
                        
                    }else{
                       // component.set("v.statusMsg", "SMS capable check successful!");
                        cBox.set("v.value", true);
                    }
                }
        });
          $A.enqueueAction(action);
         
	},
    
    doInit : function(component, event, helper){
       var rD= component.get("v.recordId");
        component.set("v.rID",rD);
        var action = component.get("c.getCaseDetails");
        action.setParams({
            "cId": rD
        });
        action.setCallback(this, function(res) {
            var state = res.getState();
            console.log(res.getReturnValue());
            if(state == 'SUCCESS') {
                component.set("v.item", res.getReturnValue());
            }  
        })
        $A.enqueueAction(action);
    }
   
   
})