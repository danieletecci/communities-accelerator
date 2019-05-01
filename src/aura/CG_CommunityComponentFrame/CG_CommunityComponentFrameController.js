({
	doInit : function(component, event, helper) {
		helper.initContent(component, event, helper);
		var urlArr = window.location.pathname.split("/s/");
        var url = (urlArr.length > 1 && urlArr[1] != "") ? urlArr[1] : "/s/";
        component.set("v.navigationURL", url);
	},
	doViewComponent : function(component, event, helper) {
		helper.viewComponent(component, event, helper);
	},
	doViewContent : function(component, event, helper) {
		helper.viewContent(component, event, helper);
	},
	doNewContent : function(component, event, helper){
		//helper.newContent(component, event, helper);
		component.find("newContentModal").show();		
	},
	doShowEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, true);
	},
	doHideEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, false);
	},
	doGoToContent : function(component, event, helper){
		var recordId = event.getParam('recordId');
		helper.newContent(component, recordId);
	}
})