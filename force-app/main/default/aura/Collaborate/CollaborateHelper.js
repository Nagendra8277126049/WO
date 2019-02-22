({
    fetchqueue: function(component){
        try{
            //call to server side controller
            var action = component.get("c.getOptions");
            
            action.setCallback(this, function(res) {
                var state = res.getState();
                console.log(res.getReturnValue());
                if(state == 'SUCCESS') {
                    component.set("v.optionList", res.getReturnValue());
                }  
            })
            $A.enqueueAction(action);
        }catch(err){
            console.log(err);
        }
        
    },
    
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        try{
            // call the server side function  
            var action = component.get("c.getDependentMap");
            // pass paramerters [object definition , contrller field name ,dependent field name] -
            // to server side function 
            action.setParams({
                'objDetail' : objDetails,
                'contrfieldApiName': controllerField,
                'depfieldApiName': dependentField 
            });
            //set callback   
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var StoreResponse = response.getReturnValue();
                    
                    // once set #StoreResponse to depnedentFieldMap attribute 
                    component.set("v.depnedentFieldMap",StoreResponse);
                    
                    // create a empty array for store map keys(@@--->which is controller picklist values) 
                    var listOfkeys = []; // for store all map keys (controller picklist values)
                    var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                    
                    // play a for loop on Return map 
                    // and fill the all map key on listOfkeys variable.
                    for (var singlekey in StoreResponse) {
                        listOfkeys.push(singlekey);
                    }
                    
                    //set the controller field value for lightning:select
                   // if (listOfkeys != undefined && listOfkeys.length > 0) {
                      //  ControllerField.push('--- None ---');
                  //  }
                    
                    for (var i = 0; i < listOfkeys.length; i++) {
                        ControllerField.push(listOfkeys[i]);
                    }  
                    // set the ControllerField variable values to Support Team (controller picklist field)
                    component.set("v.listControllingValues", ControllerField);
                }else{
                    alert('Something went wrong..');
                }
            });
            
            
            $A.enqueueAction(action);
        }catch(err){
            console.log(err);
        }
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        
        // create a empty array var for storing dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },
    
    saveDefault: function (component,valueSelect) {
        try{
            var action = component.get("c.saveSelectedValuee");
            action.setParams({
                'val' : valueSelect
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") { console.log('called') } });
            $A.enqueueAction(action);
        }catch(err){
            console.log(err);
        }
    },
     showToast: function(component, title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message, 
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
    }
    
    
    
})