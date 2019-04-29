({
	getRecords : function(component) {
		component.set("v.isLoading", true);
		
		var action = component.get("c.getRecords");
		action.setParams({
			recordId: component.get("v.recordId"),
			objectName: component.get("v.objectAPIName"),
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordsWrapper", action.getReturnValue());
            	component.set("v.isLoading", false);

            	if(action.getReturnValue().recordsSelected.length < 5){
            		component.set("v.variableDivHeight", (40 + (action.getReturnValue().recordsSelected.length * 30) + 'px'));
            	}else{
            		component.set("v.variableDivHeight", '162px');
            	}
	        }
	    });	   
	    $A.enqueueAction(action);
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