({
    doInit : function(component) {
        if(component.get("v.item.menu.NavigationURL")){
            if(component.get("v.item.menu.NavigationURL").includes("/secur/logout.jsp")){
                component.set('v.isLogOut', !component.get('v.isLogOut'));
            }
        }
        if('/s/' + component.get("v.item.menu.NavigationURL") === window.location.pathname){
            component.set("v.isActive", true);
        }
        
    },
    redirect : function(component) {
        var item = component.get('v.item');
        var link = '/s/';
        link += item.menu.NavigationURL;
        if(item.menu.URLParameters){
            link += '?' + item.menu.URLParameters;
        }
        $A.get("e.force:navigateToURL").setParams({"url" : link}).fire();
        component.set("v.menuIsOpen", false);
    }
})