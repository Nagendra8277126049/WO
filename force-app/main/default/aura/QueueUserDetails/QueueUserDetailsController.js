({
    doinit: function(component, event, helper) {
        try {
            var QueueId = component.get("v.QueueId");
            document.body.setAttribute('style', 'overflow: hidden;');
            helper.initializeHelper(component, event,QueueId); 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    OpenUserModel: function(component, event, helper) {
        try {
            var QueueId = component.get("v.QueueId");
            helper.OpenModalHelper(component, event,QueueId);  
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    confirmremove: function(component, event) {
        try {
            component.set("v.isConf", true); 
            component.set("v.isMulti", true);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    closeModal: function(component, event, helper) {
        try {
            var QueueId = component.get("v.LstOfQueue");
            helper.CloseModalHelper(component, event,QueueId); 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    adduser: function(component, event, helper) {
        try {
            var selectedusers = component.get("v.selectedLookUpRecords");
            document.body.setAttribute('style', 'overflow: hidden;');
            var QueueId = component.get("v.QueueId");
            if(selectedusers == null || selectedusers == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Please select a user."
                });
                toastEvent.fire();
            }else{
                helper.adduserHelper(component,event,selectedusers,QueueId);  
            } 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    SearchUser: function(component, event, helper) {
        try {
            var QueueId = component.get("v.QueueId");
            var getInputkeyWord = component.get("v.SearchUserKeyword");
            if(getInputkeyWord.length > 0){
                var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                helper.SearchUserHelper(component,event,QueueId);
            }
            else{  
                component.set("v.SearchQueueUserResult", null ); 
                component.set("v.Message", false);
                var forclose = component.find("searchRes");
                component.set("v.ShowSearchUserTable", false);
                component.set("v.ShowUserTable", true);
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            }
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    deleteSelected: function(component, event, helper) {
        try {
            var QueueId = component.get("v.QueueId");
            var delId = [];
            var getAllId = component.find("boxPack");
            if(! Array.isArray(getAllId)){
                if (getAllId.get("v.value") == true) {
                    delId.push(getAllId.get("v.text"));
                }
            }else{
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        delId.push(getAllId[i].get("v.text"));
                    }
                }
            }
            helper.deleteSelectedHelper(component, event, delId,QueueId);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    openuserqueue: function(component, event, helper) {
        try {
            helper.openuserqueuehelper(component, event);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    checkboxSelect : function(component, event, helper) {
        try {
            var selectedRec = event.getSource().get("v.value");
            var getSelectedNumber = component.get("v.selectedCount");
            if (selectedRec == true) {
                component.set("v.showMe",true);
                getSelectedNumber++;
            } else {
                getSelectedNumber--;
            }
            if (getSelectedNumber == '0'){
                component.set("v.showMe",false);
            }
            component.set("v.selectedCount", getSelectedNumber);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    selectAll: function(component, event, helper) {
        try {
            var selectedHeaderCheck = event.getSource().get("v.value");
            var getAllId = component.find("boxPack");
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
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    handleMenuSelect : function(component, event, helper) {
        try {
            var RecId = event.getParam("value");
            component.set("v.RecId", RecId);
            component.set("v.isConf", true); 
            component.set("v.isSingle", true);
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    removesinglerec : function(component,event,helper){
        try {
            var QueueId = component.get("v.QueueId");
            var delId = component.get("v.RecId");
            helper.deleteSelectedHelper(component, event, delId,QueueId); 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    getSelectid : function(component, event, helper) {
        try{
            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
            console.log('Event Result'+selectedAccountGetFromEvent)
            component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        }catch(err){
            console.log(err);
        }    
    },
})