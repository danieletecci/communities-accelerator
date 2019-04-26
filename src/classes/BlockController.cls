public with sharing class BlockController extends ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device, String navigationUrl){
        BlockController ctrl = new BlockController();
        ComponentWrapper cw = new ComponentWrapper();
        ctrl.customPermissionEdit = 'Block Edit Frame';
        ctrl.customPermissionView = 'Block View Frame';

        ctrl.componentFieldSet = new Set<String>{
            '[CMS]NumberOfColumns__c',
            '[CMS]LinkDetail__r.[CMS]URL__c',
            '[CMS]PagingType__c'
        };     
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;
        ctrl.navigationUrl = navigationUrl;
        cw = ctrl.getCW();

        ContentManager.CMSContent dw = (ContentManager.CMSContent) cw.data;
        
        if(!dw.contentWrapper.isEmpty()){
            cw.permissions.isEnabledEditFrame = false;
        }
        return cw;
    }

    public override DataWrapper getData() {
        
        Set<String> contentSetFields = new Set<String>{
            'Id',
            'Name',
            '[CMS]Title__c',
            '[CMS]Extract__c',
            '[CMS]LinkDetail__r.[CMS]URL__c',
            '[CMS]ExternalId__c'
        };
        
        return ContentManager.getCMSContent(clusterId, cw.meta.component, contentSetFields, device);
    }

    @auraEnabled
    public static List<ContentManager.ContentWrapper> getPage(List<String> listAllContentIds, String componentType, String pageSize, String pageNumber, String orderBy, String device){
        set<String> setAllContentIds = new set<String>();
        setAllContentIds.addAll(listAllContentIds);

        Set<String> contentSetFields = new Set<String>{
            'Id',
            'Name',
            '[CMS]Title__c',
            '[CMS]Extract__c',
            '[CMS]LinkDetail__r.[CMS]URL__c',
            '[CMS]ExternalId__c'
        };

        List<ContentUtils.ContentDataWrapper> contentDataWrapper = ContentUtils.getContentPage(
            setAllContentIds,
            contentSetFields,
            Integer.valueOf(pageNumber),
            Integer.valueOf(pageSize),
            orderBy,
            device,
            componentType
        );

        List<ContentManager.ContentWrapper> content = ContentManager.convertCMSDataToWrapper(contentDataWrapper);
        return content;
    }

}