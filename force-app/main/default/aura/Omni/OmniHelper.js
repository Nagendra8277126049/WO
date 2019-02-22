({
  displayToast : function(component, type, message) {
    var toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
      type: type,
      message: message
    });
    toastEvent.fire();
  },
    
  checkCurrentOmniStatus : function(component, omniAPI, helper) {
      var delay=5000; //5 seconds
      var defaultStatus = $A.get("$Label.c.Default_Omni_Status");
     var statusArr = defaultStatus.split(',');
      var defaultStatusId = statusArr[0];
      var defaultStatusName = statusArr[1];
      console.log('1 Omni Log: ' + defaultStatusId);
      try{
          setTimeout(function() {                
              
              omniAPI.getServicePresenceStatusId().then(function(result) {
                  console.log('Status Id is: ' + result.statusId);
                  var currentStatusId = result.statusId;
                  //helper.getCurrentStatusName(component, helper, currentStatusId);
                  helper.displayToast(component, 'success', 'Your current Omni Status: ' + result.statusName);
              }).catch(function(error) {
                                                                                helper.loginToOmni(component, omniAPI, helper, defaultStatusId, defaultStatusName);
              });
              
          }, delay);        
      }
      catch(err){
          helper.displayToast(component, 'error', 'Unable to login to Omni. Please login manually. If issue persists refresh page.');
      }
  },
    
  loginToOmni : function(component, omniAPI, helper, statusId, statusName) {        
      omniAPI.login({statusId: statusId}).then(function(result) {
          if (result) {
              console.log("Login successful");
              helper.displayToast(component, 'success', 'You are logged into Omni and set to ' + statusName);
          } else {
              console.log("Login failed");
              helper.displayToast(component, 'error', 'Omni login failed. Please login manually.');
          }
      }).catch(function(error) {
          console.log(error);
      });        
  }    
})