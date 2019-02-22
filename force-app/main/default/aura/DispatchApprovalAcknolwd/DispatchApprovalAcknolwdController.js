({
   onButtonPressed: function(component, event, helper) {
       try{
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      if(actionClicked === "NEXT"){
          component.set("v.Acknowledged",true);
      } else {
          component.set("v.Acknowledged",false);
      }
      
      var action = 'NEXT';
      // Fire that action
      var navigate = component.get('v.navigateFlow');
      navigate(action);
   } catch(Err) {
    console.log("Error ====>  "+Err);
}
   },
   	doInit: function(component, event, helper) {
        try{
        var criteria = component.get("v.criteria");
        if(!$A.util.isEmpty(criteria)){
            helper.splitCriteria(component,criteria);
        }
        } catch(Err)  {
            console.log("Error ====>  "+Err);
        }
	},
})