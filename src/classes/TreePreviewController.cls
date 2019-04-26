public with sharing class TreePreviewController {

   //WRAPPER
   	public class ItemWrapper{
   		@auraEnabled public String name;
   		@auraEnabled public String id;
   		@auraEnabled public String link;
   		@auraEnabled public String parent;
   		@auraEnabled public List<ItemWrapper> childsList;
		public ItemWrapper(String id, String name, String parent){
	        this.id = id;
            this.name = name;
	        this.parent = parent;
	        this.childsList = new List<ItemWrapper>();
	        this.link = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+id; 
        }   		
   	}
     
    @AuraEnabled
    public static ItemWrapper getTree (String recordId, String objectName, String parentLookUP){
			objectName = GeneralUtils.prefix(objectName);
			parentLookUP = GeneralUtils.prefix(parentLookUP);
    	String referentLookUP= parentLookUP.replace('__c', '__r'); 

    	ItemWrapper root;
    	if (recordId != null){
    		List<ItemWrapper> itemsList = new List<ItemWrapper>();
    		Map<String, List<ItemWrapper>> mapTree = new Map<String, List<ItemWrapper>>();
		
			TreePreviewController.getClustersParent(recordId, objectName, parentLookUP, referentLookUP, mapTree, itemsList);
			TreePreviewController.getClustersChild(recordId, objectName, parentLookUP, referentLookUP, mapTree, itemsList);
		

			for(ItemWrapper wrap : itemsList){
				if(wrap.parent==null){
					root = wrap;
				}
				if(mapTree.containsKey(wrap.id)){
					wrap.childsList=mapTree.get(wrap.id);
				}
			}

		}
				
    	return root;
    }
    
    private static void getClustersParent(String recordId, String objectName, String parentLookUP, String referentLookUP, Map<String, List<ItemWrapper>> mapTree, List<ItemWrapper> itemsList){
    	
    	String query='SELECT Id, name, '+parentLookUP+', '+referentLookUP+'.name, '; 
    	query +=referentLookUP+'.'+parentLookUP+' , '+referentLookUP+'.'+referentLookUP+'.name, '; 
    	query +=referentLookUP+'.'+referentLookUP+'.'+parentLookUP+', '+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.name, '; 
    	query +=referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP+', '+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.name, ';
    	query +=referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP+', '+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.name ';
    	query +='FROM '+objectName+' WHERE Id =:recordId';

  		SObject rec = Database.query(GeneralUtils.prefix(query));

		setMapTree(mapTree, new ItemWrapper(rec.Id, 
											(String)GeneralUtils.getFieldValue(rec, 'Name'), 
											(String)GeneralUtils.getFieldValue(rec, parentLookUP)), 
											itemsList);
		if(GeneralUtils.getFieldValue(rec, parentLookUP) != null){

			setMapTree(mapTree, 
						new ItemWrapper((String)GeneralUtils.getFieldValue(rec, parentLookUP),  
								(String)GeneralUtils.getFieldValue(rec, referentLookUP+'.name'), 
								(String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+parentLookUP)), 
					itemsList);

			if(GeneralUtils.getFieldValue(rec, referentLookUP+'.'+parentLookUP) != null){

				setMapTree(mapTree,
						  new ItemWrapper((String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+parentLookUP),
						  				 (String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.name'),
						  				 (String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+parentLookUP)),
						  itemsList);
				
				if(GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+parentLookUP) != null){
					
					setMapTree(mapTree, 
							  new ItemWrapper((String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+parentLookUP),
							  				  (String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.name'),
							  				  (String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP)), 
							  itemsList);

					if(GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP) != null){
						setMapTree(mapTree, 
									new ItemWrapper((String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP),
							  				  (String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.name'),
							  				  (String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP)), 
							  		itemsList);

						if(GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP) != null){
							setMapTree(mapTree, 
									new ItemWrapper((String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP),
							  						(String)GeneralUtils.getFieldValue(rec, referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.name'),
							  				  		null), 
							  		itemsList);
						}
					}
				}
			}
		}

		
    }

    private static void getClustersChild(String recordId, String objectName, String parentLookUP, String referentLookUP, Map<String, List<ItemWrapper>> mapTree, List<ItemWrapper> itemsList){
    	
    	String query= 'SELECT Id, name, '+parentLookUP;
    	query +=' FROM '+objectName+' WHERE '+parentLookUP+' =: recordId'; 
    	query +=' OR '+referentLookUP+'.'+parentLookUP+' =: recordId'; 
    	query +=' OR '+referentLookUP+'.'+referentLookUP+'.'+parentLookUP+' =: recordId';
    	query +=' OR '+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP+' =: recordId';
    	query +=' OR '+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+referentLookUP+'.'+parentLookUP+' =: recordId';

    	for (SObject rec : Database.query(GeneralUtils.prefix(query))){
    		
			setMapTree(mapTree, 
    					new ItemWrapper(rec.Id, 
											(String)GeneralUtils.getFieldValue(rec, 'Name'), 
											(String)GeneralUtils.getFieldValue(rec, parentLookUP)), 
											itemsList);
    	}
    }

    private static void setMapTree (Map<String, List<ItemWrapper>> mapTree, ItemWrapper item, List<ItemWrapper> itemsList){

    	if(mapTree.containsKey(item.parent)){
			mapTree.get(item.parent).add(item);
		}else{
			mapTree.put((item.parent !=null)? item.parent : 'ROOT', new List<ItemWrapper>{item});
		}
		itemsList.add(item);
    }

}