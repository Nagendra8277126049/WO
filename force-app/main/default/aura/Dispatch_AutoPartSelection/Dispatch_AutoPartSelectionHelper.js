({
    // cOMMENTED  BY Harsha - DEFECT 5446043
    /*
    doInitHelper : function(component, event,helper){
    	
        try{
            var spmdLink=$A.get("$Label.c.SPMD_URL");
            spmdLink+=component.get("v.serviceTag");
            //alert("spmdLink>>>"+spmdLink);
            component.set("v.spmdLink",spmdLink);
            helper.getserviceType(component, event,helper);
        }catch(Err){
            console.log("Error While setting value to SPMDLink ==>  "+Err);
        }
	},
    getserviceType: function(component, event,helper) {
        var action = component.get("c.getserviceType");
        var recId=component.get("v.workOrderId");
        action.setParams({ workOrderId : recId});
        action.setCallback(this, $A.getCallback(function (response) {
            helper.turnOffSpinner(component);
            var state = response.getState();
            //var responseJSON = JSON.stringify(response);
            if (state === "SUCCESS") {
                if(response.getReturnValue() && (response.getReturnValue().toUpperCase().includes("PART") || response.getReturnValue().toUpperCase().includes("MAIL"))){
                    component.set("v.enablePartSearch",true);
                }
                else{
                    component.set("v.enablePartSearch",false);
                }
            }
        }));
        $A.enqueueAction(action);
    },
    */
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
    // turn off Spinner  
    turnOffSpinner: function (component) {
        try{
            var spinner = component.find("mySpinnerAps");
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
            //console.log('Inside AutoPart turnOnSpinner');
    		var spinner = component.find("mySpinnerAps");
    		$A.util.toggleClass(spinner, "slds-hide");
            $A.util.removeClass(spinner, "slds-hide");
            $A.util.addClass(spinner,"slds-show");
        }catch(Err){
            console.log("Error While Turning off the Spinner ==>  "+Err);
        }
	},
	handleOnClickHelper : function(cmp, evt,helper) {
        try{
            helper.turnOnSpinner(cmp);
            var DefCmp = cmp.get("v.DefCmp");
            if(DefCmp.length === 0)
            {
                var action = cmp.get("c.insertAndReturnWorkOrderLI");
                var recId=cmp.get("v.workOrderId");
                //alert(recId);
                action.setParams({ workOrderIds : recId,
                                  serviceTag :cmp.get("v.serviceTag"), 
                                  addressBUID : cmp.get("v.addressBUID")
                                  });
                action.setCallback(this, $A.getCallback(function (response) {
                    var state = response.getState();
                    //var responseJSON = JSON.stringify(response);
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().length && response.getReturnValue()[0].responseMessage==="success"){
                            var sDarray			=	[];
                            //var sDarrayPof			=	[];
                            for(var key = 0; key < response.getReturnValue().length;)
                            {
                                if(response.getReturnValue()[key].PartCommodityDef){
                                	sDarray.push({label:response.getReturnValue()[key].PartCommodityDef, value:response.getReturnValue()[key].isSelected});
                                }
                                /*else if(response.getReturnValue()[key].PartCommodityPof){
                                    sDarrayPof.push({label:response.getReturnValue()[key].PartCommodityPof, value:response.getReturnValue()[key].isSelected});
                                }*/
                                key = key+1;                        
                            }
                            sDarray=sDarray.sort(function(a, b){
                                if(a.label < b.label) return -1;
                                if(a.label > b.label) return 1;
                                return 0;
                            });
                            //var cmpTarget = cmp.find('c-container');
                            //$A.util.removeClass(cmpTarget, 'c-container_hide');
                            //$A.util.addClass(cmpTarget, 'c-container_show');
                            cmp.set("v.DefCmp",sDarray);
                            cmp.set("v.DefCmpCopy",sDarray);
                            //cmp.set("v.PofCmp",sDarrayPof);
                            //cmp.set("v.PofCmpCopy",sDarrayPof);
                            //var cmpTarget1 = cmp.find('searchButton');
                            //var cmpTarget2 = cmp.find('clearButton');
                            //$A.util.removeClass(cmpTarget1, 'slds-hide');
                            //$A.util.removeClass(cmpTarget2, 'slds-hide');
                            helper.turnOffSpinner(cmp);
                            //cmp.set("v.DefSubCmp", DSC);
                        }
                        else{
                            helper.turnOffSpinner(cmp);
                            cmp.set("v.displayAdvancedSearch",true);
                            
                            helper.showToast("",'ERROR',response.getReturnValue()[0].responseMessage , "Error");
                        }
                    } 
                    else{
                        helper.turnOffSpinner(cmp);
                        cmp.set("v.displayAdvancedSearch",true);
            			
           				helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForCommodities"), "Error");            
                    }
                }));
                $A.enqueueAction(action);
            }
            else
            {
                helper.turnOffSpinner(cmp);
                var cmpTarget = cmp.find('c-container');
                $A.util.removeClass(cmpTarget, 'c-container_hide');
                $A.util.addClass(cmpTarget, 'c-container_show');   
            }
        }catch(Err){
            //helper.turnOffSpinner(component);
          	helper.turnOffSpinner(cmp);
           	helper.showToast("",'ERROR',$A.get("$Label.c.Dispatch_ErrorMessageForCommodities"), "Error");            
        }
	},
    handleAdvanceSearchHelper : function (component, event, helper){
        component.set("v.renderComponent", false);
        component.set("v.renderSearchBox", false);
        component.set("v.displayLaborSearch", false);
        component.set("v.SelectedDC",[]);
        //var toggleText = component.find("text");
        //$A.util.toggleClass(toggleText, "toggle");
        //$A.util.addClass(toggleText,"displayNone");
        //slds-hidden
        var flow = component.find("flowOnClick");
        var workOrderId = component.get("v.workOrderId");
        //var serviceTag = component.get("v.serviceTag");
        var inputVariables = [
            {
                name : 'WorkOrderRecordId',
                type : 'String',
                value : workOrderId
                //value : component.get("v.recordId")
            }
        ];
        flow.startFlow("Work_Order_Manual_Part_Selection", inputVariables);
    },
    handleChangeHelper : function (component, event,helper){
        var searchText = component.get("v.searchText");
        if(searchText){
       		searchText=searchText.toLowerCase();
        }
        var DefCmpCopy = component.get("v.DefCmpCopy");
        var DefCmp = component.get("v.DefCmp");
        //var PofCmpCopy = component.get("v.PofCmpCopy");
        //var PofCmp = component.get("v.PofCmp");
        var sDarray			=	[];
        //var sDarrayPof			=	[];
        if(!searchText){
            component.set("v.DefCmp",DefCmpCopy);
            //component.set("v.PofCmp",PofCmpCopy);
        }
        else{
            for(var keyval=0;keyval<DefCmp.length;){
                if(DefCmp[keyval].value==true){
                    sDarray.push(DefCmp[keyval]);
                }
                keyval++;
            }
            /*for(var keyval=0;keyval<PofCmp.length;){
                if(PofCmp[keyval].value==true){
                    sDarrayPof.push(PofCmp[keyval]);
                }
                keyval++;
            }
            for(var key=0;key<PofCmpCopy.length;){
                if(PofCmpCopy[key].label.toLowerCase().indexOf(searchText)>=0 && !sDarrayPof.includes(PofCmpCopy[key])){
                    sDarrayPof.push(PofCmpCopy[key]);
                }
                key=key+1;
            }
            component.set("v.PofCmp",sDarrayPof);*/
            for(var key=0;key<DefCmpCopy.length;){
                if(DefCmpCopy[key].label.toLowerCase().indexOf(searchText)>=0 && !sDarray.includes(DefCmpCopy[key])){
                    sDarray.push(DefCmpCopy[key]);
                }
                key=key+1;
            }
            sDarray=sDarray.sort(function(a, b){
                if(a.label < b.label) return -1;
                if(a.label > b.label) return 1;
                return 0;
            });
            component.set("v.DefCmp",sDarray);
             
    	}
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
    handleCommodityChangeHelper : function (component, event,helper) {
        try{ 
            var cboxRowInput =	event.getSource();
            var selctCheckRow = cboxRowInput.get("v.value");
            var DefCmpRow=component.get("v.DefCmp");
            var DefCmpRowSelected=component.get("v.SelectedDC");
            var indexNum = cboxRowInput.get("v.text");
            if(selctCheckRow == true){
                var DefCmp=DefCmpRow[indexNum].label;
                DefCmpRowSelected.push(DefCmp);
            }
            else{
                event.getSource().set("v.disabled",false);
                var DefCmp=DefCmpRow[indexNum].label;
                helper.removeA(DefCmpRowSelected,DefCmp);
            }
            component.set("v.SelectedDC",DefCmpRowSelected);
            //component.set("v.SelectedDC", k);
            //console.log('v.SelectedDC>>>'+component.get("v.SelectedDC.length"));
            //var selectedSize=component.get("v.SelectedDC.length");
            //if(selectedSize===3){
                //alert("limit reached");
            //}
        } catch(Err){
           	helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForCommodities"), "Error");            
        }
    },
    /*handlePofChangeHelper : function (component, event, helper){
        try{ 
            var cboxRowInput =	event.getSource();
            var selctCheckRow = cboxRowInput.get("v.value");
            var PofCmp=component.get("v.PofCmp");
            var DefCmpRowSelected=component.get("v.SelectedDC");
            var indexNum = cboxRowInput.get("v.text");
            if(selctCheckRow == true){
                var PofCmpval=PofCmp[indexNum].label;
                DefCmpRowSelected.push(PofCmpval);
            }
            else{
                var PofCmpval=PofCmp[indexNum].label;
                helper.removeA(DefCmpRowSelected,PofCmpval);
            }
            console.log('DefCmpRowSelected>>>'+JSON.stringify(DefCmpRowSelected));
            component.set("v.SelectedDC",DefCmpRowSelected);
            //component.set("v.SelectedDC", k);
            //console.log('v.SelectedDC>>>'+component.get("v.SelectedDC.length"));
            //var selectedSize=component.get("v.SelectedDC.length");
            //if(selectedSize===3){
                //alert("limit reached");
            //}
        } catch(Err){
            console.log("Error Message controller 1 "+Err);
           	helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForCommodities"), "Error");            
        }
    },*/
    handleSearchHelper : function (component, event, helper){
        try{
			component.set("v.displayLaborSearch", false);
            //helper.turnOnSpinner(component);
            var selectedlength	=	component.get("v.SelectedDC.length");
            var selectedDCS=component.get("v.SelectedDC");
            selectedDCS=selectedDCS.sort();
            var selectedString=selectedDCS.join(',');
            component.set('v.selectedString',selectedString);
            console.log('selectedString'+selectedString);
            var componentbuttondiv=component.find('buttonSection');
            $A.util.removeClass(componentbuttondiv, 'slds-show');
            $A.util.addClass(componentbuttondiv, 'slds-hide');
            var componentcontainer=component.find('c-container divStyle');
            $A.util.addClass(componentcontainer, 'slds-hide');
            var componentsearchbox=component.find('c-searchbox');
            $A.util.addClass(componentsearchbox, 'slds-hide');
            var componentsearchbox=component.find('selectedItem');
            $A.util.addClass(componentsearchbox, 'slds-hide');
            
            var flow = component.find("flowOnClick");
            var workOrderId = component.get("v.workOrderId");
            var inputVariables = [
                {
                    name : 'recordWOId',
                    type : 'String',
                    value : workOrderId
                    //value : component.get("v.recordId")
                },
                {
                    name : 'selectedString',
                    type : 'String',
                    value :  selectedString           
                }
            ];
            flow.startFlow("Dispatch_APS", inputVariables);
    	} catch(Err){
            helper.turnOffSpinner(component);
           	helper.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForDisplayingAutoParts"), "Error");            
        }
        
    },
    handleClearHelper : function (component, event, helper){
        component.set("v.renderComponent", false);
        component.set("v.renderSearchBox", false);
		component.set("v.displayLaborSearch",false);
        component.set("v.SelectedDC",[]);
        var flow = component.find("flowOnClick");
        var workOrderId = component.get("v.workOrderId");
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
    //will splice the array
    removeA: function (arr) {
        try{
        var what, a = arguments, L = a.length, ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax= arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    }
        catch(Err)
        {
           this.turnOffSpinner(component);
           	this.showToast("",'ERROR', $A.get("$Label.c.Dispatch_ErrorMessageForDisplayingAutoParts"), "Error");  
            }
    },
    showorhide : function(component) {
		var mt=component.find("mtag").getElement();
        $A.util.toggleClass(mt,"slds-hide");
        component.set("v.displayPartSearch",false);
		component.set("v.displayLaborSearch",false);
	},
	
	// Added by Harsha - DEFECT 5446043 - Starts Here
	checkServiceType: function(component) {
	   var spmdLink=$A.get("$Label.c.SPMD_URL_LINK");
       spmdLink+=component.get("v.serviceTag");
       component.set("v.spmdLink",spmdLink);
	    var serviceType = component.get("v.simpleRecord.Service_Type__c");
        //console.log('serviceType ' + serviceType);
	    if( !$A.util.isUndefinedOrNull(serviceType) ){
    	    if(serviceType.toUpperCase().includes("PART") || serviceType.toUpperCase().includes("MAIL")){
    	        component.set("v.enablePartSearch",true);
                component.set("v.displayLaborSearch",false);
    	    }
            else if(serviceType.toUpperCase().includes("LABOR ONLY")){
                component.set("v.displayLaborSearch",true);
                component.set("v.enablePartSearch",false);        
            }
	    } 
	},
	// Added by Harsha - DEFECT 5446043 - Ends Here
})