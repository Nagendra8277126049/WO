({
    handleOpenInNewTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: event.getParam('recordId'),
            url: event.getParam('url'),
            focus: true
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})