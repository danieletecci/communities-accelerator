({
	getRecords : function(component) {
		component.set("v.isLoading", true);
		
		var action = component.get("c.getRecords");
		action.setParams({
			recordId: component.get("v.recordId")
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordsWrapper", action.getReturnValue());
            	component.set("v.isLoading", false);
            	component.set("v.TagCriteria", action.getReturnValue().tagCriteria);
            	component.set("v.MatchCriteria", action.getReturnValue().matchCriteria);
            	var matchOptions = action.getReturnValue().matchOptions;
            	var objects = [];
                for(var matchItem in matchOptions) {
                    objects.push({label:matchOptions[matchItem], value:matchOptions[matchItem]});
                }
            	component.set("v.Options", objects);

            	if(action.getReturnValue().recordsSelected.length < 5){
            		component.set("v.variableDivHeight", (40 + (action.getReturnValue().recordsSelected.length * 30) + 'px'));
            	}else{
            		component.set("v.variableDivHeight", '162px');
            	}
                var cmpWrSelected = component.get("v.recordsWrapper").recordsSelected;
                var listSelectedIds = [];
                for(var i = 0; i < cmpWrSelected.length; i++){
                    listSelectedIds.push(cmpWrSelected[i].idRecord);
                }
                component.set("v.listSelectedIds", listSelectedIds);
	        }
	    });	   
	    $A.enqueueAction(action);
	},
    savePoint : function(component, event, helper){
        component.set("v.isLoading", true);
		var listSelectedIds = [];
		var allCheckbox = component.find("i_input_checkbox");

        var matchCriteria = component.get("v.MatchCriteria");
        var newCriteria = '';
        var firstPass = '0';

		if(allCheckbox === undefined){
			var cmpWrSelected = component.get("v.recordsWrapper").recordsSelected;
			for(var i = 0; i < cmpWrSelected.length; i++){
				listSelectedIds.push(cmpWrSelected[i].idRecord);
			}
		} else if(allCheckbox.length === undefined){
			if(allCheckbox.get("v.value") == true) {
				listSelectedIds.push(allCheckbox.get("v.text"));
			}
		}else{
			for(var i = 0; i < allCheckbox.length; i++) {
				if(allCheckbox[i].get("v.value") == true) {
					listSelectedIds.push(allCheckbox[i].get("v.text"));
				}
			}
		}
        
        component.set("v.listSelectedIds", listSelectedIds);
        var action = component.get("c.getSelectedRecords");
		action.setParams({
			data: JSON.stringify(component.get("v.recordsWrapper")),
			listSelectedIds: listSelectedIds
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordsWrapper", action.getReturnValue());
                component.set("v.isLoading", false);
            }
	    });
	    $A.enqueueAction(action);
    },
	save : function(component, event, helper) {
		component.set("v.isLoading", true);
		var listSelectedIds = component.get("v.listSelectedIds");
        var matchCriteria = component.get("v.MatchCriteria");
        var newCriteria = '';
        var firstPass = '0';
		
	    switch(matchCriteria){
            case 'Custom':
                break;
            default:
                for(var i = 0; i < listSelectedIds.length; i++){
                    if (firstPass == '0'){
                        newCriteria = newCriteria + (i+1);
                        firstPass='1';
                    }
                    else{
                    newCriteria = newCriteria + (matchCriteria == "All" ? ' AND ' : ' OR ') + (i+1);
                    }
                }
                component.set("v.TagCriteria",newCriteria);
                break;
        }
		
		var action = component.get("c.saveRelationships");
		action.setParams({
			recordId: component.get("v.recordId"),
			listSelectedIds: listSelectedIds,
			matchCriteria: component.get("v.MatchCriteria"),
			tagCriteria: component.get("v.TagCriteria")
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	var showToast = $A.get('e.force:showToast');

            	if(action.getReturnValue() == 'OK'){
					showToast.setParams({
						'title'   : $A.get("$Label.c.General_Success"),
						'message' : $A.get("$Label.c.General_RecordsSavedSuccessfully"),
						'type'    : 'success'
					});
    		
    
    				if(component.get("v.isEdit")){
    					component.set("v.isEdit", false);
    				} else if(component.get("v.isReorder")){
    					component.set("v.isReorder", false);
    				}
				    helper.getRecords(component);
				}else{
					showToast.setParams({
						'title'   : $A.get("$Label.c.General_Error"),
						'message' : action.getReturnValue(),
						'type'    : 'error'
					});
				}
                component.set("v.isLoading", false);
                showToast.fire();
			
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	selectAll: function(component, event) {
		var selectedHeaderCheck = event.getSource().get("v.value");
		var getAllId = component.find("i_input_checkbox");
		if(!Array.isArray(getAllId)){
			if(selectedHeaderCheck == true){ 
				component.find("i_input_checkbox").set("v.value", true);
			}else{
				component.find("i_input_checkbox").set("v.value", false);
			}
		}else{
			if(selectedHeaderCheck == true) {
				for(var i = 0; i < getAllId.length; i++) {
					component.find("i_input_checkbox")[i].set("v.value", true);
				}
			}else{
				for(var i = 0; i < getAllId.length; i++) {
					component.find("i_input_checkbox")[i].set("v.value", false);
				}
			}
		}
	},

	search: function(component) {
		var searchInput = component.find("i_input_search").getElement().value;
		var tableRows = component.find('i_table_edit').getElement().getElementsByClassName('c_item_searchable');
		for(var i = 0; i < tableRows.length; i++) { 
			if(String(tableRows[i].getElementsByTagName('a')[0].innerHTML).toLowerCase().includes(searchInput.toLowerCase())){
				tableRows[i].style.display = 'table-row';
			}else{
				tableRows[i].style.display = 'none';
			}
		}
	}
})