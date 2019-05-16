public class ContentLandingRecordListController {
    
    //TODO:CheckList
    // Get Parameters
    // Create Test Class

    public class TableWrapper{
        public String title;
        public List<String> columnSet;
        public List<ContentWrapper> contentWrappers;
        public String message;
        // Wrapper para enviar el título, las columnas y los registros que componen la tabla
        public TableWrapper(String title, List<String> columnSet, List<ContentWrapper> contentWrappers){
            this.title = title;
            this.columnSet = columnSet;
            this.contentWrappers = contentWrappers;
            this.message = System.Label.NoRecordsToShow;
        }   
    }

    class ContentWrapper{
        public String contentId;                  
        public List<FieldWrapper> fieldWrappers;
        public String recordTypeId;
        public List<String> actions;                      
        // Wrapper que emula un Contenido para soportar Wrappers de campo
        ContentWrapper(String contentId, List<FieldWrapper> fieldWrappers, String recordTypeId, List<String> actions){
            this.contentId = contentId;
            this.fieldWrappers = fieldWrappers;
            this.recordTypeId = recordTypeId;
            this.actions = actions;
        }
    }

    class FieldWrapper{
        public String value;
        public String link;
        // Wrapper para incluir el valor de un campo y un link al registro
        FieldWrapper(String value, String link){
            this.value = value;
            this.link = link;
        } 
    }

    class FilterWrapper{
        String contentTypeName;
        String contentTypeId;
        String clusterId;
        String categoryId;
        String tagIds;
        String status;
        String searchText;
        Boolean isTemplate;
        // Wrapper para agrupar los criterios de filtro recibidos
        FilterWrapper(String contentTypeId, String clusterId, String categoryId, String tagIds, String status, String searchText, Boolean isTemplate){
            this.contentTypeName = contentTypeId != null ? [SELECT Id, Name FROM RecordType WHERE Id =: contentTypeId LIMIT 1].Name : 'Last Modified';
            this.contentTypeId = contentTypeId;
            this.clusterId = clusterId;
            this.categoryId = categoryId;
            this.tagIds = tagIds;
            this.status = status;
            this.searchText = searchText;
            this.isTemplate = isTemplate;
        }
    }

    @auraEnabled
    public static void deleteContent(String contentId){
        Content__c content = [SELECT Id FROM Content__c WHERE ID =: contentId];
        delete content;     
    }                                               
    
    //Cacheable = TRUE, used when the table is not updated
    @auraEnabled(cacheable=true)
    public static String getTableWrapper(String contentTypeId, String clusterId, String categoryId, String tagIds, String status, String searchText, Boolean isTemplate, Integer recordOffset, Integer recordLimit){
        TableWrapper tableWrapper = buildTableWrapper(contentTypeId, clusterId, categoryId, tagIds, status, searchText, isTemplate, recordOffset, recordLimit);
        // El Wrapper es enviado al componente en forma de JSON
        return JSON.serialize(tableWrapper);
    }
    
    //Cacheable = FALSE, used when the table is updated
    @auraEnabled(cacheable=false)
    public static String getUpdatedTableWrapper(String contentTypeId, String clusterId, String categoryId, String tagIds, String status, String searchText, Boolean isTemplate, Integer recordOffset, Integer recordLimit){
        TableWrapper tableWrapper = buildTableWrapper(contentTypeId, clusterId, categoryId, tagIds, status, searchText, isTemplate, recordOffset, recordLimit);
        // El Wrapper es enviado al componente en forma de JSON
        return JSON.serialize(tableWrapper);
    }
    
    public static TableWrapper buildTableWrapper(String contentType, String clusterId, String categoryId, String tagIds, String status, String searchText, Boolean isTemplate, Integer recordOffset, Integer recordLimit){
        FilterWrapper wrapper = new FilterWrapper(contentType, clusterId, categoryId, tagIds, status, searchText, isTemplate);
        String title = (wrapper.contentTypeName + ' Records').toUpperCase();
        String columnSetString = getColumnSet();
        if(columnSetString == null || columnSetString == '') return new TableWrapper(null, null, null);
        List<String> columnSet = columnSetString.split(',');
        List<String> columnLabelSet = getColumnLabelSet();
        columnLabelSet.add(' ');
        TableWrapper tableWrapper = new TableWrapper(title, columnLabelSet, new List<ContentWrapper>());
        List<Content__c> contents = getRecords(wrapper, recordOffset, recordLimit);
        // Filtra los Contenidos que contienen el String buscado en la columna Name
        if(searchText != null && searchText != '') contents = searchTextInRecords(searchText, contents);
        // Construye los Wrappers auxiliares
        for(Content__c content : contents){
            tableWrapper.contentWrappers.add(buildContentWrapper(content, columnSet));
        }
        // Si no hay registros, mostramos un mensaje de error
        if(contents.isEmpty()){
            tableWrapper = new TableWrapper(null, null, null);
        }
        // El Wrapper es enviado al componente en forma de JSON
        return tableWrapper;
    }

    static ContentWrapper buildContentWrapper(Content__c content, List<String> columnSet){
        List<FieldWrapper> fieldWrappers = new List<FieldWrapper>();
        for(String column : columnSet){
            column = GeneralUtils.prefix(column);
            
            // Verifica si la Columna es un campo relacionado y si esta populado
            String value = getWrapperValue(content, column);
            // La Columna lleva un link al registro de Contenido
            String link = column == 'Name' ? System.URL.getSalesforceBaseURL().toExternalForm()+'/'+content.Id : null;
            // Crea el Wrapper de campo y lo agrega a la lista
            fieldWrappers.add(new FieldWrapper(value, link));
        }

        // Si es un template y esta publicado, agrega la opcion 'New from Template'
        List<String> actions = new List<String>{};

        // CMS-126 - Adding security checks before adding these actions
        UserRecordAccess ura = SecurityUtils.getUserRecordAccess(content.Id);
    
        if (ura.HasDeleteAccess){
            actions.add(System.Label.General_Delete);
        }
        if (ura.HasReadAccess){
            actions.add(System.Label.General_View);
        }
        if(content.isTemplate__c && content.Status__c == 'Published' && SecurityUtils.isObjectCreateable(GeneralUtils.prefix('[CMS]Content__c'))){
            actions.add(System.Label.ContentLandingNewFromTemplate);
        }

        // Crea el Wrapper de Contenido y lo agrega a la lista
        return new ContentWrapper(content.Id, fieldWrappers, content.RecordType.Id, actions);
    }                                                                                  
                                                              
    static List<Content__c> getRecords(FilterWrapper wrapper, Integer recordOffset, Integer recordLimit){      
        
        String columnSet = getColumnSet();
        columnSet += columnSet.contains(GeneralUtils.prefix('[CMS]Status__c')) ? '' : ','+GeneralUtils.prefix('[CMS]Status__c');
        columnSet += columnSet.contains(GeneralUtils.prefix('[CMS]isTemplate__c')) ? '' : ','+GeneralUtils.prefix('[CMS]isTemplate__c');
        
        String queryInString = 'SELECT Id, ' + columnSet + ' FROM [CMS]Content__c ';
        List<String> queryConditions = getQueryConditions(wrapper);
        // Si no recibe filtros, trae los 10 registros modificados mas recientemente
        if(queryConditions.size() <= 1){
            if(wrapper.searchText == null || wrapper.searchText == ''){
                queryInString += 'WHERE [CMS]isTemplate__c = ' + wrapper.isTemplate + ' ';
                queryInString = setDefaultCondition(queryInString, recordOffset, recordLimit);
            } else {
                queryInString = setSearchCondition(queryInString, wrapper.searchText, recordOffset, recordLimit);
            }
        // Si recibe filtros, construye la query
        } else {
            queryInString = setCustomConditions(queryInString, queryConditions, recordOffset, recordLimit);
        }
        
        // Devuelve los registros filtrados
        System.debug('queryInString: ' + queryInString);
        List<Content__c> records = Database.query(GeneralUtils.prefix(queryInString));
        System.debug('records:' + records);
        return records;
    }

    static List<Content__c> searchTextInRecords(String searchText, List<Content__c> contents){
        List<Content__c> filteredContents = new List<Content__c>();
        List<String> columnSet = getColumnSet().split(',');
        for(Content__c content : contents){
//          for(String column : columnSet){
                if(getWrapperValue(content, 'Name').toLowerCase().contains(searchText.toLowerCase())){
                    if( !filteredContents.contains(content)){
                        filteredContents.add(content);  
                    }                   
                }
//          }
        }
        return filteredContents;
    }

    static String getColumnSet(){
        // Trae las columnas seteadas en Custom Settings
        CMSContentSettings__c settings = CMSContentSettings__c.getInstance();
        return settings.ContentLandingColumnFields__c;
    }

    static List<String> getColumnLabelSet(){
        // Trae las columnas seteadas en Custom Settings
        List<String> columnSet = getColumnSet().split(',');
        List<String> columnLabelSet = new List<String>();
        for(String column : columnSet){
            columnLabelSet.add(getColumnLabel(column));
        }
        return columnLabelSet;
    }

    public static String getColumnLabel(String column){
        List<String> fields = column.split('\\.');
        DescribeSObjectResult objectName = Schema.getGlobalDescribe().get('Content__c').getDescribe();
        String columnLabel = '';

        for(Integer i=0; i < fields.size(); i++){
            if(i!=0)
                columnLabel += ' > ';
            if(i == fields.size() - 1){
                columnLabel += getFieldName(objectName.getName(), fields.get(i), false);
            } else {
                columnLabel += getFieldName(objectName.getName(), fields.get(i), true);
                objectName = getObjectFieldName(objectName.getName(), fields.get(i));
            }
        }
        return columnLabel;
    }

    public static String getFieldName(String objectName, String fieldName, Boolean removeId){
        String fieldLabel = getFieldResult(objectName, fieldName).getLabel();
        if(removeId && fieldLabel.endsWith(' ID')){
            fieldLabel = fieldLabel.substring(0, fieldLabel.length()-3);
        }
        return fieldLabel;
    }

    public static DescribeSObjectResult getObjectFieldName(String objectName, String fieldName){
        Schema.DescribeFieldResult fieldResult = getFieldResult(objectName, fieldName);
        if(fieldName == 'Owner' && fieldResult.getReferenceTo().size() > 1){
            return fieldResult.getReferenceTo()[1].getDescribe();
        }
        return fieldResult.getReferenceTo()[0].getDescribe();
    }

    public static Schema.DescribeFieldResult getFieldResult(String objectName, String fieldName){
        objectName = objectName.replace('__r', '__c');
        fieldName = fieldName.replace('__r', '__c');
        Schema.DescribeFieldResult fieldResult;
        Map<String, Schema.SobjectField> mapField = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields
            .getMap();
        if(mapField.containsKey(fieldName + 'Id')){
            fieldResult = mapField.get(fieldName + 'Id').getDescribe();
        } else {
            fieldResult = mapField.get(fieldName).getDescribe();
        }
        return fieldResult;
    }

    static String getWrapperValue(Content__c content, String column){
        String value;
        // Si la columna es un campo relacionado y esta populado
        if(column.contains('.') && content.getSObject(column.split('\\.')[0]) != null){ 
            value = (String) content.getSObject(column.split('\\.')[0]).get(column.split('\\.')[1]);
        // Si la columna es un campo populado
        } else if(! column.contains('.')){
            value = (String) content.get(column);
        // Si la columna es un campo vacio
        } else {
            value = ' - ';
        }
        return value;
    }

    static List<String> getQueryConditions(FilterWrapper wrapper){
        List<String> queryConditions = new List<String>();
        // Agrega los filtros recibidos a una lista de Query Conditions
        if(wrapper.contentTypeId != null)   queryConditions.add('RecordTypeId = \'' + wrapper.contentTypeId + '\'');
        if(wrapper.clusterId != null)       queryConditions.add('[CMS]Cluster__c = \'' + wrapper.clusterId + '\'');
        if(wrapper.categoryId != null)      queryConditions.add('[CMS]Category__c = \'' + wrapper.categoryId + '\'');
        if(wrapper.isTemplate != null)      queryConditions.add('[CMS]isTemplate__c = ' + wrapper.isTemplate);
        if(String.isNotBlank(wrapper.tagIds)){
            // Trae los IDs de los Contenidos asociados a las Tags recibidas
            wrapper.tagIds = wrapper.tagIds.deleteWhitespace();
            List<String> listOfTagIds = wrapper.tagIds.split(',');

            String tagedContentIds = getTagedContentIds(listOfTagIds);
            if(tagedContentIds != null) queryConditions.add('Id IN ' + tagedContentIds);
        }
        if(wrapper.status != null && wrapper.status.toLowerCase() != 'all') queryConditions.add('[CMS]Status__c = \'' + wrapper.status + '\'');
        return queryConditions;
    }

    static String setDefaultCondition(String queryInString, Integer recordOffset, Integer recordLimit){
        String defaultCondition = 'ORDER BY LastModifiedDate DESC  LIMIT ' + recordLimit + ' OFFSET ' + recordOffset;
        queryInString += defaultCondition;
        return queryInString;
    }

    static String setSearchCondition(String queryInString, String searchText, Integer recordOffset, Integer recordLimit){
        String searchCondition = 'WHERE Name LIKE \'%' + searchText + '%\'';
        queryInString += searchCondition;
        queryInString +=  ' LIMIT ' + recordLimit + ' OFFSET ' + recordOffset;
        return queryInString;
    }

    static String setCustomConditions(String queryInString, List<String> queryConditions, Integer recordOffset, Integer recordLimit){
        // Agrega las Query Conditions a la query
        queryInString += 'WHERE ';
        for(String queryCondition : queryConditions){
            if(queryConditions.indexOf(queryCondition) < queryConditions.size() -1){
                queryInString += queryCondition + ' AND ';
            }
            else{
                queryInString += queryCondition ;
                queryInString +=  ' LIMIT '+ recordLimit + ' OFFSET ' + recordOffset;
            } 
        }
        return queryInString;
    }

    static String getTagedContentIds(List<String> tagIds){
        List<tagAssignment__c> tagAssignments = [SELECT Id, Content__c, Tag__c FROM TagAssignment__c WHERE Tag__c IN: tagIds AND Content__c != NULL];

        Map<String,List<String>> contentTagMap = new Map<String,List<String>>();
        for(tagAssignment__c tagAssignment : tagAssignments){
            // Si el Contenido ya está en al mapa con una Tag, agregamos la Tag actual a su lista
            if(contentTagMap.keySet().contains(tagAssignment.Content__c)){
                contentTagMap.get(tagAssignment.Content__c).add(tagAssignment.Tag__c);
            // Si el Contenido no está en el mapa, lo agregamos creando una lista con la Tag actual
            } else{
                contentTagMap.put(tagAssignment.Content__c, new List<String>{tagAssignment.Tag__c});
            }
        }
        // Construye la lista de Contenidos asociados a las Tags recibidas
        String tagedContentIds = '';
        for(String contentId : contentTagMap.keySet()){
            if(! tagedContentIds.contains(contentId)){
                Boolean taged = true;
                for(String tagId : tagIds){
                    taged &= (contentTagMap.get(contentId).contains(tagId));
                }
                // Si el Contenido está asociado a TODAS las Tags recibidas, lo agrega a la lista
                if(taged){
                    tagedContentIds += '\'' + contentId +  + '\', ';
                }
            }
        }
        
        // Devuelve la lista de forma que pueda ser incluida en la query dinámicamente
        return tagedContentIds.length() > 2 ? tagedContentIds = '(' + tagedContentIds.substring(0, tagedContentIds.length()-2) + ')' : '(\'\')';
    }

}