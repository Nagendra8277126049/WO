({
    
    doInit: function(component, event, helper) {
        helper.onLoadDatasets(component);
        helper.onGetAdminSettings(component) ;
        
    },
    
    modelValueChanged : function(component, event, helper) {
        component.set("v.modelId", component.find("selectModel").get("v.value"));
        var modelId = component.get("v.modelId");
        console.log("modelId : " + modelId);
    },
    
    datasetValueChanged : function(component, event, helper) {
        console.log("calling datasetValueChanged");
        component.set("v.datasetId", component.find("selectDataset").get("v.value"));
        helper.onLoadDataModels(component)
    },
    
    onUpdateModelID : function(component, event, helper) {
        console.log("calling updateModelID");
        helper.onUpdateModelID(component);
    },
        
    onGetAdminSettings : function(component, event, helper) {
        console.log("calling updateModelID");
        helper.onGetAdminSettings(component);
    }
    
    
})