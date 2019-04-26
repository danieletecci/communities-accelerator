public class MediaElementsManagerController {
	public class RecordsWrapper{
		@auraEnabled public String place;
		@auraEnabled public SObject junctionObject;
	}

	public class ContentWrapper{
		@auraEnabled public String idME;
		@auraEnabled public String name;
		@auraEnabled public String fileURLDesktop;
		@auraEnabled public String ext;
		@auraEnabled public String lastModified;
		@auraEnabled public String size;
	}

	@auraEnabled
	public static list<RecordsWrapper> getRecord(String recordId, String places, String parentLookup, String junctionObject){
		list<RecordsWrapper> rwList = new list<RecordsWrapper>();

		list<String> placesList= new list<String> (); 
		for (String place: places.split(',')){
			RecordsWrapper rw = new RecordsWrapper ();
			rw.place = place.trim();
			rwList.add(rw);

			placesList.add(place.trim());
		}
		// busco y me fijo si existe un registro del Objeto junctionObject que se relacione a las places e ids
		String joQuery = GeneralUtils.prefix('SELECT Id, [CMS]Placement__c, [CMS]MediaElement__r.[CMS]FileURLDesktop__c, ') + parentLookup + ' FROM ' + junctionObject + ' WHERE Placement__c IN :placesList AND '+ parentLookup + '= \'' + recordId + '\'';
		for(SObject rec: Database.query(joQuery)){
			for(RecordsWrapper rw :rwList){
				system.debug(rw);
				if(rw.place == rec.get(GeneralUtils.prefix('[CMS]Placement__c')) ){
					rw.junctionObject = rec;
				}
			}
		}
		return rwList;
	}
	
	@auraEnabled
    public static List<ContentWrapper> getData(String stringOffset, String searchText, String stringElementPerPage, String findContent){
        Map<String, ContentWrapper> contentWrMap = new Map<String, ContentWrapper>();
        String contentDocId;
		Integer intOffset = Integer.valueOf(stringOffset);
		Integer elementPerPages = Integer.valueOf(stringElementPerPage);

        String whereClause = '';	
		if (String.isNotBlank(searchText)){
			String likeValue = '%' + searchText + '%';
			whereClause += ' WHERE Name LIKE \'' + likeValue + '\'';
		}
        
        Integer totalRows = Database.countQuery(GeneralUtils.prefix('SELECT count() FROM [CMS]MediaElement__c') + whereClause);
        
        if(intOffset >= 0 && intOffset <= totalRows){

            list<MediaElement__c> mediaElementsList = new list<MediaElement__c>();
            String queryMediaElement = 'SELECT Id, Name, [CMS]FileURLDesktop__c, [CMS]FileIdDesktop__c, LastModifiedDate FROM [CMS]MediaElement__c' + whereClause;    
            queryMediaElement += ' ORDER BY LastModifiedDate DESC LIMIT ' + elementPerPages + ' OFFSET ' + intOffset;
		
            Set<String> contentSet = new Set<String>();
            for(MediaElement__c me : Database.query(GeneralUtils.prefix(queryMediaElement))){
                ContentWrapper cw = new ContentWrapper();
                cw.idME = me.Id;
                cw.name = me.Name;
                cw.fileURLDesktop = me.FileURLDesktop__c;
                cw.lastModified = String.valueOf(me.LastModifiedDate);
    
                if(String.isNotBlank(findContent) && findContent == 'true'){
                    if(me.FileIdDesktop__c != null){
                        contentSet.add(me.FileIdDesktop__c);
                    } else {
                        cw.size = 'Web';
                        cw.ext = me.FileURLDesktop__c.substringAfterLast('.');
                    }
                    contentWrMap.put(me.FileIdDesktop__c, cw);
                }else{
                    contentWrMap.put(me.Id, cw);
                }
                
            }
    
            if(String.isNotBlank(findContent) && findContent == 'true'){
                if(contentSet.size() > 0){
                    for(ContentDocument file : [SELECT id, Title, ContentSize, FileExtension FROM ContentDocument WHERE id IN: contentSet]){
                        ContentWrapper cw = contentWrMap.get(file.id);
                        if(file.ContentSize != null){
                            cw.size = String.valueOf(Integer.valueOf(file.ContentSize * 0.001)) + ' KB';
                        }
                        if(String.isNotBlank(file.FileExtension)){
                            cw.ext = file.FileExtension;
                        }
                        contentWrMap.put(file.id, cw);
                    }
                }
            }
        }

        return contentWrMap.values();
    }

	@auraEnabled
	public static void assignMediaElementToId (String recordId, String place, String parentLookup, String junctionObject, String mediaElementId){

		sObject sObj = Schema.getGlobalDescribe().get(junctionObject).newSObject();

		sObj.put(parentLookup, recordId);
		sObj.put(GeneralUtils.prefix('[CMS]MediaElement__c'), mediaElementId);
		sObj.put(GeneralUtils.prefix('[CMS]Placement__c'), place);
		
		list<sObject> listToDelete = new list<sObject> ();
		for(SObject rec: Database.query(GeneralUtils.prefix('SELECT Id, [CMS]Placement__c, [CMS]MediaElement__r.[CMS]FileURLDesktop__c, ' + parentLookup + ' FROM ' + junctionObject + ' WHERE [CMS]Placement__c = \'' + place + '\' AND '+ parentLookup + '= \'' + recordId + '\''))){
			listToDelete.add(rec);
		}

		Savepoint sp = Database.setSavepoint();
		try{
			delete listToDelete;
			insert sObj;
		}catch(Exception e){
			Database.rollback(sp);
			system.debug(e.getMessage());
		}
	}
	
	@auraEnabled
	public static void deleteJunctionObject(String junctionObjectId, String junctionObjectApiName){

		sObject sObj = Schema.getGlobalDescribe().get(junctionObjectApiName).newSObject();
		sObj.put('Id', junctionObjectId);
		
		Savepoint sp = Database.setSavepoint();
		try{
			delete sObj;
		}catch(Exception e){
			Database.rollback(sp);
			system.debug(e.getMessage());
		}
	}
}