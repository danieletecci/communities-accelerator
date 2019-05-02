({
	getComponentWrapper : function(component, helper) {
		var cw = component.get("v.componentWrapper");
		var componentExternalId = component.get("v.componentExternalId");
        var device = $A.get("$Browser.formFactor");
        
        var navUrl = window.location.pathname;
        
        
        if(cw == null){
            component.set("v.isLoading", true);            
            var clusterCookie = helper.getCookie("CG_clusterId");
            
            var action = component.get("c.getComponentWrapper");
            action.setParams({
                componentExternalId: componentExternalId,
                clusterId: clusterCookie,
                device: device,
                navigationUrl: navUrl
            });

            action.setCallback(this, function(f) {
                if(f.getState() === "SUCCESS") {
                    var cWrapper = action.getReturnValue();
                    component.set("v.componentWrapper", cWrapper);
                    
                    if(clusterCookie == undefined || clusterCookie == ''){
                        helper.setCookie('CG_clusterId', cWrapper.clusterId, 100);
                    }
                    
                    //Loading
                    component.set("v.isLoading", false);
                }
            });
            $A.enqueueAction(action);
	    }else{
	    	component.set("v.isLoading", false);
	    }
	},
    goPage : function(component, pageNumber){
        var quantPages = component.get("v.componentWrapper.data.pagesNumbers")[component.get("v.componentWrapper.data.pagesNumbers").length-1];
        if(quantPages >= pageNumber && pageNumber > 0 && component.get('v.currentPageNumber') != pageNumber){
            component.set("v.isLoading", true);

            var componentWrapper = component.get("v.componentWrapper");
            var device = $A.get("$Browser.formFactor");
            var orderBy = componentWrapper.meta.component.OrderBy == 'Custom Sorting' ? componentWrapper.meta.component.OrderByAdvance : componentWrapper.meta.component.OrderBy;

            var action = component.get("c.getPage");
            action.setParams({
                listAllContentIds: componentWrapper.data.listAllContentIds,
                componentType: componentWrapper.meta.component.RecordTypeDeveloperName,
                pageSize: String(componentWrapper.meta.component.PageSize),
                pageNumber: String(pageNumber),
                orderBy: orderBy,
                device: device
            });

            action.setCallback(this, function(f) {
                if(f.getState() === "SUCCESS") {
                    component.set("v.componentWrapper.data.contentWrapper", action.getReturnValue());
                    component.set('v.currentPageNumber', pageNumber);
                    component.set("v.isLoading", false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    getCookie : function(cname){
    	var name = cname + "=";
	    var decodedCookie = decodeURIComponent(document.cookie);
	    var ca = decodedCookie.split(';');
	    for(var i = 0; i <ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
    },
    setCookie : function(cname, cvalue, exdays) {
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+ d.toUTCString();
	    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	}
})