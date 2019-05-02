({
    toggleActive : function(component, event, helper) {
        var active = component.get("v.isActive");
        component.set("v.isActive", !active);
    },
})