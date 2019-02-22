({
	showMessage: function(component, event, helper) {
        var eventParams = event.getParams();
        var ivrInput = "";
        var errorMsgTitle = "";
        if(eventParams.changeType === "LOADED") {
             console.log("Record is loaded successfully.");
            var sParameterName="";
        	var getUrlParameter = function getUrlParameter(sParam) {
                var sPageURL = decodeURIComponent(window.location.search.substring(1)), 
                    sURLVariables = sPageURL.split('&'),
                    i;
                for(i=0; i<sURLVariables.length; i++){
                    sParameterName = sURLVariables[i].split('=');//{recordType,asset},{input,2323}
                    if(sParameterName[0] ==  sParam){
                        return sParameterName[1] == undefined ? true : sParameterName[1];
                    }
                }
       		};
            component.set('v.IVR_Input', getUrlParameter('input'));
            
            if(getUrlParameter('recordType') == 'asset'){
                var assetId = component.get("v.callTransRec.Asset__c");
                if(assetId == null && !(component.get("v.callTransRec.Type__c") == "Internal Inbound" || component.get("v.callTransRec.Type__c") == "Internal Outbound"))
                {
                   
                    component.set('v.toastTitle', $A.get("$Label.c.VoiceNoMatchESC"));
                    component.set('v.toastMsg', $A.get("$Label.c.VoiceNoMatchError"));
                    helper.showToast(component);
                
         	 	}
  			}
            if(getUrlParameter('recordType') == 'case'){
                var caseId = component.get("v.callTransRec.Case__c");
                if(caseId == null && !(component.get("v.callTransRec.Type__c") == "Internal Inbound" || component.get("v.callTransRec.Type__c") == "Internal Outbound"))
                {
                   
                    component.set('v.toastTitle', $A.get("$Label.c.VoiceNoMatchSR"));
                     component.set('v.toastMsg', $A.get("$Label.c.VoiceNoMatchError"));
                     helper.showToast(component);
            	}
    		}
            if(getUrlParameter('recordType') == 'contact'){
                var contactId = component.get("v.callTransRec.Contact__c");
                if(contactId == null && !(component.get("v.callTransRec.Type__c") == "Internal Inbound" || component.get("v.callTransRec.Type__c") == "Internal Outbound"))
                {
                 component.set('v.toastTitle', $A.get("$Label.c.VoiceNoMatchContact"));
                 component.set('v.toastMsg',' ');
                 helper.showToast(component);
        		}
			}
          helper.DisableTabClose(component, event, helper);
        }
        else if(eventParams.changeType === "CHANGED")
        {
            console.log('Record Updated');
            var changedFields = JSON.stringify(event.getParams().changedFields);
            if(changedFields.indexOf("Case") > -1){
                console.log('Case Field Updated');
                helper.DisableTabClose(component, event, helper);
            }           	 
            if(changedFields.indexOf("Asset") > -1){
                console.log('Asset Field Updated');
                helper.handleCTAttrUpdate(component, event, helper);    
            }  
            if(changedFields.indexOf("Summary__c") > -1){
                console.log('Status Field Updated');
                 $A.get('e.force:refreshView').fire();

            }  
        }
    }
})