({
	doInit : function(component, event, helper) {
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
	},
	doCancel : function(component, event, helper) {
        component.set("v.isEdit", false);
        helper.getRecords(component);
	},
	doSearch : function(component, event, helper) {
        helper.search(component);
	}
})