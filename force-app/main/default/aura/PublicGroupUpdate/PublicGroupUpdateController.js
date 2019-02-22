({
	myAction : function(component, event, helper) {
	          
         var action = component.get("c.getGroupmembers");
		action.setCallback(this, function(response){
             var name = response.getState();
              if (name === "SUCCESS") {
                     component.set("v.reg", response.getReturnValue());
                    }
       		 });
          $A.enqueueAction(action);
	},
     openModel: function(component, event, helper) {
      var grpId = event.getSource().get("v.name");
         component.set("v.groupid", grpId);
         
      component.set("v.isOpen", true);
       
         
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   likenClose: function(component, event, helper) {
      
      var selecteduser = JSON.stringify(component.get("v.selectedRecord"));
      var groupids = component.get("v.groupid");
	  //alert(selecteduser);
      helper.selecteduser(component, event, selecteduser, groupids);
      component.set("v.isOpen", false);
   },
  
    
  getSelectid: function(component, event, helper) {
  var selectedAccountGetFromEvent = event.getParam("recordByEvent");
  component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
      
        
 }
})