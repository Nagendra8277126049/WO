({
    openWindow : function(component) {
		$A.createComponent(
            "c:SearchAsset",
            {
                "newAsset": component.get("v.newAsset"),
                "recordId": component.get("v.recordId"),
                "searchAssetErrorMessage": component.get("v.SearchAssetErrorMessage"),
                "accountNAErrorMessage": component.get("v.AccountNAErrorMessage"),
                "producttNAErrorMessage": component.get("v.ProducttNAErrorMessage"),
                "successMessage": component.get("v.SuccessMessage"),
                "searchButtonName": component.get("v.SearchButtonName"),
                "replaceButtonName": component.get("v.ReplaceButton")
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
	},
     FetchAsset : function(component, recID) { 
       try{                
        //Calling the Apex Function
        var action = component.get("c.populateAssetNumber");
        
        //Setting the Apex Parameter
        action.setParams({
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
                //setting the Values in the form
                if (newAst!=null && newAst!=undefined && newAst!='Populated'){
                	component.set("v.newAsset",newAst);
                }
                if (newAst==='Populated'){
                    component.set("v.newAsset",'');
                }
                this.openWindow(component, event);
                } 
           else if(state === "ERROR"){
                var errMessage = component.get("v.searchAssetErrorMessage");
			    this.showToast(component,'Error', errMessage, "Error");
            }
            else if(state === "INCOMPLETE"){
                var errMessage = component.get("v.searchAssetErrorMessage");
			    this.showToast(component,'Error', errMessage, "Error");
            }
            this.hideSpinner(component, event);
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