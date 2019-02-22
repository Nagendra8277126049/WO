({
	doInit: function(component, event, helper) {
		helper.doInitHelper(component);
    },
    
    OpenEditForm : function(component,event, helper)
    {
        alert(JSON.stringify(component.get("v.Override")));
        helper.OpenEditformHelper(component,event);
    },
    
    closeModal :function(component,event, helper)
    {
        helper.closeModalhelper(component,event);
    },
    saveRecord : function(component, event, helper)
    {
         helper.saveRecordHelper(component, event);        
    },
    
    handlechange :function(component, event, helper)
    {
        var isChecked = component.find("dspchk").get("v.value");
        component.set("v.Override", isChecked);
    }
    
})