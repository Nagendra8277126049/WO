({
    onWorkAssigned : function(component, event, helper) {
        console.log("Work assigned.");
        var workItemId = event.getParam('workItemId');
        var workId = event.getParam('workId');
        console.log(workItemId);
        console.log(workId);
        helper.CheckECS(component,workId,workItemId);
    },
    onWorkAccepted : function(component, event, helper) {
        if(component.get("v.showPopup") != null){
            console.log("Work accepted.");
            var workItemId = event.getParam('workItemId');
            var workId = event.getParam('workId');
            console.log(workItemId);
            var counter = 0;
            var list = component.get("v.omniNotificationList"); 
            var workList = component.get("v.workItemList");
            var audioList = component.get("v.omniAudioList");
            for(var i = 0, size = workList.length; i < size ; i++){
                
                if(workList[i].value == workItemId){   
                    counter = i;
                    if(audioList[i].value != null && audioList[i].value.loop == true){
                        audioList[i].value.loop = false;
                        audioList[i].value.pause();
                    }
                    if(list[i].value != null && list[i].value.closed == false){
                        list[i].value.close();
                    }   
                    	audioList.splice(i,1);
                        list.splice(i,1); 
                    	break;
                }
            }
            console.log(counter);
            workList.splice(counter,1);
            console.log("workItemList Count: " + workList.length);
            console.log("omniNotificationList Count: "+ list.length);
            component.set("v.omniNotificationList", list);
            component.set("v.workItemList", workList);
            component.set("v.omniAudioList", audioList);
        }
    }, 
    onWorkloadChanged : function(component, event, helper) {
        console.log("Workload changed.");
        var configuredCapacity = event.getParam('configuredCapacity');
        var previousWorkload = event.getParam('previousWorkload');
        var newWorkload = event.getParam('newWorkload');
        var list = component.get("v.omniNotificationList"); 
        var workList = component.get("v.workItemList");
        var audioList = component.get("v.omniAudioList");
        
        /*if(newWorkload < previousWorkload && list.length > 0 && workList.length > 0 && audioList.length > 0 && newWorkload == 0){
            console.log("newWorkload < previousWorkload");
            console.log(list[0].value);
            console.log(list[1].value);
            
            for(var i = 0, size = list.length; i < size ; i++){
                console.log(list[i].value);
                                
                if(audioList[i].value != null){
                    audioList[i].value.loop = false;
                    audioList[i].value.pause();
                }                
                if(list[i].value != null){
                    list[i].value.close();                
                }
            }
            workList.splice(0,workList.length);
            list.splice(0,list.length);
            audioList.splice(0,audioList.length);
            
            console.log("omniNotificationList Count: "+ list.length);
            console.log("workItemList Count: " + workList.length);
        } */
        if(newWorkload < previousWorkload && list.length > 0 && workList.length > 0 && audioList.length > 0 ){
            console.log("newWorkload < previousWorkload");               
            helper.getAgentWorks(component, event, helper);                               
        } 
        
        
        
    }
    
})