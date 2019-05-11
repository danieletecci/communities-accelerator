({
	doShow : function(component, event, helper) {
		$A.util.addClass(component.find("previewModalBackdrop"), "slds-backdrop_open");
		$A.util.addClass(component.find("previewModal"), "slds-fade-in-open");
	},
	doHide : function(component, event, helper) {
		$A.util.removeClass(component.find("previewModal"), "slds-fade-in-open");
		$A.util.removeClass(component.find("previewModalBackdrop"), "slds-backdrop_open");
	}
})