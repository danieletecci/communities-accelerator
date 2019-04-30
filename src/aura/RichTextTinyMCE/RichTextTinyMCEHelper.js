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
		/*sessionStorage.setItem('contentBody', component.get("v.contentBody"));
		var body = helper.replaceAll(encodeURI(component.get("v.contentBody")),"%0A","");
		var body = body.replace(/#/g, '%23');
        finalURL += '&contentBody=' + body;*/
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
            	}
            }
        }, false);
	},
	setContentBody : function(component, data){
		console.log("event.data: ", data);
		var contentBody = data;
		/*var contentBody = (str.indexOf("<body>") != -1) ? 
							str.substring(str.indexOf("<body>")+6, str.indexOf("</body>")) : 
							str;*/
		component.set("v.contentBody", contentBody);
		console.log("modifiedbody: ", component.get("v.contentBody"));
	},
	showImageSelector : function(component){
		component.find("medEl").initPopUp();
	}
})