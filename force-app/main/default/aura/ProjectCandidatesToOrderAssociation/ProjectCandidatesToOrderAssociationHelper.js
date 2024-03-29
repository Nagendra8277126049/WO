({
	sort : function(component) {
			var stageOrder = {
    			'InProgress':1,
    			'Draft':2,
    			'Cancelled':4,
    			'Closure':3
			};
            var suggestions = component.get("v.Projects");
            var s = suggestions.sort(function(a,b){
                var returnValue = 0;
				if (stageOrder[a.stage] > stageOrder[b.stage]) {
            		returnValue = 1;
        		} else if (stageOrder[a.stage] < stageOrder[b.stage]) {
            		returnValue = -1;
        		} else if (a.project.Id > b.project.Id) {
            		returnValue = -1;
        		} else if (a.project.Id < b.project.Id) {
            		returnValue = 1;
        		}
        		return returnValue; 
            });
            component.set("v.Projects", suggestions);
	}
})