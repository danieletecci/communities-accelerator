({
	onInit : function(component, event, helper) {
		helper.getObjectLabel(component, component.get("v.sObjectName"));
		helper.getStatusValues(component, component.get("v.sObjectName"), "Status__c");
	},
	onKeyUp : function(component, event, helper){
		var appEvent 	= $A.get("e.c:ContentLandingSearchEvent");
		appEvent.setParams({
			"searchedString"	: searchedString,
    		"status" 			: component.get("v.selectedStatus")
		});
		appEvent.fire();
	},
	onTabSelect : function(component, event, helper){
		console.log("active tab: " + component.get("v.selectedStatus"));
	},
	createRecord : function(component, event, helper){
		component.find("modalRT").show();
	},
})