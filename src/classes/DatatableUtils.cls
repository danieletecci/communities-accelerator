public without sharing class DatatableUtils {
       
    public static List<SObject> doGetRecords(Datatable__c datatable, Integer offSet, Integer limitRecords, DatatableController.DatatableWrapper wrapper){
        List<SObject> rows = new List<SObject>();
        
        List<String> fieldSet = new List<String>();

        for(DatatableElement__c elem : datatable.DatatableElements__r) {
            
            if(elem.Type__c == String.valueOf(Schema.DisplayType.PICKLIST)) {
                fieldSet.add('toLabel(' + elem.FieldApiName__c + ')');
            } else {
                fieldSet.add(elem.FieldApiName__c);
            }
        }

        String fieldSetString = String.join(fieldSet, ', ');

        String whereCondition = datatable.WhereCondition__c != null ? datatable.WhereCondition__c : '';
        whereCondition = GeneralUtils.replaceDynamicFields(whereCondition, 'User', UserInfo.getUserId(), true);

        String filtersWhereCondition = DatatableUtils.processAppliedFilters(wrapper.appliedFilters);

        String searchTermWhereCondition = DatatableUtils.processSearchTerm(datatable, wrapper.searchTerm);

        String query = generateDatatableRecordsQuery('SELECT count()', ' FROM ' + datatable.ObjectApiName__c + ' ', whereCondition, filtersWhereCondition, searchTermWhereCondition);

        Integer totalRows = Database.countQuery(GeneralUtils.prefix(query));

        if(totalRows > 0) {
            wrapper.totalRows = totalRows;

            query = generateDatatableRecordsQuery('SELECT Id' + ((String.isBlank(fieldSetString)) ? '' : ',' + fieldSetString) + ' ', ' FROM ' + datatable.ObjectApiName__c + ' ', whereCondition, filtersWhereCondition, searchTermWhereCondition);

            if(String.isNotEmpty(datatable.OrderBy__c)) {
                System.debug('datatable.orderBy: ' + datatable.OrderBy__c);
                query += ' ORDER BY ' + datatable.OrderBy__c;
            }
            else{
                // Adding a default order by so values don't get repeated
                query += ' ORDER BY Id ASC ';
            }

            // Adding a limit to the query
            if (limitRecords > 0){
                query += ' LIMIT ' + limitRecords;
            }

            query += ' OFFSET ' + offSet;           
            
            System.debug('query: ' + query);

            rows = Database.query(GeneralUtils.prefix(query));
        }

        return rows;
    } 
    
    public static String generateDatatableRecordsQuery(String selectPart, String fromPart, String whereCondition, String filtersCondition, String searchTermCondition) {
        String result = '';

        Boolean hasConditions = false;
        Boolean hasWhereCondition = false;
        Boolean hasFiltersCondition = false;
        Boolean hasSearchTermCondition = false;

        String query = selectPart + ' ' + fromPart;
        
        String wherePart = '';

        if(whereCondition.contains('WHERE')) {
            whereCondition = whereCondition.replace('WHERE', '');
        }

        /*
        replaceDynamicFieldsOnWhereCondition(whereCondition, true);
        */
        hasWhereCondition = String.isNotEmpty(whereCondition);
        hasFiltersCondition = String.isNotEmpty(filtersCondition);
        hasSearchTermCondition = String.isNotEmpty(searchTermCondition);

        if(hasWhereCondition || hasFiltersCondition || hasSearchTermCondition) {
            hasConditions = true;

            System.debug('whereCondition: ' + whereCondition);
            System.debug('filtersCondition: ' + filtersCondition);
            System.debug('searchTermCondition: ' + searchTermCondition);
        }

        result += String.isNotEmpty(whereCondition) && hasWhereCondition ? whereCondition : '';
        result += String.isNotEmpty(result) && hasSearchTermCondition ? ' AND ' + searchTermCondition : searchTermCondition;
        result += String.isNotEmpty(result) && hasFiltersCondition ? ' AND ' + filtersCondition : filtersCondition;

        if(hasConditions) {
            query += ' WHERE ' + result;
        }

        return query;
    }
    /**
     * Methods that retrieves the Datatable__c object information, and its childs relationships (Elements & Actions)
     * @input componentExternalId
     * @return Datatable__c
     **/
    public static Datatable__c getDatatableInfo(String componentExternalId) {
        List<Datatable__c> datatables = [SELECT Id 
                                        , Title__c
                                        , Description__c
                                        , Navigation__c
										, Navigation__r.URL__c
                                        , ObjectApiName__c
                                        , RecordsPerPage__c 
                                        , PagingType__c
                                        , NumberOfColumns__c
                                        , NoRecordsMessage__c
                                        , ActionLabel__c
                                        , WhereCondition__c
                                        , OrderBy__c
                                        , (SELECT Id, Label__c, Navigation__c, Navigation__r.URL__c, ColumnInformation__c, ColumnInformationIcon__c
                                                    , DisplaySettings__c, FieldApiName__c, Filtrable__c, Searchable__c, Sortable__c
                                                    , Type__c, Datatable__r.ObjectApiName__c, ExcludedPicklistValues__c
                                            FROM DatatableElements__r ORDER BY Order__c)
                                        , (SELECT Id, Label__c, DisplaySettings__c, Icon__c, SelectableRow__c
                                                , Type__c, RecordType.DeveloperName, Component__c, ShowAsModal__c
                                                , Navigation__r.URL__c
                                            FROM DatatableActions__r)
                                    FROM Datatable__c 
                                    WHERE ExternalId__c = : componentExternalId
                                    LIMIT 1];

        if(datatables.size() > 0) {
            return datatables.get(0);
        }else {
            return null;
        }
    }
    
    public static List<Map<String, String>> mapDatatableDataToWrappers(List<SObject> records, List<DatatableController.DatatableElementWrapper> datatableElements) {
        List<Map<String, String>> datatableData = new List<Map<String, String>>();
        
        for(SObject record : records) {
            Map<String, String> structure = new Map<String, String>();

            structure.put('Id', (String)record.get('Id'));

            for(DatatableController.DatatableElementWrapper de : datatableElements) {
                String fieldApiName = de.fieldName;
                String value;

                if(de.type == String.valueOf(Schema.DisplayType.DATE) || 
                    de.type == String.valueOf(Schema.DisplayType.DATETIME)) {
                    	Datetime fieldDate = (Datetime)record.get(fieldApiName);
                        
                        if(fieldDate != null) {
                            value  = fieldDate.format();
                        }
                    
                }else {
                    value = String.valueOf(record.get(fieldApiName));
                }

                structure.put(fieldApiName, value);
            }

            datatableData.add(structure);
        }

        return datatableData;
    }

    public static List<DatatableController.DatatableElementWrapper> mapDatatableElementsToWrappers(List<DatatableElement__c> elements) {
        List<DatatableController.DatatableElementWrapper> result = new List<DatatableController.DatatableElementWrapper>();

        for(DatatableElement__c ele : elements) {
            DatatableController.DatatableElementWrapper elem = new DatatableController.DatatableElementWrapper();
			
			if(ele.Navigation__c != null) {
				elem.navigation = ele.Navigation__r.URL__c;
			}
            elem.label = ele.Label__c;
            elem.fieldName = ele.FieldApiName__c;
            elem.type = ele.Type__c;
            elem.columnInformation = ele.ColumnInformation__c;
            elem.displaySettings = ele.DisplaySettings__c;
            elem.searchable = ele.Searchable__c;
            elem.sortable = ele.Sortable__c;
            elem.filtrable = ele.Filtrable__c;

            if(ele.Type__c == String.valueOf(Schema.DisplayType.PICKLIST)) {
                elem.filtrableValues = new List<Map<String,String>>();

                String objectName = ele.Datatable__r.ObjectApiName__c;

                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                List<Schema.PicklistEntry> values = fieldMap.get(ele.FieldApiName__c).getDescribe().getPickListValues();
                for( Schema.PicklistEntry pickListVal : values) {
                    Boolean excluded = false;

                    if(String.isNotEmpty(ele.ExcludedPicklistValues__c) && ele.ExcludedPicklistValues__c.contains(pickListVal.getValue()) ) {
                        excluded = true;
                    }

                    if(!excluded) {
                        Map<String,String> temp = new Map<String,String>();
                        temp.put('label', pickListVal.getLabel());
                        temp.put('value', pickListVal.getValue());
                        elem.filtrableValues.add(temp);
                    }
                }
            }

            result.add(elem);
        }

        return result;
    }

    public static List<DatatableController.DatatableActionWrapper> mapDatatableActionsToWrappers(List<DatatableAction__c> actions) {
        List<DatatableController.DatatableActionWrapper> result = new List<DatatableController.DatatableActionWrapper>();

        for(DatatableAction__c action : actions) {
            DatatableController.DatatableActionWrapper ac = new DatatableController.DatatableActionWrapper();
        
            ac.recordType = action.RecordType.DeveloperName;
            ac.component = action.Component__c;
            ac.selectableRows = action.SelectableRow__c;
            ac.label = action.Label__c;
            ac.icon = action.Icon__c;
            ac.displaySettings = action.DisplaySettings__c;
            ac.showAsModal = action.ShowAsModal__c;
			
			if(action.Navigation__c != null) {
				ac.navigation = action.Navigation__r.URL__c;
			}

            result.add(ac);
        }

        return result;
    }

    public static DatatableController.DatatableWrapper mapDatatableToWrapper(Datatable__c datatable) {
        DatatableController.DatatableWrapper datatableWrapper = new DatatableController.DatatableWrapper();
        datatableWrapper.Id = datatable.Id;
        datatableWrapper.title = datatable.Title__c;
        datatableWrapper.description = datatable.Description__c;
        datatableWrapper.objectApiName = datatable.ObjectApiName__c;
		if(datatable.Navigation__c != null) {
			datatableWrapper.navigation = datatable.Navigation__r.URL__c;
		}
        datatableWrapper.recordsPerPage = Integer.valueOf(datatable.RecordsPerPage__c);
        datatableWrapper.pagingType = datatable.PagingType__c;
        datatableWrapper.numberOfColumns = Integer.valueOf(datatable.NumberOfColumns__c);
        datatableWrapper.noRecordsMsg = datatable.NoRecordsMessage__c;
        datatableWrapper.actionLabel = datatable.ActionLabel__c;
        datatableWrapper.orderBy = datatable.OrderBy__c;

        return datatableWrapper;
    }

    public static String processSearchTerm(Datatable__c datatable, String searchTerm) {
        String result = '';

        System.debug('searchTerm: ' + searchTerm);

        if(String.isNotEmpty(searchTerm)) {
            
            List<String> searchableColumns = new List<String>();

            for(DatatableElement__c elem : datatable.DatatableElements__r) {
                if(elem.Searchable__c) {
                    searchableColumns.add(elem.FieldApiName__c);
                }
            }

            if(searchableColumns.size() > 0) {
                result += '(';

                for(Integer i = 0; i < searchableColumns.size() ; i++) {
                    String field = searchableColumns[i];

                    if(i != 0) {
                        result += ' OR ';
                    }
                    result += ' ' + field + ' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
                }

                result += ')';
            }
        }

        return result;
    }

    public static String processAppliedFilters(List<DatatableController.DatatableFilterWrapper> appliedFilters) {
        Boolean newFilter = false;
        String filterCondition = '';
        String result = '';
        String filterName = '';
        
        appliedFilters.sort();
        
        for(DatatableController.DatatableFilterWrapper appliedFilter : appliedFilters) {
			System.debug('appliedFilter: ' + appliedFilter);
            
            if(filterName != appliedFilter.filter.name) {
                System.debug('it is a new filter: ' + appliedFilter.filter.name);
                newFilter = true;
                
                if(String.isNotEmpty(filterCondition)) {
                    filterCondition += ')';
                }
                
                if(String.isNotEmpty(result)) {
                    result += ' AND ' + filterCondition;
                }else {
                    result += filterCondition;
                }
                
                System.debug('result: ' + result);
                
                filterCondition = '';
                filterName = appliedFilter.filter.name;
            }else {
                System.debug('the same old filter: ' + appliedFilter.filter.name);
                if(String.isNotEmpty(filterCondition)) {
                    filterCondition += ' OR ';
                }
                newFilter = false;
            }
            
            if(newFilter && String.isEmpty(filterCondition)){
                filterCondition += '(';
            }
            
            System.debug('filterCondition: ' + filterCondition);
            
            if(appliedFilter.filter.type == String.valueOf(Schema.DisplayType.STRING) || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.PICKLIST)) {
                filterCondition += appliedFilter.filter.name + ' = \'' + String.escapeSingleQuotes(appliedFilter.value1) + '\' ';
            }else if(appliedFilter.filter.type == String.valueOf(Schema.DisplayType.DATE) || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.DATETIME)) {

                if(String.isNotEmpty(appliedFilter.value1) && String.isNotEmpty(appliedFilter.value2)) {

                    Datetime datetimeValue1 = Datetime.newInstance(Date.valueOf(appliedFilter.value1), Time.newInstance(0, 0, 0, 0));
                    Datetime datetimeValue2 = Datetime.newInstance(Date.valueOf(appliedFilter.value2), Time.newInstance(23, 59, 59, 0));

                    filterCondition += appliedFilter.filter.name + ' >= ' + GeneralUtils.getDateTimeForQuery(datetimeValue1) + ' AND ' + appliedFilter.filter.name + ' <= ' + GeneralUtils.getDateTimeForQuery(datetimeValue2) + ' ';
                }else if(String.isNotEmpty(appliedFilter.value1)) {
                    Datetime datetimeValue1 = Datetime.newInstance(Date.valueOf(appliedFilter.value1), Time.newInstance(23, 59, 59, 0));
                    filterCondition += appliedFilter.filter.name + ' >= ' + GeneralUtils.getDateTimeForQuery(datetimeValue1) + ' ';
                }else if(String.isNotEmpty(appliedFilter.value2)) {
                    Datetime datetimeValue2 = Datetime.newInstance(Date.valueOf(appliedFilter.value2), Time.newInstance(23, 59, 59, 0));
                    filterCondition += appliedFilter.filter.name + ' <= ' + GeneralUtils.getDateTimeForQuery(datetimeValue2) + ' ';
                }
            }else if(appliedFilter.filter.type == String.valueOf(Schema.DisplayType.INTEGER) || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.LONG) 
                    || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.DOUBLE)) {
                if(String.isNotEmpty(appliedFilter.value1) && String.isNotEmpty(appliedFilter.value2)) {
                    filterCondition += appliedFilter.filter.name + ' >= ' + Double.valueOf(appliedFilter.value1) + ' AND ' + appliedFilter.filter.name + ' <= ' + Double.valueOf(appliedFilter.value2);
                }else if(String.isNotEmpty(appliedFilter.value1)) {
                    filterCondition += appliedFilter.filter.name + ' >= ' + Double.valueOf(appliedFilter.value1);
                }else if(String.isNotEmpty(appliedFilter.value2)) {
                    filterCondition += appliedFilter.filter.name + ' <= ' + Double.valueOf(appliedFilter.value2);
                }
            }
            
            System.debug('filterCondition end: ' + filterCondition);
        }
		
        if(String.isNotEmpty(filterCondition)) {
            
            if(String.isNotEmpty(result)) {
                result += ' AND ';
            }
            result += filterCondition + ')';
        }
        
        System.debug('applied filters result: ' + result);

        return result;
    }
}