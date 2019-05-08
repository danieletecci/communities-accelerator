({
	getComponentWrapper : function(component, helper) {
		var cw = component.get("v.componentWrapper");
		var componentType = component.get("v.componentType");
		var componentExternalId = component.get("v.componentExternalId");
        var device = $A.get("$Browser.formFactor");
        var parentComponentId = helper.getUrlParameter('parentComponentId');
        parentComponentId = parentComponentId === undefined ? '' : parentComponentId;

        var parentContentId = '';
        var ArticleId = helper.getUrlParameter('ArticleId');
        var eventId = helper.getUrlParameter('eventId');
        if( !(ArticleId === undefined) ){parentContentId = ArticleId;}
        if( !(eventId === undefined) ){parentContentId = eventId;}

        component.set("v.parentComponentId", parentComponentId);
       	component.set("v.parentContentId", parentContentId);

		if(cw == null){
	        component.set("v.isLoading", true);

	        if(component.get("v.isLivePreview")){
	    		component.set("v.showComponentEmpty", true);
	    	}

	    	var clusterCookie = helper.getCookie("CG_clusterId");

	        if( !(componentExternalId === '') && !(componentType === '') ){
				var action = component.get("c.getComponentWrapper");
				action.setParams({
					componentExternalId: componentExternalId,
		            componentType: componentType,
		            parentComponentId: parentComponentId,
		            parentContentId: parentContentId,
		            clusterId: clusterCookie,
					device: device
				}); 

			    action.setCallback(this, function(f) {
		            if(f.getState() === "SUCCESS") {
						var cWrapper = action.getReturnValue();
						var recordType = cWrapper.component.RecordTypeDeveloperName;
						if(recordType === 'EventDetail' || recordType === 'ArticleDetail'){
							var details = {};
							details.type = recordType === 'EventDetail' ? 'Event' : 'Article';
							if(cWrapper.contentWrapper.length > 0){
								var content = cWrapper.contentWrapper[0].content;
								if(details.type === 'Article') {
									details.date = content.PublishStartDate;
								} else {
									details.startDate = content.EventStartDate;  
									details.endDate = content.EventEndDate;
								}
								details.location = {};
								details.location.name = content.Location;
								details.location.href = 'https://www.google.com/maps/search/' + content.Location;
								details.title = content.Title;
								details.extract = content.Extract;
								details.imgSrc = cWrapper.contentWrapper[0].mediaElements[0].FileURLDesktop;
								details.body = content.Body;
								details.layout = content.Layout;
							}
							cWrapper.details = details;
						}
	                    
		            	component.set("v.componentWrapper", cWrapper);
		                
		                if( !(cWrapper.component == null) ){
		                	component.set("v.showComponentEmpty", false);
		                }

		                if(clusterCookie == undefined || clusterCookie == ''){
		                	helper.setCookie('CG_clusterId', cWrapper.clusterId, 100);
		                }
		                
		                //Loading
		                component.set("v.isLoading", false);
			        }
			    });
			    $A.enqueueAction(action);
		    }
	    }else{
	    	component.set("v.isLoading", false);
	    }
	},
	goPage : function(component, pageNumber){
		var quantPages = component.get("v.componentWrapper.pagesNumbers")[component.get("v.componentWrapper.pagesNumbers").length-1];
        if(quantPages >= pageNumber && pageNumber > 0 && component.get('v.currentPageNumber') != pageNumber){
			component.set("v.isLoading", true);

			var componentWrapper = component.get("v.componentWrapper");
			var device = $A.get("$Browser.formFactor");
			var orderBy = componentWrapper.component.OrderBy == 'Custom Sorting' ? componentWrapper.component.OrderByAdvance : componentWrapper.component.OrderBy;

			var action = component.get("c.getPage");
			action.setParams({
				listAllContentIds: componentWrapper.listAllContentIds,
				componentType: componentWrapper.component.RecordTypeDeveloperName,
				pageSize: String(componentWrapper.component.PageSize),
				pageNumber: String(pageNumber),
				orderBy: orderBy,
				device: device
			});

		    action.setCallback(this, function(f) {
				if(f.getState() === "SUCCESS") {
					component.set("v.componentWrapper.contentWrapper", action.getReturnValue());
	            	component.set('v.currentPageNumber', pageNumber);
	                component.set("v.isLoading", false);
		        }
		    });
		    $A.enqueueAction(action);
		}
    },
    // the function that reads the url parameters
    getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), sParameterName, i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    getCookie : function(cname){
    	var name = cname + "=";
	    var decodedCookie = decodeURIComponent(document.cookie);
	    var ca = decodedCookie.split(';');
	    for(var i = 0; i <ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
    },
    setCookie : function(cname, cvalue, exdays) {
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+ d.toUTCString();
	    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	}
})