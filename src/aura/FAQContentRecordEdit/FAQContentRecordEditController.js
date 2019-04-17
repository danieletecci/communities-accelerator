({
	doInit : function(component, event, helper){
		helper.setContentData(component);
	},
	handleUpsertEvent : function(component, event, helper){
		var status = event.getParam("status");
		var contentId = event.getParam("contentId");
		var recordId = component.get("v.contentData.Id");
		var content = component.get('v.contentData');
		content.PublishStartDate = event.getParam("publishStartDate");
		content.PublishEndDate = event.getParam("publishEndDate");
		component.set('v.contentData', content);
		if(recordId == contentId){
			event.stopPropagation();
			helper.updateContent(component, status);
		}
	}
})