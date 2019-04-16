public without sharing virtual class ContentUtils {

    public static Map<String, String> rtComponentToContent = new Map<String, String>{
        'EventList'             => 'Event',
        'FAQ'                   => 'FAQ',
        'ArticleList'           => 'Article',
        'AdvanceContent'        => 'AdvanceContent',
        'Banner'                => 'Banner'
    };

    public class ContentWrapper{
        public Set<String> setAllContentIds;
        public Integer totalPages;
        public List<ContentDataWrapper> contentDataPage;
    }
    
    public class ContentDataWrapper{
        public Content__c content;
        public List<MediaElement__c> mediaElements;
    }

    public static ContentWrapper getContentFromComponent(Component__c component, Set<String> fieldSet, Set<String> setContentDirect, Set<String> setContentToExclude, Set<String> setClusterIds, String device){
        system.debug('ContentUtils: component: ' + component);
        system.debug('ContentUtils: fieldSet: ' + fieldSet);
        system.debug('ContentUtils: setContentDirect: ' + setContentDirect);
        system.debug('ContentUtils: setContentToExclude: ' + setContentToExclude);
        system.debug('ContentUtils: setClusterIds: ' + setClusterIds);
        system.debug('ContentUtils: device: ' + device);
        
        List<Id> contentIdList = new List<Id>();
        Set<Id> setCategoriesIds = new Set<Id>();
        if(setContentToExclude == null){setContentToExclude = new Set<String>();}

        //Armado del query principal a objeto Content
        String query = '';

        //SELECT
        fieldSet.add('Audience__r.ReferenceAudienceExternalIds__c');
        query += 'SELECT ' + GeneralUtils.joinFields(fieldSet) + ', (SELECT Id, MediaElement__c, Placement__c FROM MediaElementAssignments__r WHERE Placement__c = \''+ getPlaceForRTComponent(component.RecordType.Developername) +'\') ';     
        
        //FROM
        query += 'FROM Content__c ';

        //WHERE
        String contentTypeToSearch = getRecordTypeContentFromRTComponent(component.RecordType.DeveloperName);
        
        if(setContentDirect != null){
            //Busqueda de contenido por parametro
            query += 'WHERE (Id IN: setContentDirect OR ExternalId__c IN: setContentDirect) AND Recordtype.DeveloperName =: contentTypeToSearch ';
            query += contentTypeToSearch == 'Banner' ? ' AND BannerFrameType__c = \'' + component.BannerFrameType__c + '\' ' : '';

        }else{
            if(component.Datasource__c != null){
                //Busqueda de contenido por Datasource
                if(component.Datasource__c.contains('ParentContent')){
                    if(!setContentToExclude.isEmpty()){
                        Content__c parentContent = [SELECT Id, Category__c FROM Content__c WHERE (Id IN: setContentToExclude OR ExternalId__c IN: setContentToExclude) LIMIT 1];
                        if(component.Datasource__c.contains('Categories') && parentContent.Category__c != null){
                            setCategoriesIds.add(parentContent.Category__c);
                        }
                        if(component.Datasource__c.contains('Tags')){
                            contentIdList.addAll(getContentIdsByTags(parentContent.Id, contentTypeToSearch, component.TagCriteria__c));
                        }
                    }
                }else{
                    if(component.Datasource__c.contains('ManualAssignment')){
                        contentIdList.addAll(getContentIdsByAssignment(component.Id, (component.OrderBy__c != null && component.OrderBy__c == 'Manual Order')));
                    }
                    if(component.Datasource__c.contains('Categories')){
                        setCategoriesIds.addAll(getContentIdsByCategories(component.Id));
                    }
                    if(component.Datasource__c.contains('Tags')){
                        contentIdList.addAll(getContentIdsByTags(component.Id, contentTypeToSearch, component.TagCriteria__c));
                    }
                }
            }

            if(component.Datasource__c != null && (component.Datasource__c == 'All Articles' || component.Datasource__c == 'All Events') ){
                query += 'WHERE Id NOT IN: setContentToExclude AND ExternalId__c NOT IN: setContentToExclude AND Cluster__c IN: setClusterIds AND Recordtype.DeveloperName =: contentTypeToSearch ';
            }else{

                query += 'WHERE (Id IN: contentIdList OR Category__c IN: setCategoriesIds) AND (Id NOT IN: setContentToExclude) AND (ExternalId__c NOT IN: setContentToExclude) AND Cluster__c IN: setClusterIds AND Recordtype.DeveloperName =: contentTypeToSearch ';
            }

            if(component.Recordtype.Developername == 'EventList' || component.Recordtype.DeveloperName == 'EventsRelated'){
                if (component.ExcludePastEvents__c){
                    Datetime dateAndTime = System.today();
                    query += 'AND (EventEndDate__c >: dateAndTime) ';
                }
            }

            query += contentTypeToSearch == 'Banner' ? ' AND BannerFrameType__c = \'' + component.BannerFrameType__c + '\' ' : '';
        }
        
        query += ' AND Status__c = \'Published\' AND IsTemplate__c = false ';

        //ORDER
        if((component.OrderBy__c != null && component.OrderBy__c != 'Custom Sorting' && component.OrderBy__c != 'Manual Order') || (component.OrderBy__c != null && component.OrderBy__c == 'Custom Sorting' && component.OrderByAdvance__c != null) ){
            query += 'ORDER BY ' + (component.OrderBy__c == 'Custom Sorting' ? component.OrderByAdvance__c : component.OrderBy__c);
        }
        
        if(component.HierarchicalOrderBy__c != null){
            query = query.replace('ORDER BY', 'ORDER BY Cluster__r.ClusterLevel__c ' + component.HierarchicalOrderBy__c + ', ');
        }       
        
        ContentWrapper cw = new ContentWrapper();
        Map<Id, Content__c> mapContent = new Map<Id, Content__c>((List<Content__c>)Database.query(query));

        if(!mapContent.isEmpty()){
            //Manual Order del contenido
            if(component.Datasource__c == 'ManualAssignment' && component.OrderBy__c == 'Manual Order' && contentIdList.size() > 0){
                Map<Id, Content__c> mapContentOrdered = new Map<Id, Content__c>();
                for(Id contentId : contentIdList){
                    mapContentOrdered.put(contentId, mapContent.get(contentId));
                }
                mapContent = mapContentOrdered;
            }

            //Si despues de aplicar segmentacion tenemos algun registro evaluamos las paginas
            if(!mapContent.isEmpty()){

                set<Id> contentIdsSet = mapContent.keySet();
                List<Content__c> contentList = mapContent.values();
                
                //Application of audiences
                try{
                    AudienceUtils.filterRecords(UserInfo.getUserId(), contentList, 'Audience__c');
                }catch(Exception e){
                    contentList = new List<Content__c>();
                }

                //Seteo todos los Ids posibles para despues hacer el query de paginas
                cw.setAllContentIds = (Set<String>)JSON.deserialize(JSON.serialize(contentIdsSet), Set<String>.class);

                //Calculo el total de paginas
                cw.totalPages = component.PageSize__c != null ? Integer.valueOf((contentList.size() / component.PageSize__c).round(RoundingMode.UP)) : 1;
                //Content Data Wrapper
                List<Content__c> firstPage = new List<Content__c>();
                if(component.PageSize__c == null){
                    firstPage = contentList;
                }else{
                    Decimal limitSize = component.PageSize__c < contentList.size() ? component.PageSize__c : contentList.size();
                    for(Integer i = 0; i < limitSize; i++){
                        firstPage.add(contentList[i]);
                    }
                }
                //Translate content records
                TranslationUtils.getTranslated(firstPage, UserInfo.getLanguage(), 'Content__c');

                //Replace User information on Advance Content
                if(component.Recordtype.DeveloperName == 'AdvanceContent'){
                    replaceDynamicFieldsOnContent(firstPage);
                }

                cw.contentDataPage = createContentDataWrappers(firstPage);
            }
        }

        return cw;
    }

    public static List<ContentDataWrapper> getContentPage(set<String> setAllContentIds, set<String> fieldSet, Integer page, Integer pageSize, String orderBy, String device, String componentType){
        String query = '';
        query += 'SELECT ' + GeneralUtils.joinFields(fieldSet) + ', (SELECT Id, MediaElement__c, Placement__c FROM MediaElementAssignments__r WHERE Placement__c = \''+ getPlaceForRTComponent(componentType) +'\') ';
        query += 'FROM Content__c ';
        query += 'WHERE Id IN: setAllContentIds ';
        query += 'ORDER BY ' + orderBy + ' ';
        query = query.replace('ORDER BY', 'ORDER BY Cluster__r.ClusterLevel__c ASC, ');
        query += 'LIMIT ' + pageSize + ' ';

        Decimal offSet = (page-1) * pageSize;

        query += 'OFFSET ' + offSet;
        
        List<Content__c> listContentPage = Database.query(query);

        //Translate content records
        TranslationUtils.getTranslated(listContentPage, UserInfo.getLanguage(), 'Content__c');

        List<ContentDataWrapper> contentDataPage = createContentDataWrappers(listContentPage);
        return contentDataPage;
    }
    
    private static List<Id> getContentIdsByAssignment(Id componentId, Boolean isManualOrder){
        List<Id> contentIdList = new List<Id>();
        String queryContentAssignment = 'SELECT Id, Content__c FROM ContentAssignment__c WHERE Component__c =: componentId';
        if(isManualOrder){
            queryContentAssignment += ' ORDER BY Order__c';
        }

        for(ContentAssignment__c ca: Database.query(queryContentAssignment)){
            if(!contentIdList.contains(ca.Content__c)) contentIdList.add(ca.Content__c);
        }
        return contentIdList;
    }

    private static List<Id> getContentIdsByCategories(Id parentId){
        List<Id> categoriesIdList = new List<Id>();
        for(CategoryAssignment__c ca: [SELECT Id, Category__c FROM CategoryAssignment__c WHERE Component__c =: parentId]){
            if(!categoriesIdList.contains(ca.Category__c)) categoriesIdList.add(ca.Category__c);
        }
        return categoriesIdList;
    }

    private static List<Id> getContentIdsByTags(Id parentId, String contentTypeToSearch, String tagCriteria){
        List<Id> tagIdList = new List<Id>();
        List<String> orderList = new List<String>();
        List<String> tagList = new List<String>();
        List<String> visitedList = new List<String>();
        Map<String, String> orderTagMap = new Map<String, Id>();
        System.debug(contentTypeToSearch + ' - ' + tagCriteria);
        if(String.isNotBlank(tagCriteria)){
            tagCriteria = tagCriteria.deleteWhitespace().toUpperCase();
            orderList = tagCriteria.split('\\(|\\)|AND|OR');
            tagCriteria = ' ' + tagCriteria.replaceAll('AND', ' AND ').replaceAll('OR', ' OR ').replaceAll('\\(', ' ( ').replaceAll('\\)', ' ) ') + ' ';
        }        
        
        for(TagAssignment__c ta: [SELECT Id, Tag__c, Order__c FROM TagAssignment__c WHERE Component__c =: parentId OR Content__c =: parentId]){
            if(!tagIdList.contains(ta.Tag__c)) {
                tagIdList.add(ta.Tag__c);
                orderTagMap.put(String.valueOf(ta.Order__c), ta.Tag__c);
            }
        }

        //Reemplazo de los orders por id de tags
        if(String.isNotBlank(tagCriteria)){
            for(String st : orderList){
                if(String.isNotBlank(st) && !visitedList.contains(st) && orderTagMap.containsKey(st)){
                    tagCriteria = tagCriteria.replaceAll(' ' + st + ' ', orderTagMap.get(st));
                    visitedList.add(st);
                    tagList.add(orderTagMap.get(st));
                }
            }
        }
        
        //Busqueda de los contents
        List<Id> contentIdList = new List<Id>();
        Map<Id, String> contentTagsMap = new Map<Id, String>();
        for(TagAssignment__c ta: [SELECT Id, Content__c, Tag__c FROM TagAssignment__c WHERE Tag__c IN: tagIdList AND Content__r.RecordType.Developername =: contentTypeToSearch]){
            if (String.isBlank(tagCriteria)){
                if(!contentIdList.contains(ta.Content__c)) contentIdList.add(ta.Content__c);
            }else{
                if (contentTagsMap.containsKey(ta.Content__c)){
                    contentTagsMap.put(ta.Content__c, contentTagsMap.get(ta.Content__c) + ta.Tag__c + ', ');
                }else{
                    contentTagsMap.put(ta.Content__c, ta.Tag__c + ', ');    
                }                
            }
        }
        
        //Remplazo y validacion de la formula
        if(String.isNotBlank(tagCriteria)){
            for(Id contentId : contentTagsMap.KeySet()){
                String tags = contentTagsMap.get(contentId);
                String evalCriteria = tagCriteria;
                visitedList = new List<String>();
                for(String st : tagList){
                    if(String.isNotBlank(st) && !visitedList.contains(st) && tags.contains(st)){
                        evalCriteria = evalCriteria.replaceAll(st, 'TRUE');                        
                    }else {
                        evalCriteria = evalCriteria.replaceAll(st, 'FALSE');
                    }
                    visitedList.add(st);
                }

                evalCriteria = evalCriteria.deleteWhitespace();
                evalCriteria = evalCriteria.replaceAll('AND', ' AND ').replaceAll('OR', ' OR ');
                if (String.isNotBlank(contentId) && BooleanExpressionUtils.eval(evalCriteria)){
                    if(!contentIdList.contains(contentId)) contentIdList.add(contentId);
                }
            }
        }
        return contentIdList;
    }

    private static List<ContentDataWrapper> createContentDataWrappers(List<Content__c> contents){
        List<ContentDataWrapper> listCDW = new List<ContentDataWrapper>();

        set<Id> setMediaElementIds = new set<Id>();
        for(Content__c c: contents){
            for(MediaElementAssignment__c m: c.MediaElementAssignments__r){
                setMediaElementIds.add(m.MediaElement__c);
            }
        }

        map<Id, MediaElement__c> mapMediaElements;
        if(!setMediaElementIds.isEmpty()){
            mapMediaElements = new map<Id, MediaElement__c>([SELECT Id, Name, FileURLDesktop__c FROM MediaElement__c WHERE Id IN: setMediaElementIds]);
        }

        for(Content__c c: contents){
            ContentDataWrapper cdw = new ContentDataWrapper();
            c = externalIdToUrl(c);
            cdw.content = c;
            cdw.mediaElements = new List<MediaElement__c>();
            for(MediaElementAssignment__c m: c.MediaElementAssignments__r){
                if(mapMediaElements != null && mapMediaElements.containsKey(m.MediaElement__c)){
                    cdw.mediaElements.add(mapMediaElements.get(m.MediaElement__c));    
                }
            }
            listCDW.add(cdw);
        }
        return listCDW;
    }

    public static String getRecordTypeContentFromRTComponent(String componentRT){
        String contentTypeToSearch;
        if(componentRT == 'ArticlesRelated' || componentRT == 'ArticleDetail'){contentTypeToSearch = 'ArticleList';}
        else if(componentRT == 'EventsRelated' || componentRT == 'EventDetail'){contentTypeToSearch = 'EventList';}
        else{
            contentTypeToSearch = componentRT;
        }
        return contentTypeToSearch;
    }

    // Image Placement for RT components
    private static String getPlaceForRTComponent(String componentRT){
        
        String contentPlaceToSearch = '';
        if(componentRT == 'Banner'){contentPlaceToSearch = 'BannerImage';}
        else if(componentRT == 'ArticlesRelated'){contentPlaceToSearch = 'ArticleImage';}
        else if(componentRT == 'ArticleList'){contentPlaceToSearch = 'ArticleImage';}
        else if(componentRT == 'ArticleDetail'){contentPlaceToSearch = 'ArticleImage';}
        else if(componentRT == 'EventList'){contentPlaceToSearch = 'EventImage';}
        else if(componentRT == 'EventsRelated'){contentPlaceToSearch = 'EventImage';}
        else if(componentRT == 'EventDetail'){contentPlaceToSearch = 'EventImage';}
        return contentPlaceToSearch;
    }

    private static void replaceDynamicFieldsOnContent(List<Content__c> contentList){
        for(Content__c con: contentList){
            con.HTMLContent__c = GeneralUtils.replaceDynamicFields(con.HTMLContent__c, 'User', UserInfo.getUserId(), false);
        }
    }

    private static Content__c externalIdToUrl(Content__c content){
        List<String> recordTypesWithBody = new List<String>{'Article', 'Event', 'FAQ', 'ArticleDetail', 'EventDetail'};
        String recordTypeDeveloperName = [SELECT Id, RecordType.DeveloperName FROM Content__c WHERE Id =: content.Id].RecordType.DeveloperName;
        if(recordTypesWithBody.contains(recordTypeDeveloperName)){
            if(content.Body__c != null){
                content.Body__c = RichTextController.replaceExternalIdsWithURLs(content.Body__c);
            }
            
        } else if(recordTypeDeveloperName == 'AdvanceContent'){
            if(content.HTMLContent__c != null){
                content.HTMLContent__c =  RichTextController.replaceExternalIdsWithURLs(content.HTMLContent__c);
            }
        }
        return content;
    }
    
    @auraEnabled
    public static String createFromTemplate(Id templateId, String recordName, String clusterId){

        Set<String> fieldNames = GeneralUtils.getObjectFieldNames('Content__c');
        Content__c template = Database.query('SELECT ' +  String.join(new List<String>(fieldNames), ',') + ' FROM Content__c WHERE Id =: templateId');

        if(template.IsTemplate__c && template.Status__c == 'Published'){
            Content__c newContent = template.clone(false,false,false,false);
            newContent.Name = recordName.left(60);
            newContent.TemplateUsed__c = templateId;
            newContent.Cluster__c = clusterId != null ? clusterId : newContent.Cluster__c;
            newContent.Status__c = 'Draft';
            newContent.IsTemplate__c = false;
            newContent.ExternalId__c = null;
            newContent.Category__c = null;
            newContent.OwnerId = UserInfo.getUserId();
            try{
                insert newContent;
                return newContent.Id;
            }catch(DMLException e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                throw new AuraHandledException(e.getDMLMessage(0));
            }catch(Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }  
        }else{
            throw new AuraHandledException(template.IsTemplate__c ? label.NewTemplateInvalidTemplate : label.NewTemplateNotPublished);
        }       

    }
    
}