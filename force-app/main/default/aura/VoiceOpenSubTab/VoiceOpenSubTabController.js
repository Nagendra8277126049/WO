({
	doInit: function(cmp) {
        var workspaceAPI = cmp.find("workspace");
        var sPageURL = window.location.search.substring(1); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
	
        var primeTabId;
        var subTabIds = [];
        var primeTabUrl;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] === 'primaryId')
            {
                primeTabId = sParameterName[1] === undefined ? '' : decodeURIComponent(sParameterName[1]);
            }
            else if (sParameterName[0] === 'primaryUrl')
            {
                primeTabUrl = sParameterName[1] === undefined ? '' : decodeURIComponent(sParameterName[1]);
            }
            else if (sParameterName[0] === 'subtabs')
            {
                subTabIds = !sParameterName[1] ? [] : decodeURIComponent(sParameterName[1]).split(',');
            }
        }
        
        console.log('Primary Tab Object Id ' + primeTabId);
        console.log('Primary Tab Url ' + primeTabUrl);
        console.log('Number of Sub Tabs ' + subTabIds.length);
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var thisTabId = response.tabId;
            if (primeTabId)
            {
                workspaceAPI.openTab({
                    recordId: primeTabId,
                    focus: true
                }).then(function(response) {
                    for (i = 0; i < subTabIds.length; i++)
                    {
                        workspaceAPI.openSubtab({
                            parentTabId: response,
                            recordId: subTabIds[i],
                            focus: false
                        });
                    }
                    workspaceAPI.closeTab({tabId: thisTabId});
                });
            }
            else if(primeTabUrl)  
            {
                workspaceAPI.openTab({
                    url: primeTabUrl,
                    focus: true
                }).then(function(response) {
                    for (i = 0; i < subTabIds.length; i++)
                    {
                        workspaceAPI.openSubtab({
                            parentTabId: response,
                            recordId: subTabIds[i],
                            focus: false
                        });
                    }
                    workspaceAPI.closeTab({tabId: thisTabId});
                });
            }
            else
            {
            	workspaceAPI.closeTab({tabId: thisTabId});
            }
            
        })
        .catch(function(error) {
            console.log(error);
        });
	}
})