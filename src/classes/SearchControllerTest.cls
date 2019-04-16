@isTest
public with sharing class SearchControllerTest {
    @testSetup
    static void setup(){
        List<Component__c> compList = MockupFactory.createComponent('Search',1);
        createSearchDetail(compList.get(0), 'Banner','banner','Content__c','Name','Name,Description__c','Banner');
    }
    
    @isTest
    static void getSearchResults(){
        List<SearchSetting__c> searchDetails = [SELECT Name, ExternalId__c, URLParameterName__c, URLParameterField__c, FieldsToSearch__c, FieldsToShow__c, IconName__c, ObjectAPIName__c, RecordTypeDevName__c, Filter__c, Navigation__r.URL__c, Navigation__r.URLMask__c, PredictiveSearchRecordsNumber__c 
                                                    FROM SearchSetting__c];
        List<SearchController.SearchResultWrapper> listResult = SearchController.getSearchResults('Test', searchDetails);
        System.debug('listResult ' + JSON.serialize(listResult));
    }

    @isTest
    static void getComponent(){
        SearchController.getComponent([SELECT ExternalId__c FROM Component__c][0].ExternalId__c);
    }
    
    @isTest
    static void getSearchDetails(){
        SearchController.getSearchDetails([SELECT ExternalId__c FROM Component__c][0].ExternalId__c);
    }
    
    @isTest
    static void getPredictiveResults(){
        List<SearchSetting__c> searchDetails = [SELECT Name, ExternalId__c, URLParameterName__c, URLParameterField__c, FieldsToSearch__c, FieldsToShow__c, IconName__c, ObjectAPIName__c, RecordTypeDevName__c, Filter__c, Navigation__r.URL__c, Navigation__r.URLMask__c, PredictiveSearchRecordsNumber__c 
                                                    FROM SearchSetting__c];
        List<SearchController.PredictiveResultWrapper> listResult = SearchController.getPredictiveResults('Test', searchDetails);
        System.debug('listResult ' + JSON.serialize(listResult));
    }

    static SearchSetting__c createSearchDetail(Component__c component, String name, String sectionApiName, String objectApiName, String fieldsToSearch, String fieldsToShow, String recordTypeDevName){
        SearchSetting__c rll = new SearchSetting__c(
            												Component__c			= component.Id,
                                                            Name                    = name,
                                                            ExternalId__c           = sectionApiName,
                                                            ObjectAPIName__c        = objectApiName,
                                                            FieldsToSearch__c       = fieldsToSearch,
                                                            FieldsToShow__c         = fieldsToShow,
                                                            RecordTypeDevName__c    = recordTypeDevName
        );
        insert rll;
        return rll;
    }
}