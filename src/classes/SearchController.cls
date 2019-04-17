public with sharing class SearchController {

    //WRAPPER
    public class SearchResultWrapper {
        @AuraEnabled public List<Sobject>                   records;
        @AuraEnabled public String                          sectionName;
        @AuraEnabled public String                          sectionApiName;
        @AuraEnabled public String                          iconName;
        @AuraEnabled public String                          objectAPIName;
        @AuraEnabled public String                          sortedBy;
        @AuraEnabled public List<Map<String,String>>        fieldsToShow;
        @AuraEnabled public String                          urlParameterName;
        @AuraEnabled public String                          urlParameterField;
        @AuraEnabled public String                          navigation;

        public SearchResultWrapper(List<Sobject> records, String sectionName, String sectionApiName, String iconName, 
                                    String objectAPIName, List<Map<String,String>> fieldsToShow, String urlParameterName, 
                                    String urlParameterField, String navigation){
            this.records            = records;
            this.sectionName        = sectionName;
            this.sectionApiName     = sectionApiName;
            this.iconName           = iconName;
            this.objectAPIName      = objectAPIName;
            this.sortedBy           = fieldsToShow.get(0).get('fieldName');
            this.fieldsToShow       = fieldsToShow;
            this.urlParameterName   = urlParameterName;
            this.urlParameterField  = urlParameterField;
            this.navigation         = navigation;
        }
    }

    public class PredictiveResultWrapper {
        @AuraEnabled public List<Sobject>                   records;
        @AuraEnabled public String                          sectionName;
        @AuraEnabled public String                          iconName;
        @AuraEnabled public String                          urlParameterName;
        @AuraEnabled public String                          urlParameterField;
        @AuraEnabled public String                          navigation;

        public PredictiveResultWrapper(List<Sobject> records, String sectionName, String iconName, String urlParameterName, 
                                    String urlParameterField, String navigation){
            this.records            = records;
            this.sectionName        = sectionName;
            this.iconName           = iconName;
            this.urlParameterName   = urlParameterName;
            this.urlParameterField  = urlParameterField;
            this.navigation         = navigation;
        }
    }

    public class SearchDetailWrapper {
        @AuraEnabled public ObjectComponentWrapper           component;
        @AuraEnabled public List<SearchSetting__c>           searchDetails;

        public SearchDetailWrapper(Component__c component, List<SearchSetting__c> searchDetails){
            this.component          = new ObjectComponentWrapper(component);
            this.searchDetails      = searchDetails;
        }
    }

    @AuraEnabled
    public static ObjectComponentWrapper getComponent(String externalId){
        List<Component__c> component = [SELECT Name, ExternalId__c, SearchPlaceholder__c, LinkDetail__r.URL__c, LinkDetail__r.URLMask__c, PredictiveSearchEnabled__c
                                                    FROM Component__c WHERE ExternalId__c = :externalId];
        
        return (component.isEmpty()) ? null : new ObjectComponentWrapper(component.get(0));
    }

    @AuraEnabled
    public static SearchDetailWrapper getSearchDetails(String externalId){
        List<Component__c> component = [SELECT Name, ExternalId__c, SearchPlaceholder__c, LinkDetail__r.URL__c, LinkDetail__r.URLMask__c, PredictiveSearchEnabled__c
                                                    FROM Component__c WHERE ExternalId__c = :externalId];

        List<SearchSetting__c> searchDetails = [SELECT Name, ExternalId__c, URLParameterName__c, URLParameterField__c, FieldsToSearch__c, FieldsToShow__c, IconName__c, ObjectAPIName__c, RecordTypeDevName__c, Filter__c, Navigation__r.URL__c, Navigation__r.URLMask__c, PredictiveSearchRecordsNumber__c 
                                                    FROM SearchSetting__c WHERE Active__c = true AND Component__r.ExternalId__c = :externalId];

        return new SearchDetailWrapper(((component.isEmpty()) ? null : component.get(0)), searchDetails);
    }

    @AuraEnabled
    public static List<SearchResultWrapper> getSearchResults(String searchedString, List<SearchSetting__c> searchDetails){
        List<SearchResultWrapper>   searchResults = new List<SearchResultWrapper>();

        for(SearchSetting__c rll : searchDetails){
            searchResults.add( new SearchResultWrapper( Database.query(buildQuery(rll, searchedString)),
                                                        rll.Name,
                                                        rll.ExternalId__c,
                                                        rll.IconName__c,
                                                        rll.ObjectAPIName__c,
                                                        getLabelsByFields(rll.FieldsToShow__c.split(','), rll.ObjectAPIName__c),
                                                        rll.URLParameterName__c,
                                                        rll.URLParameterField__c,
                                                        rll.Navigation__r.URL__c
                                                        ));
        }

        System.debug('[SearchController][getSearchResults] searchResults: ' + JSON.serialize(searchResults));
        return searchResults;
    }

    @AuraEnabled
    public static List<PredictiveResultWrapper> getPredictiveResults(String searchedString, List<SearchSetting__c> searchDetails){
        List<PredictiveResultWrapper>   predictiveResults = new List<PredictiveResultWrapper>();

        for(SearchSetting__c rll : searchDetails){
            predictiveResults.add( new PredictiveResultWrapper( Database.query(buildPredictiveQuery(rll, searchedString)),
                                                        rll.Name,
                                                        rll.IconName__c,
                                                        rll.URLParameterName__c,
                                                        rll.URLParameterField__c,
                                                        rll.Navigation__r.URL__c
                                                        ));
        }

        System.debug('[SearchController][getSearchResults] predictiveResults: ' + JSON.serialize(predictiveResults));
        return predictiveResults;
    }

    private static String buildQuery(SearchSetting__c rll, String searchedString){
        List<String>    fields  = rll.FieldsToSearch__c.split(',');
        String          query   = 'SELECT ' + rll.FieldsToShow__c + ((rll.FieldsToShow__c.split(',').contains(rll.URLParameterField__c)) ? '' : ',' + rll.URLParameterField__c) +
                                    ' FROM ' + rll.ObjectAPIName__c +
                                    ' WHERE ' + ((!String.isBlank(rll.RecordTypeDevName__c)) ? 
                                                    'RecordType.DeveloperName = \'' + rll.RecordTypeDevName__c + '\' AND (' : '');

        for(Integer i = 0; i < fields.size(); i++){
            String field = fields.get(i);
            query += (i == fields.size() - 1) ? 
                        field + ' LIKE \'%' + searchedString + '%\')' : field + ' LIKE \'%' + searchedString + '%\' OR ';
        }

        query += (!String.isBlank(rll.Filter__c)) ? rll.Filter__c : '';

        return query;
    }

    private static String buildPredictiveQuery(SearchSetting__c rll, String searchedString){
        List<String>    fields  = rll.FieldsToSearch__c.split(',');
        String          query   = 'SELECT Name,' + rll.URLParameterField__c +
                                    ' FROM ' + rll.ObjectAPIName__c +
                                    ' WHERE ' + ((!String.isBlank(rll.RecordTypeDevName__c)) ? 
                                                    'RecordType.DeveloperName = \'' + rll.RecordTypeDevName__c + '\' AND (' : '');

        for(Integer i = 0; i < fields.size(); i++){
            String field = fields.get(i);
            query += (i == fields.size() - 1) ? 
                        field + ' LIKE \'%' + searchedString + '%\')' : field + ' LIKE \'%' + searchedString + '%\' OR ';
        }

        query += (!String.isBlank(rll.Filter__c)) ? rll.Filter__c : '';
        query += ' LIMIT ' + rll.PredictiveSearchRecordsNumber__c;

        return query;
    }

    private static List<Map<String,String>> getLabelsByFields(List<String> fields, String sobjectName){
        List<Map<String,String>>            fieldsMaps  = new List<Map<String,String>>();
        Map<String, Schema.SObjectType>     schemaMap   = Schema.getGlobalDescribe();
        Schema.SObjectType                  leadSchema  = schemaMap.get(sobjectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for(String fApiName : fields){
            Map<String,String> fieldMetaData = new Map<String,String>();
            fieldMetaData.put('label', fieldMap.get(fApiName).getDescribe().getLabel());
            fieldMetaData.put('fieldName',fApiName);
            fieldMetaData.put('type', (fieldMap.get(fApiName).getDescribe().getType() + '').toLowerCase());
            fieldMetaData.put('sortable', 'true');

            fieldsMaps.add(fieldMetaData);
        }

        return fieldsMaps;
    }
}