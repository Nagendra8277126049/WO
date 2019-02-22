({
    splitCriteria: function(component, criteria) {
        try {
            console.log("criteria  ---->   "+criteria);
            if (criteria.includes("||")) {
                var crtArry = criteria.split('||');                
                var newArrayCriteria = [];
                for (var i = 0; i < crtArry.length; i = i + 1) {
                    if (crtArry[i]!==" " && crtArry[i]!==null && crtArry[i]!==undefined && 
                        !$A.util.isEmpty(crtArry[i])) {
                        newArrayCriteria.push(
                            {
                                value:crtArry[i]
                            }
                        );
                    }
                }
                component.set("v.arrcriteria", newArrayCriteria);
            } 
        } catch (Err) {
            console.log("Error  ===>  " + Err);
        }
    },
})