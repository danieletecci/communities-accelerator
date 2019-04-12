({
	doInit: function (component, event, helper) {
        helper.getData(component);
    },
    afterMomentLoaded: function(component, event, helper){
        helper.setTooltips(component);
    },
    doSave: function (component, event, helper) {
        helper.updateContent(
            component, 
            component.get("v.contentData").Status__c, 
            component.get("v.contentData").PublishStartDate__c,
            component.get("v.contentData").PublishEndDate__c
        );
    },
    doPublishContent: function (component, event, helper) {
        component.find("contentModalPublish").show();
    },
    doCreateFromTemplate: function (component, event, helper) {
        helper.createFromTemplate(component);
    },
    onKeyUp: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;
        var isEscapeKey = event.keyCode === 27;
        var newName = component.find("name-input").get("v.value");
        if(isEnterKey){
            helper.setName(component, newName);
        }
        if(isEscapeKey){
            component.set("v.isNameEdit", false);
        }
    },
    editName: function (component, event, helper) {
        component.set("v.temporaryName", component.get("v.contentData").Name);
        component.set("v.isNameEdit", true);
        setTimeout(function(){
            var nameinput = component.find("name-input");
            nameinput.focus();
        }, 0);
    },
    doUnarchive: function(component, event, helper){
        helper.updateContent(component, "Draft", null, null);
    },
    doDelete: function(component, event, helper){
        helper.deleteContent(component);
    },
    doHideConfirmation: function(component, event, helper){
        var confrimationModal = component.get("v.confirmationModal");
        confirmationModal.hide();
        confirmationModal.destroy();
    },
    handleMenuSelect: function(component, event, helper){
        switch(event.getParam("value")){
            case "delete":
                helper.showConfirmationDelete(component);
                break;
            case "unpublish":
                helper.updateContent(component, "Draft", null, null);
                break;
            case "archive":
                helper.updateContent(component, "Archived", null, null);
                break;
            case "unschedule":
                helper.updateContent(component, "Draft", null, null);
                break;
        }
    },
    getScheduleMessage: function(component, event, helper){
        return "schedule";
    },
    getPublishMessage: function(component, event, helper){
        return "publish";
    },
    showTooltip: function(component, event, helper){
        if(component.get("v.scheduledTooltip") || component.get("v.publishedTooltip"))
            component.set("v.tooltipClass", "slds-rise-from-ground")
    },
    hideTooltip: function(component, event, helper){
        component.set("v.tooltipClass", "slds-fall-into-ground")
    }
})