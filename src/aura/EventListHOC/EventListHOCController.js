({
    handleNavigateToDetail : function (component, event, helper){
        var values = JSON.parse(event.getParam("values"))
        var url;
        var parentComponentId;
        var parentComponentType = component.get("v.componentWrapper.component.RecordType.DeveloperName");
        if (parentComponentType == 'EventsRelatedHOC'){
            parentComponentId = component.get("v.parentComponentId");
        } else {
            parentComponentId = component.get("v.componentWrapper.component.ExternalId__c");
        }
        if(!values.url) {
            url = component.get("v.componentWrapper.component.LinkDetail__r.URL__c");
        } else {
            url = values.url;
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url +'?eventId=' + values.id + '&parentComponentId=' + parentComponentId
        });
        urlEvent.fire();
    }
})