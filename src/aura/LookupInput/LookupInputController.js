({
    doInit: function(component, event, helper) {
        // call the apex class method 
        var action = component.get("c.getInitialValue");
        // set param to method  
        action.setParams({
            'recordId': component.get('v.selectedRecordId'),
            'ObjectName': component.get("v.objectAPIName")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //set the initial value
                if (response.getReturnValue()) {
                    component.set("v.selectedRecord", response.getReturnValue());

                    var forclose = component.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');

                    var lookUpTarget = component.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');
                }

            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);

    },
    doReportValidity: function(component, event, helper) {
		var inputCmp = component.find("inputLookup");
		var divError = component.find("divError");
		if($A.util.isEmpty(component.get("v.selectedRecordId")) && component.get("v.isRequired")){
			if(!$A.util.hasClass(inputCmp, "has-errror"))
				$A.util.addClass(inputCmp, "has-errror");
			if(!$A.util.hasClass(divError, "slds-show")){
				$A.util.addClass(divError, "slds-show");
				$A.util.removeClass(divError, "slds-hide");
			}
		} else {
			if($A.util.hasClass(inputCmp, "has-errror"))
				$A.util.removeClass(inputCmp, "has-errror");
			if($A.util.hasClass(divError, "slds-show")){
				$A.util.removeClass(divError, "slds-show");
				$A.util.addClass(divError, "slds-hide");
			}
		}
    },
    doCheckValidity: function(component, event, helper) {
		return ((!$A.util.isEmpty(component.get("v.selectedRecordId")) && component.get("v.isRequired")) || !component.get("v.isRequired"));
    },
    onfocus: function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component, event, getInputkeyWord);
    },
    onblur: function(component, event, helper) {
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController: function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if (getInputkeyWord.length > 0) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        } else {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction 
    clear: function(component, event, heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord", null);
        component.set("v.listOfSearchRecords", null);
        component.set("v.selectedRecord", {});
        component.set("v.selectedRecordId", null);
    },

    // This function call when the end User Select any record from the result list.   
    handleComponentEvent: function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord", selectedAccountGetFromEvent);
        component.set("v.selectedRecordId", selectedAccountGetFromEvent.Id);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

    },
})