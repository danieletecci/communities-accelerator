public class ContentSearchFiltersController {

    //FILTER WRAPPER
    public class FilterWrapper {
        @auraEnabled public List<FilterSelectorWrapper> filters;

        public FilterWrapper(List<FilterSelectorWrapper> filters){
            this.filters = filters;
        }
    }
    //FILTER SELECTOR WRAPPER
    public class FilterSelectorWrapper{
        @auraEnabled public String label;
        @auraEnabled public Boolean isMultiPicklist;
        @auraEnabled public List<FilterOptionWrapper> values;
        @auraEnabled public String apiName;

        public FilterSelectorWrapper(String label, Boolean isMultiPicklist, List<FilterOptionWrapper> values, String apiName){
            this.label = label;
            this.isMultiPicklist = isMultiPicklist;
            this.values = values;
            this.apiName = apiName;
        }

    }
    //FILTER OPTION WRAPPER
    public class FilterOptionWrapper {
        @auraEnabled public String label;
        @AuraEnabled public String id;
        @AuraEnabled public Boolean isSelected;

        public FilterOptionWrapper(String label, string id){
            this.label = label;
            this.id = id;
            this.isSelected = false;
        }
    }
    

    @AuraEnabled(cacheable=true)
    public static FilterWrapper getFilters (String sObjectType){
        sObjectType = GeneralUtils.prefix(sObjectType);
        Set<Id> clusterIds = getCurrentUserClusterTree();
        List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE id IN :clusterIds];
        List<RecordType> contentTypeList = [SELECT Id, Name FROM RecordType WHERE sObjectType = :sObjectType AND IsActive = true];
        List<Category__c> categoryList = [SELECT Id, Name FROM Category__c WHERE Cluster__c IN :clusterIds];
        List<Tag__c> tagList = [SELECT Id, Name FROM Tag__c WHERE Cluster__c IN :clusterIds];
    
        List<FilterOptionWrapper> clusterOptions = getClusterWrapperList(clusterList);
        List<FilterOptionWrapper> contentTypeOptions = getContentTypeWrapperList(contentTypeList);
        List<FilterOptionWrapper> categoryOptions = getCategoryWrapperList(categoryList);
        List<FilterOptionWrapper> tagOptions = getTagWrapperList(tagList);

        List<FilterSelectorWrapper> filterSelectorList = new List<FilterSelectorWrapper>();
        filterSelectorList.add(new FilterSelectorWrapper(System.Label.SearchContentClusterFilter, false, clusterOptions, ClusterUtils.prefix('[CMS]Cluster__c')));
        filterSelectorList.add(new FilterSelectorWrapper(System.Label.SearchContentTypeFilter, false, contentTypeOptions, 'RecordType'));
        filterSelectorList.add(new FilterSelectorWrapper(System.Label.SearchContentCategoryFilter, false, categoryOptions, ClusterUtils.prefix('[CMS]Category__c')));
        filterSelectorList.add(new FilterSelectorWrapper(System.Label.SearchContentTagFilter, true, tagOptions, ClusterUtils.prefix('[CMS]Tag__c')));
        FilterWrapper filters = new FilterWrapper(filterSelectorList);
        return filters;
    }

    private static List<FilterOptionWrapper> getClusterWrapperList(List<Cluster__c> clusterList){
        List<FilterOptionWrapper> clusters = new List<FilterOptionWrapper>();
        for(Cluster__c cluster : clusterList){
            FilterOptionWrapper clusterWrapper = new FilterOptionWrapper(cluster.name, cluster.Id);
            clusters.add(clusterWrapper);
        }
        return clusters;
    }

    private static List<FilterOptionWrapper> getContentTypeWrapperList(List<RecordType> contentTypeList){
        List<FilterOptionWrapper> contentTypes = new List<FilterOptionWrapper>();
        for(RecordType contentType : contentTypeList){
            FilterOptionWrapper contentTypeWrapper = new FilterOptionWrapper(contentType.name, contentType.Id);
            contentTypes.add(contentTypeWrapper);
        }
        return contentTypes;
    }

    private static List<FilterOptionWrapper> getCategoryWrapperList(List<Category__c> categoryList){
        List<FilterOptionWrapper> categories = new List<FilterOptionWrapper>();
        for(Category__c category : categoryList){
            FilterOptionWrapper categoryWrapper = new FilterOptionWrapper(category.name, category.Id);
            categories.add(categoryWrapper);
        }
        return categories;
    }

    private static List<FilterOptionWrapper> getTagWrapperList(List<Tag__c> tagList){
        List<FilterOptionWrapper> tags = new List<FilterOptionWrapper>();
        for(Tag__c tag : tagList){
            FilterOptionWrapper tagWrapper = new FilterOptionWrapper(tag.name, tag.Id);
            tags.add(tagWrapper);
        }
        return tags;
    }

    private static Set<Id> getCurrentUserClusterTree(){
        
        List<ClusterUser__c> clusterUser = [SELECT Cluster__c FROM ClusterUser__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        if(!clusterUser.isEmpty()){
            Set<Id> clusters =  ClusterUtils.getEntireClusterBranch(clusterUser.get(0).Cluster__c);
            return clusters;
        }
        return null;
        
    }
    
}