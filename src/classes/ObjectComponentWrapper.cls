public class ObjectComponentWrapper {
    
    @AuraEnabled public String Id;
    @AuraEnabled public String Name;
    @AuraEnabled public String RecordTypeId;
    @AuraEnabled public String RecordTypeName;
    @AuraEnabled public String RecordTypeDeveloperName;

    @AuraEnabled public String ArticleType;
    @AuraEnabled public Boolean AutomaticTransition;
    @AuraEnabled public String BannerFrameType;
    @AuraEnabled public Decimal BannerTransitionTime;
    @AuraEnabled public String BannerType;
    @AuraEnabled public String Cluster;
    @AuraEnabled public String ClusterExternalId;
    @AuraEnabled public String HierarchicalOrderBy;
    @AuraEnabled public String Datasource;
    @AuraEnabled public Decimal DelayTime;
    @AuraEnabled public String Direction;
    @AuraEnabled public String EventsType;
    @AuraEnabled public Boolean ExcludePastEvents;
    @AuraEnabled public String ExternalId;
    @AuraEnabled public String FieldsToSearch;
    @AuraEnabled public String FirstCluster;
    @AuraEnabled public Boolean HasDelay;
    @AuraEnabled public String LinkDetail;
    //Loop is a reserved word
    @AuraEnabled public Boolean LoopField;
    @AuraEnabled public String MatchCriteria;
    @AuraEnabled public String Mode;
    @AuraEnabled public String NavigationMode;
    @AuraEnabled public Boolean OnlyClusterLeaf;
    @AuraEnabled public String OrderBy;
    @AuraEnabled public String OrderByAdvance;
    @AuraEnabled public String Orientation;
    @AuraEnabled public Decimal PageSize;
    @AuraEnabled public String PagingType;
    @AuraEnabled public Boolean PredictiveSearchEnabled;
    @AuraEnabled public String SearchPlaceholder;
    @AuraEnabled public Boolean ShowBullets;
    @AuraEnabled public Boolean ShowDisplayMode;
    @AuraEnabled public Boolean ShowFilters;
    @AuraEnabled public Boolean ShowOrder;
    @AuraEnabled public Boolean ShowSearch;
    @AuraEnabled public String Status;
    @AuraEnabled public String StatusApprovalProcess;
    @AuraEnabled public String TagCriteria;
    @AuraEnabled public String Title;
    @AuraEnabled public String NumberOfColumns;

    @AuraEnabled public String LinkDetailURL;
    
    public ObjectComponentWrapper(Component__c component){
        try{this.Id = component.Id;}catch(Exception e){}
        try{this.Name = component.Name;}catch(Exception e){}
        try{this.RecordTypeId = component.RecordTypeId;}catch(Exception e){}
        try{this.RecordTypeName = component.RecordType.Name;}catch(Exception e){}
        try{this.RecordTypeDeveloperName = component.RecordType.DeveloperName;}catch(Exception e){}

        try{this.ArticleType = component.ArticleType__c;}catch(Exception e){}
        try{this.AutomaticTransition = component.AutomaticTransition__c;}catch(Exception e){}
        try{this.BannerFrameType = component.BannerFrameType__c;}catch(Exception e){}
        try{this.BannerTransitionTime = component.BannerTransitionTime__c;}catch(Exception e){}
        try{this.BannerType = component.BannerType__c;}catch(Exception e){}
        try{this.Cluster = component.Cluster__c;}catch(Exception e){}
        try{this.ClusterExternalId = component.ClusterExternalId__c;}catch(Exception e){}
        try{this.HierarchicalOrderBy = component.HierarchicalOrderBy__c;}catch(Exception e){}
        try{this.Datasource = component.Datasource__c;}catch(Exception e){}
        try{this.DelayTime = component.DelayTime__c;}catch(Exception e){}
        try{this.Direction = component.Direction__c;}catch(Exception e){}
        try{this.EventsType = component.EventsType__c;}catch(Exception e){}
        try{this.ExcludePastEvents = component.ExcludePastEvents__c;}catch(Exception e){}
        try{this.ExternalId = component.ExternalId__c;}catch(Exception e){}
        try{this.FieldsToSearch = component.FieldsToSearch__c;}catch(Exception e){}
        try{this.FirstCluster = component.FirstCluster__c;}catch(Exception e){}
        try{this.HasDelay = component.HasDelay__c;}catch(Exception e){}
        try{this.LinkDetail = component.LinkDetail__c;}catch(Exception e){}
        try{this.LoopField = component.Loop__c;}catch(Exception e){}
        try{this.MatchCriteria = component.MatchCriteria__c;}catch(Exception e){}
        try{this.Mode = component.Mode__c;}catch(Exception e){}
        try{this.NavigationMode = component.NavigationMode__c;}catch(Exception e){}
        try{this.OnlyClusterLeaf = component.OnlyClusterLeaf__c;}catch(Exception e){}
        try{this.OrderBy = component.OrderBy__c;}catch(Exception e){}
        try{this.OrderByAdvance = component.OrderByAdvance__c;}catch(Exception e){}
        try{this.Orientation = component.Orientation__c;}catch(Exception e){}
        try{this.PageSize = component.PageSize__c;}catch(Exception e){}
        try{this.PagingType = component.PagingType__c;}catch(Exception e){}
        try{this.PredictiveSearchEnabled = component.PredictiveSearchEnabled__c;}catch(Exception e){}
        try{this.SearchPlaceholder = component.SearchPlaceholder__c;}catch(Exception e){}
        try{this.ShowBullets = component.ShowBullets__c;}catch(Exception e){}
        try{this.ShowDisplayMode = component.ShowDisplayMode__c;}catch(Exception e){}
        try{this.ShowFilters = component.ShowFilters__c;}catch(Exception e){}
        try{this.ShowOrder = component.ShowOrder__c;}catch(Exception e){}
        try{this.ShowSearch = component.ShowSearch__c;}catch(Exception e){}
        try{this.Status = component.Status__c;}catch(Exception e){}
        try{this.StatusApprovalProcess = component.StatusApprovalProcess__c;}catch(Exception e){}
        try{this.TagCriteria = component.TagCriteria__c;}catch(Exception e){}
        try{this.RecordtypeDeveloperName = component.Recordtype.DeveloperName;}catch(Exception e){}
        try{this.Title = component.Title__c;}catch(Exception e){}
        try{this.NumberOfColumns = component.NumberOfColumns__c;}catch(Exception e){}

        try{this.LinkDetailURL = component.LinkDetail__r.URL__c;}catch(Exception e){}
    }

}