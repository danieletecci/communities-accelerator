public class GeneralUtils{

    public static String generateExternalId(String name, String clusterID, String sobjectType){
        String apiName = name.deleteWhitespace();
        // Alternativa: '[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|°|-|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]'s
        apiName = apiName.replaceAll('[^a-zA-Z0-9]', '_');

        if (clusterID == null){
            return apiName;
        } else {
            if (Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(clusterID).matches() ){
                Cluster__c cluster = [SELECT Id, ExternalID__c FROM Cluster__c WHERE Id =: clusterID];

                if(String.isNotEmpty(sobjectType) && sobjectType.equalsIgnoreCase('Content__c')){
                   
                    String dateString = String.valueOf(datetime.now());
                 
                    dateString = dateString.replaceAll('-','');
                    dateString = dateString.replaceAll(':','');
                    dateString = dateString.replaceAll(' ','');
                    if(apiName.length()>59){
                        apiName=apiName.subString(0,59);    
                    }
                    return cluster.ExternalID__c +'_'+ apiName +'_'+ dateString;// contentDate + timeString;
                }else{
                    if(apiName.length()>74){
                        apiName=apiName.subString(0,74);    
                    }
                    apiName=cluster.ExternalID__c +'_'+ apiName;
                }
            }
        }
        return apiName;
    }

    public static String joinFields(List<String> listToJoin){
        set<String> finalset = new set<String>();
        finalset.addAll(listToJoin);
        return joinFields(finalset);
    }

    public static String joinFields(set<String> setToJoin){
        set<String> finalset = new set<String>();
        for(String f: setToJoin){
            finalset.add(f.toLowerCase());
        }
        return String.join((Iterable<String>)finalset, ', ');
    }

    public static String replaceDynamicFields(String originalText, String objectApiName, Id recordId, Boolean addQuotes){
        if(originalText != null && objectApiName != null && recordId != null){
            objectApiName = objectApiName.toLowerCase();

            if(originalText.substringBetween('[!' + objectApiName + '.', ']') != null){            
                set<String> fieldsToRep = new set<String>();
                String auxText = originalText;
                while(auxText.substringBetween('[!' + objectApiName + '.', ']') != null) {
                    String fieldApiName = auxText.substringBetween('[!' + objectApiName + '.', ']');
                    auxText = auxText.replace('[!' + objectApiName + '.' + fieldApiName + ']', '');
                    fieldsToRep.add(fieldApiName);
                }
                
                if(!fieldsToRep.isEmpty()){
                    String fieldsToRepStr = '';
                    for(String fieldApiName: fieldsToRep){
                        fieldsToRepStr += (fieldsToRepStr == '' ? fieldApiName : ', ' + fieldApiName);
                    }
                    String query = 'SELECT ' + fieldsToRepStr + ' FROM ' + objectApiName + ' WHERE Id =: recordId';

                    try{
                        SObject rec = Database.query(query);
                        while(originalText.substringBetween('[!' + objectApiName + '.', ']') != null) {
                            try{
                                String fieldApiName = originalText.substringBetween('[!' + objectApiName + '.', ']');
                                if(getFieldValue(rec, fieldApiName) != null){
                                    originalText = originalText.replace('[!' + objectApiName + '.' + fieldApiName + ']', (addQuotes ? '\'' : '') + String.ValueOf(getFieldValue(rec, fieldApiName)) + (addQuotes ? '\'' : ''));
                                }else{
                                    originalText = originalText.replace('[!' + objectApiName + '.' + fieldApiName + ']', (addQuotes ? '\'' : '') + (addQuotes ? '\'' : ''));
                                }
                            }catch(Exception e){}
                        }
                    }catch(Exception e){}
                }
            }
        }
        return originalText;
    }

    public static Object getFieldValue(SObject record, String fieldPath){
        SObject recordAux = record;
        while(fieldPath.contains('.')){
            String fieldAux = fieldPath.substring(0, fieldPath.indexOf('.'));
            fieldPath = fieldPath.substring(fieldPath.indexOf('.') + 1, fieldPath.length());
            if(recordAux.getSObject(fieldAux) != null){
                recordAux = recordAux.getSObject(fieldAux);
            }else{
                return null;
            }
        }
        Object val = recordAux.get(fieldPath);
        return val;
    }

    public static map<Id, List<ContentVersion>> getFilesByParentId(Set<ID> idSet){
        map<Id, List<ContentVersion>> mapParentIdFiles = new map<Id, List<ContentVersion>>();

        if(!idSet.isEmpty()){
            for(Id ids: idSet){
                mapParentIdFiles.put(ids, new List<ContentVersion>());
            }

            //Get document ids from ContentDocumentLink
            set<Id> setDocumentIds = new set<Id>();
            List<ContentDocumentLink> fileLinks = [select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId in: idSet];
            for(ContentDocumentLink fileLink: fileLinks){
                setDocumentIds.add(fileLink.ContentDocumentId);
            }

            //Get ContentVersions from documents
            map<Id, ContentVersion> mapContentVersion = new map<Id, ContentVersion>();
            for(ContentVersion cv: [select Id, title, ContentDocumentId from ContentVersion where ContentDocumentId in: setDocumentIds]){
                mapContentVersion.put(cv.ContentDocumentId, cv);
            }

            //Map to relate a record with his files
            for(ContentDocumentLink fileLink: fileLinks){
                if(mapContentVersion.containsKey(fileLink.ContentDocumentId)){
                    mapParentIdFiles.get(fileLink.LinkedEntityId).add(mapContentVersion.get(fileLink.ContentDocumentId));
                }
            }
        }

        return mapParentIdFiles;
    }

    public static String getSubstring(String text, Integer length){
        String retText;
        if(text != null){
            if(text.length() > length){
                retText = text.substring(0, length);
            }else{
                retText = text;
            }
        }
        return retText;
    }
    
    public static Boolean isSafeObject(String objName, Boolean checkPermissions){
        Boolean result = false;
        
        SObjectType myObj = Schema.getGlobalDescribe().get(objName);
        
        if(myObj != null) {
            if(checkPermissions) {
                if(myObj.getDescribe().isAccessible()) {
                    result = true;
                }
            }else {
                result = true;
            }
        }
        
        return result;
    }

    public static Boolean isSafeField(String objName, String fieldName, Boolean checkPermissions){
        Boolean result = false;
        
        if(isSafeObject(objName, checkPermissions)) {
            SObjectField myField = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName);
            
            if(myField != null) {
                if(checkPermissions) {
                    if(myField.getDescribe().isAccessible()){
                        result = true;
                    }
                }else {
                    result = true;
                }
            }    
        }
        return result;
    }

    public static map<String, Network> mapNetworks;
    public static Network getNetwork(String networkId){
        if(mapNetworks == null){
            mapNetworks = new map<String, Network>();
            for(Network n: [SELECT Id, Name FROM Network]){
                mapNetworks.put(n.Id, n);
                mapNetworks.put(String.valueOf(n.Id).substring(0, 15), n);
            }
        }
        return mapNetworks.get(networkId);
    }

    public static Map<String,String> getGroupKeyAndGroupType(String groupItemName, String readAndWrite, String readAndOnly){
        Map<String, String> mapGroupKeyAndGroupType = new Map<String, String>();
        List<String> groupItemNameList = groupItemName.split('_');
        String groupKey = '';
        String groupType = '';
        Boolean firstTime = true;
        for(String item: groupItemNameList){
            if(item != readAndWrite && item != readAndOnly){
                if(firstTime){
                    groupKey += item;
                    firstTime = false;
                }else{
                    groupKey += '_' + item;
                }
            }else{
                groupType = item;
            }
        }
        mapGroupKeyAndGroupType.put('groupKey',groupKey);
        mapGroupKeyAndGroupType.put('groupType',groupType);
        return mapGroupKeyAndGroupType;
    }

    public static Set<String> getObjectFieldNames(String objectApiName){
        Set<String> fieldNames = new Set<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType ctype = gd.get(objectApiName); 
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
        for(Schema.sObjectField field : fmap.values()){
            fieldNames.add(field.getDescribe().getName());
        }
        return fieldNames;
    }

    /* Check if an Sobject has a field */
    public static boolean hasSObjectField(String fieldName, SObject so){
        String s = JSON.serialize(so);
        // Deserialize it back into a key/value map
        Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(s);
         
        // Build a set containing the fields present on our SObject
        Set<String> fieldsPresent = obj.keyset().clone();
         
        return fieldsPresent.contains(fieldName);
    }
    
    
    public static String getNavigationId(String navigationUrl) {
        if (String.isNotBlank(navigationUrl)){
            String url = navigationUrl.split('/')[navigationUrl.split('/').size()-1];   
            List<Navigation__c> nav = [SELECT Id From Navigation__c WHERE Url__c =: url LIMIT 1]; 
            if (nav.size() > 0){
                return nav[0].Id;
            }            
        }       
        return ''; 
    }    
}