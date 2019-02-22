({
    startCollaborateChat : function(component, event, helper) {
        try{
            var bID = component.find("QueueId").get("v.value");//button ID
            console.log(bID);
            
            var index,QueueName;
            component.get("v.optionList").forEach(function(v,i) { 
                if(v.objB.buttonid__c == bID) {
                    index = i;
                }
            });
            //  var q= component.get("v.optionList")[index].objB;
            // console.log(q);
            QueueName  = component.get("v.optionList")[index].objB.Label ;  // get the button label     
            var rsn = component.find("rsn").get("v.value");//Description field
            var Role = component.find("Rl").get("v.value");//Role field
            var ColReason = component.find("RlR").get("v.value");//Reason field
           var custStatus = document.getElementById("custStatus").checked;//Customer Status
            // var custStatus = component.get("v.simpleCase.Origin");//Customer Status
            var caseId = component.get("v.recordId");// get the caseId
            var userName= component.get("v.currentUser.Name");
            var Cn= component.get("v.simpleCase.CaseNumber");
            console.log(">>>>>>>"+ Cn);
            var url = '';
            
           // if(custStatus== "Phone" || custStatus== "Chat"){
            if(custStatus){
                url= "/apex/CollaborateChat?Name="+userName+"&Description="+rsn+"&CaseNr="+Cn+"&buttonId="+bID+"&Role="+Role+"&RoleReason="+ColReason+"&QueueName="+QueueName+"&custStatus=Yes";
            } else {
                url= "/apex/CollaborateChat?Name="+userName+"&Description="+rsn+"&CaseNr="+Cn+"&buttonId="+bID+"&Role="+Role+"&RoleReason="+ColReason+"&QueueName="+QueueName+"&custStatus=No";
            }
                
            console.log(url);
            if ( ColReason !="--- None ---"){
             
            window.open(url, "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=420,height=500");  
            
                }else{
                
                    helper.showToast(component,'Error',"Review the following field: Reason", "Error");
                }
               // alert('Please select Reason field');
           
            //  helper.fetchcasedetails(component,caseId,bID,userName,QueueName,rsn,Role,ColReason,custStatus,Cn) ;
        } catch(err){
            helper.showToast(component,'Error',"Review the following field: Queue", "Error");
            console.log(err);
        }   
    },
    
    doInit : function(component, event, helper) {
        try{
            // get the fields API name and pass it to helper function  
            var controllingFieldAPI = component.get("v.controllingFieldAPI");
            var dependingFieldAPI = component.get("v.dependingFieldAPI");
            var objDetails = component.get("v.objDetail");
            component.set("v.edit" , false); 
            // call the helper functions
            helper.fetchqueue(component);
            helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
            
            var action = component.get("c.getSelectedValue");
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {  
                    var StoreResponse = response.getReturnValue();
                    console.log('StoreResponse: '+StoreResponse);                 
                    
                    window.setTimeout(
                        $A.getCallback( function() {
                           // var def1= " Centralized Tech Expert";
                            var def2 = "Troubleshooting";
                            component.find("QueueId").set("v.value",StoreResponse);
                           // component.find("Rl").set("v.value", def1);
                            component.find("RlR").set("v.value", def2);
                            
                        })); 
                    console.log('>>>>>>: '+component.find("QueueId").get("v.value")); 
                }
            });
            $A.enqueueAction(action);
        }catch(err){
            console.log(err);
        }
    },
    
    onControllerFieldChange: function(component, event, helper) { 
        try{
            var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
            var depnedentFieldMap = component.get("v.depnedentFieldMap");
            
            
            if (controllerValueKey != '--- None ---') {
                var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
                
                if(ListOfDependentFields.length > 0){
                    component.set("v.bDisabledDependentFld" , false);  
                    helper.fetchDepValues(component, ListOfDependentFields);    
                }else{
                    component.set("v.bDisabledDependentFld" , true); 
                    component.set("v.listDependingValues", ['--- None ---']);
                }  
                
            } else {
                component.set("v.listDependingValues", ['--- None ---']);
                component.set("v.bDisabledDependentFld" , true);
            }
        }catch(err){
            console.log(err);
        } 
    },
    saveSelectedValue: function(component, event, helper) {
        try{
            var valueSelect = component.find("QueueId").get("v.value");
            console.log('>>>valueSelect: '+valueSelect)
            
            helper.saveDefault(component,valueSelect);
        }catch(err){
            console.log(err);
        }
    }
    
    
    
})