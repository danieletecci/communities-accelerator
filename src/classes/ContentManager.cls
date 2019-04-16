public with sharing class ContentManager {
    
    public class CMSContent extends ComponentManager.DataWrapper {
        @auraEnabled public List<String> listAllContentIds;
        @auraEnabled public List<ContentWrapper> contentWrapper;
        @auraEnabled public List<Integer> pagesNumbers;
    }

    public class ContentWrapper{
        @auraEnabled public Content__c content;
        @auraEnabled public List<MediaElement__c> mediaElements;
    }

    public static CMSContent getCMSContent(String clusterId, Component__c component, Set<String> contentSetFields, String device) {
        ContentManager.CMSContent cmsContent = new ContentManager.CMSContent();

        Set<String> setClusterIds = ClusterUtils.getClustersParents(clusterId);

        ContentUtils.ContentWrapper contentWrapper = ContentUtils.getContentFromComponent(component, contentSetFields, null, null, setClusterIds, device);

        cmsContent.listAllContentIds = new List<String>();
        cmsContent.contentWrapper = new List<ContentWrapper>();
        cmsContent.pagesNumbers = new List<Integer>();
        
        if(contentWrapper != null){
            if(contentWrapper.setAllContentIds != null){
                cmsContent.listAllContentIds.addAll(contentWrapper.setAllContentIds); 
            }
            if(contentWrapper.contentDataPage != null){
                cmsContent.contentWrapper = convertCMSDataToWrapper(contentWrapper.contentDataPage);
            }
            if(contentWrapper.totalPages != null){
                for(Integer i = 1; i <= contentWrapper.totalPages; i++){
                    cmsContent.pagesNumbers.add(i);
                }
            }
        }
        return cmsContent;
    }

    public static List<ContentWrapper> convertCMSDataToWrapper(List<ContentUtils.ContentDataWrapper> contentDataWrapper){
        List<ContentWrapper> contentWrapper = new List<ContentWrapper>();
        for(ContentUtils.ContentDataWrapper cdw: contentDataWrapper){
            ContentWrapper cw = new ContentWrapper();
            cw.content = cdw.content;
            cw.mediaElements = cdw.mediaElements;
            contentWrapper.add(cw);
        }
        return contentWrapper;
    }
}