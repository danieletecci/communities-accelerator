public with sharing class AdvanceContentController extends ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device, String navigationUrl){
        AdvanceContentController ctrl = new AdvanceContentController();
        ComponentWrapper cw = new ComponentWrapper();
        ctrl.customPermissionEdit = 'AdvanceContent Edit Frame';
        ctrl.customPermissionView = 'AdvanceContent View Frame';
        ctrl.componentFieldSet = new Set<String>();        
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;
        ctrl.navigationUrl = navigationUrl;
        cw = ctrl.getCW();
        System.debug('------------------ ' + JSON.serialize(cw.data));
        ContentManager.CMSContent dw = (ContentManager.CMSContent) cw.data;
        System.debug('------------------ ' + JSON.serialize(dw));
        System.debug('------------------ ' + JSON.serialize(dw.contentWrapper));

        if(!dw.contentWrapper.isEmpty()){
            cw.permissions.isEnabledEditFrame = false;
        }
        return cw;
    }

    public override DataWrapper getData() {
        
        Set<String> contentSetFields = new Set<String>{
            'HTMLContent__c'
        };
        
        return ContentManager.getCMSContent(clusterId, cw.meta.component, contentSetFields, device);
    }

}