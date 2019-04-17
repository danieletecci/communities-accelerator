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
                  DesktopFileExtension__c, MobileFileExtension__c, TabletFileExtension__c
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

        system.debug('mew: ' + mew);


        return mew;
    }

    public static void retrieveLastModifiedAndSize (MediaElementWrapper mediaW){
        ContentDocument document;
        String idFile;

        if(mediaW.mediaElement.FileURLDesktop!=null){
            idFile= getIDFromUrl(mediaW.mediaElement.FileURLDesktop);
            document = [SELECT LastModifiedDate, ContentSize FROM ContentDocument where Id=:idFile];
            mediaW.lastModifiedDesktop= Date.newInstance(document.LastModifiedDate.year(), document.LastModifiedDate.month(), document.LastModifiedDate.day());
            mediaW.fileSizeDesktop= (document.ContentSize/1000) + 'KB ';
            mediaW.urlViewDesktop = CMSSettings__c.getInstance().SalesforceDomain__c + '/lightning/r/ContentDocument/' + idFile+'/view';
        }
        if(mediaW.mediaElement.FileURLTablet!=null){
            idFile= getIDFromUrl(mediaW.mediaElement.FileURLTablet);
            document = [SELECT LastModifiedDate, ContentSize FROM ContentDocument where Id=:idFile];
            mediaW.lastModifiedTablet= Date.newInstance(document.LastModifiedDate.year(), document.LastModifiedDate.month(), document.LastModifiedDate.day());
            mediaW.fileSizeTablet= (document.ContentSize/1000) + 'KB ';
            mediaW.urlViewTablet = CMSSettings__c.getInstance().SalesforceDomain__c + '/lightning/r/ContentDocument/' + idFile+'/view';
        }
        if(mediaW.mediaElement.FileURLMobile!=null){
            idFile= getIDFromUrl(mediaW.mediaElement.FileURLMobile);
            document = [SELECT LastModifiedDate, ContentSize FROM ContentDocument where Id=:idFile];
            mediaW.lastModifiedMobile= Date.newInstance(document.LastModifiedDate.year(), document.LastModifiedDate.month(), document.LastModifiedDate.day());
            mediaW.fileSizeMobile= (document.ContentSize/1000) + 'KB ';
            mediaW.urlViewMobile = CMSSettings__c.getInstance().SalesforceDomain__c + '/lightning/r/ContentDocument/' + idFile+'/view';
        }
    }

	@AuraEnabled
    public static String getFileById(String contentDocumentId){
        ContentVersion contv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];
        system.debug('contv: ' + contv);

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
        
        String url = CMSSettings__c.getInstance().SalesforceDomain__c + '/sfc/servlet.shepherd/document/download/' + contv.ContentDocumentId;
        
        MediaElement__c media = new MediaElement__c(Id = recordId);
        if(device == 'Desktop'){
            
        	media.FileNameDesktop__c = contv.Title;
			media.FileURLDesktop__c = url;
			media.WidthDesktop__c = Decimal.valueOf(width);
			media.HeightDesktop__c = Decimal.valueOf(height);
			media.DesktopFileExtension__c = contv.FileExtension;
        }
        if(device == 'Tablet'){
        	media.FileNameTablet__c = contv.Title;
			media.FileURLTablet__c = url;
			media.WidthTablet__c = Decimal.valueOf(width);
			media.HeightTablet__c = Decimal.valueOf(height);
			media.TabletFileExtension__c = contv.FileExtension;
        }
        if(device == 'Mobile'){
			media.FileNameMobile__c = contv.Title;
			media.FileURLMobile__c = url;
			media.WidthMobile__c = Decimal.valueOf(width);
			media.HeightMobile__c = Decimal.valueOf(height);
			media.MobileFileExtension__c = contv.FileExtension;
        }
        update media;

    	return media.Id;
    }
    


    public static String getIDFromUrl(String fileURL){
        String[] parts =fileURL.split('/');
        String idFile= parts[(parts.size()-1)];
        System.debug('idFile: ' + idFile);
        return idFile;
    }


    @AuraEnabled
    public static void deleteDocument(String urlDocument){
        String idFile= getIDFromUrl(urlDocument);
        ContentDocument document = new ContentDocument(Id = idFile);
        Delete(document);
    }

    @AuraEnabled
    public static void deleteFileDesktop(String recordId){
            
        MediaElement__c media = MediaElementUploadController.getMedia(recordId);
        MediaElementUploadController.deleteDocument(media.FileURLDesktop__c);

        media.DesktopFileExtension__c=null;
        media.FileNameDesktop__c=null;
        media.FileURLDesktop__c=null;
        media.HeightDesktop__c=null;
        media.WidthDesktop__c=null;
        update(media);
            
    }

    @AuraEnabled
    public static void deleteFileTablet(String recordId){
            
        MediaElement__c media = MediaElementUploadController.getMedia(recordId);
        MediaElementUploadController.deleteDocument(media.FileURLTablet__c);

        media.TabletFileExtension__c=null;
        media.FileNameTablet__c=null;
        media.FileURLTablet__c=null;
        media.HeightTablet__c=null;
        media.WidthTablet__c=null;
        update(media);
            
    }

    @AuraEnabled
    public static void deleteFileMobile(String recordId){
            
        MediaElement__c media = MediaElementUploadController.getMedia(recordId);
        MediaElementUploadController.deleteDocument(media.FileURLMobile__c);

        media.MobileFileExtension__c=null;
        media.FileNameMobile__c=null;
        media.FileURLMobile__c=null;
        media.HeightMobile__c=null;
        media.WidthMobile__c=null;
        update(media);
            
    }

}