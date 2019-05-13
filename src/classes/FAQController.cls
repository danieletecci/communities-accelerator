public with sharing class FAQController extends ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device, String navigationUrl){
        FAQController ctrl = new FAQController();
        ComponentWrapper cw = new ComponentWrapper();
        ctrl.customPermissionEdit = 'FAQ Edit Frame';
        ctrl.customPermissionView = 'FAQ View Frame';
        ctrl.componentFieldSet = new Set<String>();        
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;
        ctrl.navigationUrl = navigationUrl;
        cw = ctrl.getCW();

        return cw;
    }

    public override DataWrapper getData() {
        
        Set<String> contentSetFields = new Set<String>{
            '[CMS]Title__c',
            '[CMS]Body__c',
            'Name'
        };
        
        return ContentManager.getCMSContent(clusterId, cw.meta.component, contentSetFields, device);
    }

}