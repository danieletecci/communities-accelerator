({
	initSearch : function(component, event, helper){
        component.set("v.searchValue", '');
        component.find("searchField").set("v.value", '');
        component.set("v.offset", '0');
		component.set("v.mediaElementList", '');
		//document.body.style.overflowY = "hidden";
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.addClass(cmpBack, 'slds-backdrop--open');
        helper.searchByText(component, event, helper);
    },
	searchByText : function(component, event, helper) {
		component.set('v.scrollCalled', true);
		component.set("v.isEndPage", false);
		component.set("v.offset", 0);
		component.set("v.searchValue", component.find("searchField").get("v.value"));
		component.set("v.mediaElementList", '');
		helper.getMedElems(component);
	},
	selectMediaElement : function(component, event, helper) {
        var mElementUrl;
		var mElementId;
		var mElementName;
		var compEvents;
		
		var childElements = Array.from(event.currentTarget.children);

        childElements.forEach(element => {
            if(element.tagName === "IMG" && element.classList.contains("img_mediaElementReview")){
				mElementUrl = element.getAttribute("src"), 
				mElementId = element.getAttribute("id");
				mElementName = element.dataset.name;
				compEvents = component.getEvent("URLEvent");
				compEvents.setParams({ 
					"URL" 	: mElementUrl,
					"ID" 	:  mElementId,
					"NAME" 	: mElementName
				});
				compEvents.fire();
				helper.closeModal(component, event, helper);
            }
        });

    },
	getMedElems: function( component ) {
		//component.set("v.isLoading", true);
		var searchtext = component.get("v.searchValue");
		var elementPerPage = component.get("v.elementPerPage");
		var action = component.get("c.getData");

		action.setParams({
			stringOffset: component.get("v.offset").toString(),
			searchText: searchtext,
			stringElementPerPage: elementPerPage.toString(),
			findContent: 'true'
		});

		action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
				if(action.getReturnValue() == ''){
					component.set("v.isEndPage", true);
				} else{
		        	if(component.get("v.mediaElementList") != ''){
		            	var medElemList = component.get("v.mediaElementList");
		            	var returnList = action.getReturnValue();

		            	returnList.forEach(function(ACC) {
							medElemList.push(ACC);
						});
						component.set("v.mediaElementList", medElemList);
		        	} else {
		        		component.set("v.mediaElementList", action.getReturnValue());
		        	}
				}
            	//component.set("v.isLoading", false);
            	component.set("v.offset", component.get("v.offset")+elementPerPage);

            	//Added to use the scroll once time
            	component.set('v.scrollCalled', false);
	        }
	    });

	    $A.enqueueAction(action);
	},
	closeModal : function(component, event, helper){	
		document.body.style.overflowY = "auto";	
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	},
    doSearch: function(component, event, helper) {
        if (event.which === 13 || event.keyCode === 13) {
            helper.searchByText(component, event, helper);
        }
    },
	getMoreRecords: function(component, event, helper) {
        var elem = event.currentTarget;
        if (component.isValid() && !component.get('v.scrollCalled')) {
            if (elem.clientHeight + elem.scrollTop + 1 >= elem.scrollHeight) {
                //Call your helper method to show more items
                helper.getMedElems(component);
                component.set('v.scrollCalled', true);
            }
        }
    }
})