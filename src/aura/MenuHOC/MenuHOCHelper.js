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
                helper.setActiveMenu(component);
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
    },
    
    setActiveMenu : function(component){
        
        var navigations = component.get('v.componentWrapper.navWrapper');
        if(navigations){
            for(var i = 0 ; i < navigations.length ; i++){
                if(('/s/' + navigations[i].menu.NavigationURL === window.location.pathname) || (navigations[i].menu.NavigationURL == '/' && window.location.pathname == '/s/')){
                    navigations[i].menu['isActive'] = true;
                }else{
                    navigations[i].menu['isActive'] = false;
                }
            }
            component.set('v.componentWrapper.navWrapper', navigations);
        }
        
    }
    
})