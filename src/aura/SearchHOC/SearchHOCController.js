({
	onInit 	: function(component,event,helper){
		helper.init(component,helper, helper.getUrlParameter('q'));

	},
	onKeyUp : function(component, event, helper) {
		var queryTerm = event.target.value;

		helper.managePredictiveResults(component, helper, queryTerm);
		helper.manageSearchResults(component, helper, event, queryTerm);
		helper.manageCancelButton(component, queryTerm);
	},
	onSearchBlur: function(component, event, helper){
		helper.hidePredictiveResults(component);
	},
	onSearchFocus: function(component, event, helper){
		helper.removeAutocomplete();
		helper.showPredictiveResults(component);
	},
	onClear : function(component, event, helper){
		helper.clearPredictiveResults(component, helper);
	}
})