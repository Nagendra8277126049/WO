public class PostChatWindowController {
    
    public Boolean setStartTime{get;set;}
    public String surveyURL{get;set;}

        public PostChatWindowController (){   
                setStartTime = false;
        }
        
        public pageReference onPageLoadAction(){
        try{              
            
            if(ApexPages.currentPage().getParameters().get('startTime') != ''){
                setStartTime = true;
            }
            
            system.debug(ApexPages.currentPage().getParameters().get('chatKey'));
            system.debug(ApexPages.currentPage().getParameters().get('buttonId'));
            surveyURL = System.Label.LiveAgent_SurveyURL+'&Language=English&SessionID='+  ApexPages.currentPage().getParameters().get('chatKey') +'&ServiceLine='+ ApexPages.currentPage().getParameters().get('buttonId');
            system.debug(surveyURL);
        }
        catch(Exception e){
            system.debug('Exception is'+e);
        }
        return null;
    }
}