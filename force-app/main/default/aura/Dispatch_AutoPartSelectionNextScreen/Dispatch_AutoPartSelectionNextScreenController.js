({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component);
        //helper.handleClearHelper(component, event,helper);
    },
    SelectPart: function(component, event, helper) {
        helper.handleSelectPart(component, event);
    },
    handleValidateParts: function(component, event, helper) {
        helper.handleValidatePartsHelper(component, event, helper);
        //helper.handleClearHelper(component, event,helper);
    },
    closeAutoPartsPopUp: function(component, event, helper) {
		component.set('v.showAutoAddPopUp', false);
    },
    /* // Commented By Harsha - DEFECT 5462004
    handleAddParts : function (component, event,helper) {
        helper.handleAddPartsHelper(component);
        //helper.handleClearHelper(component, event,helper);
    },
    */
    handleQuantitychange: function(component, event, helper) {
        helper.handleQuantitychangeHelper(component, event);
    },
    handleClear: function(component, event, helper) {
        helper.handleClearHelper(component);
    },
    handleAdvancedSearch: function(component, event, helper) {
        helper.handleAdvanceSearchHelper(component);
    },
    doSomething :function(component,event, helper)
    {
        alert('Inside doSomething');
        /*var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": component.get("v.spmdLink")
    });
    urlEvent.fire();*/
    }
})