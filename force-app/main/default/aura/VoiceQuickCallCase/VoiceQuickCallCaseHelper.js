({
    validateCaseDetails: function(component, event)
    {
        try{
            var cmpEvent = event.getSource();
            var Subject = component.find("CaseSubject").get("v.value");
            var Description = component.find("CaseDescription").get("v.value");
            var Disposition = component.find("CaseDisposition").get("v.value");
            var fieldNames = "";
            var errorMessage = "";
            
            if ((Subject == null) || (Subject == "") || (Subject == " ")){
                fieldNames = "Case Title";
            }
            if ((Description == null) || (Description == "") || (Description == " ")){
                if(fieldNames != "")
                    fieldNames = fieldNames + ", Case Description";
                else
                    fieldNames = "Case Description";
            } 
            if ((Disposition == null) || (Disposition == "") || (Disposition == " ")){
                if(fieldNames != "")
                    fieldNames = fieldNames + ", Disposition Reason";
                else
                    fieldNames = "Disposition Reason";
            }
            if (fieldNames != ""){
                event.preventDefault();
                errorMessage = "Complete the following fields: "+fieldNames;
                component.set("v.errorMsg", errorMessage);
            }
        }    
        catch(Err)
        {      
            console.log("Error: "+Err);
        }
    },
    
    updateCallTranscript : function(component, caseId, transcriptId) 
    {
        var action = component.get("c.updateTranscriptRecord");	
        action.setParams
        ({ 
            'transcriptId' : transcriptId, 
            'caseId' : caseId
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                $A.get('e.force:refreshView').fire();
                this.closeModal();
                console.log("Successfully Updated.");
            }
            else
                console.log("Error in Helper :" +response.getReturnValue());
        });                   
        $A.enqueueAction(action);
     },
    closeModal : function(component, event){
         $A.get("e.force:closeQuickAction").fire();
    },
})