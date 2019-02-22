({
    // cOMMENTED  BY Harsha - DEFECT 5446043
    /*
    doInit: function (component, event,helper){
        console.log('serviceTag--->'+component.get("v.serviceTag"));
        console.log('addressBUID--->'+component.get("v.addressBUID"));
        console.log('workOrderId--->'+component.get("v.workOrderId"));
        helper.doInitHelper(component, event,helper); // cOMMENTED  BY Harsha - DEFECT 5446043
         //helper.handleAdvanceSearchHelper(component, event,helper);
		//helper.doInitHelper(component, event,helper);
		//helper.turnOffSpinner(component);
    },
    */
    // cOMMENTED  BY Harsha - DEFECT 5446043
    
    recordUpdated: function (component, event,helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "CHANGED") {
            var changedFields = event.getParams().changedFields;
            //helper.doInitHelper(component, event,helper); // cOMMENTED  BY Harsha - DEFECT 5446043
            // Added by Harsha - DEFECT 5446043 - Starts Here
            var stringChangedFields = JSON.stringify(changedFields);
            if(stringChangedFields.includes("Service_Type__c")){
                helper.checkServiceType(component);   
            }
            // Added by Harsha - DEFECT 5446043 - Ends Here
        }
        // Added by Harsha - DEFECT 5446043 - Starts Here
        else if (changeType === "LOADED") {
            helper.checkServiceType(component);  
        }
        // Added by Harsha - DEFECT 5446043 - Ends Here
    },
    navigateToSPMD: function (component, event,helper) { 
		//helper.navigateToSPMDHelper(component, event,helper);
    },
	handleOnClick: function (cmp, evt,helper) {        
        helper.handleOnClickHelper(cmp, evt,helper);    
    },
    handleAdvancedSearch: function (component, event,helper) {   
        helper.handleAdvanceSearchHelper(component, event,helper);
    },
    handleChange: function (component, event,helper) {        
        helper.handleChangeHelper(component, event,helper);    
    },
    handleCommodityChange : function (component, event,helper) {
        helper.handleCommodityChangeHelper(component, event,helper);
    },
    /*handlePofChange : function (component, event,helper) {
        helper.handlePofChangeHelper(component, event,helper);
    },*/
    handleSearch : function (component, event,helper) {
        component.set("v.renderComponent", false);
        helper.handleSearchHelper(component, event,helper);
    },
    /*SelectPart : function (component, event,helper) {
        helper.handleSelectPart(component, event,helper);
    },
    addParts : function (component, event,helper) {
        helper.handleaddParts(component, event,helper);
    },*/
    /*unrender: function (component, event, helper) {
        this.superUnrender();
    },*/
    handleClear : function (component, event, helper){
		helper.handleClearHelper(component, event, helper);
    },
    
    opentable : function(component,event,helper){
        helper.showorhide(component);
        var toggletext = component.find("text");
        $A.util.toggleClass(toggletext, "toggle");
        helper.handleOnClickHelper(component,event,helper);
        helper.handleChangeHelper(component, event,helper); 
    }
})