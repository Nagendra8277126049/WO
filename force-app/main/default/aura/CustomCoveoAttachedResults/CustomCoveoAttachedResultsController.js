({
    init : function(component, event, helper) {
        var panel = component.find('panel');
        var searchUi = panel.get('v.searchUI')

        searchUi.registerBeforeInit(function(searchUiCmp, root, Coveo) {
            
            searchUi.setSearchInterfaceOptions({
                ResultLink: {
                    onClick: function(e, result) {
                        if(result.raw.sfid || result.raw.sfcaseid) {
                            component.openTab(null, result.raw.sfid || result.raw.sfcaseid)
                        } else {
                            window.open(result.clickUri);
                        }
                    }
                }
            })
            
        });
    },

    openTab: function(component, event, helper) {
        var params = event.getParams().arguments;
        helper.openNewTab(params.url, params.sfid);
    }

})