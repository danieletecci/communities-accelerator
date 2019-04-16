({
	doInit : function(component, event, helper) {
		var startDate = component.get("v.content").PublishStartDate__c;
		var endDate = component.get("v.content").PublishEndDate__c;
		const options = [
		    {'label': $A.get("$Label.c.PublishModalRadioPublishNow"), 'value': 'publish'},
		    {'label': $A.get("$Label.c.PublishModalRadioSchedulePublication"), 'value': 'schedule'}
		];
		component.set("v.options", options);
		component.set("v.startDate", startDate);
		component.set("v.endDate", endDate);
		if(startDate && new Date(startDate) > new Date())
			component.set("v.action", "schedule");
		if(endDate){
			component.set("v.expire", true);
		}
	},
	doPublish : function(component, event, helper){
		if(helper.isValid(component)){
			helper.publishContent(component);
		}
	},
	doShow : function(component, event, helper) {
		$A.util.addClass(component.find("publishModalBackdrop"), "slds-backdrop_open");
		$A.util.addClass(component.find("publishModal"), "slds-fade-in-open");
	},
	doHide : function(component, event, helper) {
		$A.util.removeClass(component.find("publishModal"), "slds-fade-in-open");
		$A.util.removeClass(component.find("publishModalBackdrop"), "slds-backdrop_open");
	}
})