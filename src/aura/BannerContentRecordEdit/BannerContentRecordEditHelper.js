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
					component.set("v.timeZone", 			data.timeZone);
					component.set("v.visibilitySelectors", 	data.visibilitySelectors);
					component.set("v.security", 			data.security);
					component.set("v.bannerFrameTypes",		data.bannerFrameTypes);

                    var frameType = component.get("v.contentData.BannerFrameType");
                    if(!frameType){
						component.set("v.contentData.BannerFrameType",data.bannerFrameTypes[0]);                        
                    }

                    if(data.content.MediaElementAssignments != null){
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
			status : status,
			contentOldTagAssignments : content.Tags
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
	}

	
})
