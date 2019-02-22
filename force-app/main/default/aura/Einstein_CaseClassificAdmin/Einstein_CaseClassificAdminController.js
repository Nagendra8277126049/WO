({
    getToken: function(component, event, helper) {
        console.log("calling helper");
        helper.getToken(component);
    },
    doInit: function(component, event, helper) {
        console.log("calling onLoadDatasets");
        helper.onLoadDatasets(component);
        helper.onGetAdminSettings(component) ;
        helper.doInitUsage(component);
        //Adding default value
        //component.set("v.datasetId", component.find("selectDataset").get("v.value"));
        //helper.onLoadDataModels(component)
        //Added
    },
    
    modelValueChanged : function(component, event, helper) {
        console.log("calling modelValueChanged");
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
        //component.set("v.modelId", component.find("selectModel").get("v.value"));
        //console.log('ModelID ' + component.find("selectModel").get("v.value"));
        helper.onUpdateModelID(component);
    },
    
    OnRefreshModelMetrics : function(component, event, helper) {
        helper.OnRefreshModelMetrics(component);
    },
    
    onGetAdminSettings : function(component, event, helper) {
        console.log("calling updateModelID");
        helper.onGetAdminSettings(component);
    },
    
    
})