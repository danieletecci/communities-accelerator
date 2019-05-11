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
					component.set("v.prefix", 				data.prefix);
					component.set("v.contentData", 			data.content);
					component.set("v.timeZone", 			data.timeZone);
					component.set("v.visibilitySelectors", 	data.visibilitySelectors);
					component.set("v.hasEditAccess", 		data.hasEditAccess);
					component.set("v.bannerFrameTypes",		data.bannerFrameTypes);

                    var frameType = component.get("v.contentData.BannerFrameType");
                    if(!frameType){
						component.set("v.contentData.BannerFrameType", data.bannerFrameTypes[0]);                        
                    }

                    if(data.content.MediaElementAssignments != null && data.content.MediaElementAssignments.length > 0){
						component.set('v.imageUrl', data.content.MediaElementAssignments[0].MediaElement.FileURLDesktop);
                        component.set('v.mediaElementName', data.content.MediaElementAssignments[0].MediaElement.Name);
                        component.set('v.mediaElementId', data.content.MediaElementAssignments[0].MediaElement.Id);
					}
                    helper.setLayoutOptions(component);

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
    setLayoutOptions : function(component) {
		var layoutOptions = [
			{value:"Middle-Left", imageUrl:"/ContentLayouts/Banner-OverlayQuadrant/Middle-Left.png", label:$A.get("$Label.c.BannerContentDetailLeftAlign")},
			{value:"Middle-Center", imageUrl:"/ContentLayouts/Banner-OverlayQuadrant/Middle-Center.png", label:$A.get("$Label.c.BannerContentDetailMiddleAlign")},
			{value:"Middle-Right", imageUrl:"/ContentLayouts/Banner-OverlayQuadrant/Middle-Right.png", label:$A.get("$Label.c.BannerContentDetailRightAlign")}
		];
		component.set('v.layoutOptions', layoutOptions);
		component.set('v.contentData.OverlayQuadrant', component.get('v.contentData.OverlayQuadrant') == null ? 'Middle-Left' : component.get('v.contentData.OverlayQuadrant')); 
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
	unassignFeatureImg: function(component, event, helper){
		component.set('v.mediaElementId', null);
		component.set('v.imageUrl', null);
		component.set('v.mediaElementName', null);
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
		
		this.addField(component.get("v.featureRequired"), fields, $A.get("$Label.c.ArticleContentDetailImage"), false, null, component.find("featureDiv"), component.find("featureError"), component.get("v.imageUrl"));
		this.addField(component.get("v.titleRequired"), fields, $A.get("$Label.c.ArticleContentDetailTitle"), true, component.find("title"), null, null, content.Title);
		this.addField(component.get("v.extractRequired"), fields, $A.get("$Label.c.ArticleContentDetailExtract"), true, component.find("extract"), null, null, content.Extract);
		this.addField(component.get("v.buttonRequired"), fields, $A.get("$Label.c.BannerContentDetailButton"), true, component.find("buttonLabel"), null, null, content.ButtonLabel);
		this.addField(component.get("v.linkRequired"), fields, $A.get("$Label.c.BannerContentDetailLink"), true, component.find("linkDetail"), null, null, content.LinkDetail);
		this.addField(component.get("v.layoutRequired"), fields, $A.get("$Label.c.BannerContentDetailLayout"), false, null, component.find("layoutDiv"), component.find("layoutError"), content.OverlayQuadrant);

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
