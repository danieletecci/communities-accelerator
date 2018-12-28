public class MockupFactory {
    
    // Before to create first cluster, run just one time.
    public static void generateAcceleratorSetting(){

        AcceleratorSettings__c acceleratorSetting  = new AcceleratorSettings__c ( 
            MaxSizeDesktop__c= 1280, 
            MaxSizeMobile__c = 480, 
            MaxSizeTablet__c = 768,
            ClusterFieldForPublicGroups__c='ExternalId__c');
        insert acceleratorSetting;
    }
    
    //Create Cluster__c, sure to call generateAcceleratorSetting() one time before
    public static List<Cluster__c> createCluster(String clusterName, String parentClusterId, Integer quantity, String clusterType){
        
        List<String> parentClusterIdList = new List<String>();
        if(!String.isBlank(parentClusterId)){
            
            parentClusterIdList.add(parentClusterId);
        }
        
        List<Cluster__c> clusterList = createCluster(clusterName, parentClusterIdList, quantity, clusterType, null, null);
        return clusterList;
    }

   public static List<Cluster__c> createCluster(String clusterName, List<String> parentClusterIdList, Integer quantity, String clusterType, String defaultLanguage, String otherLangeuage){
        List<Cluster__c> clusterList = new List<Cluster__c>();
        RecordType rtGroup = [SELECT Id FROM RecordType WHERE SobjectType = 'Cluster__c' AND DeveloperName =: clusterType];
        System.debug('MockupFactorycreateCluster parentClusterIdList: ' + parentClusterIdList);
        Cluster__c clusterl = new Cluster__c();
       if(!String.isBlank(defaultLanguage) && !String.isBlank(otherLangeuage)){
           clusterl.DefaultLanguage__c = defaultLanguage;
           clusterl.OtherLanguages__c = otherLangeuage;
       }
       
        if(parentClusterIdList.size()>0){
            integer j = 0;
            for(Id parentClusterId: parentClusterIdList){
                for(Integer i = 0; i < quantity; i++){

                    Cluster__c clusterItemOne = new Cluster__c(Name = clusterName+j+i, ParentCluster__c = parentClusterId, RecordTypeId = rtGroup.Id);
                    clusterItemOne.DefaultLanguage__c = clusterl.DefaultLanguage__c;
                    clusterItemOne.OtherLanguages__c = clusterl.OtherLanguages__c;
                    clusterList.add(clusterItemOne);
                    
                }
                j++;
            }
        }else{
            integer j = 0;
            for(Integer i = 0; i < quantity; i++){
                    
                Cluster__c clusterOne = new Cluster__c(Name = clusterName+i+j, ParentCluster__c = null, RecordTypeId = rtGroup.Id);
                clusterOne.DefaultLanguage__c = clusterl.DefaultLanguage__c;
                clusterOne.OtherLanguages__c = clusterl.OtherLanguages__c;
                clusterList.add(clusterOne);
            }
            j++;
        }   
       
       
        insert clusterList;
        return clusterList;
    }

    public static List<Tag__c>  createTag(String tagName, String description, Integer cuantity, Id clusterId){
        List<Tag__c> tagList = new List<Tag__c>();
        
        for(Integer i = 0;i<cuantity;i++){
            tagList.add( new Tag__c(Name=tagName+1,Description__c=description, Cluster__c=clusterId));

        }
        insert tagList;

        return tagList;
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
        User user = new User();
        user.username = username;
        user.email = email;
        insert user;
        return user;
    }
    
    public static User createFullUser(String username, String email){
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
        for(integer i; i<quantity; i++){
            clusterUserList.add( new ClusterUser__c(Cluster__c=clusterId, User__c=userId, AccessLevel__c=accessLevel));
        }
        return clusterUserList;

    }
    
    public static ClusterUser__c insertClusterUser(Id clusterId, Id userId, String accessLevel){
        ClusterUser__c clusterUser = new ClusterUser__c(Cluster__c=clusterId, User__c=userId, AccessLevel__c=accessLevel);
        insert clusterUser;
        return clusterUser;
    }

    public static void deleteClusterByName(String clusterName){

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name = :clusterName LIMIT 1];
        delete getClusterRoot;
    }

    //Create Component__c by RecordTypeName
    public static List<Component__c> createComponent(String nameRecordType, Integer quantity){
        List<Component__c> componentList= new List<Component__c>();
        RecordType recordT = [SELECT id FROM RecordType WHERE SobjectType = 'Component__c' AND Name =: nameRecordType LIMIT 1];
        
        for(Integer i = 0; i < quantity; i++){
            componentList.add(new Component__c(Name = nameRecordType + ' ' + i,
                                    ExternalId__c = nameRecordType +'Component_' + i,
                                    Datasource__c = 'ManualAssignment',
                                    Status__c = 'Available',
                                    RecordTypeId = recordT.id));
        }
        insert componentList;
        return componentList;
    }

    //Create Content__c by RecordTypeName
    public static List<Content__c> createContent(String nameRecordType, Cluster__c clusterArg, Integer quantity){
        List<Content__c> contentList = new List<Content__c>();
        RecordType recordT = [SELECT id FROM RecordType WHERE SobjectType = 'Content__c' AND Name =: nameRecordType LIMIT 1];

        for(Integer i = 0; i < quantity; i++){
            contentList.add(new Content__c(Name = nameRecordType + ' ' + i,
                                    ExternalId__c = nameRecordType + 'Content_' + i,
                                    RecordTypeId = recordT.id,
                                    Cluster__c = clusterArg.id));
        }
        insert contentList;
        return contentList;
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
                                    ExternalId__c = 'MediaElement_' + i));
        }
        insert mediaElementList;
        return mediaElementList;
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
        }
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

    public static List<Navigation__c>  createNavigation(String navName, String url, Integer cuantity, Id clusterId){
        List<Navigation__c> navList = new List<Navigation__c>();
        
        for(Integer i = 0;i<cuantity;i++){
            navList.add( new Navigation__c(Name=navName+1, URL__c=url, Cluster__c=clusterId));
        }
        insert navList;

        return navList;
    }
}