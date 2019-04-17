public with sharing class BannerController extends ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device,String navigationUrl){
        BannerController ctrl = new BannerController();
        ctrl.customPermissionEdit = 'Banner Edit Frame';
        ctrl.customPermissionView = 'Banner View Frame';
        ctrl.componentFieldSet = new Set<String>{
            '[CMS]BannerFrameType__c',
            '[CMS]Orientation__c',
            '[CMS]BannerType__c',
            '[CMS]ShowBullets__c',
            '[CMS]AutomaticTransition__c',
            '[CMS]BannerTransitionTime__c',
            '[CMS]Loop__c',
            '[CMS]Direction__c'
        };
        
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;
        ctrl.navigationUrl = navigationUrl;

        return ctrl.getCW();
    }

    public override DataWrapper getData() {
        
        Set<String> contentSetFields = new Set<String>{
            'Id',
            'Name',
            '[CMS]LinkDetail__r.[CMS]URL__c',
            '[CMS]OverlayQuadrant__c',
            '[CMS]Title__c',
            '[CMS]Extract__c',
            '[CMS]ButtonLabel__c',
            '[CMS]BannerFrameType__c'
        };
        
        return ContentManager.getCMSContent(clusterId, component, contentSetFields, device);
    }

}