({
	selecteduser : function(component, event, selecteduser, groupids) {
    console.log(selecteduser + '  ' + 'selecteduser>>');
    var action = component.get('c.addUsers');
    console.log(selecteduser + '  ' + 'selecteduser>>1');
   action.setParams({
       "lstRecordId": selecteduser, "groupid" : groupids
  });
  
action.setCallback(this, function(response) {
   //store state of response
   var state = response.getState();
   if (state === "SUCCESS") {
    console.log(state);
    if (response.getReturnValue() != '') {
    
     alert('The following error has occurred' + response.getReturnValue());
    } else {
    alert('User Added to Public Group');
    }
    // call the onLoad function for refresh the List view    
   
   }
  });
  $A.enqueueAction(action);  
		
	}
})