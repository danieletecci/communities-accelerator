public without sharing class DatatableController extends ComponentManager {

    public Datatable__c datatable {get;set;}
    public List<DatatableElement__c> datatableElements {get;set;}
    public List<DatatableAction__c> datatableActions {get;set;}

    /* Aura Methods - BEGIN */
    @AuraEnabled
    public static String doInit(String externalId, String clusterId, String device) {
        DatatableController controller = new DatatableController();
        ComponentWrapper cw = new ComponentWrapper();

        controller.componentExternalId = externalId;
        controller.componentFieldSet = new Set<String>();
        controller.customPermissionEdit='Datatable Edit Frame';
        controller.customPermissionView='Datatable View Frame';
        controller.defaultComponentFieldSet = new Set<String>();

        cw = controller.getCW();
        cw.clusterId = clusterId;
        
        DatatableWrapper dataTableWr = (DatatableWrapper) cw.data;

        cw.hasContent = dataTableWr.tableData.size() > 0;

        return JSON.serialize(cw);
    }

    @AuraEnabled
    public static String getRecords(String componentWrapper, Integer actualPage, Boolean limitRecords, Boolean offSetRecords, String fieldName, String direction) {
        DatatableController.DatatableWrapper wrapper = (DatatableController.DatatableWrapper) JSON.deserialize(componentWrapper, DatatableController.DatatableWrapper.class);

        Datatable__c datatable = DatatableUtils.getDatatableInfo(wrapper.componentExternalId);

        Integer offSetAmount = (offSetRecords) ? wrapper.recordsPerPage * actualPage : 0;
        Integer limitRecordsAmount = (limitRecords) ? wrapper.recordsPerPage : wrapper.recordsPerPage * actualPage;
        // Sort
        if (!String.isEmpty(fieldName) && !String.isEmpty(direction)){
            wrapper.orderBy = fieldName + ' ' + direction;
        }
        // Filter
        datatable.OrderBy__c = wrapper.orderBy;

        List<SObject> records = DatatableUtils.doGetRecords(datatable, offSetAmount, limitRecordsAmount, wrapper);
        return JSON.serialize(DatatableUtils.mapDatatableDataToWrappers(records, wrapper.columns));
    }

    @AuraEnabled
    public static String handleDelete(String componentWrapper, List<Id> ids) {
        System.debug('in DatatableController.handleDelete() method.');
        Boolean result = true;

        if(result) {
            DatatableController.DatatableWrapper wrapper = (DatatableController.DatatableWrapper)JSON.deserialize(componentWrapper, DatatableController.DatatableWrapper.class);
        }
        
        return '';
    }

    /* Aura Methods - END */

     public override MetaWrapper getMeta() {
         MetaWrapper mw = new MetaWrapper();
         List<DataTable__c> dt = [SELECT Id,Name FROM DataTable__c WHERE ExternalId__c=: this.componentExternalId];
         if (dt[0] != null){
            mw.objectId = dt[0].Id;
            mw.name = dt[0].Name;
         }
  
         return mw;
     }

    public override DataWrapper getData() {
        System.debug('in DatatableController.getData() - externalId: ' + this.componentExternalId);

        Datatable__c datatable = DatatableUtils.getDatatableInfo(this.componentExternalId);

        if(datatable != null) {
            
            DatatableWrapper datatableWrapper = DatatableUtils.mapDatatableToWrapper(datatable);
            datatableWrapper.componentExternalId = this.componentExternalId;
            datatableWrapper.searchTerm = '';

            datatableWrapper.columns = DatatableUtils.mapDatatableElementsToWrappers(datatable.DatatableElements__r);
            datatableWrapper.actions = DatatableUtils.mapDatatableActionsToWrappers(datatable.DatatableActions__r);

            List<SObject> records = DatatableUtils.doGetRecords(datatable, 0, datatableWrapper.recordsPerPage, datatableWrapper);
            datatableWrapper.tableData = DatatableUtils.mapDatatableDataToWrappers(records, datatableWrapper.columns);

            return datatableWrapper;
        }else {
            return null;
        }
    }

    public class DatatableWrapper extends ComponentManager.DataWrapper {
        public String componentExternalId {get;set;}
        public String id {get;set;}
        public String name {get;set;}
        public String objectApiName {get;set;}
        public String title {get;set;}
        public String navigation {get;set;}
        public Integer recordsPerPage {get;set;}
        public String pagingType {get;set;}
        public Integer totalRows {get;set;}
        public Integer numberOfColumns {get;set;}
        public String noRecordsMsg {get;set;}
        public String actionLabel {get;set;}
        public String searchTerm {get;set;}
        public String orderBy {get;set;}
        public String description {get;set;}

        public List<DatatableFilterWrapper> appliedFilters {get;set;}
        public List<DatatableController.DatatableElementWrapper> columns {get;set;}
        public List<DatatableController.DatatableActionWrapper> actions {get;set;}        
        public List<Map<String, String>> tableData {get;set;}

        public DatatableWrapper() {
            appliedFilters = new List<DatatableFilterWrapper>();
        }
    }

    public class DatatableElementWrapper {
        public String label {get;set;}
        public String fieldName {get;set;}
        public String type {get;set;}

        public String navigation {get;set;}
        public String columnInformation {get;set;}
        public String columnInformationIcon {get;set;}
        public String displaySettings {get;set;}
        
        public Boolean searchable {get;set;}
        public Boolean sortable {get;set;}
        public Boolean filtrable {get;set;}
        public List<Map<String,String>> filtrableValues {get;set;}
    }

    public class DatatableActionWrapper {
        public String navigation {get;set;}
        public String recordType {get;set;}
        public String component {get;set;}
        public Boolean selectableRows {get;set;}
        public String label {get;set;}
        public String icon {get;set;}
        public String displaySettings {get;set;}
        public Boolean showAsModal {get;set;}
    }

    public class DatatableFilterWrapper implements Comparable {
        public DatatableController.DatatableFilterFieldWrapper filter {get;set;}
        public String value1 {get;set;}
        public String value2 {get;set;}
        public String label {get;set;}

        public Integer compareTo(Object compareTo) {
            DatatableController.DatatableFilterWrapper obj = (DatatableController.DatatableFilterWrapper)compareTo;
            
            if(String.isNotEmpty(this.filter.name) && String.isNotEmpty(obj.filter.name)) {
                return this.filter.name.compareTo(obj.filter.name);
            }else {
                return 0;
            }
        }
    }

    public class DatatableFilterFieldWrapper {
        public String name {get;set;}
        public String type {get;set;}
    }

    public class DatatableRowWrapper {
        public String columnName {get;set;}
        public String rowValue {get;set;}
    }
}