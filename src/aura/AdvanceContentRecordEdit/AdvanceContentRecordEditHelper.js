({
	setContentData : function(component) {
		var action 		= component.get('c.getData');
		var recordId 	= component.get('v.recordId');
		var helper		= this;
		action.setParams({
			recordId: recordId
    	});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				if(data){
					component.set("v.namespace", 			data.namespace);
					component.set("v.contentData", 			data.content);
					
					component.set("v.visibilitySelectors", 	data.visibilitySelectors);
					component.set("v.hasEditAccess", 			data.hasEditAccess);
					if(data.content.MediaElementAssignments != null && data.content.MediaElementAssignments.length > 0){
						component.set('v.imageUrl', data.content.MediaElementAssignments[0].MediaElement.FileURLDesktop);
                        component.set('v.mediaElementName', data.content.MediaElementAssignments[0].MediaElement.Name);
                        component.set('v.mediaElementId', data.content.MediaElementAssignments[0].MediaElement.Id);
					}
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
    updateContent : function(component, status){
    	var helper				   = this;
		var content 			   = component.get('v.contentData');
		var previousStatus		   = content.Status;
		var visibilitySelectors    = component.get('v.visibilitySelectors');
		var mediaElementId 		   = component.get('v.mediaElementId');
		var action 				   = component.get('c.saveContent');        
		action.setParams({
			content : content,
			visibilitySelectorsString : JSON.stringify(visibilitySelectors),
			mediaElementId : mediaElementId,
			status : status
        });
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.showCorrectMessage(component, content, previousStatus, status);
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId": content.Id,
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
	showCorrectMessage : function(component, content, previousStatus, actualStatus){
		var recordTypeName 	= content.RecordTypeName;
		var recordName 		= content.Name;
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
	},
	validateRequiredFields : function(component, callback){
		var fields = this.getEmptyRequiredFieldsList(component);
		var errorMessage = $A.get("$Label.c.ReviewFields") + "\n";
		var hasEmptyFields = false;
		if(!$A.util.isEmpty(fields)){

			fields.forEach(function myFunction(item, index, arr) {
				if(item.isEmpty){
					hasEmptyFields = true;
					errorMessage += " • " + item.label + "\n";
					if(item.isStandard){
						item.input.reportValidity();
					} else {
						if(item.div && !$A.util.hasClass(item.div, "has-errror")){
							$A.util.addClass(item.div, "has-errror");
						}
						if(item.error && !$A.util.hasClass(item.error, "slds-show")){
							$A.util.addClass(item.error, "slds-show");
							$A.util.removeClass(item.error, "slds-hide");
						}
					}
				} else {
					if(item.isStandard){
						item.input.reportValidity();
					} else {
						if(item.div && $A.util.hasClass(item.div, "has-errror")){
							$A.util.removeClass(item.div, "has-errror");
						}
						if(item.error && $A.util.hasClass(item.error, "slds-show")){
							$A.util.removeClass(item.error, "slds-show");
							$A.util.addClass(item.error, "slds-hide");
						}
					}
				}
			});
			if(hasEmptyFields)
				this.showToast($A.get("$Label.c.MissingRequiredFields"), errorMessage, "error");
			else
				callback();
		} else {
			callback();
		}
	},
	getEmptyRequiredFieldsList : function(component){
		var fields = [];
		var content = component.get("v.contentData");
		
		this.addField(component.get("v.bodyRequired"), fields, $A.get("$Label.c.ArticleContentDetailBody"), false, null, null, component.find("bodyError"), content.Body);

		return fields;
	},
	addField : function(isRequired, fields, label, isStandard, input, div, error, value){
		if(isRequired){
			fields.push({
				"isStandard"	: isStandard,
				"label"			: label,
				"input"			: input,
				"div"			: div,
				"error"			: error,
				"isEmpty"		:  $A.util.isEmpty(value)
			});
		}
	}
})