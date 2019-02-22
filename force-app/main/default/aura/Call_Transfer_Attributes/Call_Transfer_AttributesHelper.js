({
    handleCloseTab : function(component, event){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
      },
    
    showTransferType : function(component, event){
        var transferType = component.find("transferType").get("v.value");
        component.set("v.transferType", transferType);
    },
    
    callBRE : function(component, event){
        var request = component.get("c.CallBRE_API");
        request.setParams({
            RecordId: component.get("v.ctrRecId")
        })
        request.setCallback(this, function(response){
            var state = response.getState();
            console.log("State >>>> "+state);
            var destVDN = response.getReturnValue();
            console.log("Destination VDN >>>> "+destVDN);
            if (state == "SUCCESS" && destVDN != undefined){
                this.proxyClickToDial(destVDN);
                this.callContextStoreUpdate(component, event);
                //Finally close the tab
       	        this.handleCloseTab(component, event);
            }
            else
                console.log("Something went wrong");
        });
        $A.enqueueAction(request);
        //this.proxyClickToDial("3445520");
        console.log('Record updated succesfully');
    },
    
    proxyClickToDial: function(destVDN)          
    {
        //Any logic to retrieve the phone number can be done here.
        var click2dialParams = {
            Number: destVDN,
            TransferType: "consult"
        };
        //TransferType can be either "blind" or "consult"
        click2dialParams.timestamp = new Date();
        
        //Final message should be structured as {"Number":"6135919002", "TransferType": "blind", "timestamp":"2018-07-04T17:12:48.323Z"}
        var message = JSON.stringify(click2dialParams);
        try
        {
            //We send a post message through both of the iFrames for both servers.
            document.getElementById("ICEA").contentWindow.postMessage(message, "*");
            console.log(message);
        }
        catch (e) { 
            console.log("Inside ProxyClickToDial catch");
        }
    },
    callContextStoreUpdate : function(component, event){
        var request = component.get("c.UpdateTransferCount");
        request.setParams({
            ctaId: component.get("v.ctrRecId")
        })
        $A.enqueueAction(request);        
    }
})