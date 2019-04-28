({
	doInit : function(component, event, helper) {
		helper.getComponentWrapper(component, helper);
	},
    handleNavigateToDetail : function (component, event, helper){
        var values = JSON.parse(event.getParam("values"))
        var url;
        
        if(!values.url) {
            url = component.get("v.componentWrapper.meta.component.LinkDetailURL");
        } else {
            url = values.url;
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
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