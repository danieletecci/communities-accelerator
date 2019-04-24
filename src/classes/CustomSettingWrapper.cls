public class CustomSettingWrapper {
    
    @AuraEnabled public String ClusterFieldForPublicGroups;
    @AuraEnabled public String SalesforceDomain;
    @AuraEnabled public String ContentLandingColumnFields;
    @AuraEnabled public String ContentLandingRecordTypes;
    @AuraEnabled public String ContentTemplateRecordTypes;
    @AuraEnabled public Decimal MaxSizeDesktop;
    @AuraEnabled public Decimal MaxSizeMobile;
    @AuraEnabled public Decimal MaxSizeTablet;
    @AuraEnabled public Boolean EnableMediaElementAutomaticResize;
    
    public CustomSettingWrapper(CMSSettings__c cmsSetting, CMSContentSettings__c contentSetting, CMSMediaElementSettings__c meSetting){
        this.ClusterFieldForPublicGroups = cmsSetting.ClusterFieldForPublicGroups__c;
        this.SalesforceDomain = cmsSetting.SalesforceDomain__c;
        this.ContentLandingColumnFields = contentSetting.ContentLandingColumnFields__c;
        this.ContentLandingRecordTypes = contentSetting.ContentLandingRecordTypes__c;
        this.ContentTemplateRecordTypes = contentSetting.ContentTemplateRecordTypes__c;
        this.MaxSizeDesktop = meSetting.MaxSizeDesktop__c;
        this.MaxSizeMobile = meSetting.MaxSizeMobile__c;
        this.MaxSizeTablet = meSetting.MaxSizeTablet__c;
        this.EnableMediaElementAutomaticResize = meSetting.EnableMediaElementAutomaticResize__c;
    }

}