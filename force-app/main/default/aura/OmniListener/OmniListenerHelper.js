({
    CheckECS : function(component, workID, workItemID) { 
        try{                
            //Calling the Apex Function
            var action = component.get("c.queueCheck");
            
            //Setting the Apex Parameter
            action.setParams({
                workId : workID,
                workItemId : workItemID
            });
            
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                
                //check if result is successfull
                if(state === "SUCCESS"){
                    //Reset Form
                    var flag = a.getReturnValue();
                    //setting the Values in the form
                    console.log("flag Value");
                    console.log(flag);
                    var workListVal = component.get("v.workItemList");
                    var audioListVal = component.get("v.omniAudioList");         
                    var listVal = component.get("v.omniNotificationList");
                    if (flag!=null && flag!=undefined){
                        component.set("v.showPopup",flag);
                        if(flag != null){    
                            workListVal.push({
                                value: workItemID
                            });
                            var omniAudio = new Audio("/resource/OmniListner_AudioClip");
                            console.log(omniAudio);
                            omniAudio.loop = true;
                            console.log(omniAudio.loop);
                            omniAudio.play();     
                            audioListVal.push({
                                value: omniAudio
                            });
                            component.set("v.omniNotificationaudio", omniAudio);
                            var url = $A.get("$Label.c.Popup_Notification_Url")+"?lctName="+flag;
                            var popupwind  = window.open(url,"_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=100,left=500,width=300, height=300");                         				    
                            listVal.push({
                                value: popupwind
                            });
                            component.set("v.omniNotificationWindow", popupwind);
                            component.set("v.omniNotificationList", listVal);
                            component.set("v.omniAudioList", audioListVal);
                            component.set("v.workItemList", workListVal);                     
                            console.log('popup');                        						
                            console.log(component.get("v.omniNotificationList"));
                            console.log(component.get("v.workItemList"));
                            console.log(component.get("v.omniAudioList"));
                            
                        }
                    } 
                }
                
            });
            //adds the server-side action to the queue        
            $A.enqueueAction(action); 
        }catch(Err){
            
        }
    },
    getAgentWorks: function(component, event, helper) {
        var omniAPI = component.find("omniToolkit");
        omniAPI.getAgentWorks().then(function(result) {
            var works = JSON.parse(result.works);
            var list = component.get("v.omniNotificationList"); 
            var workList = component.get("v.workItemList");
            var audioList = component.get("v.omniAudioList");
            console.log('Assigned Entity Id of the first Agent Work is: ');
            console.log(works);
            var a = [];
            for (var i = 0; i < works.length; i++) {
                a[works[i].workItemId] = true;               
            }
            var workListCheck = workList;
            for (var i = 0; i < workListCheck.length; i++) {
                debugger;
                if (!a[workListCheck[i].value]) {
                    if(audioList[i].value != null && audioList[i].value.loop == true){
                        audioList[i].value.loop = false;
                        audioList[i].value.pause();
                    }                
                    if(list[i].value != null && list[i].value.closed == false){
                        list[i].value.close();                
                    } 
                    if (works.length > 0){
                        audioList.splice(i,1);
                        list.splice(i,1);
                        workList.splice(i,1); 
                    } 
                }
            }
            if (works.length === 0){
                audioList.splice(0,audioList.length);
                list.splice(0,list.length);
                workList.splice(0,workList.length); 
           }
            component.set("v.omniNotificationList", list);
        	component.set("v.workItemList", workList);
        	component.set("v.omniAudioList", audioList);
        }).catch(function(error) {
            console.log(error);
        });
    }
})