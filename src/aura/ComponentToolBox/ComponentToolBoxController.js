({
    doInit : function(component, event, helper) {
        var showComponentFrame = component.get('v.showComponentFrame');
        
        if(showComponentFrame){
            if(String(window.location.href).includes('livepreview.') || String(window.location.href).includes('sitestudio.')){
                component.set('v.showComponentFrame', false);
            }
        }
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
	doShowEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, true);
	},
	doHideEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, false);
	},
	doHideNamePanel : function(component, event, helper){
		helper.showHideNamePanel(component, event, false);
	},
	doShowNamePanel : function(component, event, helper){
		helper.showHideNamePanel(component, event, true);
	},
	doNewContent : function(component, event, helper){
		component.find("newContentModal").show();
	},
	doGoToContent : function(component, event, helper){
		var recordId = event.getParam('recordId') 
		helper.newContent(component, recordId);
	}
})