public with sharing class ContentDetailHeaderController {
    //DATA WRAPPER
    public class DataWrapper{
        @AuraEnabled public Content__c      content;
        @AuraEnabled public String          timeZone;
        @AuraEnabled public SecurityWrapper  security;
        
        public DataWrapper(Content__c content, String timeZone, SecurityWrapper security){
            this.content    = content;
            this.timeZone   = timeZone;
            this.security   = security;
        }
    }

    public class SecurityWrapper{
        @AuraEnabled public Boolean     hasEditAccess;
        @AuraEnabled public Boolean     hasCreateContentPermission;
        @AuraEnabled public Boolean     hasRecordTypeAvailable;
        @AuraEnabled public Boolean     hasDeleteAccess;

        public SecurityWrapper(Boolean hasEditAccess, Boolean hasDeleteAccess, Boolean hasCreateContentPermission, Boolean hasRecordTypeAvailable){
            this.hasEditAccess              = hasEditAccess;
            this.hasDeleteAccess            = hasDeleteAccess;
            this.hasCreateContentPermission = hasCreateContentPermission;
            this.hasRecordTypeAvailable     = hasRecordTypeAvailable;
        }
    }

    @AuraEnabled(cacheable=true)
    public static DataWrapper getData(String recordId){
        Content__c content = getContentData(recordId);
        UserRecordAccess ura = getRecordAccess(recordId);
        SecurityWrapper sw = new SecurityWrapper(ura.HasEditAccess, ura.HasDeleteAccess, hasCreateContentPermission(), hasRecordTypeAvailable(content.RecordType.DeveloperName));
        return new DataWrapper(getContentData(recordId), UserInfo.getTimeZone().getID(), sw);
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
        return ContentUtils.createFromTemplate(recordId);
    }

    private static Content__c getContentData(String recordId){
        Content__c content = [SELECT Id, Name, Cluster__r.Name, Status__c, PublishStartDate__c, PublishEndDate__c, LastModifiedDate, IsTemplate__c, CreatedBy.Name, RecordType.Name, RecordType.DeveloperName FROM Content__c WHERE id = :recordId];
        return content;
    }

    private static Boolean hasCreateContentPermission(){
        return Schema.sObjectType.Content__c.isCreateable();
    }

    private static UserRecordAccess getRecordAccess(String recordId){
        UserRecordAccess ura = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        return ura;
    }

    private static Boolean hasRecordTypeAvailable(String recordTypeDeveloperName){
        return Schema.SObjectType.Content__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).isAvailable();
    }
}