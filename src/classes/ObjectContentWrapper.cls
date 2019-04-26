public class ObjectContentWrapper {
    
    @AuraEnabled public String Id;
    @AuraEnabled public String Name;
    @AuraEnabled public String RecordTypeId;
    @AuraEnabled public String RecordTypeName;
    @AuraEnabled public String RecordTypeDeveloperName;

    @AuraEnabled public Datetime PublishedDate;
    @AuraEnabled public String Audience;
    @AuraEnabled public String BannerFrameType;
    @AuraEnabled public String Body;
    @AuraEnabled public String ButtonLabel;
    @AuraEnabled public String Category;
    @AuraEnabled public String Cluster;
    @AuraEnabled public String ClusterRootExternalId;
    @AuraEnabled public String ContentRedirect;
    @AuraEnabled public String Description;
    @AuraEnabled public String EventDates;
    @AuraEnabled public Datetime EventEndDate;
    @AuraEnabled public Datetime EventStartDate;
    @AuraEnabled public String EventStartDay;
    @AuraEnabled public String EventStartMonth;
    @AuraEnabled public String ExternalId;
    @AuraEnabled public String Extract;
    @AuraEnabled public String HTMLContent;
    @AuraEnabled public Boolean IsActive;
    @AuraEnabled public Boolean IsTemplate = false;
    @AuraEnabled public String Layout;
    @AuraEnabled public String LinkDetail;
    @AuraEnabled public String Location;
    @AuraEnabled public Decimal Order;
    @AuraEnabled public String OverlayQuadrant;
    @AuraEnabled public Datetime PublishEndDate;
    @AuraEnabled public Datetime PublishStartDate;
    @AuraEnabled public String RedirectType;
    @AuraEnabled public String Status;
    @AuraEnabled public String StatusApprovalProcess;
    @AuraEnabled public String StructureComponent;
    @AuraEnabled public String StructureNavigation;
    @AuraEnabled public String TemplateDescription;
    @AuraEnabled public String TemplateUsed;
    @AuraEnabled public String Title;
    @AuraEnabled public String URLRedirect;
    @AuraEnabled public Datetime LastModifiedDate;
    @AuraEnabled public String CreatedByName;

    @AuraEnabled public String LinkDetailURL;
    @AuraEnabled public String ClusterName;

    @AuraEnabled public List<MediaElementAssignment> MediaElementAssignments;

    @AuraEnabled public List<TagAssignment> Tags;

    public class MediaElementAssignment{
        @AuraEnabled public ObjectMediaElementWrapper MediaElement;
    }

    public class TagAssignment{
        @AuraEnabled public String tag;
        @AuraEnabled public String id;
    }
    
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
        try{this.LastModifiedDate = content.LastModifiedDate;}catch(Exception e){}
        try{this.CreatedByName = content.CreatedBy.Name;}catch(Exception e){}

        try{this.LinkDetailURL = content.LinkDetail__r.URL__c;}catch(Exception e){}
        try{this.ClusterName = content.Cluster__r.Name;}catch(Exception e){}

        //Media Element Assignment
        try{
            this.MediaElementAssignments = new List<MediaElementAssignment>();
            for(MediaElementAssignment__c mea: content.MediaElementAssignments__r){
                MediaElementAssignment meas = new MediaElementAssignment();
                meas.MediaElement = new ObjectMediaElementWrapper(mea.MediaElement__r);
                this.MediaElementAssignments.add(meas);
            }
        }catch(Exception e){}
        
        //Tag Assignment
        try{
            this.Tags= new List<TagAssignment>();
            for(TagAssignment__c taga: content.Tags__r){
                TagAssignment tagas = new TagAssignment();
                try{tagas.tag = taga.Tag__c;}catch(Exception e){}
                try{tagas.id = taga.Id;}catch(Exception e){}
                
                this.Tags.add(tagas);
            }
        }catch(Exception e){}
        
    }

    public Content__c parse(){
        Content__c content = new Content__c(Id = this.Id);
        try{content.Name = this.Name;}catch(Exception e){}
        try{content.RecordTypeId = this.RecordTypeId;}catch(Exception e){}
        
        try{content.PublishedDate__c = this.PublishedDate;}catch(Exception e){}
        try{content.Audience__c = this.Audience;}catch(Exception e){}
        try{content.BannerFrameType__c = this.BannerFrameType;}catch(Exception e){}
        try{content.Body__c = this.Body;}catch(Exception e){}
        try{content.ButtonLabel__c = this.ButtonLabel;}catch(Exception e){}
        try{content.Category__c = this.Category;}catch(Exception e){}
        try{content.Cluster__c = this.Cluster;}catch(Exception e){}
        try{content.ContentRedirect__c = this.ContentRedirect;}catch(Exception e){}
        try{content.Description__c = this.Description;}catch(Exception e){}
        try{content.EventEndDate__c = this.EventEndDate;}catch(Exception e){}
        try{content.EventStartDate__c = this.EventStartDate;}catch(Exception e){}
        try{content.ExternalId__c = this.ExternalId;}catch(Exception e){}
        try{content.Extract__c = this.Extract;}catch(Exception e){}
        try{content.HTMLContent__c = this.HTMLContent;}catch(Exception e){}
        try{content.IsTemplate__c = this.IsTemplate;}catch(Exception e){}
        try{content.Layout__c = this.Layout;}catch(Exception e){}
        try{content.LinkDetail__c = this.LinkDetail;}catch(Exception e){}
        try{content.Location__c = this.Location;}catch(Exception e){}
        try{content.Order__c = this.Order;}catch(Exception e){}
        try{content.OverlayQuadrant__c = this.OverlayQuadrant;}catch(Exception e){}
        try{content.PublishEndDate__c = this.PublishEndDate;}catch(Exception e){}
        try{content.PublishStartDate__c = this.PublishStartDate;}catch(Exception e){}
        try{content.RedirectType__c = this.RedirectType;}catch(Exception e){}
        try{content.Status__c = this.Status;}catch(Exception e){}
        try{content.StatusApprovalProcess__c = this.StatusApprovalProcess;}catch(Exception e){}
        try{content.StructureComponent__c = this.StructureComponent;}catch(Exception e){}
        try{content.StructureNavigation__c = this.StructureNavigation;}catch(Exception e){}
        try{content.TemplateDescription__c = this.TemplateDescription;}catch(Exception e){}
        try{content.TemplateUsed__c = this.TemplateUsed;}catch(Exception e){}
        try{content.Title__c = this.Title;}catch(Exception e){}
        try{content.URLRedirect__c = this.URLRedirect;}catch(Exception e){}
        return content;
    }

}