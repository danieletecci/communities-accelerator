({
    getRecord : function(component, event, helper) {
        helper.getRecord(component, event, helper);
    },
    doGetPage : function(component, event, helper) {
        component.set("v.pageNumber", Math.trunc(event.getParam('page') + 1));
        var fieldName = component.get("v.fieldName");
        var direction = component.get("v.direction");
        helper.doGetPage(component, event, helper, event.getParam('page'), fieldName, direction);
    },
    doHandleFilter : function(component, event, helper){
        var componentWrapper = component.get("v.componentWrapper");
        var eventValues = JSON.parse(event.getParam("values"));
        componentWrapper.data.appliedFilters  = eventValues;
        component.set('v.componentWrapper', componentWrapper);
        var fieldName = component.get("v.fieldName");
        var direction = component.get("v.direction");
        helper.dohandleFilter(component, event, helper, component.get("v.pageNumber"), fieldName, direction); 
    },
    doHandleSort : function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var direction = event.getParam('direction');
        component.set("v.fieldName", fieldName);
        component.set("v.direction", direction);        
        helper.doHandleSort(component, event, helper, component.get("v.pageNumber"), fieldName, direction);
    },
    doHandleSearch : function(component, event, helper) {
        var searchTerm = event.getParam("values");
        component.set("v.componentWrapper.data.searchTerm", searchTerm);
        component.set("v.componentWrapper.data.tableData", []);
        var fieldName = component.get("v.fieldName");
        var direction = component.get("v.direction");
        helper.doHandleSearch(component, event, helper, component.get("v.pageNumber"), fieldName, direction);
    },
    doHandleDelete : function(component, event, helper) {
        helper.doHandleDelete(component, event, helper);
    },   
    doHandleClearFilters : function(component, event, helper) {
        var componentWrapper = component.get("v.componentWrapper");
        
        var filters = [];
        componentWrapper.data.appliedFilters  = filters;

        component.set('v.componentWrapper', componentWrapper);

        helper.doHandleFilter(component, event, helper);
    },
    doHandleCustomRowAction : function(component, event, helper) {
        helper.doHandleCustomRowAction(component, event, helper);
    },
    closeCustom : function(component, event, helper) {
        component.set("v.customContent", []);
        component.set('v.showDatatable', true);
    },
})