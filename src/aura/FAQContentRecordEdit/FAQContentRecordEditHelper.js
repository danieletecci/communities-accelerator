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
					component.set("v.contentData", 			data.content);
					
					component.set("v.visibilitySelectors", 	data.visibilitySelectors);
					component.set("v.security", 			data.security);
					if(data.content.MediaElementAssignments__r != null){
						component.set('v.imageUrl', data.content.MediaElementAssignments__r[0].MediaElement__r.FileURLDesktop__c);
                        component.set('v.mediaElementName', data.content.MediaElementAssignments__r[0].MediaElement__r.Name);
                        component.set('v.mediaElementId', data.content.MediaElementAssignments__r[0].MediaElement__r.Id);
					}
					component.find("richTextContainer").setContentBody();
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
		var previousStatus		   = content.Status__c;
		var visibilitySelectors    = component.get('v.visibilitySelectors');
		var mediaElementId 		   = component.get('v.mediaElementId');
		var action 				   = component.get('c.saveContent');        
		action.setParams({
			content : content,
			visibilitySelectorsString : JSON.stringify(visibilitySelectors),
			mediaElementId : mediaElementId,
			status : status,
			contentOldTagAssignments : content.Tags__r
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
		var recordTypeName 	= content.RecordType.Name;
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
	stringFormat: function(string) {
	    var outerArguments = arguments;
	    return string.replace(/\{(\d+)\}/g, function() {
	        return outerArguments[parseInt(arguments[1]) + 1];
	    });
	}
})