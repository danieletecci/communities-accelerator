public class ObjectComponentWrapper {
    
    public String Id;
    public String Name;
    public String RecordTypeId;
    public String RecordTypeName;
    public String RecordTypeDeveloperName;

    public String ArticleType;
    public Boolean AutomaticTransition;
    public String BannerFrameType;
    public Decimal BannerTransitionTime;
    public String BannerType;
    public String Cluster;
    public String ClusterExternalId;
    public String HierarchicalOrderBy;
    public String Datasource;
    public Decimal DelayTime;
    public String Direction;
    public String EventsType;
    public Boolean ExcludePastEvents;
    public String ExternalId;
    public String FieldsToSearch;
    public String FirstCluster;
    public Boolean HasDelay;
    public String LinkDetail;
    //Loop is a reserved word
    public Boolean LoopField;
    public String MatchCriteria;
    public String Mode;
    public String NavigationMode;
    public Boolean OnlyClusterLeaf;
    public String OrderBy;
    public String OrderByAdvance;
    public String Orientation;
    public Decimal PageSize;
    public String PagingType;
    public Boolean PredictiveSearchEnabled;
    public String SearchPlaceholder;
    public Boolean ShowBullets;
    public Boolean ShowDisplayMode;
    public Boolean ShowFilters;
    public Boolean ShowOrder;
    public Boolean ShowSearch;
    public String Status;
    public String StatusApprovalProcess;
    public String TagCriteria;

    public String LinkDetailURL;
    
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

        try{this.LinkDetailURL = component.LinkDetail__r.URL__c;}catch(Exception e){}
    }

}