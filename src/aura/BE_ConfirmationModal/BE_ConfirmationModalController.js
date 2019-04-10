({
	doShow : function(component, event, helper) {
		$A.util.addClass(component.find("confirmModalBackdrop"), "slds-backdrop_open");
		$A.util.addClass(component.find("confirmModal"), "slds-fade-in-open");
	},
	doHide : function(component, event, helper) {
		$A.util.removeClass(component.find("confirmModal"), "slds-fade-in-open");
		$A.util.removeClass(component.find("confirmModalBackdrop"), "slds-backdrop_open");
	}
})