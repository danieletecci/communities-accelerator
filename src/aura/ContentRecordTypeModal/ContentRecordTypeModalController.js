({
	onInit : function(component, event, helper) {
        helper.getObjectLabel(component, component.get("v.sObjectName"));
        helper.getRecordTypes(component, component.get("v.sObjectName"), component.get("v.rtDevNameList"));
	},
	onShow : function(component, event, helper) {
	    helper.openModal(component);
	},
    onHide : function(component, event, helper) {
	    helper.closeModal(component);
	},
    onNewRecord : function(component, event, helper) {
	    helper.goToNewRecord(component);
	    helper.closeModal(component);
	},
	optionSelected : function(component,event,helper){
        var recordTypeId = event.target.getAttribute("value");
        component.set("v.value", recordTypeId);
    }
})