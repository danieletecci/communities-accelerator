public with sharing class FE_FAQController extends FE_ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device, String navigationUrl){
        FE_FAQController ctrl = new FE_FAQController();
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
            'Title__c',
            'Body__c'
        };
        
        return FE_ContentManager.getCMSContent(clusterId, cw.meta.component, contentSetFields, device);
    }

}