window.coveoCustomScripts['default'] = function(promise) {
    var root = document.querySelector("#search");
    var searchInterface = Coveo.$$(root);
    
    function displayQuickviewActionItemOnly(args) {
        Coveo.$$(Coveo.$$(args.item).find('.CoveoResultActionsMenu')).addClass('coveo-menu-opened');
                    Coveo.$$(args.item).find('.CoveoResultActionsMenu').style['border-style'] = 'none';
        
        if (Coveo.$$(args.item).find('.CoveoSalesforceQuickview'))
                                Coveo.$$(args.item).find('.CoveoSalesforceQuickview').style['border-left-style'] = 'none';
        
        if (Coveo.$$(args.item).find('.CoveoAttachToCase'))
                        Coveo.$$(args.item).find('.CoveoAttachToCase').style.display = 'none';
        
        if (Coveo.$$(args.item).find('.CoveoResultActionsSendEmail'))
                        Coveo.$$(args.item).find('.CoveoResultActionsSendEmail').style.display = 'none';
        
        if (Coveo.$$(args.item).find('.CoveoResultActionsPostToFeed'))
                        Coveo.$$(args.item).find('.CoveoResultActionsPostToFeed').style.display = 'none';        
    }
    
    function displayAllActionItems(args) {
        Coveo.$$(args.item).find('.CoveoResultActionsMenu').style['border-style'] = 'solid';
        
        if (Coveo.$$(args.item).find('.CoveoSalesforceQuickview'))
            Coveo.$$(args.item).find('.CoveoSalesforceQuickview').style['border-left-style'] = 'solid';
        
        if (Coveo.$$(args.item).find('.CoveoAttachToCase'))
            Coveo.$$(args.item).find('.CoveoAttachToCase').style.display = 'block';
        
        if (Coveo.$$(args.item).find('.CoveoResultActionsSendEmail'))
            Coveo.$$(args.item).find('.CoveoResultActionsSendEmail').style.display = 'block';
        
        if (Coveo.$$(args.item).find('.CoveoResultActionsPostToFeed'))
            Coveo.$$(args.item).find('.CoveoResultActionsPostToFeed').style.display = 'block';
    }
    
    searchInterface.on("newResultDisplayed", function(e, args) {
        displayQuickviewActionItemOnly(args);
        
        Coveo.$$(args.item.querySelector(".CoveoSalesforceQuickview")).on('mouseover', function() {
            displayAllActionItems(args);
        });
        
        Coveo.$$(args.item).on('mouseleave', function() {
                        displayQuickviewActionItemOnly(args);
        });
    });
}
