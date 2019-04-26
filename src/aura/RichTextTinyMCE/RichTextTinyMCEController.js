({
	doInit : function(component, event, helper) {
		var hostname = window.location.hostname;
		var arr = hostname.split(".");
		var instance = arr[0];
        var namespace = component.get("v.namespace");

		var finalURL = 'https://' + instance + '--' + namespace + '.visualforce.com/apex/RichTextTinyMCE';
		
		//Set iframe URL
		var mainURL = window.location.href;
		if(mainURL.indexOf('?') != -1){
			var parameters = mainURL.substring(mainURL.indexOf('?'));
			finalURL += parameters;
			finalURL += '&';
		}else{
			finalURL += '?';
		}
		finalURL += 'parentHostName=' + 'https://' + window.location.hostname;
		if(!component.get("v.contentBody"))
			component.set("v.contentBody","");
		var body = helper.replaceAll(encodeURI(component.get("v.contentBody")),"%0A","");
		var body = body.replace(/#/g, '%23');

        finalURL += '&contentBody=' + body;
		
		component.set('v.iframeUrl', finalURL);
        
		window.addEventListener('message', function(event) {
            if (event.origin == 'https://' + instance + '--' + namespace + '.visualforce.com'){
            	if(event.data=='scrollUp'){
            		document.documentElement.scrollTop = 0;
            	}else{
            		var str = event.data;
            		var contentBody = str.substring(str.indexOf("<body>")+6, str.indexOf("</body>"));
            		component.set("v.contentBody", contentBody);
            		console.log("modifiedbody: ", component.get("v.contentBody"));
            	}
            }
        }, false);

	}
})