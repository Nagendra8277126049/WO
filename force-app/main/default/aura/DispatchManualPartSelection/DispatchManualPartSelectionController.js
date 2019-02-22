({
	doInit : function(component, event, helper) {
		try {   
            helper.turnOnSpinner(component);
        	helper.helperMethod(component, event, helper);
            helper.helperHandleKeyUp(component, event,helper);
            //helper.handleChangeHelper(component, event,helper); 
        }catch(Err){
        	console.log("Error While handleSearchWithPPID ==>  "+Err);             
        }
	},
    handlePofCheckboxChange : function(component, event, helper) {
        try {            
        	helper.checkboxPofChangeHandler(component, event, helper);
        }catch(Err){
        	console.log("Error While handleSearchWithPPID ==>  "+Err);             
        }
    },
    onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   },
    handleChange: function (component, event,helper) {        
        helper.handleChangeHelper(component, event,helper);    
    },
    
    keyPressController : function(component, event, helper) {
      // get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");        
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            console.log('keyPressController ---> before');
	        helper.keyPressController(component, event); 
        }         
	},
    checkboxChangeHandler : function (component, event,helper) {
        try{
            helper.checkboxChangeHandler(component, event,helper);  
        }catch(Err){
            console.log("Error While checkboxChangeHandler ==>  "+Err);
        }
        
    },
    handleSearchWithPPID : function (component, event,helper) {
        try{
            helper.helperSearchOnClick(component, event,helper);
        }catch(Err){
            console.log("Error While handleSearchWithPPID ==>  "+Err);
        }
    },
    handleKeyUp: function (component, event,helper) {  
        try{
            helper.helperHandleKeyUp(component, event,helper);    
        }catch(Err){
            console.log("Error While handleKeyUp ==>  "+Err);
        }
        
    },
    SearchOnClick: function (component, event,helper) {  
        try{
            helper.helperSearchOnClick(component, event,helper);    
        }catch(Err){
            console.log("Error While handleKeyUp ==>  "+Err);
        }
        
    },
    handleClear: function (component, event,helper) {  
        try{
            helper.handleClearHelper(component, event,helper);    
        }catch(Err){
            console.log("Error While handleClear ==>  "+Err);
        }
        
    },
    
    handleSelectParts: function (component, event,helper) {  
        try{
            //helper.handleSelectParts(component, event,helper);    
        }catch(Err){
            console.log("Error While handleSelectParts ==>  "+Err);
        }
        
    },
})