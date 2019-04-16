({
	getWrapper : function(component, event, helper) {
		var clusterCookie = helper.getCookie("CG_clusterId");
		var componentExternalId = component.get("v.componentExternalId");
		var device = $A.get("$Browser.formFactor");
		component.set('v.isLivePreview', String(window.location.href).includes('livepreview.') || String(window.location.href).includes('sitestudio.'));

		var action = component.get("c.getNavWrapper");

		action.setParams({
			componentExternalId: componentExternalId,
			clusterId: clusterCookie,
			device: device
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.componentWrapper", action.getReturnValue());
	        }
	    });
	    
	    $A.enqueueAction(action);
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
    }

})