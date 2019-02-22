({
    Search: function(component, event, helper) {
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
          // else call helper function
            
            helper.SearchHelper(component, event);
        }
    },
     openModel: function(component, event, helper) {
      //var grpId = event.getSource().get("v.name");
         //component.set("v.groupid", grpId);
      var removeLabel = event.getSource().get("v.label"); 
         if(removeLabel === 'Add User'){
             
           component.set("v.isAdded ", true);  
            
         }else{
           
           component.set("v.isRemove", true);  
         }
         
      if(component.get("v.groupid") == null){
            
               component.set("v.MessageAddUser", true);
                  
         }else{
           
           component.set("v.labelBtn", removeLabel);
           component.set("v.isOpen", true);
           component.set("v.MessageAddUser", false);
             
         }
         
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
      component.set("v.isAdded ", false);
      component.set("v.isRemove", false); 
   },
 
   likenClose: function(component, event, helper) {
      
      var selecteduser = JSON.stringify(component.get("v.selectedRecord"));
      var groupids = component.get("v.groupid");
      var buttonlabel = component.get("v.labelBtn");
    
       if(!selecteduser.includes("Id")){
           
           alert('Please select User');
           
       }else{
      helper.selecteduser(component, event, selecteduser, groupids, buttonlabel);
      component.set("v.isOpen", false);
      component.set("v.selectedRecord", null);   
       }

   },
  
    
    
  getSelectid: function(component, event, helper) {
  var selectedAccountGetFromEvent = event.getParam("recordByEvent");
  component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
      
        
 },
    
 handleRadioClick: function(component, event, helper) {
   var grpId = document.querySelector('input[name="options"]:checked').value
    component.set("v.groupid", grpId);   

 },
    
})