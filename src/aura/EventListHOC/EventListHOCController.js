({
    handleNavigateToDetail : function (component, event, helper){
        var values = JSON.parse(event.getParam("values"))
        var url;
        var parentComponentId;
        var parentComponentType = component.get("v.componentWrapper.component.RecordTypeDeveloperName");
        if (parentComponentType == 'EventsRelatedHOC'){
            parentComponentId = component.get("v.parentComponentId");
        } else {
            parentComponentId = component.get("v.componentWrapper.component.ExternalId");
        }

        if(!values.url) {
            url = component.get("v.componentWrapper.component.LinkDetailURL");
            if(component.get("v.componentWrapper.component.LinkDetailType") === 'Detail'){
                url += '/' + values.sfid;
            }
        } else {
            url = values.url;
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url + '?eventId=' + values.id + '&parentComponentId=' + parentComponentId
        });
        urlEvent.fire();
    }
})