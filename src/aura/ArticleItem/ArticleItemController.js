({
	handleDetail : function (component, event, helper){
        var recordId = component.get("v.contentWrapper.content.ExternalId");
        var linkDetail = component.get("v.contentWrapper.content.LinkDetailURL");
        
        var parentComponentId;
        var parentComponentType = component.get("v.componentWrapper.component.RecordType.DeveloperName");
        if (parentComponentType == 'ArticlesRelatedHOC'){
            parentComponentId = component.get("v.parentComponentId");
        } else {
            parentComponentId = component.get("v.componentWrapper.component.ExternalId");
        }

        if ( linkDetail == null){
        	linkDetail = component.get("v.componentWrapper.component.LinkDetailURL");
        }
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
			"url": linkDetail +'?ArticleId=' + recordId + '&parentComponentId=' + parentComponentId
        });
        urlEvent.fire();
    }
})