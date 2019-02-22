({
    closeMe : function(comp, event, helper)  { 
        comp.destroy();
    },
    updateCase : function(component, recID, assetRecord) { 
        try{                
            //Calling the Apex Function
            var action = component.get("c.updateAssetinCase");
            
            //Setting the Apex Parameter
            action.setParams({
                ast : assetRecord,
                caseId : recID
            });
            
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                
                //check if result is successfull
                if(state === "SUCCESS"){
                    //Reset Form
                    var newAst = a.getReturnValue();
                    //resetting the Values in the form
                    component.set("v.newAsset",newAst);
                    this.callBIL(component, recID);               
                } 
                else if(state === "ERROR"){
                    var errMessage = component.get("v.searchAssetErrorMessage");
                    this.showToast(component,'Error',errMessage, "Error");
                }
                
            });
            //adds the server-side action to the queue        
            $A.enqueueAction(action); 
        }catch(Err){
            var errMessage = component.get("v.searchAssetErrorMessage");
            this.showToast(component,'Error',errMessage, "Error");
        }
    },
    showToast : function(component, title, message, type) {
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message, 
                "type": type,
                "mode": "pester",
                "duration": "3000"
            });
            toastEvent.fire();
        }catch(Err){
            console.log(Err);
        }
    },
    callBIL : function(component, recID) { 
        try{                
            //Calling the Apex Function
            var action = component.get("c.associateServiceTag");
            
            //Setting the Apex Parameter
            action.setParams({
                recordId : recID
            });
            
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                
                //check if result is successfull
                if(state === "SUCCESS"){
                    //Reset Form
                    var newAst = a.getReturnValue();
                    //Toast message to the user                
                    if (newAst!=null && newAst!=undefined && newAst != "AccountNA" && newAst != "ProductNA"){
                        var successMessage = component.get("v.successMessage");
                        this.showToast(component,'Success', successMessage,"Success");
                    } else if(newAst === "AccountNA"){
                        var errMessage = component.get("v.accountNAErrorMessage");
                        this.showToast(component,'Error', errMessage, "Error");
                    }else if(newAst === "ProductNA"){
                        var errMessage = component.get("v.producttNAErrorMessage");
                        this.showToast(component,'Error', errMessage, "Error");
                    }
                        else{
                            var errMessage = component.get("v.searchAssetErrorMessage");
                            this.showToast(component,'Error', errMessage, "Error");
                        }
                } 
                else if(state === "ERROR"){
                    var errMessage = component.get("v.searchAssetErrorMessage");
                    this.showToast(component,'Error', errMessage, "Error");
                }
                    else if(state === "INCOMPLETE"){
                        var errMessage = component.get("v.searchAssetErrorMessage");
                        this.showToast(component,'Error', errMessage, "Error");
                    }
                this.closeMe(component, event, this);
                $A.get("e.force:refreshView").fire();
            });
            //adds the server-side action to the queue        
            $A.enqueueAction(action);        
        }catch(Err){
            var errMessage = component.get("v.searchAssetErrorMessage");
            this.showToast(component,'Error', errMessage, "Error");
            this.hideSpinner(component, event);
        }
    },
    showSpinner : function(component,event,helper){
        component.set("v.toggleSpinner", true);  
      },
    hideSpinner : function(component,event,helper){
        component.set("v.toggleSpinner", false);
        
    }
})