({
    //TODO
    getToken: function(component) {
        //var self = this;        
        //var getEinsteinApiToken = component.get("c.getEinsteinApiToken");
        //console.debug('EinsteinApiToken:' + getEinsteinApiToken)
        //component.set("v.EinsteinApiToken", 'EinsteinApiToken: ' + getEinsteinApiToken)
        console.log("calling Apex controller");
        var action = component.get("c.getEinsteinApiToken");
        //action.setStorable();
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log(a);
                component.set("v.EinsteinApiToken", a.getReturnValue());
                console.log("callback SUCCESS");
            } else if (state === "ERROR") {
                component.find("leh").passErrors(a.getError());
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    onLoadDatasets: function(component) {
        var self = this;
        var action = component.get("c.getDatasets");
        //var dataType = component.get("v.dataType");
        //action.setParams({
        //    dataType: dataType
        //});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            }
            
            
            component.set("v.datasets", response.getReturnValue());
            var datasets = response.getReturnValue();
            var defaultdatasetID = datasets[0].id;
            component.set("v.datasetId", defaultdatasetID); //added
            console.log("defaultdatasetID : " + defaultdatasetID);
            self.onLoadDataModels(component);
            //alert('test');
            
            var event = component.getEvent("waitingEvent");
            event.fire();
            
        });
        var event = component.getEvent("waitingEvent");
        event.fire();
        $A.enqueueAction(action);
    },
    
    onLoadDataModels: function(component) {
        console.log("calling onLoadDataModels");
        var self = this;
        var action = component.get("c.getModels");
        var mdatasetId = component.get("v.datasetId");
        console.log("datasetID: " + mdatasetId);
        action.setParams({
            datasetId: mdatasetId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            }
            component.set("v.datasetModels", response.getReturnValue());
            console.log(response.getReturnValue());
            var models = component.get("v.datasetModels");
            if (models.length > 0) {
                var defaultmodelID = models[0].modelId;
                console.log('default modelID: '+defaultmodelID);
                component.set("v.modelId", defaultmodelID);
            }
            var event = component.getEvent("waitingEvent");
            event.fire();
        });
        var event = component.getEvent("waitingEvent");
        event.fire();
        $A.enqueueAction(action);
    },
    
    onUpdateModelID: function(component) {
        var self = this;
        var action = component.get("c.updateModelId");
        var mnewmodelId = component.get("v.modelId");
        console.log("newModelID from components: " + mnewmodelId);
        action.setParams({
            newModelID: mnewmodelId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            }
            var today = new Date();
            var updateMessage = 'Model ID updated to: ' + response.getReturnValue() + ' on ' + today;
            component.set("v.ModelUpdateMessage", updateMessage);
            console.log(response.getReturnValue());
            var event = component.getEvent("waitingEvent");
            event.fire();
        });
        var event = component.getEvent("waitingEvent");
        event.fire();
        $A.enqueueAction(action);
    },
    
    onGetAdminSettings: function(component) {
        var self = this;
        var action = component.get("c.getAdminSettings");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            }
            component.set("v.adminSettings", response.getReturnValue());
            console.log(response.getReturnValue());
            var event = component.getEvent("waitingEvent");
            event.fire();
        });
        var event = component.getEvent("waitingEvent");
        event.fire();
        $A.enqueueAction(action);
    },
    
    OnRefreshModelMetrics: function(component) {
        component.set("v.refreshModelMetricsMessage", "Please wait. Refreshing Model Metrics..."); 
        var self = this;
        var action = component.get("c.refreshMetrics");        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            }
            var RMresult = response.getReturnValue();
            console.log('RMresult: ' + response.getReturnValue());
            if (RMresult) 
            {
                var today = new Date();
                var updateMessage = 'Refreshing Model Result: ' + response.getReturnValue() + ' - ' + today;
                component.set("v.refreshModelMetricsMessage", updateMessage);            
            }
            else { }
            var event = component.getEvent("waitingEvent");
            event.fire();
        });
        var event = component.getEvent("waitingEvent");
        event.fire();
        $A.enqueueAction(action);
    },
    
    
    doInitUsage : function(component, event, helper) {
        let action = component.get("c.getUsage");
        action.setCallback(this, function(a){
            let state = a.getState();
            if (state === "SUCCESS") {
                console.log(a.getReturnValue());
                component.set("v.usage", a.getReturnValue());
            }  else if (state === "ERROR") {
                component.find("leh").passErrors(a.getError());
            }
        });
        $A.enqueueAction(action);
    }
    
})