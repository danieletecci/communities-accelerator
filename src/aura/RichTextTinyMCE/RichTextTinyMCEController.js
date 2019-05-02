({
	doInit : function(component, event, helper) {
		helper.setIframeUrl(component);
		helper.addMessageEventListener(component);
	},
	handleURLEvent : function(component, event, helper) {
		var URL = event.getParam("URL");
        var ID = event.getParam("ID");
		component.find('KB_iframe').getElement().contentWindow.postMessage({
																				event : "insertimage",
																				data : URL
																			}, 
																			component.get("v.vHost"));
        event.stopPropagation();
	},
	handleContentChange : function(component, event, helper){
		component.find('KB_iframe').getElement().contentWindow.postMessage({
																				event : "contentchange",
																				data : component.get("v.contentBody")
																			}, 
																			component.get("v.vHost"));
	},
	handleIframeLoad : function(component, event, helper){
		component.find('KB_iframe').getElement().contentWindow.postMessage({
																				event : "contentchange",
																				data : component.get("v.contentBody"),
																			}, 
																			component.get("v.vHost"));

	},
	itemsChange: function(component, event) {
		component.find("medEl").initPopUp();
    }
})