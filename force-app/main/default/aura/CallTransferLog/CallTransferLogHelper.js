({
  
	helpercallTransLog : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") 
        {
            var action = component.get("c.getCTAttrRec");
            action.setParams({ucid: component.get("v.ctRecord.Call_UCID__c")})
            console.log(component.get("v.ctRecord.Call_UCID__c"));
            component.set("v.Columns", [
                {label: 'Title', fieldName: 'linkName', type: 'url',
                 typeAttributes: {label: { fieldName: 'Name',title:'title'}, target: '_self'}}, 
                {label: 'Created By', fieldName: 'linkCreatedBy', type: 'url', 
                 typeAttributes: {label: { fieldName: 'Created_By__c' }, target: '_self'}},
                {label:"Transfer Reason", fieldName:"Transfer_Reason__c", type:"text"},
                {label:"Transferred To", fieldName:"Transferred_To_Queue__c", type:"text"}
            ]);
            action.setCallback(this, function(data) {
                var records = data.getReturnValue().CTAttr;
                var recordall = data.getReturnValue();
                records.forEach(function(record){
                        record.linkName = '/'+record.Id;
                       record.linkCreatedBy = '/'+record.CreatedById;
                    });
                component.set("v.CallTransferAttr", records);
                component.set("v.CTAttrWrapper", recordall);
                  console.log("===data.getReturnValue()===" +records);
            
            });
           $A.enqueueAction(action);
            
         }
	}
})