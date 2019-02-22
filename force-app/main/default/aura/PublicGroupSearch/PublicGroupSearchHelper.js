({
    SearchHelper: function(component, event) {
        // show spinner message
         component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchGroup");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
           // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                     component.set("v.MessageAddUser", false);
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);
                
                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
   selecteduser : function(component, event, selecteduser, groupids, buttonlabel) {
    console.log(selecteduser + '  ' + 'selecteduser>>');
    var action = component.get('c.addUsers');
    console.log(selecteduser + '  ' + 'selecteduser>>1');
   action.setParams({
       "lstRecordId": selecteduser, "groupid" : groupids, "buttonlabels":buttonlabel
  });
  
action.setCallback(this, function(response) {
   //store state of response
   var state = response.getState();
   if (state === "SUCCESS") {
    console.log(state);
    if (response.getReturnValue() != '') {
    
     alert('The following error has occurred' + response.getReturnValue());
    } else {
        if(buttonlabel == 'Add User'){
    		alert('User Added to Public Group');
            component.set("v.isOpen", false);
      component.set("v.isAdded ", false);
      component.set("v.isRemove", false); 
        }else{
         	alert('User Removed from Public Group'); 
            component.set("v.isOpen", false);
      component.set("v.isAdded ", false);
      component.set("v.isRemove", false); 
            
        }
    }
    // call the onLoad function for refresh the List view    
   
   }
  });
  $A.enqueueAction(action);  
		
	},
  
})