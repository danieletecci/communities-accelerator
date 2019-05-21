public without sharing class ClusterUserTriggers extends TriggersHandler { 
	
	// Constructor
	public ClusterUserTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
		super(p_triggerNew, p_triggerOld);

		allow_masterLoop_AfterInsert = true;
		allow_masterLoop_AfterUpdate = true;
		allow_masterLoop_AfterUndelete = true;
		allow_masterLoop_AfterDelete = true;
        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
		allow_executeDMLs = true;
        allow_dataPreparing = true;
	}

	// Master loops	
	// Ids of the clusters from the new users that need to be inserted in the corresponding groups
	Set<Id> clusterIdsToGetGroups = new Set<Id>();
    Map<String, Group> groupsByClusterAndAccessLevel = new Map<String, Group>();

	// Cluster Users that need to be added to the cluster groups
	List<ClusterUser__c> clusterUsersToAddToROUpGroups = new List<ClusterUser__c>();
	List<ClusterUser__c> clusterUsersToAddToRODownGroups = new List<ClusterUser__c>();
	List<ClusterUser__c> clusterUsersToAddToRWGroups = new List<ClusterUser__c>();
   
    //Cluster users that need to be removed from the cluster groups
	List<ClusterUser__c> clusterUsersToRemoveFromROUpGroups = new List<ClusterUser__c>();
	List<ClusterUser__c> clusterUsersToRemoveFromRODownGroups = new List<ClusterUser__c>();
	List<ClusterUser__c> clusterUsersToRemoveFromRWGroups = new List<ClusterUser__c>();
	
	// GroupMembers to be inserted
	List<GroupMember> groupMembersToBeInserted = new List<GroupMember>();
	// GroupMembers to be deleted
	List<Id> groupMembersToBeDeleted = new List<Id>();

	public override void masterLoop_AfterInsert(SObject recNew){
		getClusterIdsToGetGroups((ClusterUser__C) recNew, null);
		getClusterUsersToModifyGroupMembers((ClusterUser__C) recNew, null);
		addClusterUserId((ClusterUser__c) recNew);
	}

	public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld){
		getClusterIdsToGetGroups((ClusterUser__C) recNew, (ClusterUser__C) recOld);
		getClusterUsersToModifyGroupMembers((ClusterUser__C) recNew, (ClusterUser__C) recOld);
		addClusterUserId((ClusterUser__c) recNew);
	}

	public override void masterLoop_AfterUndelete(SObject recNew){
		getClusterIdsToGetGroups((ClusterUser__C) recNew, null);
		getClusterUsersToModifyGroupMembers((ClusterUser__C) recNew, null);
	}
	
	public override void masterLoop_AfterDelete(SObject recOld){
		getClusterIdsToGetGroups(null, (ClusterUser__C) recOld);
		getClusterUsersToModifyGroupMembers(null, (ClusterUser__C) recOld);
	}
    
    public override void masterLoop_BeforeInsert(SObject recNew){
        ClusterUser__c clusterUser = (ClusterUser__c) recNew;
        clusterUser.UserForDuplicateRule__c = clusterUser.User__c;
    }
    
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld){    
        ClusterUser__c clusterUserNew = (ClusterUser__c) recNew;
        ClusterUser__c clusterUserOld = (ClusterUser__c) recOld;
        
        if (clusterUserNew.User__c != clusterUserOld.User__c){
            clusterUserNew.UserForDuplicateRule__c = clusterUserNew.User__c;
        }
    }

	// Data preparing
	public override void dataPreparing(){
        getGroupsByClusterAndAccessLevel();		
        addGroupMembersToBeInserted();
		addGroupMembersToBeDeleted();
		validateClusterUsers();
	}

	// DMLs
	public override void executeDMLs(){
        // Future Methods
        insertGroupMembers(JSON.serialize(groupMembersToBeInserted));
        deleteGroupMembers(groupMembersToBeDeleted);

		upsertClusterUserToUserSettings();
	}

	// Use case methods
	private Group getGroupsForClusterUser(ClusterUser__C clusterUser, String accessLevel){
		String key = (String)clusterUser.Cluster__C + accessLevel;
		return groupsByClusterAndAccessLevel.get(key);
	}

	private void getClusterIdsToGetGroups(ClusterUser__C clusterUserNew, ClusterUser__C clusterUserOld){
		if (clusterUserNew == null && clusterUserOld != null){
            clusterIdsToGetGroups.add(clusterUserOld.Cluster__c);
        }
        else if (clusterUserOld == null || clusterUserNew.AccessLevel__c != clusterUserOld.AccessLevel__c){
			clusterIdsToGetGroups.add(clusterUserNew.Cluster__c);
		}
	}

	private void getClusterUsersToModifyGroupMembers(ClusterUser__C clusterUserNew, ClusterUser__C clusterUserOld){
		if (clusterUserNew == null && clusterUserOld.AccessLevel__c == 'Read/Write'){
			clusterUsersToRemoveFromROUpGroups.add(clusterUserOld);
			clusterUsersToRemoveFromRWGroups.add(clusterUserOld);
		}else if (clusterUserNew == null && clusterUserOld.AccessLevel__c == 'Read Only'){
			clusterUsersToremoveFromROUpGroups.add(clusterUserOld);
            clusterUsersToRemoveFromRODownGroups.add(clusterUserOld);
        }else if (clusterUserOld == null && clusterUserNew.AccessLevel__c == 'Read/Write'){
			clusterUsersToAddToROUpGroups.add(clusterUserNew);
			clusterUsersToAddToRWGroups.add(clusterUserNew);
		}else if (clusterUserOld == null && clusterUserNew.AccessLevel__c == 'Read Only'){
			clusterUsersToAddToROUpGroups.add(clusterUserNew);
			clusterUsersToAddToRODownGroups.add(clusterUserNew);
		}else if(clusterUserNew.AccessLevel__c == 'Read Only' && clusterUserOld.AccessLevel__c == 'Read/Write'){
			clusterUsersToAddToRODownGroups.add(clusterUserNew);
			clusterUsersToRemoveFromRWGroups.add(clusterUserOld);
		}else if(clusterUserNew.AccessLevel__c == 'Read/Write' && clusterUserOld.AccessLevel__c == 'Read Only'){
			clusterUsersToRemoveFromRODownGroups.add(clusterUserNew);
			clusterUsersToAddToRWGroups.add(clusterUserOld);
		}else if(clusterUserNew == null){
			clusterUsersToRemoveFromRWGroups.add(clusterUserOld);
			clusterUsersToRemoveFromRODownGroups.add(clusterUserOld);
			clusterUsersToRemoveFromROUpGroups.add(clusterUserOld);
		}
	}
	
	private GroupMember createGroupMemberForClusterUser(ClusterUser__c clusterUser, Group g){
		GroupMember gm = new GroupMember();
		gm.UserOrGroupId = clusterUser.User__c;
		gm.GroupId = g.Id;
		return gm;
	}
    
    private void addGroupMembersToBeInserted(){
        for (ClusterUser__c clusterUser : clusterUsersToAddToROUpGroups){
			addGroupMemberFromClusterUserByAccessLevel(clusterUser, 'ROUp');
		}
		for (ClusterUser__c clusterUser : clusterUsersToAddToRODownGroups){
            addGroupMemberFromClusterUserByAccessLevel(clusterUser, 'RODown');
		}
		for (ClusterUser__c clusterUser : clusterUsersToAddToRWGroups){
            addGroupMemberFromClusterUserByAccessLevel(clusterUser, 'RW');
		}
    }
    
    private void addGroupMemberFromClusterUserByAccessLevel(ClusterUser__c clusterUser, String accessLevel){
        Group groupForClusterUser = getGroupsForClusterUser(clusterUser, accessLevel);
		GroupMember gm = createGroupMemberForClusterUser(clusterUser, groupForClusterUser);
		groupMembersToBeInserted.add(gm);
    }
    
    private void addGroupMembersToBeDeleted(){
        Map<Id, List<Id>> groupsByUser = new Map<Id, List<Id>>();
        
        for (ClusterUser__c clusterUser : clusterUsersToRemoveFromROUpGroups){
            addGroupsByUser(groupsByUser, clusterUser, 'ROUp');
        }
        for (ClusterUser__c clusterUser : clusterUsersToRemoveFromRODownGroups){
            addGroupsByUser(groupsByUser, clusterUser, 'RODown');
        }
        for (ClusterUser__c clusterUser : clusterUsersToRemoveFromRWGroups){
            addGroupsByUser(groupsByUser, clusterUser, 'RW');
        }

		Set<Id> usersForDelete = groupsByUser.keySet(); 
        Set<Id> groupsForDelete = new Set<Id>();
        for (Id userId : usersForDelete){
            groupsForDelete.addAll(groupsByUser.get(userId));
        }
		List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember
                                          WHERE UserOrGroupId IN :usersForDelete
                                          AND GroupId IN :groupsForDelete
                                         ];
        //Filter groupMembers List
		for (GroupMember gm : groupMembers){
            for (Id groupId: groupsByUser.get(gm.UserOrGroupId)){
             	if (groupId == gm.GroupId) groupMembersToBeDeleted.add(gm.Id);    
            }
		}
    }
    
    private void addGroupsByUser(Map<Id, List<Id>> groupsByUser, ClusterUser__c clusterUser, String groupAccessLevel){
        Group g = getGroupsForClusterUser(clusterUser, groupAccessLevel);
        List<Id> groupsIdForUser = groupsByUser.get(clusterUser.User__c);
        if (groupsIdForUser == null) groupsIdForUser = new List<Id>();  
        groupsIdForUser.add(g.Id);
        groupsByUser.put(clusterUser.User__c, groupsIdForUser);
    }
    
    private void getGroupsByClusterAndAccessLevel(){
        List<Cluster__c> clusters = [SELECT Id, PublicGroupRODownName__c, PublicGroupROUpName__c, PublicGroupRWName__c FROM Cluster__c WHERE Id in :clusterIdsToGetGroups];

		Set<String> groupNames = new Set<String>();
		for (Cluster__c cluster : clusters){
			groupNames.add(cluster.PublicGroupRWName__c);
			groupNames.add(cluster.PublicGroupRODownName__c);
			groupNames.add(cluster.PublicGroupROUpName__c);
		}

		List<Group> groups = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN : groupNames];
		Map<String, Group> mapGroups = new Map<String, Group>();
		for (Group g : groups){
			mapGroups.put(g.DeveloperName, g);
		}

		for (Cluster__c cluster : clusters){
			groupsByClusterAndAccessLevel.put((String)cluster.Id + 'RW', mapGroups.get(cluster.PublicGroupRWName__c));
			groupsByClusterAndAccessLevel.put((String)cluster.Id + 'RODown', mapGroups.get(cluster.PublicGroupRODownName__c));
			groupsByClusterAndAccessLevel.put((String)cluster.Id + 'ROUp', mapGroups.get(cluster.PublicGroupROUpName__c));
		}
    }
    
    @Future
    public static void insertGroupMembers(String groupMembersJSON){
        List<GroupMember> groupMembers = (List<GroupMember>)JSON.deserialize(groupMembersJSON, List<GroupMember>.class);
        if (! groupMembers.isEmpty()) insert groupMembers;
    }
    
    @Future
    public static void deleteGroupMembers(List<Id> groupMemberIds){
        system.debug('GMs Ids' + groupMemberIds);
        List<GroupMember> groupMembers = [SELECT Id FROM GroupMember WHERE Id IN :groupMemberIds];
        system.debug('group members to be deleted' + groupMembers);
        if (! groupMembers.isEmpty()) delete groupMembers;
    }

	// CMS-490 Upserting to CMS User Settings
	Map<Id, ClusterUser__c> mapUserIdCluster = new Map<Id, ClusterUser__c>();
	Map<Id, CMSUserSettings__c> mapExistingUserSettings = new Map<Id, CMSUserSettings__c>();
	List<CMSUserSettings__c> listUserSettingsToUpsert = new List<CMSUserSettings__c>();

	private void addClusterUserId(ClusterUser__c recNew){
		if (recNew.User__c != null){
			mapUserIdCluster.put(recNew.User__c, recNew);
		}
	}
 
	private void validateClusterUsers(){
		if (!mapUserIdCluster.isEmpty()){
			// Duplicate check
			for (CMSUserSettings__c userSettingExisting : [SELECT Name, User__c, Cluster__c FROM CMSUserSettings__c WHERE User__c IN: mapUserIdCluster.keySet()]){
				mapExistingUserSettings.put(userSettingExisting.User__c, userSettingExisting);
			}
			// Getting only non Community Users 
			for (User user : [SELECT UserName, Profile.UserLicense.Name FROM User WHERE Id IN : mapUserIdCluster.keySet() AND (NOT Profile.UserLicense.Name LIKE '%Community%')]){
				CMSUserSettings__c userSetting = (mapExistingUserSettings.containsKey(user.Id)) ? mapExistingUserSettings.get(user.Id) : new CMSUserSettings__c();
				userSetting.Name = user.UserName;
				userSetting.User__c = user.Id;
				userSetting.Cluster__c = mapUserIdCluster.get(user.Id).Cluster__c;
				
				listUserSettingsToUpsert.add(userSetting);
			}
		}
	}

	private void upsertClusterUserToUserSettings(){	
		if (!listUserSettingsToUpsert.isEmpty()){
			upsert listUserSettingsToUpsert;
		}
	}
}