({
	init : function(component, helper, searchedString) {
		helper.getSearchDetails(component, helper, searchedString);
	},
	getComponent : function(component, helper){
		var componentExternalId = component.get("v.componentExtId");
		if(componentExternalId){
			var action = component.get("c.getComponent");

			action.setParams({
				externalId: componentExternalId
			});

			action.setCallback(this, function(response) {
		        if(response.getState() === "SUCCESS") {
		           	var componentRecord = response.getReturnValue();
					component.set("v.component", componentRecord);
		           	if(componentRecord.SearchPlaceholder)
		           		helper.setPlaceholder(component, componentRecord.SearchPlaceholder);
			    }
			});
			    
			$A.enqueueAction(action);
		}
	},
	getSearchDetails: function(component, helper, searchedString){
		var componentExternalId = component.get("v.componentExtId");
		if(componentExternalId){
			var action = component.get("c.getSearchDetails");

			action.setParams({
				externalId: componentExternalId
			});

			action.setCallback(this, function(response) {
		        if(response.getState() === "SUCCESS") {
		           	var searchDetailsWrapper = response.getReturnValue();
		           	component.set("v.component", searchDetailsWrapper.component);
		           	component.set("v.searchDetails", searchDetailsWrapper.searchDetails);
		           	if(searchDetailsWrapper.component.SearchPlaceholder)
		           		helper.setPlaceholder(component, searchDetailsWrapper.component.SearchPlaceholder);
		           	if(searchedString){
		           		helper.setValue(component, searchedString);
		           		helper.getSearchResults(component, searchedString);
		           	}
			    }
			});
			    
			$A.enqueueAction(action);
		}
	},
	manageSearchResults : function(component, helper, event, searchedString){
		var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            helper.getSearchResults(component, searchedString);
        }
	},
	getSearchResults: function (component, searchedString) {
       	if(!component.get("v.component").LinkDetail || this.isSearchPage(component)){
            var appEvent 	= $A.get("e.c:SearchSettingFindEvent");
		    appEvent.setParams({
				"searchedString"	: searchedString,
    			"searchDetails" 	: component.get("v.searchDetails"),
				"component" 		: component.get("v.component")
		    });
		    appEvent.fire();
        } else {
        	var urlEvent = $A.get("e.force:navigateToURL");
		    urlEvent.setParams({
		      	"url": "/" + component.get("v.component").LinkDetailURL + "?q=" + encodeURI(searchedString)
		    });
		    urlEvent.fire();
        }
    },
    managePredictiveResults : function(component, helper, searchString){
    	if(component.get("v.component").PredictiveSearchEnabled){
			component.set("v.searchLength", searchString.length);
			if(searchString.length > 1){
				helper.getPredictiveResults(component, searchString);
			}
		}
    },
	getPredictiveResults: function (component, searchedString) {
		component.set("v.isLoading", true);
		var helper = this;
       	var action = component.get("c.getPredictiveResults");
        action.setParams({
            searchedString  : searchedString,
            searchDetails   : component.get("v.searchDetails")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
            	var results = action.getReturnValue();
            	component.set("v.recordsNumber", 0);
				component.set("v.predictiveResults", results);
				component.set("v.isLoading", false);
				helper.setRecordNumber(component, results);
            }
        });
        $A.enqueueAction(action);
    },
    setPlaceholder : function (component, customLabelName) {
    	component.set('v.placeholder', $A.get("$Label.c." + customLabelName));
    	//component.find("search-input-2").set("v.placeholder", $A.get("$Label.c." + customLabelName));
    },
    setValue : function (component, searchedString) {
		component.set("v.inputValue", searchedString);
        $A.util.removeClass(component.find('cancel-button'), 'slds-hide');
    },
    getUrlParameter : function (sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    getCurrentPageName : function(){
    	var path = window.location.pathname;
		var page = path.split("/").pop();
		return page;
    },
    isSearchPage : function(component){
    	return (component.get("v.component").LinkDetail && component.get("v.component").LinkDetailURL == this.getCurrentPageName());
    },
    isNotSearchPage : function(component){
    	return (component.get("v.component").LinkDetail && component.get("v.component").LinkDetailURL != this.getCurrentPageName());
    },
    setRecordNumber : function(component, results){
    	var recordsNumber = 0;
    	for(var i=0; i<results.length; i++){
    		recordsNumber += results[i].records.length;
    	}
    	if(recordsNumber == 0)
    		this.hidePredictiveResults(component);
    	else
    		this.showPredictiveResults(component);
    },
    showPredictiveResults : function(component){
		$A.util.removeClass(component.find('predictiveSearchContainer'), 'slds-hide');
    },
    hidePredictiveResults : function(component){
		$A.util.addClass(component.find('predictiveSearchContainer'), 'slds-hide');
    },
    removeAutocomplete : function(){
    	var input = document.getElementById("search-input-2");
	    if(input.getAttribute("autocomplete") !== "off"){
	        input.setAttribute("autocomplete","off");
	    }
    },
    manageCancelButton : function(component, searchedString){
    	if (searchedString.length > 0) {
            $A.util.removeClass(component.find('cancel-button'), 'slds-hide');
        } else {
            $A.util.addClass(component.find('cancel-button'), 'slds-hide');
        }
    },
    clearPredictiveResults : function(component, helper){
    	document.getElementById('search-input-2').value = '';
    	helper.hidePredictiveResults(component);
    	helper.manageCancelButton(component, "");
    	component.set("v.predictiveResults", []);
    }
})