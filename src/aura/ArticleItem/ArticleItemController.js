({
	handleDetail : function (component, event, helper){
        var recordId = component.get("v.contentWrapper.content.ExternalId__c");
        var linkDetail = component.get("v.contentWrapper.content.LinkDetail__r.URL__c");
        
        var parentComponentId;
        var parentComponentType = component.get("v.componentWrapper.component.RecordType.DeveloperName");
        if (parentComponentType == 'ArticlesRelatedHOC'){
            parentComponentId = component.get("v.parentComponentId");
        } else {
            parentComponentId = component.get("v.componentWrapper.component.ExternalId__c");
        }

        if ( linkDetail == null){
        	linkDetail = component.get("v.componentWrapper.component.LinkDetail__r.URL__c");
        }
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
			"url": linkDetail +'?ArticleId=' + recordId + '&parentComponentId=' + parentComponentId
        });
        urlEvent.fire();
    }
})