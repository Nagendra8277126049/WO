({
    onblur : function(component,event,helper){
        try {
            component.set("v.listOfSearchRecords", null );
            component.set("v.SearchKeyWord", '');
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    onfocus : function(component,event,helper){
        try {
            $A.util.addClass(component.find("mySpinner"), "slds-show");
            component.set("v.listOfSearchRecords", null ); 
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var getInputkeyWord = '';
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }  
    },
    keyPressController : function(component, event, helper) {
        try {
            $A.util.addClass(component.find("mySpinner"), "slds-show");
            var getInputkeyWord = component.get("v.SearchKeyWord");
            var lstofgm  = component.get("v.lstofgroupmember");
            var CloneId = component.get("v.CloneId");
            console.log('Clone'+CloneId);
            if(getInputkeyWord.length > 0){
                var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                helper.searchHelper(component,event,getInputkeyWord,lstofgm);
            }
            else{  
                component.set("v.listOfSearchRecords", null ); 
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            }
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
    clear :function(component,event,heplper){
        try {
            var selectedPillId = event.getSource().get("v.name");
            var AllPillsList = component.get("v.lstSelectedRecords");
            for(var i = 0; i < AllPillsList.length; i++){
                if(AllPillsList[i].Id == selectedPillId){
                    AllPillsList.splice(i, 1);
                    component.set("v.lstSelectedRecords", AllPillsList);
                }
            }
            component.set("v.SearchKeyWord",null);
            component.set("v.listOfSearchRecords", null ); 
            if(AllPillsList.length < 15){
                component.set("v.isSelc",true);
            } 
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        }
    },
    handleComponentEvent : function(component, event, helper) {
        try {
            component.set("v.SearchKeyWord",null);
            var listSelectedItems =  component.get("v.lstSelectedRecords");
            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
            listSelectedItems.push(selectedAccountGetFromEvent);
            var maxselcted = listSelectedItems.length;
            component.set("v.TotalNumberOfRecord",maxselcted);        
            component.set("v.lstSelectedRecords" , listSelectedItems);
            if(maxselcted < 15){
                component.set("v.isSelc",true);   
                component.set("v.lstSelectedRecords" , listSelectedItems); 
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "warning",
                    "message": "You have selected 15 records. Cannot add more than 15 records at one time."
                });
                toastEvent.fire();
                component.set("v.isSelc",false); 
            } 
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        catch(Err){
            helper.showToast(component, 'Error',"Error Occured While Loading Component", "Error");
        } 
    },
})