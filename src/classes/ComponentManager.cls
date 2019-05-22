public without sharing virtual class ComponentManager {
    
    //Parameters
    public String componentExternalId;
    public String clusterId;
    public String device;
    public Component__c componentRecord;
    public String componentId;
    public String navigationUrl;

    //Base atributes
    public Set<String> defaultComponentFieldSet;
    public Set<String> componentFieldSet;
    public String customPermissionEdit;
    public String customPermissionView;

    //Component Wrapper
    public ComponentWrapper cw;

    //WRAPPERS
    public class ComponentWrapper{
        @auraEnabled public CustomSettingWrapper acceleratorSettings;
        @auraEnabled public String clusterId;
        @auraEnabled public PermissionsWrapper permissions;
        @auraEnabled public MetaWrapper meta;
        @auraEnabled public DataWrapper data;
        @auraEnabled public String contentRecordTypeId;
        @auraEnabled public Boolean hasContent;
    }

    public class PermissionsWrapper{
        @auraEnabled public Boolean isEnabledEditFrame; 
        @auraEnabled public Boolean isEnabledViewFrame;
    }

    public virtual class MetaWrapper{
        @auraEnabled public ObjectComponentWrapper component;
        @auraEnabled public String objectId;
        @auraEnabled public String name;
        @auraEnabled public String navId;
        @auraEnabled public String namespace;
    }
    
    public virtual class DataWrapper{}

    //Get general component wrapper
    public ComponentWrapper getCW(){
        cw = new ComponentWrapper();
        //Looking for default cluster
        if(clusterId == null || clusterId.trim() == ''){
            clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
        }

        cw.acceleratorSettings = new CustomSettingWrapper(CMSSettings__c.getInstance(), CMSContentSettings__c.getInstance(), CMSMediaElementSettings__c.getInstance());
        cw.clusterId = clusterId;
        cw.permissions = getPermissionWrapper();
        cw.meta = getMeta();
        cw.hasContent = false;

        if(cw.meta.component != null){
            String contentRTDevName = ContentUtils.rtComponentToContent.get(cw.meta.component.RecordtypeDeveloperName);
            if(contentRTDevName != null){
                cw.contentRecordTypeId = Schema.SObjectType.Content__c.getRecordTypeInfosByDeveloperName().get(GeneralUtils.prefix(contentRTDevName)).getRecordTypeId();
            }
        }
        
        cw.data = getData();
        
        return cw;
    }

    public virtual PermissionsWrapper getPermissionWrapper() {
        PermissionsWrapper pw = new PermissionsWrapper();
        pw.isEnabledEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
        pw.isEnabledViewFrame = FeatureManagement.checkPermission('CommunityViewFrame');
        
        if(!pw.isEnabledEditFrame){
            pw.isEnabledEditFrame = FeatureManagement.checkPermission(customPermissionEdit.deleteWhitespace());
        }

        if (!pw.isEnabledViewFrame){
            pw.isEnabledViewFrame = FeatureManagement.checkPermission(customPermissionView.deleteWhitespace());
        }

        return pw; 
    }

    public virtual MetaWrapper getMeta() {
        MetaWrapper mw = new MetaWrapper();
        //Default fields
        defaultComponentFieldSet = new Set<String>();
        defaultComponentFieldSet.add('Id');
        defaultComponentFieldSet.add('Name');
        defaultComponentFieldSet.add('Recordtype.DeveloperName');        
        defaultComponentFieldSet.add('Recordtype.Id');
        defaultComponentFieldSet.add('[CMS]Datasource__c');
        defaultComponentFieldSet.add('[CMS]OrderBy__c');        
        defaultComponentFieldSet.add('[CMS]OrderByAdvance__c');
        defaultComponentFieldSet.add('[CMS]HierarchicalOrderBy__c');
        defaultComponentFieldSet.add('[CMS]TagCriteria__c');
        defaultComponentFieldSet.add('[CMS]PageSize__c');
        defaultComponentFieldSet.add('[CMS]Title__c');
        defaultComponentFieldSet.addAll(componentFieldSet);
        if(String.isNotBlank(componentExternalId)){
            componentRecord = ComponentUtils.getComponent(componentExternalId, defaultComponentFieldSet, device);
        }
        else{
            componentRecord = ComponentUtils.getComponent(componentId, defaultComponentFieldSet, device);
        }

        //Translate component record
        TranslationUtils.getTranslated(componentRecord, UserInfo.getLanguage(), '[CMS]Component__c');
        
        mw.component = new ObjectComponentWrapper(componentRecord);
        mw.navId = GeneralUtils.getNavigationId(navigationUrl);
        mw.namespace = GeneralUtils.getNameSpace();
        return mw;
    }

    public virtual DataWrapper getData() {
        DataWrapper cw = new DataWrapper();
        return cw;
    }

}