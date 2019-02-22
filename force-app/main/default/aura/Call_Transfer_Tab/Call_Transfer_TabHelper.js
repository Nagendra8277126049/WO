({
	    getCallTransAttrRecId : function(component, event){
            var sPageURL = decodeURIComponent(window.location.search.substring(1));
            var sParam = sPageURL.split("=");
            var sCallTranscriptId = sParam[1];
            if(sCallTranscriptId.includes("&"))
            {
                var sParam1 = sCallTranscriptId.split("&");  
				sCallTranscriptId = sParam1[0];
            }
            console.log("Call Transcript Record Id passed from URL <====> "+sCallTranscriptId);
            var action = component.get("c.getCallTransferAttrId");
            action.setParams({
                CallTranscriptId : sCallTranscriptId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log("State >>>> "+state);
                var sRecId = response.getReturnValue();
                console.log("Apex Returned Record Id >>>> "+sRecId);
                if (state == "SUCCESS" && sRecId != undefined && sRecId != ''){
                    component.set("v.ctrRecId", sRecId);
                    this.createComponent(component, event);
                }
                else if(state == "SUCCESS" && sRecId == ''){
                    this.createLoadComponent(component, event);
                }
                else
                    console.log("Something went wrong");
            });
            $A.enqueueAction(action);
    },
    createComponent : function(component, event) {
        var sRecId = component.get("v.ctrRecId");
        console.log("Calling component passing Rec Id as>>>>"+sRecId);
        $A.createComponent(
            "c:Call_Transfer_Attributes", {
                "ctrRecId": sRecId
            },
            function(newcomponent) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);
                }
            }
        );
    },
    createLoadComponent : function(component, event) {
        $A.createComponent(
            "c:CallTransferLoadMessage", {
                
            },            
            function(newcomponent) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);
                }
            }
        );
    },
    setTabIconAndTitle : function(component, event){
        var tabCheck = window.location.href;
        if (tabCheck.indexOf("Call_Transfer_Tab") > -1){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Call Transfer"
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "utility:outbound_call",
                    iconAlt: "Call Transfer"                
                });
                workspaceAPI.disableTabClose({
                    tabId: focusedTabId,
                    disabled: false,
                    closeable:true
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
    },
})