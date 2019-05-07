({
    toggleOpened : function(component, event, helper) {
        var opened = component.get("v.opened");
        component.set("v.opened", !opened);
    },
})