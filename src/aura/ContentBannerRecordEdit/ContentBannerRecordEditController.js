({	
	doInit : function(component, event, helper){
		helper.setContentData(component);
	},
	handleUpsertEvent : function(component, event, helper){
		var status = event.getParam("status");
		var contentId = event.getParam("contentId");
		var recordId = component.get("v.contentData.Id");
		var content = component.get('v.contentData');
		content.PublishStartDate__c = event.getParam("publishStartDate");
		content.PublishEndDate__c = event.getParam("publishEndDate");
		component.set('v.contentData', content);
		if(recordId == contentId){
			event.stopPropagation();
			helper.updateContent(component, status);
		}
	},
	handleMediaElementEvent : function(component, event, helper){
		var mediaElementId = event.getParam("ID");
		var imageUrl = event.getParam("URL");
		var mediaElementName = event.getParam("NAME");
		component.set('v.mediaElementId', mediaElementId);
		component.set('v.imageUrl', imageUrl);
		component.set('v.mediaElementName', mediaElementName);
	},
	unassignFeatureImg: function(component, event, helper){
		helper.unassignFeatureImg(component, event, helper);
	}

})