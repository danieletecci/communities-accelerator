public with sharing class MediaElementUploadController {

    //WRAPPERS
    public class MediaElementWrapper{
        @auraEnabled public CustomSettingWrapper acceleratorSettings;
        @auraEnabled public ObjectMediaElementWrapper mediaElement;
        @auraEnabled public Date lastModifiedDesktop;
        @auraEnabled public Date lastModifiedTablet;
        @auraEnabled public Date lastModifiedMobile;
        @auraEnabled public String fileSizeDesktop;
        @auraEnabled public String fileSizeTablet;
        @auraEnabled public String fileSizeMobile;
        @auraEnabled public String urlViewDesktop;
        @auraEnabled public String urlViewTablet;
        @auraEnabled public String urlViewMobile;
        public MediaElementWrapper(){
            this.acceleratorSettings = new CustomSettingWrapper(CMSSettings__c.getInstance(), CMSContentSettings__c.getInstance(), CMSMediaElementSettings__c.getInstance());
        }
    }

    public static MediaElement__c getMedia(String recordId){
        MediaElement__c media = [SELECT Id, ExternalId__c,
                  FileNameDesktop__c, FileNameMobile__c, FileNameTablet__c,
                  FileURLDesktop__c, FileURLMobile__c, FileURLTablet__c,
                  HeightDesktop__c, HeightMobile__c, HeightTablet__c,
                  WidthDesktop__c, WidthMobile__c, WidthTablet__c,
                  DesktopFileExtension__c, MobileFileExtension__c, TabletFileExtension__c,
                  FileIdDesktop__c, FileIdTablet__c, FileIdMobile__c
                  FROM MediaElement__c
                  WHERE Id =: recordId];  
        return media;      
    }

    @AuraEnabled
    public static MediaElementWrapper getRecord(String recordId){
        MediaElement__c me = MediaElementUploadController.getMedia(recordId);
        MediaElementWrapper mew = new MediaElementWrapper();
        mew.mediaElement = new ObjectMediaElementWrapper(me);
        MediaElementUploadController.retrieveLastModifiedAndSize(mew);
        return mew;
    }

    public static void retrieveLastModifiedAndSize(MediaElementWrapper mediaW){
        ContentDocument document;
        String idFile;

        if(mediaW.mediaElement.FileIdDesktop!=null){
            document = [SELECT LastModifiedDate, ContentSize FROM ContentDocument where Id =: mediaW.mediaElement.FileIdDesktop];
            mediaW.lastModifiedDesktop= Date.newInstance(document.LastModifiedDate.year(), document.LastModifiedDate.month(), document.LastModifiedDate.day());
            mediaW.fileSizeDesktop= (document.ContentSize/1000) + 'KB ';
            mediaW.urlViewDesktop = mediaW.mediaElement.FileURLDesktop;
        }
        if(mediaW.mediaElement.FileURLTablet!=null){
            document = [SELECT LastModifiedDate, ContentSize FROM ContentDocument where Id =: mediaW.mediaElement.FileIdTablet];
            mediaW.lastModifiedTablet= Date.newInstance(document.LastModifiedDate.year(), document.LastModifiedDate.month(), document.LastModifiedDate.day());
            mediaW.fileSizeTablet= (document.ContentSize/1000) + 'KB ';
            mediaW.urlViewTablet = mediaW.mediaElement.FileURLTablet;
        }
        if(mediaW.mediaElement.FileURLMobile!=null){
            document = [SELECT LastModifiedDate, ContentSize FROM ContentDocument where Id=:mediaW.mediaElement.FileIdMobile];
            mediaW.lastModifiedMobile= Date.newInstance(document.LastModifiedDate.year(), document.LastModifiedDate.month(), document.LastModifiedDate.day());
            mediaW.fileSizeMobile= (document.ContentSize/1000) + 'KB ';
            mediaW.urlViewMobile = mediaW.mediaElement.FileURLMobile;
        }
    }

    @AuraEnabled
    public static String getFileById(String contentDocumentId){
        ContentVersion contv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];
        return EncodingUtil.base64Encode(contv.VersionData);
    }
    
    @AuraEnabled
    public static String createFile(String recordId, String fileId, String base64Str, String fileName, String width, String height, String device){ 
        ContentVersion contv;

        if(fileId != null && fileId != ''){
            contv = [SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: fileId];
        }else{
            //Creacion del ContentVersion
            contv = new ContentVersion(
                ContentLocation = 'S',
                VersionData = EncodingUtil.base64Decode( base64Str.substring(base64Str.indexOf(',') + 1) ),
                Title = fileName,
                PathOnClient = filename
            );
            insert contv;
            contv = [SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE Id =: contv.Id];

            insert new ContentDocumentLink(
                ContentDocumentId = contv.ContentDocumentId,
                LinkedEntityId = recordId,
                ShareType = 'V'
            );
        }

        ContentDistribution cd = new ContentDistribution(
            Name = 'PublicLink',
            ContentVersionId = contv.id,
            PreferencesAllowViewInBrowser= true,
            PreferencesLinkLatestVersion=true,
            PreferencesNotifyOnVisit=false,
            PreferencesPasswordRequired=false,
            PreferencesAllowOriginalDownload= true
        );
        insert cd;

        ContentDistribution cdu = [SELECT ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contv.ContentDocumentId];
        String contentDistributionPublicUrl = cdu.DistributionPublicUrl;
        String contentContentDownloadUrl = cdu.ContentDownloadUrl;

        MediaElement__c media = new MediaElement__c(Id = recordId);
        if(device == 'Desktop'){
            media.FileNameDesktop__c = contv.Title;
            media.FileURLDesktop__c = contentContentDownloadUrl;
            media.WidthDesktop__c = Decimal.valueOf(width);
            media.HeightDesktop__c = Decimal.valueOf(height);
            media.DesktopFileExtension__c = contv.FileExtension;
            media.FileIdDesktop__c = contv.ContentDocumentId;
        }
        if(device == 'Tablet'){
            media.FileNameTablet__c = contv.Title;
            media.FileURLTablet__c = contentContentDownloadUrl;
            media.WidthTablet__c = Decimal.valueOf(width);
            media.HeightTablet__c = Decimal.valueOf(height);
            media.TabletFileExtension__c = contv.FileExtension;
            media.FileIdTablet__c = contv.ContentDocumentId;
        }
        if(device == 'Mobile'){
            media.FileNameMobile__c = contv.Title;
            media.FileURLMobile__c = contentContentDownloadUrl;
            media.WidthMobile__c = Decimal.valueOf(width);
            media.HeightMobile__c = Decimal.valueOf(height);
            media.MobileFileExtension__c = contv.FileExtension;
            media.FileIdMobile__c = contv.ContentDocumentId;
        }
        update media;

        return media.Id;
    }

    @AuraEnabled
    public static void deleteDocument(String urlDocument){
        ContentDocument document = new ContentDocument(Id = urlDocument);
        delete document;
    }

    @AuraEnabled
    public static void deleteFileDesktop(String recordId){
        MediaElement__c media = MediaElementUploadController.getMedia(recordId);
        MediaElementUploadController.deleteDocument(media.FileIdDesktop__c);

        media.DesktopFileExtension__c=null;
        media.FileNameDesktop__c=null;
        media.FileURLDesktop__c=null;
        media.FileIdDesktop__c=null;
        media.HeightDesktop__c=null;
        media.WidthDesktop__c=null;
        update media;
    }

    @AuraEnabled
    public static void deleteFileTablet(String recordId){
        MediaElement__c media = MediaElementUploadController.getMedia(recordId);
        MediaElementUploadController.deleteDocument(media.FileIdTablet__c);

        media.TabletFileExtension__c=null;
        media.FileNameTablet__c=null;
        media.FileURLTablet__c=null;
        media.FileIdTablet__c=null;
        media.HeightTablet__c=null;
        media.WidthTablet__c=null;
        update media;
    }

    @AuraEnabled
    public static void deleteFileMobile(String recordId){
        MediaElement__c media = MediaElementUploadController.getMedia(recordId);
        MediaElementUploadController.deleteDocument(media.FileIdMobile__c);

        media.MobileFileExtension__c=null;
        media.FileNameMobile__c=null;
        media.FileURLMobile__c=null;
        media.FileIdMobile__c=null;
        media.HeightMobile__c=null;
        media.WidthMobile__c=null;
        update media;
    }

}