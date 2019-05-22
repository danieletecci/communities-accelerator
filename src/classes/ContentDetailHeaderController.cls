public with sharing class ContentDetailHeaderController {
    //DATA WRAPPER
    public class DataWrapper{
        @AuraEnabled public ObjectContentWrapper    content;
        @AuraEnabled public String                  timeZone;
        @AuraEnabled public String                  gmtOffset;
        @AuraEnabled public SecurityWrapper         security;
        @AuraEnabled public String                  namespace;
        
        public DataWrapper(Content__c content, String timeZone, String gmtOffset, SecurityWrapper security){
            this.content            = new ObjectContentWrapper(content);
            this.timeZone           = timeZone;
            this.gmtOffset          = gmtOffset;
            this.security           = security;
            this.namespace          = GeneralUtils.getNameSpace();
        }
    }

    public class SecurityWrapper{
        @AuraEnabled public Boolean     hasEditAccess;
        @AuraEnabled public Boolean     hasCreateContentPermission;
        @AuraEnabled public Boolean     hasDeleteAccess;
        @AuraEnabled public Boolean     canPublish;
        @AuraEnabled public Boolean     canSchedule;

        public SecurityWrapper(Boolean hasEditAccess, Boolean hasDeleteAccess, Boolean hasCreateContentPermission){
            this.hasEditAccess              = hasEditAccess;
            this.hasDeleteAccess            = hasDeleteAccess;
            this.hasCreateContentPermission = hasCreateContentPermission;
        }
    }

    @AuraEnabled(cacheable=false)
    public static DataWrapper getData(String recordId){
        Content__c content = getContentData(recordId);
        UserRecordAccess ura = SecurityUtils.getUserRecordAccess(recordId);
        
        Boolean hasContentEditPublishedPerm = SecurityUtils.hasCustomPermission(GeneralUtils.prefix('[CMS]ContentEditPublished'));
        Boolean hasContentEditScheduledPerm = SecurityUtils.hasCustomPermission(GeneralUtils.prefix('[CMS]ContentEditScheduled'));
        Boolean hasContentCreateTemplatePerm = SecurityUtils.hasCustomPermission(GeneralUtils.prefix('[CMS]ContentCreateTemplate'));
        Boolean isObjectCreateable = SecurityUtils.isObjectCreateable(GeneralUtils.prefix('[CMS]Content__c'));
        
        SecurityWrapper sw = new SecurityWrapper(
            ura.HasEditAccess && ((content.Status__c == Label.ContentDetailPublished) ? hasContentEditPublishedPerm : ((content.Status__c == Label.ContentDetailScheduled) ? hasContentEditScheduledPerm : true)),
            ura.HasDeleteAccess, 
            isObjectCreateable
        );
        sw.canPublish = hasContentEditPublishedPerm;
        sw.canSchedule = hasContentEditScheduledPerm;

        String tzName = UserInfo.getTimeZone().getDisplayName();
        
        return new DataWrapper(
            content,
            UserInfo.getTimeZone().getID(), 
            tzName.substring(tzName.indexOf('GMT')+3, tzName.indexOf(')')), 
            sw
        );
    }

    @AuraEnabled
    public static String setName(String recordId, String name){
        Content__c c = new Content__c(Id=recordId, Name=name);
        update c;
        return c.Name;
    }

    @AuraEnabled
    public static String setStatus(String recordId, String status, DateTime publishStartDate, DateTime publishEndDate){
        Content__c c = new Content__c(
            Id                  = recordId, 
            Status__c           = status, 
            PublishStartDate__c = publishStartDate, 
            PublishEndDate__c   = publishEndDate
        );
        try{
            update c;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return c.Status__c;
    }

    @AuraEnabled
    public static void deleteContent(String recordId){
        Content__c c = new Content__c(
            Id                  = recordId
        );
        try{
            delete c;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createFromTemplate(String recordId){
        return null; //ContentUtils.createFromTemplate(recordId);
    }

    private static Content__c getContentData(String recordId){
        Content__c content = [SELECT Id, Name, Cluster__r.Name, Status__c, PublishStartDate__c, PublishEndDate__c, LastModifiedDate, IsTemplate__c, CreatedBy.Name, RecordType.Name, RecordType.DeveloperName FROM Content__c WHERE id = :recordId];
        return content;
    }
}