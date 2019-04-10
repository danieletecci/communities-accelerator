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
					component.set("v.contentData", dataWrapper.content);
					component.set("v.timeZone", dataWrapper.timeZone);
					component.set("v.security", dataWrapper.security);
				}else{
					helper.displayErrorMessage($A.get("$Label.c.NewsContentDetailLoadError"));
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
				helper.showCorrectMessage(component, contentData.Status__c, status);
				contentData.Status__c = status;
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
		var action = component.get('c.createFromTemplate');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId')
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentCreatedFromTemplate"), component.get("v.contentData").Name));
				var contentId = response.getReturnValue();
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId": contentId,
					 });
				navEvt.fire();
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
						component.get("v.contentData").RecordType.Name, 
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
		var recordTypeName 	= component.get("v.contentData").recordType.Name;
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
			var cmpEvent = $A.get("e.c:upsertContentsEvent");
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
            "c:BE_ConfirmationModal",
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