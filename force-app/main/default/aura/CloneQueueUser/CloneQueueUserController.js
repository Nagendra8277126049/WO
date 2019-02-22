({
        douserinit: function(component, event, helper) {
            try {
            document.body.setAttribute('style', 'overflow: hidden;');
            var UserId = component.get("v.UserId");
           helper.UserDetailHelper(component, event,UserId); 
            }
            catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
        },
        doinit: function(component, event, helper) {
            try {
            document.body.setAttribute('style', 'overflow: hidden;');
            var UserId = component.get("v.UserId");
            
           helper.initializeHelper(component, event,UserId);
            }
            catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
        },
        OpenUserModal: function(component, event, helper) {
            try {
            component.set("v.isOpen", true); 
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
        OpenQueueModal : function(component, event) {
            try {
            component.set("v.isQOpen", true); 
            }
            catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
        },
        OpenAssignedQueues: function(component, event, helper){
            try {
            var UserId = component.get("v.UserId");
            helper.OpenAssignedQueuesHelper(component,event);  
            }
            catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
        },
        CloneUser: function(component, event, helper) {
            try {
            component.set("v.isOpen", false);
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
            }
            catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
        },
        getSelectid : function(component, event, helper) {
            try{
                var selectedUserFromEvent = event.getParam("recordByEvent");
                console.log('Event Result'+selectedUserFromEvent)
                component.set("v.selectedRecord" , selectedUserFromEvent); 
            }catch(err){
                console.log(err);
            }    
        },
    	AddQueue: function(component, event, helper) {
            try {
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
            }
            catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    SearchQueueUser: function(component, event, helper) {
        try {
        helper.openWindow(component, event);
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
    removesinglerec: function(component, event, helper) {
        try {
        var delId = component.get("v.RecId");
        var UserId = component.get("v.UserId");
        helper.deleteSelectedHelper(component, event, delId,UserId); 
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
        deleteSelected: function(component, event, helper) {
        try {
        var UserId = component.get("v.UserId");
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
       helper.deleteSelectedHelper(component, event, delId,UserId); 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    })