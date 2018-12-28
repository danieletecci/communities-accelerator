public with sharing class CG_BaseComponentController {
    
    //WRAPPERS
    public class ComponentWrapper{
		@auraEnabled public AcceleratorSettings__c acceleratorSettings;
		@auraEnabled public Boolean isEnabledCommunityEditFrame;
        @auraEnabled public Component__c component;
		@auraEnabled public List<String> listAllContentIds;
		@auraEnabled public List<ContentWrapper> contentWrapper;
		@auraEnabled public List<Integer> pagesNumbers;
        @auraEnabled public List<Category__c> categories;
		@auraEnabled public List<Tag__c> tags;
		@auraEnabled public String clusterId;
		public ComponentWrapper(){
			this.acceleratorSettings = AcceleratorSettings__c.getInstance();
            this.isEnabledCommunityEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
		}
	}
    
    public class ContentWrapper{
        @auraEnabled public Content__c content;
        @auraEnabled public List<MediaElement__c> mediaElements;
    }

    @auraEnabled
	public static ComponentWrapper getComponentWrapper(String componentExternalId, String componentType, String parentComponentId, String parentContentId, String clusterId, String device){
		system.debug('CG_BaseComponentController: componentExternalId: ' + componentExternalId);
		system.debug('CG_BaseComponentController: componentType: ' + componentType);
		system.debug('CG_BaseComponentController: parentComponentId: ' + parentComponentId);
		system.debug('CG_BaseComponentController: parentContentId: ' + parentContentId);
		system.debug('CG_BaseComponentController: clusterId: ' + clusterId);
		system.debug('CG_BaseComponentController: device: ' + device);

		Component__c component;
		Component__c parentComponent;
		set<String> setContentDirect;
		set<String> setContentToExclude;

		//Si no se parametrizan Clusters busco los default
		if(clusterId == null || clusterId.trim() == ''){
			clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
		}
		set<String> setClusterIds = ClusterUtils.getClustersParents(clusterId);

		//Busqueda de componente
		component = ComponentUtils.getComponent(componentExternalId, getComponentFieldSetByComponentType(componentType, device), device);
		
		if(componentType == 'RelatedNews' || componentType == 'RelatedEvents'){
			//Busqueda del componente padre
			String parentComponentType;
			if(componentType == 'RelatedNews'){parentComponentType = 'News';}
			if(componentType == 'RelatedEvents'){parentComponentType = 'Event';}

			parentComponent = ComponentUtils.getComponent(parentComponentId, getComponentFieldSetByComponentType(parentComponentType, device), device);
			
			if(parentContentId != null && parentContentId != ''){
				setContentToExclude = new set<String>{parentContentId};
			}
		}else{
			if(componentType.contains('Detail') && parentContentId != null && parentContentId != ''){
				setContentDirect = new set<String>{parentContentId};
			}
		}

		//Busqueda de contenido
		ContentUtils.ContentWrapper contentWrapper;
		if(component != null){
			if (component.Datasource__c == 'ParentComponentBehaviour'){
				contentWrapper = ContentUtils.getContentFromComponent(parentComponent, getContentFieldSetByComponentType(parentComponent.Recordtype.Developername, device), setContentDirect, setContentToExclude, setClusterIds, device);
				for (String fieldApiName: getComponentFieldSetByComponentType(component.RecordType.DeveloperName, device)){
					if (fieldApiName != 'Id' && fieldApiName != 'ExternalId__c' && fieldApiName != 'Recordtype.Developername'){
						if (fieldApiName == 'PageSize__c'){
							component.put(fieldApiName, (Decimal)parentComponent.get(fieldApiName));
						} else {
							component.put(fieldApiName, (String)parentComponent.get(fieldApiName));
						}
					}
				}
			} else{
				contentWrapper = ContentUtils.getContentFromComponent(component, getContentFieldSetByComponentType(component.Recordtype.Developername, device), setContentDirect, setContentToExclude, setClusterIds, device);
			}
		}

		//Armado del Component Wrapper
		ComponentWrapper cw = new ComponentWrapper();
		cw.component = component;
		cw.clusterId = clusterId;

		cw.listAllContentIds = new List<String>();
		cw.contentWrapper = new List<ContentWrapper>();
		cw.pagesNumbers = new List<Integer>();
		
		if(contentWrapper != null){
			if(contentWrapper.setAllContentIds != null){
				cw.listAllContentIds.addAll(contentWrapper.setAllContentIds);
			}
			if(contentWrapper.contentDataPage != null){
				cw.contentWrapper = convertDataToWrapper(contentWrapper.contentDataPage);
			}
			if(contentWrapper.totalPages != null){
				for(Integer i = 1; i <= contentWrapper.totalPages; i++){
					cw.pagesNumbers.add(i);
				}
			}
		}
		
		return cw;
	}

	@auraEnabled
	public static List<ContentWrapper> getPage(List<String> listAllContentIds, String componentType, String pageSize, String pageNumber, String orderBy, String device){
		set<String> setAllContentIds = new set<String>();
		setAllContentIds.addAll(listAllContentIds);

		List<ContentUtils.ContentDataWrapper> contentDataWrapper = ContentUtils.getContentPage(
			setAllContentIds,
			getContentFieldSetByComponentType(componentType, device),
			Integer.valueOf(pageNumber),
			Integer.valueOf(pageSize),
			orderBy,
			device
		);

		List<ContentWrapper> contentWrapper = convertDataToWrapper(contentDataWrapper);
        return contentWrapper;
    }

    private static List<ContentWrapper> convertDataToWrapper(List<ContentUtils.ContentDataWrapper> contentDataWrapper){
    	List<ContentWrapper> contentWrapper = new List<ContentWrapper>();
    	for(ContentUtils.ContentDataWrapper cdw: contentDataWrapper){
    		ContentWrapper cw = new ContentWrapper();
    		cw.content = cdw.content;
    		cw.mediaElements = cdw.mediaElements;
    		contentWrapper.add(cw);
    	}
    	return contentWrapper;
    }

    private static set<String> getComponentFieldSetByComponentType(String componentType, String device){
        set<String> setFields;
        if(componentType == 'Banner'){			setFields = new set<String>{'BannerFrameType__c','Orientation__c','BannerType__c','ShowBullets__c','AutomaticTransition__c','BannerTransitionTime__c','Loop__c','Direction__c'};}
        if(componentType == 'News'){			setFields = new set<String>{'NewsType__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'Event'){			setFields = new set<String>{'EventsType__c', 'ExcludePastEvents__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'AdvanceContent'){	setFields = new set<String>{};}
        if(componentType == 'FAQ'){				setFields = new set<String>{};}
        if(componentType == 'NewsDetail'){		setFields = new set<String>{'ShowDescription__c', 'ShowImage__c', 'ShowTitle__c'};}
        if(componentType == 'EventDetail'){		setFields = new set<String>{};}
        if(componentType == 'RelatedNews'){		setFields = new set<String>{'NewsType__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'RelatedEvents'){	setFields = new set<String>{'EventsType__c', 'ExcludePastEvents__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}

        //Default fields
        setFields.add('Id');
        setFields.add('Name');
        setFields.add('Recordtype.Developername');
        setFields.add('Datasource__c');
        setFields.add('OrderBy__c');
        setFields.add('OrderByAdvance__c');
        setFields.add('PageSize__c');

        return setFields;
    }

    private static set<String> getContentFieldSetByComponentType(String componentType, String device){
    	if(componentType == 'RelatedEvents'){componentType = 'Event';}
    	if(componentType == 'RelatedNews'){componentType = 'News';}
    	
        set<String> setFields;
        if(componentType == 'Banner'){			setFields = new set<String>{'LinkDetail__r.URL__c','OverlayQuadrant__c', 'ListTitle__c', 'ListDescription__c', 'ButtonLabel__c'};}
        if(componentType == 'News'){			setFields = new set<String>{'ListTitle__c', 'ListDescription__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'Event'){			setFields = new set<String>{'ListTitle__c', 'ListDescription__c', 'EventStartDate__c', 'EventEndDate__c', 'Location__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'AdvanceContent'){	setFields = new set<String>{'DetailTitle__c', 'HTMLContent__c'};}
        if(componentType == 'FAQ'){				setFields = new set<String>{'ListTitle__c', 'ListDescription__c'};}
        if(componentType == 'NewsDetail'){		setFields = new set<String>{'DetailTitle__c', 'DetailDescription__c'};}
        if(componentType == 'EventDetail'){		setFields = new set<String>{'DetailTitle__c', 'DetailDescription__c', 'EventStartDate__c', 'EventEndDate__c', 'Location__c'};}

        //Default fields
        setFields.add('Id');
        setFields.add('Name');

        return setFields;
    }

}