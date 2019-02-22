({
	helperMethod : function(component, event, helper) {
		// Figure out which buttons to display
              var availableActions = component.get('v.availableActions');
              for (var i = 0; i < availableActions.length; i++) {
                 if (availableActions[i] == "NEXT") {
                    component.set("v.canNext", true);
                 }
              }
        	var spmdLink=$A.get("$Label.c.SPMD_URL");
            spmdLink+=component.get("v.serviceTag");
            //alert("spmdLink>>>"+spmdLink);
            component.set("v.spmdLink",spmdLink);
	},
    removeA: function (arr) {
        var what, a = arguments, L = a.length, ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax= arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    },
    titleCase: function (str) {
       var splitStr = str.toLowerCase().split(' ');
       for (var i = 0; i < splitStr.length; i++) {
           // You do not need to check if i is larger than splitStr length, as your for does that for you
           // Assign it back to the array
           splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);     
       }
       // Directly return the joined string
       return splitStr.join(' '); 
    },
    handleChangeHelper : function (component, event,helper){
        var searchText = component.get("v.SearchKeyWord");
        if(searchText){
        	searchText=searchText.toLowerCase();
        }
        var commodityListCopy = component.get("v.commodityListCopy");
        var commodityList = component.get("v.commodityList");
        //var commodityListPofCopy = component.get("v.commodityListPofCopy");
        //var commodityListPof = component.get("v.commodityListPof");
        var sDarray			=	[];
        var sDarrayPof			=	[];
       /* if(!searchText){
            component.set("v.commodityList",commodityListCopy);
            //component.set("v.commodityListPof",commodityListPofCopy);
        }*/
        //else{
            for(var keyval=0;keyval<commodityList.length;){
                if(commodityList[keyval].value==true){
                    sDarray.push(commodityList[keyval]);
                }
                keyval++;
            }
            /*for(var keyval=0;keyval<commodityListPof.length;){
                if(commodityListPof[keyval].value==true){
                    sDarrayPof.push(commodityListPof[keyval]);
                }
                keyval++;
            }*/
            for(var key=0;key<commodityListCopy.length;){
                if(commodityListCopy[key].label.toLowerCase().indexOf(searchText)>=0 && !sDarray.includes(commodityListCopy[key])){
                    sDarray.push(commodityListCopy[key]);
                }
                key=key+1;
            }
            //sorting the displayed List here
            sDarray=sDarray.sort(function(a, b){
                if(a.label < b.label) return -1;
                if(a.label > b.label) return 1;
                return 0;
            });
            component.set("v.commodityList",sDarray);
            /*for(var key=0;key<commodityListPofCopy.length;){
                if(commodityListPofCopy[key].label.toLowerCase().indexOf(searchText)>=0 && !sDarrayPof.includes(commodityListPofCopy[key])){
                    sDarrayPof.push(commodityListPofCopy[key]);
                }
                key=key+1;
            }
            component.set("v.commodityListPof",sDarrayPof);*/
    	//}
        setTimeout(function() {
            var inputText = document.getElementsByClassName("commodity");
            for(var i=0;i<inputText.length;){
                var innerHTML = inputText[i].innerHTML.replace("<span><strong>","").replace("</strong></span>","");
                var index = innerHTML.toLowerCase().indexOf(searchText);
                if (index >= 0) { 
                    innerHTML = innerHTML.substring(0,index) + "<span><strong>" + innerHTML.substring(index,index+searchText.length) + "</strong></span>" + innerHTML.substring(index + searchText.length);
                }
                inputText[i].innerHTML = innerHTML;
                i=i+1;
            } 
        }, 100);
    },
    checkboxChangeHandler: function (component, event,helper) {
        var cboxRowInput =	event.getSource();
        var selectedCheckRow = cboxRowInput.get("v.value");
        var commodityRow=component.get("v.commodityList");
        var commodityRowSelected=component.get("v.selectedCommodityList");
        var indexNum = cboxRowInput.get("v.text");
        
        if(selectedCheckRow == true){
            component.set("v.searchText","");
            var commodity=commodityRow[indexNum].label;
            commodityRowSelected.push(commodity);
            commodityRowSelected=commodityRowSelected.sort();
        }
        else{
            event.getSource().set("v.disabled",false);
            var commodity=commodityRow[indexNum].label;
            helper.removeA(commodityRowSelected,commodity);
        }

        component.set("v.selectedCommodityList", commodityRowSelected);
        component.set("v.selectedCommodityArray", commodityRowSelected);
    },
    /*checkboxPofChangeHandler: function (component, event,helper) {
        var cboxRowInput =	event.getSource();
        var selectedCheckRow = cboxRowInput.get("v.value");
        //var commodityRow=component.get("v.commodityListPof");
        var commodityRowSelected=component.get("v.selectedCommodityList");
        var indexNum = cboxRowInput.get("v.text");
        console.log('checkboxChangeHandler ---> ' + selectedCheckRow);
        console.log('checkboxChangeHandler ---> ' + commodityRow[indexNum].label);
        
        if(selectedCheckRow == true){
            component.set("v.searchText","");
            var commodity=commodityRow[indexNum].label;
            commodityRowSelected.push(commodity);
        }
        else{
            var commodity=commodityRow[indexNum].label;
            helper.removeA(commodityRowSelected,commodity);
        }
        console.log('checkboxChangeHandler ---> inside ' + commodityRowSelected);
        //console.log('checkboxChangeHandler ---> inside ' + commodityRowSelected.length());
        component.set("v.selectedCommodityList", commodityRowSelected);
        component.set("v.selectedCommodityArray", commodityRowSelected);
        console.log('selectedCommodityArray ---> inside--- ' + component.get("v.selectedCommodityArray"));
    },*/
    helperHandleKeyUp : function(component, event,helper) 
    {        	
        helper.turnOnSpinner(component);
        var action = component.get("c.getCommodities");
        var recId= component.get("v.recordId");
        var commodityListCopy= component.get("v.commodityListCopy");
        if(!commodityListCopy.length){
            helper.turnOnSpinner(component);
            /*action.setParams({ workOrderIds : '0WOm00000004LizGAE',
                              serviceTag : '128K51S', 
                              addressBUID : '11'
                              });*/

            action.setParams({ recordId : recId,
                              assetId : component.get("v.assetId"), 
                              serviceTag : component.get("v.serviceTag"), 
                              addressBUID : component.get("v.addressBUID")
                              });
        
            action.setCallback(this, $A.getCallback(function (response) 
           {
                var state = response.getState();
                //var responseJSON = JSON.stringify(response);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().length && response.getReturnValue()[0].responseMessage=="success"){
                        console.log("server code invoke is success--");
                        console.log('response string--->'+JSON.stringify(response.getReturnValue()));
                        var sDarray			=	[];
                        var sDarrayPof			=	[];
                        for(var key = 0; key < response.getReturnValue().length;)
                        {
                            if(response.getReturnValue()[key].PartCommodityDef){
                                var camelCaseVal=helper.titleCase(response.getReturnValue()[key].PartCommodityDef);
                                sDarray.push({label:response.getReturnValue()[key].PartCommodityDef, value:response.getReturnValue()[key].isSelected, camelLabel: camelCaseVal});
                            }
                            /*else if(response.getReturnValue()[key].PartCommodityPof){
                                sDarrayPof.push({label:response.getReturnValue()[key].PartCommodityPof, value:response.getReturnValue()[key].isSelected});
                            }*/
                            key = key+1;                        
                        }
                        //sorting the displayed List here
                        sDarray=sDarray.sort(function(a, b){
                            if(a.label < b.label) return -1;
                            if(a.label > b.label) return 1;
                            return 0;
                        });
                        component.set("v.commodityList",sDarray);
                        component.set("v.commodityListCopy",sDarray);
                        //component.set("v.commodityListPof",sDarrayPof);
                        //component.set("v.commodityListPofCopy",sDarrayPof);
                        component.set("v.loadSection",true);
                    }
                    else{
           				helper.showToast("",'ERROR', response.getReturnValue()[0].responseMessage, "Error"); 
                    }
                    helper.turnOffSpinner(component);
                    //var cmpTarget1 = cmp.find('searchButton');
                    //var cmpTarget2 = cmp.find('clearButton');
                    //$A.util.removeClass(cmpTarget1, 'slds-hide');
                    //$A.util.removeClass(cmpTarget2, 'slds-hide');                    
                    //cmp.set("v.DefSubCmp", DSC);
                    //console.log();
                } 
            }));
            $A.enqueueAction(action);
        }
        else{
            helper.turnOffSpinner(component);
            component.set("v.loadSection",true);
        }
	},
    helperSearchOnClick: function (component, event,helper) {
        component.set("v.selectedCommodityList",[]);
        component.set("v.selectedCommodityArray",[]);
        var commodityList=component.get("v.commodityList");
        //var commodityListPof=component.get("v.commodityListPof");
        if(commodityList.length){
            for(var key = 0; key < commodityList.length;){
                console.log('commodityList[key].label>>>'+commodityList[key].label);
                commodityList[key].value=false;
                key++;
            }
        }
        component.set("v.commodityList",commodityList);
    },
    
    // turn off Spinner  
    turnOffSpinner: function (component) {
        try{
            console.log('Inside the turn off spinner');
            var spinner = component.find("mySpinner");
        	$A.util.toggleClass(spinner, "slds-hide");
            $A.util.removeClass(spinner, 'slds-show');
            $A.util.addClass(spinner,'slds-hide');
        }catch(Err){
            console.log("Error While Turning on the Spinner ==>  "+Err);
        }
    },
    
    // turn on spinner
    turnOnSpinner: function (component) {
        try{
            console.log('Inside the turner on');
    		var spinner = component.find("mySpinner");
    		$A.util.toggleClass(spinner, "slds-hide");
            $A.util.removeClass(spinner, "slds-hide");
            $A.util.addClass(spinner,"slds-show");
        }catch(Err){
            console.log("Error While Turning off the Spinner ==>  "+Err);
        }
	},
    /*handleClearHelper : function (component, event, helper){
        try{
            //helper.turnOnSpinner(component);
            component.set("v.loadSection", false);
            var flow = component.find("flowData");
            var recordId = component.get("v.recordId");
            var addressBUID = component.get("v.addressBUID");
            var serviceTag = component.get("v.serviceTag");
            var inputVariables = [
                {
                    name : 'WorkOrderRecordId',
                    type : 'String',
                    value : recordId
                },
                {
                    name : 'addressBUID',
                    type : 'String',
                    value :  addressBUID           
                },
                {
                    name : 'serviceTag',
                    type : 'String',
                    value :  serviceTag           
                }
            ];
            //flow.startFlow("Work_Order_Manual_Part_Selection", inputVariables);
        } catch(Err){
            console.log("Error Message controller 1 "+Err);
           	helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageCancellingParts"), "Error");            
        }
    },*/
    handleClearHelper : function (component, event, helper){
        component.set("v.loadSection", false);
        component.set("v.renderComponent", false);
        component.set("v.selectedCommodityList", []);
        var toggleText = component.find("text");
        //$A.util.toggleClass(toggleText, "toggle");
        //$A.util.addClass(toggleText,"displayNone");
        //slds-hidden
        var flow = component.find("flowData");
        var workOrderId = component.get("v.recordId");
        var inputVariables = [
            {
                name : 'recordId',
                type : 'String',
                value : workOrderId
                //value : component.get("v.recordId")
            }
        ];
        flow.startFlow("Dispatch_APS", inputVariables);
    },
    showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message, 
            "type": type,
            //"mode": "sticky",
            "mode": "pester",
            "duration": "3000"
        });
        toastEvent.fire();
    },
})