({
	getData : function(component){
		var action = component.get('c.getData');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId')
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var dataWrapper = response.getReturnValue();
				if(dataWrapper){
					component.set("v.contentData", 	dataWrapper.content);
					component.set("v.timeZone", 	dataWrapper.timeZone);
					component.set("v.gmtOffset", 	dataWrapper.gmtOffset);
					component.set("v.security", 	dataWrapper.security);
					helper.setTooltips(component);
				}else{
					helper.displayErrorMessage($A.get("$Label.c.ArticleContentDetailLoadError"));
				}
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	setName : function(component, newName){
		var action = component.get('c.setName');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId'),
			name: newName
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var newName = response.getReturnValue();
				var contentData = component.get("v.contentData");
				contentData.Name = newName;
				component.set("v.contentData", contentData);
				component.set("v.isNameEdit", false);
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	setStatus : function(component, status, publishStartDate, publishEndDate){
		var action = component.get('c.setStatus');
		var helper = this;

		action.setParams({
			recordId			: component.get('v.recordId'),
			status 				: status,
			publishStartDate 	: publishStartDate,
			publishEndDate 		: publishEndDate
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var status = response.getReturnValue();
				var contentData = component.get("v.contentData");
				helper.showCorrectMessage(component, contentData.Status, status);
				contentData.Status = status;
				component.set("v.contentData", contentData);
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	createFromTemplate : function(component){
		component.find("newContentModal").show();
	},
	deleteContent : function(component){
		var action = component.get('c.deleteContent');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId')
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.displaySuccessMessage(
					helper.stringFormat(
						$A.get("$Label.c.ContentDetailDeletedMessage"), 
						component.get("v.contentData").RecordTypeName, 
						component.get("v.contentData").Name
					)
				);
				var urlEvent = $A.get("e.force:navigateToURL");
			    urlEvent.setParams({
			      "url": "/lightning/n/ContentLanding"
			    });
			    urlEvent.fire();
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	showCorrectMessage : function(component, previousStatus, actualStatus){
		var recordTypeName 	= component.get("v.contentData").RecordTypeName;
		var recordName 		= component.get("v.contentData").Name;
		var helper 			= this;

		if(previousStatus === 'Draft' && actualStatus === 'Draft'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailDraftMessage"), recordTypeName, recordName));
		} else if(previousStatus === 'Draft' && actualStatus === 'Published'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailPublishMessage"), recordTypeName, recordName));
		} else if(previousStatus === 'Published' && actualStatus === 'Draft'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailUnpublishMessage"), recordTypeName, recordName));
		} else if(previousStatus === 'Published' && actualStatus === 'Published'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailPublishMessage"), recordTypeName, recordName));
		}
	},
	updateContent : function(component, status, publishStartDate, publishEndDate){
		var contentId 			= component.get('v.recordId');
		if(component.get("v.hasDetailComponent")){
			var cmpEvent = $A.get("e.c:ContentUpsertEvent");
	        cmpEvent.setParams({
				"status" 			: status,
				"contentId" 		: contentId,
				"publishStartDate"	: publishStartDate,
				"publishEndDate"	: publishEndDate
			});
	        cmpEvent.fire();
	    } else
	    	helper.setStatus(component, status, publishStartDate, publishEndDate);
	},
	showConfirmationDelete : function(component){
		$A.createComponent(
            "c:ConfirmationModal",
            {
                "aura:id"		: "confirmationModal",
                "title"			: $A.get("$Label.c.General_Delete") + ' ' + component.get("v.contentData").Name,
                "message"		: $A.get("$Label.c.ContentDeletingMessage"),
                "confirmLabel"	: $A.get("$Label.c.General_Delete"),
                "confirmVariant": "destructive",
                "onconfirm"		: component.getReference("c.doDelete"),
                "oncancel"		: component.getReference("c.doHideConfirmation")
            },
            function(confirmationModal, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    component.set("v.confirmationModal", confirmationModal);
                    confirmationModal.show();
                }
            }
        );
    },
    setTooltips : function(component){
    	try{
    		if(component.get("v.contentData").PublishStartDate && component.get("v.contentData").Status == $A.get("$Label.c.ContentDetailScheduled")){
	        	moment.locale(component.get("v.locale"));
		    	var publishStartDate = moment(component.get("v.contentData").PublishStartDate).format('LLL');
				component.set("v.scheduledTooltip", this.stringFormat($A.get("$Label.c.ContentPendingPublication"), publishStartDate));
	    	}
	    } catch(e){
	    	console.log(e.message);
	    }
	    try{
	    	if(component.get("v.contentData").PublishEndDate && component.get("v.contentData").Status == $A.get("$Label.c.ContentDetailPublished")){
	        	var gmtOffset = component.get("v.gmtOffset");
	        	var pedMoment = moment(component.get("v.contentData").PublishEndDate).zone(gmtOffset);
		    	var publishEndDate = pedMoment.format('LLL');
		    	component.set("v.publishedTooltip", this.stringFormat($A.get("$Label.c.ContentPublishedUntil"), publishEndDate));
	    	}
	    } catch(e){
	    	console.log(e.message);
	    }
    },
	displayErrorMessage : function(message){
		var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Error",
						message: message,
						type: "error"
					});
		toastEvent.fire();
	},
	displaySuccessMessage : function(message){
		var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Success!",
						message: message,
						type: "success"
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