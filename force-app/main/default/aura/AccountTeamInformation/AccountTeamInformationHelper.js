({
	getTeamInfo : function(cmp) {
		let action = cmp.get('c.getTeamInfo');
        action.setParams({projId : cmp.get('v.recordId')});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                if(!$A.util.isEmpty(response.getReturnValue())){
                    cmp.set('v.accountTeamList', response.getReturnValue());
                }else{
                    cmp.set('v.shouldShowMessageNoTeamInformation', true);
                }
            }else{
                //THROW ERROR 
                alert('There was an internal error.');
                let errorMessage = response.getError()[0].message || 'undefined';
                console.log('ERROR (apex Affinity Controller - method getTeamInfo): ' + errorMessage);
            }  
            cmp.set('v.isLoading', false);
        }); 
        $A.enqueueAction(action);
	}
})