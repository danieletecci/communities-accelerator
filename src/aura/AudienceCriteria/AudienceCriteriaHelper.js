({
    getCriteria : function(component, event, helper) {
		component.set("v.isLoading", true);
		
		var action = component.get("c.getCriteria");
		action.setParams({
			audienceId: component.get("v.recordId")
		});

	    action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
				var audienceWrapper = JSON.parse(action.getReturnValue());
				component.set("v.audienceWrapper", audienceWrapper);
				component.set("v.isLoading", false);
	        }
	    });	   
	    $A.enqueueAction(action);
	},

	saveCriteria : function(component, event, helper) {
		component.set("v.isLoading", true);
		var audienceWrapper = component.get("v.audienceWrapper");

		for(var i=0; i<audienceWrapper.criteria.length; i++){
			if(audienceWrapper.criteria[i].field != undefined && audienceWrapper.criteria[i].field != ''){
				var order = audienceWrapper.criteria[i].order;

				//Set field
				var fieldPicklist = document.getElementById('field-' + order);
				var fieldPicklistValue = fieldPicklist.options[fieldPicklist.selectedIndex].value;
				audienceWrapper.criteria[i].field = fieldPicklistValue;

				//Set operator
				var operatorPicklist = document.getElementById('operator-' + order);
				var operatorPicklistValue = operatorPicklist.options[operatorPicklist.selectedIndex].value;
				audienceWrapper.criteria[i].operator = operatorPicklistValue;

				//Set value
				if(audienceWrapper.criteria[i].valueType == 'Picklist'){
					var valuePicklist = document.getElementById('valuePicklist-' + order);
					audienceWrapper.criteria[i].value = valuePicklist.options[valuePicklist.selectedIndex].value;
				}
				if(audienceWrapper.criteria[i].valueType == 'Checkbox'){
					audienceWrapper.criteria[i].value = document.getElementById('valueCheckbox-' + order).checked;
				}
			}
		}

		var action = component.get("c.saveCriteria");
		action.setParams({
			audienceId: audienceWrapper.audienceId,
			matchCriteria: audienceWrapper.matchCriteria,
			audienceCriteria: audienceWrapper.audienceCriteria,
			criteriaWrapper: JSON.stringify(audienceWrapper.criteria)
		});

	    action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.getCriteria(component, event, helper);
				helper.showToast($A.get("$Label.c.General_Success"), $A.get("$Label.c.General_RecordsSavedSuccessfully"), 'success');
				
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = $A.get("$Label.c.General_Error");
				if (errors && Array.isArray(errors) && errors.length > 0) {
					message = errors[0].message;
				}
				helper.showToast('Error', message, 'error');
				component.set("v.isLoading", false);
			}
	    });
		$A.enqueueAction(action);
	},
	
	changeField : function(component, event, helper) {
		var e = document.getElementById(event.currentTarget.id);
		var lineOrder = event.currentTarget.id.split('-')[1];
		var selectedValue = e.options[e.selectedIndex].value;

		var criteria = component.get("v.audienceWrapper.criteria");
		var fields = component.get("v.audienceWrapper.fields");

		var criterion;
		//Looking for the criterion
		for(var i=0; i<criteria.length; i++){
			if(criteria[i].order == lineOrder){
				criterion = criteria[i];
			}
		}

		criterion.field = selectedValue;
		criterion.valueType = '';
		for(var i=0; i<fields.length; i++){
			if(selectedValue == fields[i].fieldPath){
				criterion.operator = '';
				criterion.valueType = fields[i].fieldType;
				if(criterion.valueType == 'Checkbox'){
					criterion.value = false;
				}else{
					criterion.value = undefined;
				}
			}
		}

		//Set changes on criterion
		for(var i=0; i<criteria.length; i++){
			if(criteria[i].order == lineOrder){
				criteria[i] = criterion;
			}
		}
		component.set("v.audienceWrapper.criteria", criteria);
    },
    
    addCriterion : function(component, event, helper) {
		var criteria = component.get("v.audienceWrapper.criteria");
		
		if(criteria.length < 10){
			var criterion = new Object();
			if(criteria.length == 0){
				criterion.order = 1;
			}else{
				criterion.order = criteria[criteria.length-1].order + 1;
			}
			criterion.mainObjectType = '';
			criterion.field = '';
			criterion.operator = '';
			criterion.valueType = '';
			criterion.value = '';
			criteria.push(criterion);

			component.set("v.audienceWrapper.criteria", criteria);
		}
    },
	
	removeCriterion : function(component, event, helper) {
		var lineOrder = event.getSource().get("v.name");
		var criteria = component.get("v.audienceWrapper.criteria");
		for(var i=0; i<criteria.length; i++){
			if(criteria[i].order == lineOrder){
				criteria.splice(i, 1);
			}
		}
		for(var i=0; i<criteria.length; i++){
			criteria[i].order = i+1;
		}
		component.set("v.audienceWrapper.criteria", criteria);
    },

	changeMatchCriteria : function(component, event, helper) {
		var buttonName = event.getSource().get("v.name");
		var audienceWrapper = component.set("v.audienceWrapper.matchCriteria", buttonName);
	},
	
    showToast : function(toastTitle,toastMessage,toastType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: toastTitle,
            message: toastMessage,
            type: toastTitle,
            mode: (toastType === "success") ? 'dismissable' : 'sticky'
        });
        toastEvent.fire();
    }
})