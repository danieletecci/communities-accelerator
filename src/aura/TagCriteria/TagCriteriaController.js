({
	doInit : function(component, event, helper) {
		component.set("v.isEdit", false);
		component.set("v.isReorder", false);
        helper.getRecords(component);
	},
	doSave : function(component, event, helper) {
        helper.save(component, event, helper);
	},
	doSelectAll : function(component, event, helper) {
        helper.selectAll(component, event);
	},
	doEdit : function(component, event, helper) {
        component.set("v.isEdit", true);
        component.set("v.isSearch", false);
	},
	doCancel : function(component, event, helper) {
        component.set("v.isEdit", false);
        component.set("v.isSearch", false);
        helper.getRecords(component);
	},
	doSearch : function(component, event, helper) {
        helper.search(component);
	},
    doSearchTag : function(component, event, helper) {
        component.set("v.isSearch", true);
	},
    doClose : function(component, event, helper) {
        component.set("v.isSearch", false);
	},
    doAccept : function(component, event, helper) {
        //component.set("v.isSearch", false);
        helper.savePoint(component, event, helper);
        component.set("v.isSearch", false);
	},
})