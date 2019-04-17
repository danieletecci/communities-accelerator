public class ObjectContentWrapper {
    
    public String Id;
    public String Name;
    public String RecordTypeId;
    public String RecordTypeName;
    public String RecordTypeDeveloperName;

    public Datetime PublishedDate;
    public String Audience;
    public String BannerFrameType;
    public String Body;
    public String ButtonLabel;
    public String Category;
    public String Cluster;
    public String ClusterRootExternalId;
    public String ContentRedirect;
    public String Description;
    public String EventDates;
    public Datetime EventEndDate;
    public Datetime EventStartDate;
    public Datetime EventStartDay;
    public Datetime EventStartMonth;
    public String ExternalId;
    public String Extract;
    public String HTMLContent;
    public Boolean IsActive;
    public Boolean IsTemplate;
    public String Layout;
    public String LinkDetail;
    public String Location;
    public Decimal Order;
    public String OverlayQuadrant;
    public Datetime PublishEndDate;
    public String PublishStartDate;
    public String RedirectType;
    public String Status;
    public String StatusApprovalProcess;
    public String StructureComponent;
    public String StructureNavigation;
    public String TemplateDescription;
    public String TemplateUsed;
    public String Title;
    public String URLRedirect;
    
    public ObjectContentWrapper(Content__c content){
        try{this.Id = content.Id;}catch(Exception e){}
        try{this.Name = content.Name;}catch(Exception e){}
        try{this.RecordTypeId = content.RecordTypeId;}catch(Exception e){}
        try{this.RecordTypeName = content.RecordType.Name;}catch(Exception e){}
        try{this.RecordTypeDeveloperName = content.RecordType.DeveloperName;}catch(Exception e){}
        try{this.PublishedDate = content.PublishedDate__c;}catch(Exception e){}
        try{this.Audience = content.Audience__c;}catch(Exception e){}
        try{this.BannerFrameType = content.BannerFrameType__c;}catch(Exception e){}
        try{this.Body = content.Body__c;}catch(Exception e){}
        try{this.ButtonLabel = content.ButtonLabel__c;}catch(Exception e){}
        try{this.Category = content.Category__c;}catch(Exception e){}
        try{this.Cluster = content.Cluster__c;}catch(Exception e){}
        try{this.ClusterRootExternalId = content.ClusterRootExternalId__c;}catch(Exception e){}
        try{this.ContentRedirect = content.ContentRedirect__c;}catch(Exception e){}
        try{this.Description = content.Description__c;}catch(Exception e){}
        try{this.EventDates = content.EventDates__c;}catch(Exception e){}
        try{this.EventEndDate = content.EventEndDate__c;}catch(Exception e){}
        try{this.EventStartDate = content.EventStartDate__c;}catch(Exception e){}
        try{this.EventStartDay = content.EventStartDay__c;}catch(Exception e){}
        try{this.EventStartMonth = content.EventStartMonth__c;}catch(Exception e){}
        try{this.ExternalId = content.ExternalId__c;}catch(Exception e){}
        try{this.Extract = content.Extract__c;}catch(Exception e){}
        try{this.HTMLContent = content.HTMLContent__c;}catch(Exception e){}
        try{this.IsActive = content.IsActive__c;}catch(Exception e){}
        try{this.IsTemplate = content.IsTemplate__c;}catch(Exception e){}
        try{this.Layout = content.Layout__c;}catch(Exception e){}
        try{this.LinkDetail = content.LinkDetail__c;}catch(Exception e){}
        try{this.Location = content.Location__c;}catch(Exception e){}
        try{this.Order = content.Order__c;}catch(Exception e){}
        try{this.OverlayQuadrant = content.OverlayQuadrant__c;}catch(Exception e){}
        try{this.PublishEndDate = content.PublishEndDate__c;}catch(Exception e){}
        try{this.PublishStartDate = content.PublishStartDate__c;}catch(Exception e){}
        try{this.RedirectType = content.RedirectType__c;}catch(Exception e){}
        try{this.Status = content.Status__c;}catch(Exception e){}
        try{this.StatusApprovalProcess = content.StatusApprovalProcess__c;}catch(Exception e){}
        try{this.StructureComponent = content.StructureComponent__c;}catch(Exception e){}
        try{this.StructureNavigation = content.StructureNavigation__c;}catch(Exception e){}
        try{this.TemplateDescription = content.TemplateDescription__c;}catch(Exception e){}
        try{this.TemplateUsed = content.TemplateUsed__c;}catch(Exception e){}
        try{this.Title = content.Title__c;}catch(Exception e){}
        try{this.URLRedirect = content.URLRedirect__c;}catch(Exception e){}
    }

}