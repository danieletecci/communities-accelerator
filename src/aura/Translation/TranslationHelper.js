({
	getLanguages : function(component) {
		component.set("v.isLoading", true);

		var action = component.get("c.getLanguages");
		action.setParams({
			parentLookupName: component.get("v.parentLookupName"),
			fieldSet: component.get("v.fieldSet"),
			recordId: component.get("v.recordId")
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordsWrapper", action.getReturnValue());
            	component.set("v.isLoading", false); 
	        }
	    });
	    $A.enqueueAction(action);
	},
	changeLanguage : function(component) {
		component.set("v.isLoading", true);

		var action = component.get("c.changeLanguage");
		action.setParams({
			parentLookupName: component.get("v.parentLookupName"),
			language: component.find("langSelect").get("v.value"),
			recordId: component.get("v.recordId"),
			recordsWr: JSON.stringify(component.get("v.recordsWrapper"))
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordsWrapper", action.getReturnValue());
            	component.set("v.isLoading", false); 
	        }
	    });
	    $A.enqueueAction(action);
	},
	saveTranslation : function(component) {
		component.set("v.isLoading", true);

		var action = component.get("c.saveTranslation");
		action.setParams({
			parentLookupName: component.get("v.parentLookupName"),
			recordId: component.get("v.recordId"),
			recordsWr: JSON.stringify(component.get("v.recordsWrapper"))
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	var showToast = $A.get('e.force:showToast');
            	component.set("v.recordsWrapper", action.getReturnValue());
            	component.set("v.isLoading", false);

            	if(component.get("v.recordsWrapper.response") == 'OK'){
					showToast.setParams({
						'title'   : $A.get("$Label.c.General_Success"),
						'message' : $A.get("$Label.c.General_RecordsSavedSuccessfully"),
						'type'    : 'success'
					});
				}else{
					showToast.setParams({
						'title'   : $A.get("$Label.c.General_Error"),
						'message' : action.getReturnValue(),
						'type'    : 'error'
					});
				}
				//component.set("v.isLoading", false);

				showToast.fire();
            	 
	        }
	    });
	    $A.enqueueAction(action);
	}
})