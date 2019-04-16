public class MockupFactory {
    
    // Before to create first cluster, run just one time.
    public static void generateAcceleratorSetting(){

        AcceleratorSettings__c acceleratorSetting  = new AcceleratorSettings__c ( 
            MaxSizeDesktop__c = 1280, 
            MaxSizeMobile__c = 480, 
            MaxSizeTablet__c = 768,
            ClusterFieldForPublicGroups__c = 'ExternalId__c',
            ContentLandingColumnFields__c = 'RecordType.Name,Name,Category__r.Name,Status__c',
            ContentLandingRecordTypes__c = 'Article,Event'
            );
        insert acceleratorSetting;
    }
    
    //Create Cluster__c, sure to call generateAcceleratorSetting() one time before
    public static List<Cluster__c> createCluster(String clusterName, String parentClusterId, Integer quantity, String clusterType, String externalId){
        
        List<String> parentClusterIdList = new List<String>();
        if(!String.isBlank(parentClusterId)){
            
            parentClusterIdList.add(parentClusterId);
        }
        
        List<Cluster__c> clusterList = createCluster(clusterName, parentClusterIdList, quantity, clusterType, null, null, externalId);
        return clusterList;
    }

   public static List<Cluster__c> createCluster(String clusterName, List<String> parentClusterIdList, Integer quantity, String clusterType, String defaultLanguage, String otherLangeuage, String externalId){
        List<Cluster__c> clusterList = new List<Cluster__c>();
        RecordType rtGroup = [SELECT Id FROM RecordType WHERE SobjectType = 'Cluster__c' AND DeveloperName =: clusterType];
        System.debug('MockupFactorycreateCluster parentClusterIdList: ' + parentClusterIdList);
        Cluster__c clusterl = new Cluster__c();
        String externalIdName;
        if(externalId.length() >3){
            externalIdName = externalId.substring(0, 3);     
        }else{
            externalIdName=externalId;
        }
       if(!String.isBlank(defaultLanguage) && !String.isBlank(otherLangeuage)){
           clusterl.DefaultLanguage__c = defaultLanguage;
           clusterl.OtherLanguages__c = otherLangeuage;
       }
       
        if(parentClusterIdList.size()>0){
            integer j = 0;
            for(Id parentClusterId: parentClusterIdList){
                for(Integer i = 0; i < quantity; i++){

                    Cluster__c clusterItemOne = new Cluster__c(Name = clusterName+j+i, ExternalId__c= externalIdName+j+i, ParentCluster__c = parentClusterId, RecordTypeId = rtGroup.Id);
                    clusterItemOne.DefaultLanguage__c = clusterl.DefaultLanguage__c;
                    clusterItemOne.OtherLanguages__c = clusterl.OtherLanguages__c;
                    clusterList.add(clusterItemOne);
                    
                }
                j++;
            }
        }else{
            integer j = 0;
            for(Integer i = 0; i < quantity; i++){
                    
                Cluster__c clusterOne = new Cluster__c(Name = clusterName+i+j, ExternalId__c= externalIdName+i+j, ParentCluster__c = null, RecordTypeId = rtGroup.Id);
                clusterOne.DefaultLanguage__c = clusterl.DefaultLanguage__c;
                clusterOne.OtherLanguages__c = clusterl.OtherLanguages__c;
                clusterList.add(clusterOne);
            }
            j++;
        }   
       
        System.debug('DEBUG | clusterList: ' + clusterList);
        insert clusterList;
        return clusterList;
    }

    public static List<Tag__c>  createTag(String tagName, String description, Integer quantity, Id clusterId){
        List<Tag__c> tagList = new List<Tag__c>();
        
        for(Integer i = 0;i<quantity;i++){
            tagList.add( new Tag__c(Name=tagName+i,Description__c=description, Cluster__c=clusterId, Status__c='Inactive'));

        }
        insert tagList;

        return tagList;
    }

        //Create TagAssignment__c by Category && Component
    public static List<TagAssignment__c> createTagAssignment(List<Tag__c> tagList, List<Component__c> componentList, List<Content__c> contentList){
        List<TagAssignment__c> tagAssignmentList = new List<TagAssignment__c>();
        Integer quantity = 0;
        if(tagList != null && componentList != null){
            quantity = tagList.size() < componentList.size() ? tagList.size() : componentList.size();
        }
        for(Integer i = 0; i < quantity; i++){
            tagAssignmentList.add(new TagAssignment__c(Tag__c = tagList[i].id,
                                    Component__c = componentList[i].id, Content__c = contentList[i].id));
        }
        insert tagAssignmentList;
        return tagAssignmentList;
    }


    public static List<Category__c>  createCategory(String catName, Integer quantity, Id clusterId){
        List<Category__c> catList = new List<Category__c>();
        
        for(Integer i = 0;i<quantity;i++){
            catList.add( new Category__c(Name=catName+i, Cluster__c=clusterId, Status__c='Inactive'));

        }
        insert catList;

        return catList;
    }

    //Create CategoryAssignment__c by Category && Component
    public static List<CategoryAssignment__c> createCategoryAssignment(List<Category__c> categoryList, List<Component__c> componentList){
        List<CategoryAssignment__c> categoryAssignmentList = new List<CategoryAssignment__c>();
        Integer quantity = 0;
        if(categoryList != null && componentList != null){
            quantity = categoryList.size() < componentList.size() ? categoryList.size() : componentList.size();
        }
        for(Integer i = 0; i < quantity; i++){
            categoryAssignmentList.add(new CategoryAssignment__c(Category__c = categoryList[i].id,
                                    Component__c = componentList[i].id));
        }
        insert categoryAssignmentList;
        return categoryAssignmentList;
    }
    
    //Create Cluster__c (Root) by names
    /*public static List<Cluster__c> createClusterRoot(List<String> nameList){
        List<Cluster__c> clusterRootList = new List<Cluster__c>();
        RecordType rtRoot = [SELECT Id FROM RecordType WHERE SobjectType = 'Cluster__c' AND DeveloperName = 'ClusterRoot'];

        for(String name : nameList){
            clusterRootList.add(new Cluster__c(Name = name, RecordTypeId = rtRoot.Id));

        }
        insert tagList;

        return tagList;
    }
*/
    
    public static User createUser(String username, String email){
        Profile profileTest = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
        User user = new User(    
            username = username,
            email = email,
            Alias = 'standt',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileTest.Id,
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        
        insert user;
        return user;
    }
    
    public static List<ClusterUser__c> createClusterUser(Id clusterId, Id userId, Integer quantity, String accessLevel){

        //ClusterUser__c clusterUser = new ClusterUser__c(Cluster__c=clusterId, User__c=userId, AccessLevel__c=accessLevel);
        List<ClusterUser__c> clusterUserList = new List<ClusterUser__c>();
        for(integer i = 0; i<quantity; i++){
            clusterUserList.add( new ClusterUser__c(Cluster__c=clusterId, User__c=userId, AccessLevel__c=accessLevel));
        }
        insert clusterUserList;
        return clusterUserList;
    }

    public static void deleteClusterByName(String clusterName){

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name = :clusterName LIMIT 1];
        delete getClusterRoot;
    }

    //Create Component__c by RecordTypeName
    public static List<Component__c> createComponent(String nameRecordType, Integer quantity){

        List<Component__c> componentList = createComponent(nameRecordType, quantity, null);
        
        return componentList;
    }

    //Create Component__c by RecordTypeName
    public static List<Component__c> createComponent(String nameRecordType, Integer quantity, Cluster__c cluster){
        List<Component__c> componentList= new List<Component__c>();
        RecordType recordT = [SELECT id FROM RecordType WHERE SobjectType = 'Component__c' AND Name =: nameRecordType LIMIT 1];

        if(nameRecordType != 'Banner'){

            for(Integer i = 0; i < quantity; i++){
                componentList.add(new Component__c(Name = nameRecordType + ' ' + i,
                                        ExternalId__c = nameRecordType +'Component_' + i,
                                        Datasource__c = 'ManualAssignment',
                                        RecordTypeId = recordT.Id,
                                        Cluster__c = cluster == null ? null : cluster.Id,
                                        Status__c='Inactive'));
            }

        }else{
            for(Integer i = 0; i < quantity; i++){
                componentList.add(new Component__c(Name = nameRecordType + ' ' + i,
                                        ExternalId__c = nameRecordType +'Component_' + i,
                                        Datasource__c = 'ManualAssignment',
                                        RecordTypeId = recordT.id,
                                        Cluster__c = cluster == null ? null : cluster.Id,
                                        Status__c='Inactive',
                                        BannerFrameType__c='Hero'));
            }
        }

        insert componentList;
        return componentList;
    }

    //Create Content__c by RecordTypeName
    public static List<Content__c> createContent(String nameRecordType, Cluster__c clusterArg, Integer quantity){
        List<Content__c> contentList = new List<Content__c>();
        RecordType recordT = [SELECT id FROM RecordType WHERE SobjectType = 'Content__c' AND Name =: nameRecordType LIMIT 1];

        if (nameRecordType != 'Banner'){
           for(Integer i = 0; i < quantity; i++){
            contentList.add(new Content__c(Name =nameRecordType + ' ' + i,
                                    ExternalId__c = nameRecordType + 'Content_' + i,
                                    RecordTypeId = recordT.id,
                                    Cluster__c = clusterArg.id,
                                    Order__c = i+1,
                                    Status__c='Draft'));
            } 
        }
        else
        {
            for(Integer i = 0; i < quantity; i++){
            contentList.add(new Content__c(Name =nameRecordType + ' ' + i,
                                    ExternalId__c = nameRecordType + 'Content_' + i,
                                    RecordTypeId = recordT.id,
                                    Cluster__c = clusterArg.id,
                                    Order__c = i+1,
                                    Status__c='Draft',
                                    BannerFrameType__c='Hero'));
            }       
        }
        insert contentList;
        return contentList;
    }

    //Create Banner Content__c related to a Component
    public static Content__c createBannerContentRelatedToComponent(Cluster__c clusterArg, Component__c component){
        RecordType recordT = [SELECT Id FROM RecordType WHERE SobjectType = 'Content__c' AND Name = 'Banner' LIMIT 1];
        Content__c content = new Content__c(
            Name = 'Banner',
            ExternalId__c = 'BannerContent',
            RecordTypeId = recordT.Id,
            Cluster__c = clusterArg.Id,
            Order__c = 1,
            Status__c = 'Draft',
            StructureComponent__c = component.Id,
            BannerFrameType__c = 'Hero'
        );
        insert content;
        return content;
    }

    //Create ContentAssignment__c by Content && Component
    public static List<ContentAssignment__c> createContentAssignment(List<Content__c> contentList, List<Component__c> componentList){
        List<ContentAssignment__c> contentAssignmentList = new List<ContentAssignment__c>();
        Integer quantity = 0;
        if(contentList != null && componentList != null){
            quantity = contentList.size() < componentList.size() ? contentList.size() : componentList.size();
        }
        for(Integer i = 0; i < quantity; i++){
            contentAssignmentList.add(new ContentAssignment__c(Content__c = contentList[i].id,
                                    Component__c = componentList[i].id));
        }
        insert contentAssignmentList;
        return contentAssignmentList;
    }

    //Create MediaElement__c
    public static List<MediaElement__c> createMediaElement(Integer quantity){
        List<MediaElement__c> mediaElementList = new List<MediaElement__c>();
        
        for(Integer i = 0; i < quantity; i++){
            mediaElementList.add(new MediaElement__c(Name = 'MediaElement ' + i,
                                    ExternalId__c = 'MediaElement_' + i, Status__c='Inactive'));
        }
        insert mediaElementList;
        return mediaElementList;
    }

    //Create MediaElementAssignment__c of each Content__c
    public static List<MediaElementAssignment__c> createMediaElementAssignment(List<Content__c> contentList, List<MediaElement__c> mediaElementList){
        List<MediaElementAssignment__c> mediaElementAssList = new List<MediaElementAssignment__c>();
        
        for(Integer i = 0; i < contentList.size(); i++){
            mediaElementAssList.add(new MediaElementAssignment__c(Content__c = contentList[i].id,
                                    MediaElement__c = mediaElementList[i].id));
        }
        insert mediaElementAssList;
        return mediaElementAssList;
    }

    //Create ContentDocument
    public static List<ContentDocument> createContentDocument(String name, Integer quantity){
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
        for(Integer i = 0; i < quantity; i++){
            ContentVersion contentVersion = new ContentVersion(
              Title = name + i,
              PathOnClient = name + i + '.jpg',
              VersionData = Blob.valueOf('Test Content' + name + i),
              IsMajorVersion = true
            );
            contentVersionList.add(contentVersion);
        }
        insert contentVersionList;    

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        return documents;
    }

    //Create ContentDocumentLink
    public static List<ContentDocumentLink> createContentDocumentLink(List<MediaElement__c> mediaElementList){
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        
        String base64Data = 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
        ContentVersion cv = new ContentVersion(
            ContentLocation = 'S',
            VersionData = EncodingUtil.base64Decode(base64Data),
            Title = 'ContentVersion',
            PathOnClient = 'ContentVersion');
        insert cv;

        String contentDocument = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        for(MediaElement__c mediaElement : mediaElementList){
            contentDocumentLinkList.add(new ContentDocumentLink(
                            ContentDocumentId = contentDocument,
                            LinkedEntityId = mediaElement.Id,
                            ShareType = 'V' ));
            mediaElement.FileURLDesktop__c =AcceleratorSettings__c.getInstance().SalesforceDomain__c + '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
        }
        update mediaElementList;
        insert contentDocumentLinkList;
        return contentDocumentLinkList;
    }

    //Create Translation__c
    public static List<Translation__c> createTranslation(Content__c content, Map<String,String> apiNameTypeMap, String language){
        List<Translation__c> translationList= new List<Translation__c>();
                
        for(String key : apiNameTypeMap.keyset()){
            String typeField = apiNameTypeMap.get(key);
            Translation__c translation = new Translation__c(Name = 'Translation ' + key + ' ' + typeField,
                                    Content__c = content.Id,
                                    FieldApiName__c = key,
                                    FieldType__c = typeField,
                                    LanguageCode__c = language);

            if(typeField == 'Text'){
                translation.TranslationText__c = key + ' Translate ';
            }else {
                if(typeField == 'TextArea'){
                    translation.TranslationTextArea__c = key + ' Translated';
                } else {
                    if(typeField == 'TextAreaRich'){
                        translation.TranslationTextAreaRich__c = key + ' Translated';
                    } else {
                        if(typeField == 'URL'){
                            translation.TranslationURL__c = key + ' Translated';
                        } else {
                            if(typeField == 'Email'){
                                translation.TranslationURL__c = key + ' Translated';
                            }
                        }
                    }
                }
            }
            translationList.add(translation);
        }
        insert translationList;
        return translationList;
    }

 
    public static List<Navigation__c>  createNavigation(String navName, String url, Integer quantity, Id clusterId){
        List<Navigation__c> navList = new List<Navigation__c>();
       
        for(Integer i = 0;i<quantity;i++){
            navList.add(new Navigation__c(Name=navName+i, URL__c=url, Status__c='Inactive', Cluster__c=clusterId));
        }
        
        insert navList;

        return navList;
    }

    public static List<Menu__c>  createMenu(String menuName, Integer quantity, Id clusterId){
        List<Menu__c> menuList = new List<Menu__c>();
        
        for(Integer i = 0;i<quantity;i++){
            menuList.add( new Menu__c(Name=menuName+i, Cluster__c=clusterId, Status__c='Inactive'));
        }
        insert menuList;

        return menuList;
    }

        //Create MenuAssignment__c by Menu && Component
    public static List<MenuAssignment__c> createMenuAssignment(List<Menu__c> menuList, List<Component__c> componentList){
        List<MenuAssignment__c> menuAssignmentList = new List<MenuAssignment__c>();
        Integer quantity = 0;
        if(menuList != null && componentList != null){
            quantity = menuList.size() < componentList.size() ? menuList.size() : componentList.size();
        }
        for(Integer i = 0; i < quantity; i++){
            menuAssignmentList.add(new MenuAssignment__c(Menu__c = menuList[i].id,
                                    Component__c = componentList[i].id, Order__c = i+1));
        }
        insert menuAssignmentList;
        return menuAssignmentList;
    }

    
    public static List<Datatable__c> createDatatables(String name, String externalId, String objectApiName, Integer quantity, Id clusterId) {
        List<Datatable__c> datatablesToCreate = new List<Datatable__c>();
        
        for(Integer i = 0 ; i < quantity ; i ++) {
            Datatable__c dat = new Datatable__c();
            dat.Name = name + '_' + i;
            dat.Cluster__c = clusterId;
            dat.ExternalId__c = externalId + '_' + i;
            dat.ObjectApiName__c = objectApiName;
            dat.RecordsPerPage__c = 1;
            dat.NumberOfColumns__c = '1';
            
            datatablesToCreate.add(dat);
        }
        
        insert datatablesToCreate;
        
        return datatablesToCreate;
    }
    
    public static List<DatatableElement__c> createDatatableElements(String name, String externalId, Integer quantity, Id datatableId) {
        List<DatatableElement__c> datatableElementsToCreate = new List<DatatableElement__c>();
        
        for(Integer i = 0 ; i < quantity ; i ++) {
            DatatableElement__c datElement = new DatatableElement__c();
            datElement.Name = name + '_' + i;
            datElement.ExternalId__c = name + '_' + i;
            datElement.Datatable__c = datatableId;
            datElement.FieldApiName__c ='Name';
            datElement.Label__c = 'TestLabel';
     
            
            datatableElementsToCreate.add(datElement);
        }
        
        insert datatableElementsToCreate;
        
        return datatableElementsToCreate;
    }
    
    public static List<DatatableAction__c> createDatatableActions(String name, String externalId, Integer quantity, Id datatableId, Id recordtypeId) {
        List<DatatableAction__c> datatableActionsToCreate = new List<DatatableAction__c>();
        
        for(Integer i = 0 ; i < quantity ; i ++) {
            DatatableAction__c datAction = new DatatableAction__c();
            datAction.Name = name + '_' + i;
            datAction.Datatable__c = datatableId;
            datAction.ExternalId__c = name + '_' + i;
            datAction.RecordTypeId = recordtypeId;
            datAction.Type__c = 'Custom';
            datAction.Label__c = 'Test';
            datAction.DisplaySettings__c = 'Desktop';
            datAction.Component__c = 'Spinner';
            
            datatableActionsToCreate.add(datAction);
        }
        
        insert datatableActionsToCreate;
        return datatableActionsToCreate;
    }    

}