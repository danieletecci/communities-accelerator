public with sharing class CG_BaseComponentController {
    
    //WRAPPERS
    public class ComponentWrapper{
		@auraEnabled public CustomSettingWrapper acceleratorSettings;
		@auraEnabled public Boolean isEnabledCommunityEditFrame;
		@auraEnabled public Boolean isEnabledCommunityViewFrame;
        @auraEnabled public ObjectComponentWrapper component;
		@auraEnabled public List<String> listAllContentIds;
		@auraEnabled public List<ContentWrapper> contentWrapper;
		@auraEnabled public List<Integer> pagesNumbers;
        @auraEnabled public List<Category__c> categories;
		@auraEnabled public List<Tag__c> tags;
		@auraEnabled public String clusterId;
		@auraEnabled public String namespace;

		public ComponentWrapper(){
			this.acceleratorSettings = new CustomSettingWrapper(CMSSettings__c.getInstance(), CMSContentSettings__c.getInstance(), CMSMediaElementSettings__c.getInstance());
            this.isEnabledCommunityEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
            this.isEnabledCommunityViewFrame = FeatureManagement.checkPermission('CommunityViewFrame');
            this.namespace = GeneralUtils.getNameSpace();
		}
	}
    
    public class ContentWrapper{
        @auraEnabled public ObjectContentWrapper content;
        @auraEnabled public List<ObjectMediaElementWrapper> mediaElements;
    }

    @auraEnabled
	public static ComponentWrapper getComponentWrapper(String componentExternalId, String componentType, String parentComponentId, String parentContentId, String clusterId, String device){

		Component__c component;
		Component__c parentComponent;
		Set<String> setContentDirect;
		Set<String> setContentToExclude;

		//Si no se parametrizan Clusters busco los default
		if(clusterId == null || clusterId.trim() == ''){
			clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
		}
		Set<String> setClusterIds = ClusterUtils.getClustersParents(clusterId);
		//Busqueda de componente
		component = ComponentUtils.getComponent(componentExternalId, getComponentFieldSetByComponentType(componentType, device), device);
		
		if(componentType == 'ArticlesRelated' || componentType == 'EventsRelated'){
			//Busqueda del componente padre
			String parentComponentType;
			if(componentType == 'ArticlesRelated'){parentComponentType = 'ArticleList';}
			if(componentType == 'EventsRelated'){parentComponentType = 'EventList';}

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
		if(component != null)
		{
			if (component.Datasource__c == 'ParentComponentBehaviour'){
				contentWrapper = ContentUtils.getContentFromComponent(new ObjectComponentWrapper(parentComponent), getContentFieldSetByComponentType(parentComponent.Recordtype.Developername, device), setContentDirect, setContentToExclude, setClusterIds, device);
				for (String fieldApiName: getComponentFieldSetByComponentType(component.RecordType.DeveloperName, device)){
					fieldApiName = GeneralUtils.prefix(fieldApiName);
					if (fieldApiName != 'Id' && fieldApiName != GeneralUtils.prefix('[CMS]ExternalId__c') && fieldApiName != 'Recordtype.Developername'){
						
						if (fieldApiName == GeneralUtils.prefix('[CMS]PageSize__c')){
							component.PageSize__c = parentComponent.PageSize__c;
                        }else if(fieldApiName == GeneralUtils.prefix('[CMS]LinkDetail__r.[CMS]URL__c')){
                            component.LinkDetail__r = parentComponent.LinkDetail__r;
                        }else if (fieldApiName == GeneralUtils.prefix('[CMS]ExcludePastEvents__c')){
                            component.ExcludePastEvents__c = parentComponent.ExcludePastEvents__c;
                        } else {
							component.put(fieldApiName, (String)GeneralUtils.getFieldValue(parentComponent, fieldApiName));
						}

					}
				}
			}else{
				if(componentType == 'ArticleList' || componentType == 'EventList' || 
				componentType == 'ArticleDetail' || componentType == 'EventDetail' || componentType == 'ArticlesRelated' ||
				componentType == 'EventsRelated'){
					contentWrapper = ContentUtils.getContentFromComponent(new ObjectComponentWrapper(component), getContentFieldSetByComponentType(component.Recordtype.Developername, device), setContentDirect, setContentToExclude, setClusterIds, device);
				}
			}
		}

		//Armado del Component Wrapper
		ComponentWrapper cw = new ComponentWrapper();
		
		//Verificar los custom permisions
		if(FeatureManagement.checkPermission(componentType + 'EditFrame') || FeatureManagement.checkPermission('CommunityEditFrame')){
			cw.isEnabledCommunityEditFrame = true;
		}else{
			cw.isEnabledCommunityEditFrame = false;
		}

		if(FeatureManagement.checkPermission(componentType + 'ViewFrame') || FeatureManagement.checkPermission('CommunityViewFrame')){
			cw.isEnabledCommunityViewFrame = true;
		}else{
			cw.isEnabledCommunityViewFrame = false;
		}



		cw.component = new ObjectComponentWrapper(component);
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
			device,
			componentType
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
        Set<String> setFields;
        if(componentType == 'ArticleList'){			setFields = new set<String>{'[CMS]ArticleType__c', '[CMS]PagingType__c', '[CMS]LinkDetail__r.[CMS]URL__c', '[CMS]ExternalId__c', '[CMS]NumberOfColumns__c'};}
        if(componentType == 'EventList'){			setFields = new set<String>{'[CMS]EventsType__c', '[CMS]ExcludePastEvents__c', '[CMS]PagingType__c', '[CMS]LinkDetail__r.[CMS]URL__c', '[CMS]ExternalId__c', '[CMS]NumberOfColumns__c'};}
        if(componentType == 'ArticleDetail'){		setFields = new set<String>{};}
        if(componentType == 'EventDetail'){		setFields = new set<String>{};}
        if(componentType == 'ArticlesRelated'){		setFields = new set<String>{'[CMS]ArticleType__c', '[CMS]PagingType__c', '[CMS]LinkDetail__r.[CMS]URL__c', '[CMS]ExternalId__c'};}
        if(componentType == 'EventsRelated'){	setFields = new set<String>{'[CMS]EventsType__c', '[CMS]ExcludePastEvents__c', '[CMS]PagingType__c', '[CMS]LinkDetail__r.[CMS]URL__c', '[CMS]ExternalId__c'};}
        if(componentType == 'LanguageSelector'){	setFields = new set<String>{};}
        if(componentType == 'Menu'){	setFields = new set<String>{};}
        
        //Default fields
        setFields.add('Id');
        setFields.add('Name');
        setFields.add('Recordtype.Developername');
        setFields.add('[CMS]Datasource__c');
        setFields.add('[CMS]OrderBy__c');
        setFields.add('[CMS]OrderByAdvance__c');
        setFields.add('[CMS]PageSize__c');
        setFields.add('[CMS]HierarchicalOrderBy__c');
        setFields.add('[CMS]TagCriteria__c');
        setFields.add('[CMS]Title__c');

        return setFields;
    }

    private static set<String> getContentFieldSetByComponentType(String componentType, String device){
    	if(componentType == 'EventsRelated'){componentType = 'EventList';}
    	if(componentType == 'ArticlesRelated'){componentType = 'ArticleList';}
    	
        set<String> setFields;
        if(componentType == 'ArticleList'){			setFields = new set<String>{'[CMS]Title__c','[CMS]Body__c', '[CMS]Extract__c', '[CMS]LinkDetail__r.[CMS]URL__c', '[CMS]ExternalId__c', '[CMS]PublishStartDate__c'};}
        if(componentType == 'EventList'){			setFields = new set<String>{'[CMS]Title__c','[CMS]Body__c', '[CMS]Extract__c', '[CMS]EventStartDate__c', '[CMS]EventEndDate__c', '[CMS]Location__c', '[CMS]LinkDetail__r.[CMS]URL__c', '[CMS]ExternalId__c'};}
        if(componentType == 'ArticleDetail'){		setFields = new set<String>{'[CMS]Title__c', '[CMS]Extract__c','[CMS]Body__c','[CMS]Layout__c', '[CMS]PublishStartDate__c'};}
        if(componentType == 'EventDetail'){		setFields = new set<String>{'[CMS]Title__c', '[CMS]Extract__c','[CMS]Body__c', '[CMS]EventStartDate__c', '[CMS]EventEndDate__c', '[CMS]Location__c','[CMS]Layout__c'};}

        setFields.add('Id');
        setFields.add('Name');

        return setFields;
    }
}