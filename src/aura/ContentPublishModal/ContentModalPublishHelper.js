({
	isValid : function(component) {
		var action 			= component.get("v.action");
		var expire 			= component.get("v.expire");
		var startDate 		= component.get("v.startDate");
		var endDate 		= component.get("v.endDate");
		var validStartDate = true, validEndDate = true;
		if(action === 'schedule'){
			if(new Date(startDate) < new Date())
				component.find("start-date").setCustomValidity($A.get("$Label.c.PublishModalFutureStartDate"));
			else
				component.find("start-date").setCustomValidity("");
			component.find("start-date").reportValidity();
			validEndDate = component.find("start-date").checkValidity();
		}
		if(expire === true){
			if(action === 'publish' && new Date(endDate) < new Date())
				component.find("end-date").setCustomValidity($A.get("$Label.c.PublishModalFutureStartDate"));
			else if(action === 'schedule' && startDate === null && new Date(endDate) < new Date())
				component.find("end-date").setCustomValidity($A.get("$Label.c.PublishModalFutureEndDate"));
			else if(action === 'schedule' && startDate != null && new Date(endDate) < new Date(startDate))
				component.find("end-date").setCustomValidity($A.get("$Label.c.PublishModalWrongEndDate"));
			else
				component.find("end-date").setCustomValidity("");
			component.find("end-date").reportValidity();
			validEndDate = component.find("end-date").checkValidity();
		}

		return (validEndDate && validStartDate);
	},
	publishContent : function(component){
		var contentId = component.get('v.content').Id;
		var status  = (component.get("v.action") === "schedule") ? "Scheduled" : "Published";
		if(component.get("v.action") === "publish"){
			component.set("v.startDate", new Date());
		}
		if(component.get("v.hasDetailComponent")){
			var cmpEvent = $A.get("e.c:ContentUpsertEvent");
	        cmpEvent.setParams({
				"contentId" 		: contentId,
				"status" 			: status,	
				"publishStartDate"	: component.get("v.startDate"),
				"publishEndDate"	: component.get("v.endDate")
			});
	        cmpEvent.fire();
			$A.util.removeClass(component.find("publishModal"), "slds-fade-in-open");
			$A.util.removeClass(component.find("publishModalBackdrop"), "slds-backdrop_open");
	    } else
	    	helper.scheduleContent(component);
	},
	scheduleContent: function(component){
		var action  = component.get('c.schedulePublication');
		var status  = (component.get("v.action") === "schedule") ? "Scheduled" : "Published";
		var content = component.get("v.content");
		var helper  = this;

		if(component.get("v.action") === "publish"){
			component.set("v.startDate", new Date());
		}

		content.PublishStartDate = component.get("v.startDate");
		content.PublishStartDate = component.get("v.endDate");
		content.PublishStartDate = status;

		action.setParams({
			content : content
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var contentResult = response.getReturnValue();
				component.set("v.content", contentResult);
				helper.showCorrectMessage(component, content, status);
				$A.util.removeClass(component.find("publishModal"), "slds-fade-in-open");
				$A.util.removeClass(component.find("publishModalBackdrop"), "slds-backdrop_open");
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.showToast($A.get("$Label.c.General_Error"), message, "error");
			}
		});

		$A.enqueueAction(action);
	},
	showCorrectMessage : function(component, content, status){
		var recordTypeName 	= content.RecordTypeName;
		var recordName 		= content.Name;

		if(status === 'Scheduled'){
			this.showToast(
				$A.get("$Label.c.General_Success"),
				this.stringFormat($A.get("$Label.c.ContentModalScheduledMessage"), recordTypeName, recordName),
				"success"
			);
		} else if(status === 'Published'){
			this.showToast(
				$A.get("$Label.c.General_Success"),
				this.stringFormat($A.get("$Label.c.ContentDetailPublishMessage"), recordTypeName, recordName),
				"success"
			);
		}
	},
	showToast : function(toastTitle,toastMessage,toastType){
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        title: toastTitle,
	        message: toastMessage,
	        type: toastType,
			mode: (toastType === "success") ? 'dismissable' : 'sticky'
	    });
	    toastEvent.fire();
	},
	stringFormat: function(string) {
	    var outerArguments = arguments;
	    return string.replace(/\{(\d+)\}/g, function() {
	        return outerArguments[parseInt(arguments[1]) + 1];
	    });
	}
})