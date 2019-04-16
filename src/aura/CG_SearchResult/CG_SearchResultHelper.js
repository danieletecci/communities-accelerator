({
	getSearchResults : function(component,helper) {
		var action = component.get("c.getSearchResults");
        action.setParams({
            searchedString  : component.get("v.searchedString"),
            searchDetails   : component.get("v.searchDetails")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
            	var results 	= action.getReturnValue();
				component.set("v.results", results);
				component.set("v.selectedItem", (results && results.length > 0) ? results[0].sectionApiName : null);
				helper.setRecordList(component, component.get("v.selectedItem"));
            }
        });
        $A.enqueueAction(action);
	},
	setRecordList : function(component, selectedItem) {
		var results 		= component.get("v.results");
		var selectedResult 	= results.find( result => result.sectionApiName === selectedItem );
		selectedResult		= this.setNameAsUrl(selectedResult);
		console.log("[SearchHOCResultsHelper.js][RecordListSetEvent] selectedResult: " + JSON.stringify(selectedResult));


        var appEvent 	= $A.get("e.c:RecordListSetEvent");
		appEvent.setParams({
			"title"				: selectedResult.sectionName,
			"iconName"			: selectedResult.iconName,
		    "columns" 			: selectedResult.fieldsToShow,
		    "data"				: selectedResult.records,
		    "dataTableSchema" 	: selectedResult.objectAPIName,
		    "totalNumberOfRows" : selectedResult.records.length
		});
		appEvent.fire();

		console.log("[SearchHOCResultsHelper.js][RecordListSetEvent] selectedResult: " + JSON.stringify(selectedResult));
	},
	setNameAsUrl : function(selectedResult) {
		var linkField = {label: 'Name', fieldName: 'linkDetail', type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }};
		var nameColumn 	= selectedResult.fieldsToShow.find( result => result.fieldName === 'Name' );
		if(nameColumn && selectedResult.navigation && selectedResult.urlParameterName && selectedResult.urlParameterField){
			var index = selectedResult.fieldsToShow.indexOf(nameColumn);
			if (index > -1) {
			  selectedResult.fieldsToShow[index] = linkField;
			}
			for(var i=0; i<selectedResult.records.length; i++){
				selectedResult.records[i].linkDetail = "/" + selectedResult.navigation + '?' + selectedResult.urlParameterName + '=' + selectedResult.records[i][selectedResult.urlParameterField];
				console.log("[SearchHOCResultsHelper.js][setNameAsUrl] link: " + selectedResult.records[i].linkDetail);
			}
		}

		return selectedResult;
	}
})