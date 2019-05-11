({
	doInit : function(component, event, helper){
		helper.setContentData(component);
	},
	handleUpsertEvent : function(component, event, helper){
		var status = event.getParam("status");
		var contentId = event.getParam("contentId");
		var recordId = component.get("v.contentData.Id");
		if(recordId == contentId){
			component.set("v.contentData.PublishStartDate", event.getParam("publishStartDate"));		
	        component.set("v.contentData.PublishEndDate", event.getParam("publishEndDate"));
			event.stopPropagation();
			if(status == $A.get("$Label.c.ContentDetailScheduled") || status == $A.get("$Label.c.ContentDetailPublished")){
				helper.validateRequiredFields(component, function(){
					helper.updateContent(component, status);
				});
			} else {
				helper.updateContent(component, status);
			}
		}
	}
})