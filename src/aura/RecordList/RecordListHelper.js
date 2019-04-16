({
	setTableData : function(component, event) {

		component.set("v.title", 					event.getParam("title"));
		component.set("v.iconName", 				event.getParam("iconName"));
		component.set("v.columns", 					event.getParam("columns"));
		component.set("v.data", 					event.getParam("data"));
		component.set("v.dataTableSchema", 			event.getParam("dataTableSchema"));
		component.set("v.keyField", 				event.getParam("keyField") || "Id");
		component.set("v.initialRows", 				event.getParam("initialRows" || 5));
		component.set("v.selectedRowsCount", 		event.getParam("selectedRowsCount" || 0));
		component.set("v.enableInfiniteLoading", 	event.getParam("enableInfiniteLoading" || true));
		component.set("v.rowsToLoad", 				event.getParam("rowsToLoad" || 50));
		component.set("v.loadMoreOffset", 			event.getParam("loadMoreOffset" || 20));
		component.set("v.sortedBy", 				event.getParam("sortedBy"));
		component.set("v.totalNumberOfRows", 		event.getParam("totalNumberOfRows" || 300));
	},
	sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection  !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})