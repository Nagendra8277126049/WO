({
    handleOpenModal: function(component) {
        component.set("v.openModal", true);
        
        const childComp = component.get("V.child")[0];
        childComp.initMethod(childComp);
    },
    
    handleCloseModal: function(component, event, helper) {
        const childComp = component.get("V.child")[0];
        
        if (childComp.closeMethod)
        	childComp.closeMethod(childComp);
        
        component.set("v.openModal", false); 
    },
    
    handleAction: function(component, event, helper) {
        const childComp = component.get("V.child")[0];
        const result = childComp.confirmMethod(childComp);
        
        var event = component.getEvent('callback');
        event.setParam("return", result);
        event.fire();
        component.set("v.openModal", false);
    }
})