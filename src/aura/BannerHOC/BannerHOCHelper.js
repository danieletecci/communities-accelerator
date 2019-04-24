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
                    var elements = new Object();
                    component.set("v.componentWrapper", cWrapper);
                    
                    if(clusterCookie == undefined || clusterCookie == ''){
                        helper.setCookie('CG_clusterId', cWrapper.clusterId, 100);
                    }

                    if(cWrapper.data.contentWrapper.length > 0){
                        elements = cWrapper.data.contentWrapper.map((c, index) => {
                            return {
                                id: c.content.Id,
                                class: index == 0 ? 'carousel-item active' : 'carousel-item',
                                indicatorClass: index == 0 ? 'active' : '',
                                imgSrc: c.mediaElements.length > 0  ? c.mediaElements[0].FileURLDesktop : '',
                                title: c.content.Title,
                                description: c.content.Extract
                            }
                        })
                    }

                    component.set("v.elements", elements);
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