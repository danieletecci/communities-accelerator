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