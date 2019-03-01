public class ContentDetailController {

    //DATA WRAPPER
    public class DataWrapper{
        @auraEnabled public Content__c content;
        @auraEnabled public List<VisibilitySelectorWrapper> visibilitySelectors;
        @auraEnabled public String currentUserName;
        
        public DataWrapper(Content__c content, List<VisibilitySelectorWrapper> visibilitySelectors, String currentUserName){
            this.content = content;
            this.visibilitySelectors = visibilitySelectors;
            this.currentUserName = currentUserName;
        }
    }

    //VISIBILITY WRAPPER
    public class VisibilitySelectorWrapper {
        @auraEnabled public String label;
        @auraEnabled public String apiName;
        @auraEnabled public Boolean isMultiPicklist;
        @auraEnabled public List<VisibilityOptionWrapper> values;

        public VisibilitySelectorWrapper(String label, String apiName, Boolean isMultiPicklist, List<VisibilityOptionWrapper> values){
            this.label = label;
            this.apiName = apiName;
            this.isMultiPicklist = isMultiPicklist;
            this.values = values;
        }
    }

    //VISIBILITY OPTION WRAPPER
    public class VisibilityOptionWrapper {
        @auraEnabled public String label;
        @AuraEnabled public String id;
        @AuraEnabled public Boolean isSelected;

        public VisibilityOptionWrapper(String label, string id, Boolean isSelected){
            this.label = label;
            this.id = id;
            this.isSelected = isSelected;
        }
    }

    @AuraEnabled
    public static DataWrapper getDataExisting(String recordId){
        //Gets the entire cluster branch of the current user.
        Set<Id> clusterIds = getClusterBranch();
        //Gets the data from the current content.
        Content__c contentRecord = getContentData(recordId);
        //Gets the tags related to the content record.
        Set<Id> tagIds = getTagsFromContentRecord(contentRecord);
        //Gets all the visibility options, with the current content options set as true.
        List<VisibilitySelectorWrapper> visibilitySelectorList = new List<VisibilitySelectorWrapper>();
        visibilitySelectorList.add(getClusterSelectorWrapper(clusterIds, contentRecord.cluster__c));
        visibilitySelectorList.add(getCategorySelectorWrapper(clusterIds, contentRecord.category__c));
        visibilitySelectorList.add(getTagSelectorWrapper(clusterIds, tagIds));
        DataWrapper data = new DataWrapper(contentRecord, visibilitySelectorList, UserInfo.getName());
        return data;

    }

    @AuraEnabled
    public static DataWrapper getDataNew(String contentRecordTypeId){
        //Gets the entire cluster branch of the current user.
        Set<Id> clusterIds = getClusterBranch();
        //Gets the data from the current content.
        Content__c contentRecord = initializeContentValues(contentRecordTypeId);
        //A non allowed record type was passed as url parameter
        if(contentRecord == null){
            return null;
        }
        //Gets all the visibility options.
        List<VisibilitySelectorWrapper> visibilitySelectorList = new List<VisibilitySelectorWrapper>();
        visibilitySelectorList.add(getClusterSelectorWrapper(clusterIds, contentRecord.cluster__c));
        visibilitySelectorList.add(getCategorySelectorWrapper(clusterIds, contentRecord.category__c));
        visibilitySelectorList.add(getTagSelectorWrapper(clusterIds, new Set<Id>()));
        DataWrapper data = new DataWrapper(contentRecord, visibilitySelectorList, UserInfo.getName());
        return data;

    }

    @AuraEnabled
    public static Content__c saveContent(Content__c content, String visibilitySelectorsString, String mediaElementId, String action, List<TagAssignment__c> contentOldTagAssignments){
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug('CONTENT' + content);
            List<VisibilitySelectorWrapper> visibilitySelectors = (List<VisibilitySelectorWrapper>)JSON.deserialize(visibilitySelectorsString, List<VisibilitySelectorWrapper>.class);
            content = updateContent(content, visibilitySelectors, action);
            updateTagAssignments(content, getSelectorByApiName(visibilitySelectors, 'Tag__c'), contentOldTagAssignments);
            if(mediaElementId != null)
                updateMediaElementAssignment(content, mediaElementId);
            
            return content;
        }catch(Exception e){
            Database.rollback(sp);
            System.debug(e + 'Error during content upsert process, rolling back');
            System.debug(e.getStackTraceString());
            return null;
        } 
        
    }

    private static void updateTagAssignments(Content__c content, VisibilitySelectorWrapper tagVisibility, List<TagAssignment__c> contentOldTagAssignments){
        Map<String, String> tagToTagAssignment = new Map<String, String>();
        List<TagAssignment__c> tagAssignmentsToDelete = new List<TagAssignment__c>();
        List<TagAssignment__c> tagAssignmentsToCreate = new List<tagAssignment__c>();
        if(contentOldTagAssignments != null){
            for(TagAssignment__c tagAssignment : contentOldTagAssignments){
                tagToTagAssignment.put(tagAssignment.Tag__c, tagAssignment.Id);
            }
        }
        
        for(VisibilityOptionWrapper tagOption : tagVisibility.values){
            if(tagOption.isSelected){
                //If a new tag is being added to the content
                if(tagToTagAssignment.get(tagOption.id) == null){
                    tagAssignmentsToCreate.add(new TagAssignment__c(Content__c = content.id, Tag__c = tagOption.id));
                }
            }else{
                //If a tag was removed from the content
                if(tagToTagAssignment.get(tagOption.id) != null){
                    tagAssignmentsToDelete.add(new TagAssignment__c(id=tagToTagAssignment.get(tagOption.id)));
                }
            }
        }
        if(!tagAssignmentsToCreate.isEmpty()){
            insert tagAssignmentsToCreate;
        }
        if(!tagAssignmentsToDelete.isEmpty()){
            delete tagAssignmentsToDelete;
        }

    }

    private static void updateMediaElementAssignment(Content__c content, String mediaElementId){

        Boolean MEAAlreadyCreated = false;
        String meListPlacement = content.recordType.name + 'ImageList';
        String meDetailPlacement = content.recordType.name + 'ImageDetail';
        if(content.id != null){
            List<MediaElementAssignment__c> MEAToDelete = new List<MediaElementAssignment__c>();
            List<MediaElementAssignment__c> oldMediaElementAssignments = [SELECT id, mediaElement__c FROM MediaElementAssignment__c WHERE Content__c = :content.id AND (placement__c = :meListPlacement OR placement__c = :meDetailPlacement)];
            for(MediaElementAssignment__c mea : oldMediaElementAssignments){
                if(mea.mediaElement__c != mediaElementId){
                    MEAToDelete.add(mea);
                }else{
                    MEAAlreadyCreated = true;
                }
            }
            delete MEAToDelete;
        }
        if(!MEAAlreadyCreated){
            MediaElementAssignment__c mediaelementAssignmentList = new MediaElementAssignment__c(content__c = content.id, mediaElement__c = mediaElementId, placement__c = meListPlacement);
            MediaElementAssignment__c mediaelementAssignmentDetail = new MediaElementAssignment__c(content__c = content.id, mediaElement__c = mediaElementId, placement__c = meDetailPlacement);
            List<MediaElementAssignment__c> MEAToCreate = new List<MediaElementAssignment__c>{mediaelementAssignmentList, mediaelementAssignmentDetail};
            insert MEAToCreate;
        }
    }

    private static Content__c updateContent(Content__c content, List<VisibilitySelectorWrapper> visibilitySelectors, String action){
        Id newContentCategory;
        Id newContentCluster;
        VisibilitySelectorWrapper categorySelector = getSelectorByApiName(visibilitySelectors, 'Category__c');
        VisibilitySelectorWrapper clusterSelector = getSelectorByApiName(visibilitySelectors, 'Cluster__c');
        for(VisibilityOptionWrapper category : categorySelector.values){
            if(category.isSelected){
                newContentCategory = category.id;
                break;
            }
        }
        for(VisibilityOptionWrapper cluster : clusterSelector.values){
            if(cluster.isSelected){
                newContentCluster = cluster.id;
            }
        }
        content.Cluster__c = newContentCluster;
        content.Category__c = newContentCategory;
        content.Name = content.ListTitle__c;
        if(action == 'Publish'){
			content.Status__c = 'Published';
		}else if (action == 'UnPublish' || action == 'Draft'){
			content.Status__c = 'Draft';
		}
        if(content.id == null)
            insert content;
        else
            update content;
        return content;
    }

    private static Set<Id> getClusterBranch(){
        List<ClusterUser__c> clusterUser = [SELECT Cluster__c FROM ClusterUser__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        if(!clusterUser.isEmpty()){
            Set<Id> clusters =  ClusterUtils.getEntireClusterBranch(clusterUser.get(0).cluster__c);
            return clusters;
        }
        return null;
    }

    private static Content__c getContentData(String recordId){
        Content__c content = [SELECT name, lastModifiedDate, createdBy.name, cluster__c, category__c, 
                                     ListTitle__c, Description__c, ListDescription__c, Status__c, 
                                     RecordType.name, ExternalId__c,
                              (SELECT Tag__c FROM Tags__r),
                              (SELECT MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE placement__c LIKE '%ImageList') 
                              FROM Content__c 
                              WHERE id = :recordId];
        return content;
    }

    private static Set<Id> getTagsFromContentRecord(Content__c content){
        Set<Id> tagIds = new Set<Id>();
        for(TagAssignment__c tagAssignment : content.tags__r){
            tagIds.add(tagAssignment.Tag__c);
        }
        return tagIds;
    }

    private static VisibilitySelectorWrapper getClusterSelectorWrapper(Set<Id> clusterIds, String contentClusterId){
        List<Cluster__c> clusters = [SELECT id, name FROM Cluster__c WHERE id IN :clusterIds];
        List<VisibilityOptionWrapper> clusterWrapperList = new List<VisibilityOptionWrapper>();
        for(Cluster__c cluster : clusters){
            VisibilityOptionWrapper clusterWrapper;  
            if(cluster.id == contentClusterId){
                clusterWrapper = new VisibilityOptionWrapper(cluster.name, cluster.Id, true);
            }else{
                clusterWrapper = new VisibilityOptionWrapper(cluster.name, cluster.Id, false);
            }
            clusterWrapperList.add(clusterWrapper);
        }
        VisibilitySelectorWrapper clusterSelectorWrapper = new VisibilitySelectorWrapper('Cluster', 'Cluster__c', false, clusterWrapperList);
        return clusterSelectorWrapper;
    }

    private static VisibilitySelectorWrapper getCategorySelectorWrapper(Set<Id> clusterIds, String contentCategoryId){
        List<Category__c> categories = [SELECT id, name FROM Category__c WHERE Cluster__c IN :clusterIds];
        List<VisibilityOptionWrapper> categoryWrapperList = new List<VisibilityOptionWrapper>();
        for(Category__c category : categories){
            VisibilityOptionWrapper categoryWrapper;  
            if(category.id == contentCategoryId){
                categoryWrapper = new VisibilityOptionWrapper(category.name, category.Id, true);
            }else{
                categoryWrapper = new VisibilityOptionWrapper(category.name, category.Id, false);
            }
            categoryWrapperList.add(categoryWrapper);
        }
        VisibilitySelectorWrapper categorySelectorWrapper = new VisibilitySelectorWrapper('Category', 'Category__c', false, categoryWrapperList);
        return categorySelectorWrapper;
    }

    private static VisibilitySelectorWrapper getTagSelectorWrapper(Set<Id> clusterIds, Set<Id> tagIds){
        List<Tag__c> tags = [SELECT id, name FROM Tag__c WHERE Cluster__c IN :clusterIds];
        List<VisibilityOptionWrapper> tagWrapperList = new List<VisibilityOptionWrapper>();
        for(Tag__c tag : tags){
            VisibilityOptionWrapper tagWrapper;  
            if(tagIds.contains(tag.Id)){
                tagWrapper = new VisibilityOptionWrapper(tag.name, tag.Id, true);
            }else{
                tagWrapper = new VisibilityOptionWrapper(tag.name, tag.Id, false);
            }
            tagWrapperList.add(tagWrapper);
        }
        VisibilitySelectorWrapper categorySelectorWrapper = new VisibilitySelectorWrapper('Tags', 'Tag__c', true, tagWrapperList);
        return categorySelectorWrapper;
    }

    private static VisibilitySelectorWrapper getSelectorByApiName(List<VisibilitySelectorWrapper> visibilitySelectorList, String apiName){
        for(VisibilitySelectorWrapper visibilitySelector : visibilitySelectorList){
            if(visibilitySelector.apiName == apiName){
                return visibilitySelector;
            }
        }
        return null;
    }

    private static Content__c initializeContentValues(Id recordTypeId){
        Content__c content = new Content__c();
        RecordType rt = [SELECT id, name, developerName FROM RecordType WHERE Id = :recordTypeId];
        if(rt.developerName != 'News'){
            return null;
        }
        content.name = '';
        content.listTitle__c = '';
        content.description__c = '';
        content.listDescription__c = '';
        content.ExternalId__c = '';
        content.recordTypeId = recordTypeId;
        content.recordType = rt;
        return content;
    }
}