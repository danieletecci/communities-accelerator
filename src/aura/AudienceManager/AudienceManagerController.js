({
	doInit : function(component, event, helper) {
		//component.set("v.isEdit", false);
        helper.getRecords(component);
	},

	doSearch : function(component, event, helper) {
        helper.search(component);
	}
})