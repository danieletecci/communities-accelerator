({
    getRecord : function(component, event, helper) {
        helper.getRecord(component, event, helper);
    },
    doGetPage : function(component, event, helper) {
        helper.doGetPage(component, event, helper, event.getParam('page'));
    },
    doHandleSearch : function(component, event, helper) {
        var searchTerm = event.getParam("values");
        component.set("v.componentWrapper.data.searchTerm", searchTerm);
        component.set("v.componentWrapper.data.tableData", []);
        helper.doHandleSearch(component, event, helper);
    },
    doHandleDelete : function(component, event, helper) {
        helper.doHandleDelete(component, event, helper);
    },
    doHandleSort : function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var direction = event.getParam('direction');
        helper.doHandleSort(component, event, helper, fieldName, direction);
    },
    doHandleClearFilters : function(component, event, helper) {
        var componentWrapper = component.get("v.componentWrapper");
        
        var filters = [];
        componentWrapper.data.appliedFilters  = filters;

        component.set('v.componentWrapper', componentWrapper);

        helper.doHandleFilter(component, event, helper);
    },
    doHandleFilter : function(component, event, helper){
        var componentWrapper = component.get("v.componentWrapper");
        var eventValues = JSON.parse(event.getParam("values"));
        componentWrapper.data.appliedFilters  = eventValues;
        component.set('v.componentWrapper', componentWrapper);
        helper.dohandleFilter(component);
    },
    doHandleCustomRowAction : function(component, event, helper) {
        helper.doHandleCustomRowAction(component, event, helper);
    },
    closeCustom : function(component, event, helper) {
        component.set("v.customContent", []);
        component.set('v.showDatatable', true);
    },
})
