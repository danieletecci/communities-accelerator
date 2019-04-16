({
	onItemSelect : function(component, event, helper) {
		helper.setRecordList(component, event.getParam('name'));
	},
	handleSearchDetails : function(component, event, helper) {
		component.set("v.searchDetails", 	event.getParam("searchDetails")	);
		component.set("v.component", 		event.getParam("component")		);
		component.set("v.searchedString", 	event.getParam("searchedString"));
		helper.getSearchResults(component, helper);
	}
})