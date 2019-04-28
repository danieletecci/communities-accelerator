({
	doInit : function(component, event, helper) {
		component.set('v.isLivePreview', String(window.location.href).includes('livepreview.') || String(window.location.href).includes('sitestudio.'));
		helper.getComponentWrapper(component, helper);
	},
	doNext : function (component, event, helper){
        helper.goPage(component, component.get('v.currentPageNumber') + 1);
    },
    doPrevious : function (component, event, helper){
		helper.goPage(component, component.get('v.currentPageNumber') - 1);
    },
    doGetPage : function(component, event, helper){       
		helper.goPage(component, event.getParam("numberofpage"));
    }
})