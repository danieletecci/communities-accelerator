({
	doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    openSubMenu : function(component, event, helper) {
		helper.openSubMenu(component,event);
	},
	redirect : function(component, event, helper) {
        helper.redirect(component);
	},
    urlChange : function(component, event, helper){
        if('/s/' + component.get("v.item.menu.NavigationURL") === window.location.pathname){
            component.set("v.isActive", true);
        }else{
            component.set("v.isActive", false);
        }
    }
})