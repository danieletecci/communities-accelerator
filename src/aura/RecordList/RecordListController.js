({
	handleRecordList : function (component, event, helper){
		helper.setTableData(component, event);
	},
	loadMoreData: function (cmp, event, helper) {
        var rowsToLoad = cmp.get('v.rowsToLoad'),
            fetchData = cmp.get('v.dataTableSchema'),
            promiseData;

        event.getSource().set("v.isLoading", true);
        cmp.set('v.loadMoreStatus', 'Loading');

        /*
        promiseData = helper.fetchData(cmp, fetchData, rowsToLoad);

        promiseData.then($A.getCallback(function (data) {
            if (cmp.get('v.data').length >= cmp.get('v.totalNumberOfRows')) {
                cmp.set('v.enableInfiniteLoading', false);
                cmp.set('v.loadMoreStatus', 'No more data to load');
            } else {
                var currentData = cmp.get('v.data');
                var newData = currentData.concat(data);
                cmp.set('v.data', newData);
                cmp.set('v.loadMoreStatus', '');
            }
            event.getSource().set("v.isLoading", false);
        }));
        */
    },
    sortData: function(cmp, event, helper){
        console.log('[RecordListController.js][sortData]');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})