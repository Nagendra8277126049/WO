({
	doInit : function(component, event, helper) {
        setTimeout(function() {
            helper.getCallTransAttrRecId(component, event);
            helper.setTabIconAndTitle(component, event);
        }, 900);
	},
})