({
	doinit: function(component, event, helper) {
        var UserId = component.get("v.UserId");
       helper.initializeHelper(component, event,UserId);  
    },
    SearchQueue: function(component, event, helper) {
        var UserId = component.get("v.UserId");
        var getInputkeyWord = component.get("v.SearchQueueKeyword");
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.SearchQueueHelper(component,event,UserId);
        }
        else{  
            component.set("v.SearchQueueResult", null ); 
            component.set("v.Message", false);
            var forclose = component.find("searchRes");
            component.set("v.ShowSearchQueueTable", false);
            component.set("v.ShowQueueTable", true);
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    OpenUserModal: function(component, event) {
            component.set("v.isUOpen", true); 
        },
    checkboxSelect : function(component, event, helper) {
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.value");
        // get the selectedCount attrbute value(default is 0) for add/less numbers. 
        var getSelectedNumber = component.get("v.selectedCount");
        // check, if selected checkbox value is true then increment getSelectedNumber with 1 
        // else Decrement the getSelectedNumber with 1     
        if (selectedRec == true) {
            component.set("v.showMe",true);
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        if (getSelectedNumber == '0'){
            component.set("v.showMe",false);
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.selectedCount", getSelectedNumber);
    },
    selectAll: function(component, event, helper) {
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array   
        if (!Array.isArray(getAllId)) {
            if (selectedHeaderCheck == true) {
                component.set("v.showMe",true);
                component.find("boxPack").set("v.value", true);
                component.set("v.selectedCount", 1);
            } else {
                component.set("v.showMe",false);
                component.find("boxPack").set("v.value", false);
                component.set("v.selectedCount", 0);
            }
        } else {
            // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
            // and set the all selected checkbox length in selectedCount attribute.
            // if value is false then make all checkboxes false in else part with play for loop 
            // and select count as 0 
            if (selectedHeaderCheck == true) {
                component.set("v.showMe",true);
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", true);
                    component.set("v.selectedCount", getAllId.length);
                }
            } else {
                component.set("v.showMe",false);
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", false);
                    component.set("v.selectedCount", 0);
                }
            }
        }
    },
        handleMenuSelect : function(component, event, helper) {
        var RecId = event.getParam("value");
        component.set("v.RecId", RecId);
        component.set("v.isConf", true); 
        component.set("v.isSingle", true);
        },
    removesinglerec: function(component, event, helper) {
        var delId = component.get("v.RecId");
        var UserId = component.get("v.UserId");
        helper.deleteSelectedHelper(component, event, delId,UserId); 
    },
    confirmremove: function(component, event) {
        component.set("v.isConf", true); 
        component.set("v.isMulti", true);
    },
    //For Delete selected records 
    deleteSelected: function(component, event, helper) {
        var UserId = component.get("v.UserId");
        // create var to store record id's for selected checkboxes  
        var delId = [];
       	// get all checkboxes 
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                delId.push(getAllId.get("v.text"));
            }
        }else{
            // play a for loop and check every checkbox values 
            // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    delId.push(getAllId[i].get("v.text"));
                }
            }
        } 
        // call the helper function and pass all selected record id's.    
        helper.deleteSelectedHelper(component, event, delId,UserId);  
    },
    SearchQueueUser: function(component, event, helper) {
        helper.openWindow(component, event);
    },
    OpenQueueModel : function(component, event, helper) {
           var UserId = component.get("v.UserId");
        helper.OpenQueueModelHelper(component, event,UserId); 
    },
    closeModal: function(component, event, helper) {
        helper.CloseModalHelper(component, event);  
    },
    CloneUser: function(component, event, helper) {
            component.set("v.isUOpen", false);
            //document.body.setAttribute('style', 'overflow: hidden;');
            var selectedusers = component.get("v.selectedUserRecords");
            var CloneId = component.get("v.UserId");
            console.log('SelectedUsers'+selectedusers);
            if(selectedusers == null || selectedusers == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Please select a user."
                });
                toastEvent.fire();
            }else{
                helper.CloneUserhelper(component,event,selectedusers,CloneId);  
            }  
        },
    getSelectid: function(component, event, helper) {
        try{
            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
            component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        }catch(err){
            console.log(err);
        }
    },
    AddQueue: function(component, event, helper) {
        var selectedqueue = component.get("v.selectedLookUpRecords");
        var UserId = component.get("v.UserId");
        
        if(selectedqueue == null || selectedqueue == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Please select a queue."
            });
            toastEvent.fire();
        }else{
    		helper.AddQueuehelper(component, event, selectedqueue,UserId)
        }  
    },
})