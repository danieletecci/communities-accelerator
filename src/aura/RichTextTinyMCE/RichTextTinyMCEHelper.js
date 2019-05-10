({
	replaceAll : function(target, search, replacement) {
	    return target.split(search).join(replacement);
	},
	setIframeUrl : function(component){
		var hostname 	= window.location.hostname;
		var arr 		= hostname.split(".");
		var instance 	= arr[0];
        var namespace 	= component.get("v.namespace");
        var vHost		= 'https://' + instance + '--' + namespace + '.visualforce.com';
		var finalURL 	= vHost + '/apex/RichTextTinyMCE';
		var mainURL 	= window.location.href;
		var helper		= this;

		component.set("v.vHost", vHost);

		// Set Parent Host Name
		if(mainURL.indexOf('?') != -1){
			var parameters = mainURL.substring(mainURL.indexOf('?'));
			finalURL += parameters;
			finalURL += '&';
		}else{
			finalURL += '?';
		}
		finalURL += 'parentHostName=' + 'https://' + window.location.hostname;

		// Set Content Body
		if(!component.get("v.contentBody"))
			component.set("v.contentBody","");
		
		component.set('v.iframeUrl', finalURL);
	},
	addMessageEventListener : function(component){
        var helper		= this;

		window.addEventListener('message', function(event) {
            if (event.origin == component.get("v.vHost")){
            	var paramters = event.data;
            	switch(paramters.event){
            		case "contentchange":
            			helper.setContentBody(component, paramters.data);
            			break;
            		case "showimageselector" :
            			helper.showImageSelector(component);
            			break;
            		case "vfWindow" :
            			paramters.data.postMessage("prova", component.get("v.vHost"));
            		case "showpreview" :
            			helper.showRichTextPreview(component);
            			break;
            	}
            }
        }, false);
	},
	setContentBody : function(component, data){
		var contentBody = data;
		component.set("v.contentBody", contentBody);
	},
	showImageSelector : function(component){
		component.set("v.meHelper", !component.get("v.meHelper"));
	},
	showRichTextPreview : function(component){
		component.set("v.rtpHelper", !component.get("v.rtpHelper"));
	}
})