({    
    showToast : function(component, title, message, type) {
        try{
            var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
            	"title": title,
            	"message": message, 
            	"type": type,
            	"mode": "pester",
            	"duration": "3000"
        	});
        	toastEvent.fire();
        }catch(Err){
            console.log(Err);
        }
    }
})