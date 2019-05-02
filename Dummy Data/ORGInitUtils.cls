public with sharing class ORGInitUtils {
    private static map<String, RecordType> mapRecordTypes;
    private static map<String, SObject> mapRecords = new map<String, SObject>();
    private static set<String> caObjectsSet = new set<String>{'Category__c','CategoryAssignment__c','Cluster__c','ClusterUser__c','Component__c','Content__c','ContentAssignment__c','MediaElement__c','MediaElementAssignment__c','Navigation__c','Tag__c','TagAssignment__c','Translation__c','Menu__c','RecipeIngredient__c','Brand__c', 'DatatableAction__c'};
        
    private static void addToMapRecords(List<SObject> records){
        for(SObject rec: records){
            mapRecords.put((String)rec.get('ExternalId__c'), rec);
        }
    }

    private static String getId(String externalId){
        if(externalId != null && mapRecords.containsKey(externalId)){
            return (String)mapRecords.get(externalId).get('id');
        }
        return null;
    }    
    
    private static RecordType getRTId(String objDevName){
        if(mapRecordTypes == null){
            mapRecordTypes = new map<String, RecordType>();
            for(RecordType rt: [SELECT Id, SObjectType, DeveloperName, Name FROM RecordType WHERE SObjectType IN: caObjectsSet]){
                mapRecordTypes.put((rt.SObjectType + '-' + rt.DeveloperName).toLowerCase(), rt);
            }
        }
        return mapRecordTypes.get(objDevName.toLowerCase());
    }
    
    public static void deleteDummyData(){
        delete [SELECT Id FROM Content__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Component__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Category__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Tag__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM MediaElement__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Navigation__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Menu__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM ClusterUser__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Cluster__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM CategoryAssignment__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM ContentAssignment__c WHERE Name LIKE 'DUMMY_%'];
        //delete [SELECT Id FROM ContentCartltem__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM MediaElementAssignment__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM MenuAssignment__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM TagAssignment__c WHERE Name LIKE 'DUMMY_%'];
        delete [SELECT Id FROM Translation__c WHERE Name LIKE 'DUMMY_%'];
    }
    
    public static void deleteAllCMSData(){
        delete [SELECT Id FROM Content__c];
        delete [SELECT Id FROM Component__c];
        delete [SELECT Id FROM Category__c];
        delete [SELECT Id FROM Tag__c];
        delete [SELECT Id FROM MediaElement__c];
        delete [SELECT Id FROM Navigation__c];
        delete [SELECT Id FROM Menu__c];
        delete [SELECT Id FROM ClusterUser__c];
        delete [SELECT Id FROM Cluster__c];
        delete [SELECT Id FROM CategoryAssignment__c];
        delete [SELECT Id FROM ContentAssignment__c];
        //delete [SELECT Id FROM ContentCartltem__c];
        delete [SELECT Id FROM MediaElementAssignment__c];
        delete [SELECT Id FROM MenuAssignment__c];
        delete [SELECT Id FROM TagAssignment__c];
        delete [SELECT Id FROM Translation__c];
    }

    public static void upsertDummyData(){
        
        createUsersAndPermissionSetAssignment();
        
        //TriggersHandlerManager.byPassTrigger('ClusterTriggers');
        upsertClusters();
        
        TriggersHandlerManager.byPassTrigger('CategoryTriggers');
        upsertCategories();
        
        TriggersHandlerManager.byPassTrigger('TagTriggers');
        upsertTags();
        
        TriggersHandlerManager.byPassTrigger('MediaElementTriggers');
        upsertMediaElements();
        
        TriggersHandlerManager.byPassTrigger('NavigationTriggers');
        upsertNavigations();
        
        TriggersHandlerManager.byPassTrigger('MenuTriggers');
        upsertMenus();
        
        TriggersHandlerManager.byPassTrigger('ContentTriggers');
        upsertContents();
        
        TriggersHandlerManager.byPassTrigger('ComponentTriggers');
        upsertComponents();
        
        TriggersHandlerManager.byPassTrigger('BrandTriggers');
        //upsertBrands();
        
        TriggersHandlerManager.byPassTrigger('TranslationTriggers');
        upsertTranslation();
        
        TriggersHandlerManager.byPassTrigger('MenuAssignmentTriggers');
        upsertMenuAssigment();

        //TriggersHandlerManager.byPassTrigger('RecipeTriggers');
        //upsertRecipe();
        
        //TriggersHandlerManager.byPassTrigger('RecipeIngredientTriggers');
        //upsertRecipeIngredient();
        
        //TriggersHandlerManager.byPassTrigger('RecipeStepTriggers');
        //upsertRecipeStep();
        
        //upsertContentCartItems();

        upsertSearchDetails(); 
        
        TriggersHandlerManager.byPassTrigger('DatatableTriggers');
        upsertListViews();
    }

    private static void upsertClusters(){
        //Inserta 28 Clusters

        List<Cluster__c> clustersLevel1List = new List<Cluster__c>();
        List<Cluster__c> clustersLevel2List = new List<Cluster__c>();
        List<Cluster__c> clustersLevel3List = new List<Cluster__c>();
        List<Cluster__c> clustersLevel4List = new List<Cluster__c>();

        //Clusters Nivel 1
        Cluster__c onTradeClusterGlobal = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterRoot').Id,   Name = 'DUMMY_On Trade - Global',     ExternalId__c = 'DONTG',   CommunityName__c = 'OnTrade',   CommunityURL__c = 'ontrade.com',    MappingClusterField__c = 'DefaultLanguage__c',  MappingObject__c = 'User',  MappingObjectField__c = 'LanguageLocaleKey',    DefaultLanguage__c = 'en_US',   ParentCluster__c = null);
        Cluster__c offTradeClusterGlobal = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterRoot').Id,   Name = 'DUMMY_Off Trade - Global',    ExternalId__c = 'DOFTG',  CommunityName__c = 'OffTrade',  CommunityURL__c = 'offtrade.com',   MappingClusterField__c = 'DefaultLanguage__c',  MappingObject__c = 'User',  MappingObjectField__c = 'LanguageLocaleKey',    DefaultLanguage__c = 'en_US',   ParentCluster__c = null);

        clustersLevel1List.add(onTradeClusterGlobal);
        clustersLevel1List.add(offTradeClusterGlobal);
        
        List<Database.UpsertResult> clusterL1Result = Database.upsert(clustersLevel1List, Cluster__c.Fields.ExternalId__c, true);
        
        //Cluster Nivel 2 - ON-TRADE
        Cluster__c onTradeClusterEurope     = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DOnTrade - Europe',     ExternalId__c = 'On_Eu',   DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterGlobal.Id);
        Cluster__c onTradeClusterAmerica    = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DUMMY_On Trade - America',    ExternalId__c = 'On_Am',  DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterGlobal.Id);
        Cluster__c onTradeClusterAsia       = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DUMMY_On Trade - Asia',       ExternalId__c = 'On_As',     DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterGlobal.Id);

        //Cluster Nivel 2 - OFF-TRADE
        Cluster__c offTradeClusterEurope    = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DUMMY_Off Trade - Europe',    ExternalId__c = 'Of_Eu',  DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterGlobal.Id);
        Cluster__c offTradeClusterAmerica   = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DUMMY_Off Trade - America',   ExternalId__c = 'Of_Am', DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterGlobal.Id);

        clustersLevel2List.add(onTradeClusterEurope);
        clustersLevel2List.add(onTradeClusterAmerica);
        clustersLevel2List.add(onTradeClusterAsia);
        clustersLevel2List.add(offTradeClusterEurope);
        clustersLevel2List.add(offTradeClusterAmerica);
        
        List<Database.UpsertResult> clusterL2Result = Database.upsert(clustersLevel2List, Cluster__c.Fields.ExternalId__c, true);
        
        //Cluster Nivel 3 - ON-TRADE
        //Europa
        system.debug('onTradeClusterEurope.Id: ' + onTradeClusterEurope.Id);
        Cluster__c onTradeClusterSpain      = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Spain',      ExternalId__c = 'On_Sp',        DefaultLanguage__c = 'es',      ParentCluster__c = onTradeClusterEurope.Id);
        Cluster__c onTradeClusterFrance     = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - France',     ExternalId__c = 'On_Fr',       DefaultLanguage__c = 'fr',      ParentCluster__c = onTradeClusterEurope.Id);
        Cluster__c onTradeClusterUK         = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DUMMY_On Trade - UK',         ExternalId__c = 'On_UK',           DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterEurope.Id);

        //America
        system.debug('onTradeClusterAmerica.Id: ' + onTradeClusterAmerica.Id);
        Cluster__c onTradeClusterArgentine  = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Argentine',  ExternalId__c = 'On_Ar',    DefaultLanguage__c = 'es',      ParentCluster__c = onTradeClusterAmerica.Id);
        Cluster__c onTradeClusterBrazil     = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Brazil',    ExternalId__c = 'On_Br',      DefaultLanguage__c = 'pt_BR',   ParentCluster__c = onTradeClusterAmerica.Id);
        Cluster__c onTradeClusterUS         = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - US',         ExternalId__c = 'On_US',           DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterAmerica.Id);

        //Asia
        Cluster__c onTradeClusterJapan      = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Japan',      ExternalId__c = 'On_Jp',        DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterAsia.Id);

        //Cluster Nivel 3 - OFF-TRADE
        //Europa
        Cluster__c offTradeClusterSpain     = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - Spain',     ExternalId__c = 'Of_Sp',       DefaultLanguage__c = 'es',      ParentCluster__c = offTradeClusterEurope.Id);
        Cluster__c offTradeClusterFrance    = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - France',    ExternalId__c = 'Of_Fr',      DefaultLanguage__c = 'fr',      ParentCluster__c = offTradeClusterEurope.Id);
        Cluster__c offTradeClusterUK        = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterGroup').Id,  Name = 'DUMMY_Off Trade - UK',        ExternalId__c = 'Of_UK',          DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterEurope.Id);

        //America
        Cluster__c offTradeClusterArgentine = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - Argentine', ExternalId__c = 'Of_Ar',   DefaultLanguage__c = 'es',      ParentCluster__c = offTradeClusterAmerica.Id);
        Cluster__c offTradeClusterBrazil    = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - Brazil',   ExternalId__c = 'Of_Br',     DefaultLanguage__c = 'pt_BR',   ParentCluster__c = offTradeClusterAmerica.Id);
        Cluster__c offTradeClusterUS        = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - US',        ExternalId__c = 'Of_US',          DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterAmerica.Id);
        
        clustersLevel3List.add(onTradeClusterSpain);
        clustersLevel3List.add(onTradeClusterFrance);
        clustersLevel3List.add(onTradeClusterUK);
        clustersLevel3List.add(onTradeClusterArgentine);
        clustersLevel3List.add(onTradeClusterBrazil);
        clustersLevel3List.add(onTradeClusterUS);
        clustersLevel3List.add(onTradeClusterJapan);
        clustersLevel3List.add(offTradeClusterSpain);
        clustersLevel3List.add(offTradeClusterFrance);
        clustersLevel3List.add(offTradeClusterUK);
        clustersLevel3List.add(offTradeClusterArgentine);
        clustersLevel3List.add(offTradeClusterBrazil);
        clustersLevel3List.add(offTradeClusterUS);
                
        List<Database.UpsertResult> clusterL3Result = Database.upsert(clustersLevel3List, Cluster__c.Fields.ExternalId__c, true);
        
        //Cluster Nivel 4 - ON-TRADE
        //UK
        Cluster__c onTradeClusterEngland    = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - England',    ExternalId__c = 'On_En',      DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterUK.Id);
        Cluster__c onTradeClusterIreland    = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Ireland',    ExternalId__c = 'On_Ir',      DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterUK.Id);
        Cluster__c onTradeClusterWales      = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Wales',      ExternalId__c = 'On_Wa',        DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterUK.Id);
        Cluster__c onTradeClusterScotland   = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_On Trade - Scotland',   ExternalId__c = 'On_Sc',     DefaultLanguage__c = 'en_US',   ParentCluster__c = onTradeClusterUK.Id);
        
        //Cluster Nivel 4 - OFF-TRADE
        //UK
        Cluster__c offTradeClusterEngland   = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - England',   ExternalId__c = 'Of_En',     DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterUK.Id);
        Cluster__c offTradeClusterIreland   = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - Ireland',   ExternalId__c = 'Of_Ir',     DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterUK.Id);
        Cluster__c offTradeClusterWales     = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - Wales',     ExternalId__c = 'Of_Wa',       DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterUK.Id);
        Cluster__c offTradeClusterScotland  = new Cluster__c(RecordTypeId = getRTId('Cluster__c-ClusterLeaf').Id,   Name = 'DUMMY_Off Trade - Scotland',  ExternalId__c = 'Of_Sc',    DefaultLanguage__c = 'en_US',   ParentCluster__c = offTradeClusterUK.Id);

        clustersLevel4List.add(onTradeClusterEngland);
        clustersLevel4List.add(onTradeClusterIreland);
        clustersLevel4List.add(onTradeClusterWales);
        clustersLevel4List.add(onTradeClusterScotland);
        clustersLevel4List.add(offTradeClusterEngland);
        clustersLevel4List.add(offTradeClusterIreland);
        clustersLevel4List.add(offTradeClusterWales);
        clustersLevel4List.add(offTradeClusterScotland);
        
        List<Database.UpsertResult> clusterL4Result = Database.upsert(clustersLevel4List, Cluster__c.Fields.ExternalId__c, true);
        
        addToMapRecords(clustersLevel1List);
        addToMapRecords(clustersLevel2List);
        addToMapRecords(clustersLevel3List);
        addToMapRecords(clustersLevel4List);
    }

    private static void upsertCategories(){
        //Inserta 30 Categories
        
        List<Category__c> categoriesLevel1List = new List<Category__c>();
        List<Category__c> categoriesLevel2List = new List<Category__c>();
        List<Category__c> categoriesLevel3List = new List<Category__c>();
        List<Category__c> categoriesLevel4List = new List<Category__c>();
        List<Category__c> categoriesLevel5List = new List<Category__c>();
        
        //Categories Nivel 1
        Category__c celularesyTelefonos     = new Category__c(Name = 'DUMMY_Celulares y Teléfonos',       ExternalId__c = 'DUMMY_CelularesyTelefonos',      Cluster__c = getId('DONTG'), ParentCategory__c = null, Status__c='Inactive');
        Category__c camarasyAccesorios      = new Category__c(Name = 'DUMMY_Cámaras y Accesorios',        ExternalId__c = 'DUMMY_CamarasyAccesorios',       Cluster__c = getId('DONTG'), ParentCategory__c = null, Status__c='Inactive');
        Category__c electronicaAudioyVideo  = new Category__c(Name = 'DUMMY_Electrónica, Audio y Video',  ExternalId__c = 'DUMMY_ElectronicaAudioyVideo',   Cluster__c = getId('DONTG'), ParentCategory__c = null, Status__c='Inactive');
        Category__c consolasyVideojuegos    = new Category__c(Name = 'DUMMY_Consolas y Videojuegos',      ExternalId__c = 'DUMMY_ConsolasyVideojuegos',     Cluster__c = getId('DONTG'), ParentCategory__c = null, Status__c='Inactive');
        Category__c computacion             = new Category__c(Name = 'DUMMY_Computación',                 ExternalId__c = 'DUMMY_Computacion',              Cluster__c = getId('DONTG'), ParentCategory__c = null, Status__c='Inactive');
        Category__c televisores             = new Category__c(Name = 'DUMMY_Televisores',                 ExternalId__c = 'DUMMY_Televisores',              Cluster__c = getId('DONTG'), ParentCategory__c = null, Status__c='Inactive');

        categoriesLevel1List.add(celularesyTelefonos);
        categoriesLevel1List.add(computacion);
        categoriesLevel1List.add(camarasyAccesorios);
        categoriesLevel1List.add(electronicaAudioyVideo);
        categoriesLevel1List.add(consolasyVideojuegos);
        categoriesLevel1List.add(televisores);
        
        List<Database.UpsertResult> categoriesL1Result = Database.upsert(categoriesLevel1List, Category__c.Fields.ExternalId__c, true);
        
        //Categories Nivel 2
        Category__c celularesySmartphones       = new Category__c(Name = 'DUMMY_Celulares y Smartphones',         ExternalId__c = 'DUMMY_CelularesySmartphones',        Cluster__c = getId('DONTG'), ParentCategory__c = celularesyTelefonos.Id, Status__c='Inactive');
        Category__c accesoriosparaCelulares     = new Category__c(Name = 'DUMMY_Accesorios para Celulares',       ExternalId__c = 'DUMMY_AccesoriosparaCelulares',      Cluster__c = getId('DONTG'), ParentCategory__c = celularesyTelefonos.Id, Status__c='Inactive');
        Category__c componentesdePC             = new Category__c(Name = 'DUMMY_Componentes de PC',               ExternalId__c = 'DUMMY_ComponentesdePC',              Cluster__c = getId('DONTG'), ParentCategory__c = computacion.Id, Status__c='Inactive');
        Category__c notebooksyAccesorios        = new Category__c(Name = 'DUMMY_Notebooks y Accesorios',          ExternalId__c = 'DUMMY_notebooksyAccesorios',         Cluster__c = getId('DONTG'), ParentCategory__c = computacion.Id, Status__c='Inactive');
        Category__c impresorasyAccesorios       = new Category__c(Name = 'DUMMY_Impresoras y Accesorios',         ExternalId__c = 'DUMMY_ImpresorasyAccesorios',        Cluster__c = getId('DONTG'), ParentCategory__c = computacion.Id, Status__c='Inactive');
        Category__c perifericosdePC             = new Category__c(Name = 'DUMMY_Periféricos de PC',               ExternalId__c = 'DUMMY_PeriféricosdePC',              Cluster__c = getId('DONTG'), ParentCategory__c = computacion.Id, Status__c='Inactive');
        Category__c camarasDigitales            = new Category__c(Name = 'DUMMY_Cámaras Digitales',               ExternalId__c = 'DUMMY_CámarasDigitales',             Cluster__c = getId('DONTG'), ParentCategory__c = camarasyAccesorios.Id, Status__c='Inactive');
        Category__c accesoriosparaCamaras       = new Category__c(Name = 'DUMMY_Accesorios para Cámaras',         ExternalId__c = 'DUMMY_AccesoriosparaCámaras',        Cluster__c = getId('DONTG'), ParentCategory__c = camarasyAccesorios.Id, Status__c='Inactive');
        Category__c audio                       = new Category__c(Name = 'DUMMY_Audio',                           ExternalId__c = 'DUMMY_Audio',                        Cluster__c = getId('DONTG'), ParentCategory__c = electronicaAudioyVideo.Id, Status__c='Inactive');
        Category__c accesoriosparaAudioyVideo   = new Category__c(Name = 'DUMMY_Accesorios para Audio y Video',   ExternalId__c = 'DUMMY_AccesoriosparaAudioyVideo',    Cluster__c = getId('DONTG'), ParentCategory__c = electronicaAudioyVideo.Id, Status__c='Inactive');
        Category__c componentesElectronicos     = new Category__c(Name = 'DUMMY_Componentes Electrónicos',        ExternalId__c = 'DUMMY_ComponentesElectrónicos',      Cluster__c = getId('DONTG'), ParentCategory__c = electronicaAudioyVideo.Id, Status__c='Inactive');
        Category__c seguridadyVigilanciaHogar   = new Category__c(Name = 'DUMMY_Seguridad y Vigilancia - Hogar',  ExternalId__c = 'DUMMY_SeguridadyVigilancia-Hogar',   Cluster__c = getId('DONTG'), ParentCategory__c = electronicaAudioyVideo.Id, Status__c='Inactive');
        Category__c videojuegos                 = new Category__c(Name = 'DUMMY_Videojuegos',                     ExternalId__c = 'DUMMY_Videojuegos',                  Cluster__c = getId('DONTG'), ParentCategory__c = consolasyVideojuegos.Id, Status__c='Inactive');
        Category__c playStation                 = new Category__c(Name = 'DUMMY_PlayStation',                     ExternalId__c = 'DUMMY_PlayStation',                  Cluster__c = getId('DONTG'), ParentCategory__c = consolasyVideojuegos.Id, Status__c='Inactive');
        Category__c tvLED                       = new Category__c(Name = 'DUMMY_TV LED',                          ExternalId__c = 'DUMMY_TVLED',                        Cluster__c = getId('DONTG'), ParentCategory__c = televisores.Id, Status__c='Inactive');
        Category__c tvLCD                       = new Category__c(Name = 'DUMMY_TV LCD',                          ExternalId__c = 'DUMMY_TVLCD',                        Cluster__c = getId('DONTG'), ParentCategory__c = televisores.Id, Status__c='Inactive');
        Category__c tvdeTubo                    = new Category__c(Name = 'DUMMY_TV de Tubo',                      ExternalId__c = 'DUMMY_TVdeTubo',                     Cluster__c = getId('DONTG'), ParentCategory__c = televisores.Id, Status__c='Inactive');
        Category__c tvPlasma                    = new Category__c(Name = 'DUMMY_TV Plasma',                       ExternalId__c = 'DUMMY_TVPlasma',                     Cluster__c = getId('DONTG'), ParentCategory__c = televisores.Id, Status__c='Inactive');
        
        categoriesLevel2List.add(celularesySmartphones);
        categoriesLevel2List.add(accesoriosparaCelulares);
        categoriesLevel2List.add(componentesdePC);
        categoriesLevel2List.add(notebooksyAccesorios);
        categoriesLevel2List.add(impresorasyAccesorios);
        categoriesLevel2List.add(perifericosdePC);
        categoriesLevel2List.add(camarasDigitales);
        categoriesLevel2List.add(accesoriosparaCamaras);
        categoriesLevel2List.add(componentesElectronicos);
        categoriesLevel2List.add(seguridadyVigilanciaHogar);
        categoriesLevel2List.add(videojuegos);
        categoriesLevel2List.add(playStation);
        categoriesLevel2List.add(tvLED);
        categoriesLevel2List.add(tvLCD);
        categoriesLevel2List.add(tvdeTubo);
        categoriesLevel2List.add(tvPlasma);
        
        List<Database.UpsertResult> categoriesL2Result = Database.upsert(categoriesLevel2List, Category__c.Fields.ExternalId__c, true);
        
        //Categories Nivel 3
        Category__c discosRigidosyRemovibles    = new Category__c(Name = 'DUMMY_Discos Rígidos y Removibles', ExternalId__c = 'DUMMY_DiscosRigidosyRemovibles', Cluster__c = getId('DONTG'), ParentCategory__c = componentesdePC.Id, Status__c='Inactive');
        Category__c motherboards                = new Category__c(Name = 'DUMMY_Motherboards',                ExternalId__c = 'DUMMY_Motherboards',             Cluster__c = getId('DONTG'), ParentCategory__c = componentesdePC.Id, Status__c='Inactive');
        Category__c placasdeVideo               = new Category__c(Name = 'DUMMY_Placas de Video',             ExternalId__c = 'DUMMY_placasdeVideo',            Cluster__c = getId('DONTG'), ParentCategory__c = componentesdePC.Id, Status__c='Inactive');

        categoriesLevel3List.add(discosRigidosyRemovibles);
        categoriesLevel3List.add(motherboards);
        categoriesLevel3List.add(placasdeVideo);
        
        List<Database.UpsertResult> categoriesL3Result = Database.upsert(categoriesLevel3List, Category__c.Fields.ExternalId__c, true);
        
        //Categories Nivel 4
        Category__c hdd         = new Category__c(Name = 'DUMMY_HDD',         ExternalId__c = 'DUMMY_HDD',      Cluster__c = getId('DONTG'),   ParentCategory__c = discosRigidosyRemovibles.Id, Status__c='Inactive');
        Category__c ssd         = new Category__c(Name = 'DUMMY_SSD',         ExternalId__c = 'DUMMY_SSD',      Cluster__c = getId('DONTG'),   ParentCategory__c = discosRigidosyRemovibles.Id, Status__c='Inactive');
        Category__c portatil    = new Category__c(Name = 'DUMMY_Portatil',    ExternalId__c = 'DUMMY_Portatil', Cluster__c = getId('DONTG'),   ParentCategory__c = discosRigidosyRemovibles.Id, Status__c='Inactive');

        categoriesLevel4List.add(hdd);
        categoriesLevel4List.add(ssd);
        categoriesLevel4List.add(portatil);
        
        List<Database.UpsertResult> categoriesL4Result = Database.upsert(categoriesLevel4List, Category__c.Fields.ExternalId__c, true);
        
        //Categories Nivel 5
        Category__c paraPc          = new Category__c(Name = 'DUMMY_Para Pc',         ExternalId__c = 'DUMMY_paraPc',       Cluster__c = getId('DONTG'),   ParentCategory__c = ssd.Id, Status__c='Inactive');
        Category__c paraNotebook    = new Category__c(Name = 'DUMMY_Para Notebook',   ExternalId__c = 'DUMMY_paraNotebook', Cluster__c = getId('DONTG'),   ParentCategory__c = ssd.Id, Status__c='Inactive');

        categoriesLevel5List.add(paraPc);
        categoriesLevel5List.add(paraNotebook);
        
        List<Database.UpsertResult> categoriesL5Result = Database.upsert(categoriesLevel5List, Category__c.Fields.ExternalId__c, true);
        
        addToMapRecords(categoriesLevel1List);
        addToMapRecords(categoriesLevel2List);
        addToMapRecords(categoriesLevel3List);
        addToMapRecords(categoriesLevel4List);
        addToMapRecords(categoriesLevel5List);
    }

    private static void upsertTags(){
        //Inserta 8 Tags

        List<Tag__c> tagsList = new List<Tag__c>();

        Tag__c home             = new Tag__c(Name = 'DUMMY_Home',                 ExternalId__c = 'DUMMY_home',             Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c anioNuevo        = new Tag__c(Name = 'DUMMY_Año nuevo',            ExternalId__c = 'DUMMY_anioNuevo',        Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c carnaval         = new Tag__c(Name = 'DUMMY_Carnaval',             ExternalId__c = 'DUMMY_carnaval',         Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c semanaSanta      = new Tag__c(Name = 'DUMMY_Semana santa',         ExternalId__c = 'DUMMY_semanaSanta',      Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c navidad          = new Tag__c(Name = 'DUMMY_Navidad',              ExternalId__c = 'DUMMY_navidad',          Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c diadelaMadre     = new Tag__c(Name = 'DUMMY_Dia de la madre',      ExternalId__c = 'DUMMY_diadelaMadre',     Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c diadelPadre      = new Tag__c(Name = 'DUMMY_Dia del padre',        ExternalId__c = 'DUMMY_diadelPadre',      Cluster__c = getId('DONTG'), Status__c='Inactive');
        Tag__c diadelNinio      = new Tag__c(Name = 'DUMMY_Dia del niño',         ExternalId__c = 'DUMMY_diadelNinio',      Cluster__c = getId('DONTG'), Status__c='Inactive');

        tagsList.add(home);
        tagsList.add(anioNuevo);
        tagsList.add(carnaval);
        tagsList.add(semanaSanta);
        tagsList.add(navidad);
        tagsList.add(diadelaMadre);
        tagsList.add(diadelPadre);
        tagsList.add(diadelNinio);
        
        List<Database.UpsertResult> result = Database.upsert(tagsList, Tag__c.Fields.ExternalId__c, true);
        
        addToMapRecords(tagsList);
    }

    private static void upsertMediaElements(){
        //Inserta 8 Media Elements

        List<MediaElement__c> mediaElementsList = new List<MediaElement__c>();

        MediaElement__c meLogoCG    = new MediaElement__c(Name = 'DUMMY_Logo CG',     Description__c = 'Logo CG',         DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meLogoCG',    FileNameDesktop__c = 'LogoCG',      FileURLDesktop__c = 'https://static.wixstatic.com/media/759493_a2635c736fe642698090fbaccd52cbf8~mv2.png/v1/fill/w_168,h_83,al_c,q_80,usm_0.66_1.00_0.01/759493_a2635c736fe642698090fbaccd52cbf8~mv2.webp', Status__c='Inactive');
        MediaElement__c meColina    = new MediaElement__c(Name = 'DUMMY_Colina',      Description__c = 'Colina CG',       DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meColina',    FileNameDesktop__c = 'Colina',      FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_4a38a079a0a0445a911f28a599ddc067~mv2_d_5184_3456_s_4_2.jpg/v1/fill/w_1899,h_904,al_c,q_85,usm_0.66_1.00_0.01/7d9c7e_4a38a079a0a0445a911f28a599ddc067~mv2_d_5184_3456_s_4_2.webp', Status__c='Inactive');
        MediaElement__c meUSA       = new MediaElement__c(Name = 'DUMMY_USA',         Description__c = 'USA CG',          DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meUSA',       FileNameDesktop__c = 'USA',         FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_d42e1cc0f89c4d8a99d31e0b3cd509c1~mv2_d_4397_3456_s_4_2.jpg/v1/fill/w_950,h_728,al_c,q_85,usm_0.66_1.00_0.01/7d9c7e_d42e1cc0f89c4d8a99d31e0b3cd509c1~mv2_d_4397_3456_s_4_2.webp', Status__c='Inactive');
        MediaElement__c meBSAS      = new MediaElement__c(Name = 'DUMMY_BSAS',        Description__c = 'BSAS CG',         DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meBSAS',      FileNameDesktop__c = 'BSAS',        FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_ad976b831f4c40a9b131950fd1766fe8~mv2_d_4272_2436_s_4_2.jpg/v1/fill/w_950,h_728,al_c,q_85,usm_0.66_1.00_0.01/7d9c7e_ad976b831f4c40a9b131950fd1766fe8~mv2_d_4272_2436_s_4_2.webp', Status__c='Inactive');
        MediaElement__c meEstatuas  = new MediaElement__c(Name = 'DUMMY_Estatuas',    Description__c = 'meEstatuas CG',   DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meEstatuas',  FileNameDesktop__c = 'meEstatuas',  FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.jpg/v1/fill/w_1184,h_564,al_c,q_85/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.webp', Status__c='Inactive');
        MediaElement__c meAbeja     = new MediaElement__c(Name = 'DUMMY_Abeja',       Description__c = 'meAbeja CG',      DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meAbeja',     FileNameDesktop__c = 'meAbeja',     FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_04b9707a3a2f4e08b48a58499f20c774~mv2.jpg/v1/fill/w_1250,h_595,al_c,q_85/7d9c7e_04b9707a3a2f4e08b48a58499f20c774~mv2.webp', Status__c='Inactive');
        MediaElement__c meVeleros   = new MediaElement__c(Name = 'DUMMY_Veleros',     Description__c = 'meVeleros CG',    DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meVeleros',   FileNameDesktop__c = 'meVeleros',   FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_96eab3aa358244db868d5971a30c57e4~mv2.jpg/v1/fill/w_1410,h_671,al_c,q_85/7d9c7e_96eab3aa358244db868d5971a30c57e4~mv2.webp', Status__c='Inactive');
        MediaElement__c meOtonio    = new MediaElement__c(Name = 'DUMMY_Otoño',       Description__c = 'meOtonio CG',     DesktopFileExtension__c = 'jpg', ExternalId__c = 'DUMMY_meOtonio',    FileNameDesktop__c = 'meOtonio',    FileURLDesktop__c = 'https://static.wixstatic.com/media/7d9c7e_2c56e79cf7974db59a8d5f78262925d3~mv2_d_5184_3456_s_4_2.jpg/v1/fill/w_1899,h_904,al_c,q_85,usm_0.66_1.00_0.01/7d9c7e_2c56e79cf7974db59a8d5f78262925d3~mv2_d_5184_3456_s_4_2.webp', Status__c='Inactive');

        mediaElementsList.add(meLogoCG);
        mediaElementsList.add(meColina);
        mediaElementsList.add(meUSA);
        mediaElementsList.add(meBSAS);
        mediaElementsList.add(meEstatuas);
        mediaElementsList.add(meAbeja);
        mediaElementsList.add(meVeleros);
        mediaElementsList.add(meOtonio);
        
        List<Database.UpsertResult> result = Database.upsert(mediaElementsList, MediaElement__c.Fields.ExternalId__c, true);
        
        addToMapRecords(mediaElementsList);
    }

    private static void upsertNavigations(){
        /* Inserta 17 Navigations - BEGIN */

        List<Navigation__c> navigationsList = new List<Navigation__c>();

        Navigation__c home          = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_home',           Name = 'DUMMY_Home',          Type__c = 'Internal', URL__c = '/', Status__c='Inactive');
        Navigation__c support       = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support',        Name = 'DUMMY_Support',       Type__c = 'Internal', URL__c = 'support', Status__c='Inactive');
        Navigation__c clients       = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_clients',        Name = 'DUMMY_Clients',       Type__c = 'Internal', URL__c = 'clients', Status__c='Inactive');
        Navigation__c catalog       = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_catalog',        Name = 'DUMMY_Catalog',       Type__c = 'Internal', URL__c = 'catalog', Status__c='Inactive');
        Navigation__c newsDetail    = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_newsDetail',     Name = 'DUMMY_News Detail',   Type__c = 'Internal', URL__c = 'newsdetails', Status__c='Inactive');
        Navigation__c eventDetail   = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_eventDetail',    Name = 'DUMMY_Event Detail',  Type__c = 'Internal', URL__c = 'eventdetails', Status__c='Inactive');
        Navigation__c support1      = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support1',       Name = 'DUMMY_Support 1',     Type__c = 'Internal', URL__c = 'support1', Status__c='Inactive');
        Navigation__c support2      = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support2',       Name = 'DUMMY_Support 2',     Type__c = 'Internal', URL__c = 'support2', Status__c='Inactive');
        Navigation__c clients1      = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_clients1',       Name = 'DUMMY_Clients 1',     Type__c = 'Internal', URL__c = 'clients1', Status__c='Inactive');
        Navigation__c clients2      = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_clients2',       Name = 'DUMMY_Clients 2',     Type__c = 'Internal', URL__c = 'clients2', Status__c='Inactive');
        Navigation__c catalog1      = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_catalog1',       Name = 'DUMMY_Catalog 1',     Type__c = 'Internal', URL__c = 'catalog1', Status__c='Inactive');
        Navigation__c catalog2      = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_catalog2',       Name = 'DUMMY_Catalog 2',     Type__c = 'Internal', URL__c = 'catalog2', Status__c='Inactive');
        Navigation__c support1_1    = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support1_1',     Name = 'DUMMY_Support 1_1',   Type__c = 'Internal', URL__c = 'support1-1', Status__c='Inactive');
        Navigation__c support2_1    = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support2_1',     Name = 'DUMMY_Support 2_1',   Type__c = 'Internal', URL__c = 'support2-1', Status__c='Inactive');
        Navigation__c support1_1_1  = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support1_1_1',   Name = 'DUMMY_Support 1_1_1', Type__c = 'Internal', URL__c = 'support1-1-1', Status__c='Inactive');
        Navigation__c support2_1_1  = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_support2_1_1',   Name = 'DUMMY_Support 2_1_1', Type__c = 'Internal', URL__c = 'support2-1-1', Status__c='Inactive');
        Navigation__c search  = new Navigation__c(Cluster__c = getId('DONTG'), ExternalId__c = 'DUMMY_Nav_search',         Name = 'DUMMY_Search',        Type__c = 'Internal', URL__c = 'search',  Status__c='Inactive');

        navigationsList.add(home);
        navigationsList.add(support);
        navigationsList.add(clients);
        navigationsList.add(catalog);
        navigationsList.add(newsDetail);
        navigationsList.add(eventDetail);
        navigationsList.add(support1);
        navigationsList.add(support2);
        navigationsList.add(clients1);
        navigationsList.add(clients2);
        navigationsList.add(catalog1);
        navigationsList.add(catalog2);
        navigationsList.add(support1_1);
        navigationsList.add(support2_1);
        navigationsList.add(support1_1_1);
        navigationsList.add(support2_1_1);
        navigationsList.add(search);
        
        List<Database.UpsertResult> result = Database.upsert(navigationsList, Navigation__c.Fields.ExternalId__c, true);
        
        addToMapRecords(navigationsList);
        /* Inserta 17 Navigations - END */
    }
    
    private static void upsertMenus() {
        
        /* Inserta 16 Menus - BEGIN */
        List<Menu__c> menusL1List = new List<Menu__c>();
        List<Menu__c> menusL2List = new List<Menu__c>();
        List<Menu__c> menusL3List = new List<Menu__c>();
        List<Menu__c> menusL4List = new List<Menu__c>();

        Menu__c home          = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-Menu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_home',           Name = 'DUMMY_Home',          MenuLabel__c = 'Home',     ParentMenu__c = null, Navigation__c = getId('DUMMY_Nav_home'), Status__c='Inactive');
        Menu__c support       = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-Menu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_support',        Name = 'DUMMY_Support',       MenuLabel__c = 'Support',  ParentMenu__c = null, Navigation__c = getId('DUMMY_Nav_support'), Status__c='Inactive');
        Menu__c clients       = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-Menu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_clients',        Name = 'DUMMY_Clients',       MenuLabel__c = 'Clients',  ParentMenu__c = null, Navigation__c = getId('DUMMY_Nav_clients'), Status__c='Inactive');
        Menu__c catalog       = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-Menu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_catalog',        Name = 'DUMMY_Catalog',       MenuLabel__c = 'Catalog',  ParentMenu__c = null, Navigation__c = getId('DUMMY_Nav_catalog'), Status__c='Inactive');
        
        menusL1List.add(home);
        menusL1List.add(support);
        menusL1List.add(clients);
        menusL1List.add(catalog);
        
        List<Database.UpsertResult> resultL1 = Database.upsert(menusL1List, Menu__c.Fields.ExternalId__c, true);
        
        Menu__c support1      = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_support1',       Name = 'DUMMY_Support 1',     MenuLabel__c = 'Support 1', ParentMenu__c = support.Id, Navigation__c = getId('DUMMY_Nav_support1'), Status__c='Inactive');
        Menu__c support2      = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_support2',       Name = 'DUMMY_Support 2',     MenuLabel__c = 'Support 2', ParentMenu__c = support.Id, Navigation__c = getId('DUMMY_Nav_support2'), Status__c='Inactive');
        Menu__c clients1      = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_clients1',       Name = 'DUMMY_Clients 1',     MenuLabel__c = 'Clients 1', ParentMenu__c = clients.Id, Navigation__c = getId('DUMMY_Nav_clients1'), Status__c='Inactive');
        Menu__c clients2      = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_clients2',       Name = 'DUMMY_Clients 2',     MenuLabel__c = 'Clients 2', ParentMenu__c = clients.Id, Navigation__c = getId('DUMMY_Nav_clients2'), Status__c='Inactive');
        Menu__c catalog1      = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_catalog1',       Name = 'DUMMY_Catalog 1',     MenuLabel__c = 'Catalog 1', ParentMenu__c = catalog.Id, Navigation__c = getId('DUMMY_Nav_catalog1'), Status__c='Inactive');
        Menu__c catalog2      = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'Same Tab', ExternalId__c = 'DUMMY_Menu_catalog2',       Name = 'DUMMY_Catalog 2',     MenuLabel__c = 'Catalog 2', ParentMenu__c = catalog.Id, Navigation__c = getId('DUMMY_Nav_catalog2'), Status__c='Inactive');
        
        menusL2List.add(support1);
        menusL2List.add(support2);
        menusL2List.add(clients1);
        menusL2List.add(clients2);
        menusL2List.add(catalog1);
        menusL2List.add(catalog2);
        
        List<Database.UpsertResult> resultL2 = Database.upsert(menusL2List, Menu__c.Fields.ExternalId__c, true);
        
        Menu__c support1_1    = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'New Tab', ExternalId__c = 'DUMMY_Menu_support1_1',     Name = 'DUMMY_Support 1_1',   MenuLabel__c = 'Support 1_1', ParentMenu__c = support1.Id, Navigation__c = getId('DUMMY_Nav_support1_1'), Status__c='Inactive');
        Menu__c support1_2    = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'New Tab', ExternalId__c = 'DUMMY_Menu_support1_2',     Name = 'DUMMY_Support 1_2',   MenuLabel__c = 'Support 1_2', ParentMenu__c = support1.Id, Navigation__c = getId('DUMMY_Nav_support1_1'), Status__c='Inactive');
        Menu__c support2_1    = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'New Tab', ExternalId__c = 'DUMMY_Menu_support2_1',     Name = 'DUMMY_Support 2_1',   MenuLabel__c = 'Support 2_1', ParentMenu__c = support2.Id, Navigation__c = getId('DUMMY_Nav_support2_1'), Status__c='Inactive');
        
        menusL3List.add(support1_1);
        menusL3List.add(support1_2);
        menusL3List.add(support2_1);
        
        List<Database.UpsertResult> resultL3 = Database.upsert(menusL3List, Menu__c.Fields.ExternalId__c, true);
        
        Menu__c support1_1_1  = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'New Tab', ExternalId__c = 'DUMMY_Menu_support1_1_1',   Name = 'DUMMY_Support 1_1_1', MenuLabel__c = 'Support 1_1_1', ParentMenu__c = support1_1.Id, Navigation__c = getId('DUMMY_Nav_support1_1_1'), Status__c='Inactive');
        Menu__c support1_1_2  = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'New Tab', ExternalId__c = 'DUMMY_Menu_support1_1_2',   Name = 'DUMMY_Support 1_1_2', MenuLabel__c = 'Support 1_1_2', ParentMenu__c = support1_1.Id, Navigation__c = getId('DUMMY_Nav_support1_1_1'), Status__c='Inactive');
        Menu__c support2_1_1  = new Menu__c(Cluster__c = getId('DONTG'), RecordTypeId = getRTId('Menu__c-SubMenu').Id, Behaviour__c = 'New Tab', ExternalId__c = 'DUMMY_Menu_support2_1_1',   Name = 'DUMMY_Support 2_1_1', MenuLabel__c = 'Support 2_1_1', ParentMenu__c = support2_1.Id, Navigation__c = getId('DUMMY_Nav_support2_1_1'), Status__c='Inactive');

        menusL4List.add(support1_1_1);
        menusL4List.add(support1_1_2);
        menusL4List.add(support2_1_1);
        
        List<Database.UpsertResult> resultL4 = Database.upsert(menusL4List, Menu__c.Fields.ExternalId__c, true);
        
        addToMapRecords(menusL1List);
        addToMapRecords(menusL2List);
        addToMapRecords(menusL3List);
        addToMapRecords(menusL4List);
        
        /* Inserta 16 Menus - END */
    }

    private static void upsertContents(){
        /* Inserta 16 Contents - BEGIN */
        
        List<Content__c> contentsList = new List<Content__c>();
        List<TagAssignment__c> tagAssignmentList = new List<TagAssignment__c>();
        List<MediaElementAssignment__c> mediaElementAssignmentList = new List<MediaElementAssignment__c>();
        

        Content__c banner1               = new Content__c(RecordTypeId = getRTId('Content__c-Banner').Id,            Name = 'DUMMY_Banner Home Estatuas',  ExternalId__c = 'DUMMY_cont_Estatuas',    Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_CelularesySmartphones'), OverlayQuadrant__c = 'Top-Left', Title__c = 'Lorem Ipsum Banner 1', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', ButtonLabel__c = 'GO', Status__c = 'Draft');
        Content__c banner2               = new Content__c(RecordTypeId = getRTId('Content__c-Banner').Id,            Name = 'DUMMY_Banner Home Colina',    ExternalId__c = 'DUMMY_cont_Colina',      Cluster__c = getId('On_Eu'),   Category__c = getId('DUMMY_AccesoriosparaCelulares'), OverlayQuadrant__c = 'Middle-Center', Title__c = 'Lorem Ipsum Banner 2', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', ButtonLabel__c = 'GO', Status__c='Draft');
        Content__c advanceContent        = new Content__c(RecordTypeId = getRTId('Content__c-AdvanceContent').Id,    Name = 'DUMMY_Advnce Content 1',      ExternalId__c = 'DUMMY_cont_AC1',         Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_ComponentesdePC'), HTMLContent__c = '<iframe width="560" height="315" src="https://www.youtube.com/embed/zeSxHleDbxA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><br/><br/><!-- Menú de navegación del sitio --><ul class="navbar">  <li><a href="indice.html">Página principal</a>  <li><a href="meditaciones.html">Meditaciones</a>  <li><a href="ciudad.html">Mi ciudad</a>  <li><a href="enlaces.html">Enlaces</a></ul><br/><!-- Contenido principal --><h1>BIENVENIDO [!user.name] (Tu jefe es: [!user.manager.name]): Mi primera página con estilo</h1><p>¡Bienvenido a mi primera página con estilo!<p>No tiene imágenes, pero tiene estilo.También tiene enlaces, aunque no te lleven aningún sitio…<p>Debería haber más cosas aquí, pero todavía no séqué poner.<br/><br/><!-- Firma y fecha de la página, ¡sólo por cortesía! --><address>Creada el 5 de abril de 2004<br>  por mí mismo.</address>', Status__c = 'Draft');
        Content__c event1                = new Content__c(RecordTypeId = getRTId('Content__c-Event').Id,             Name = 'DUMMY_Event 1',               ExternalId__c = 'DUMMY_cont_Event1',      Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_notebooksyAccesorios'), Title__c = 'Lorem Ipsum Event 1', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c='Draft');
        Content__c event2                = new Content__c(RecordTypeId = getRTId('Content__c-Event').Id,             Name = 'DUMMY_Event 2',               ExternalId__c = 'DUMMY_cont_Event2',      Cluster__c = getId('On_Am'),  Category__c = getId('DUMMY_ImpresorasyAccesorios'), Title__c = 'Lorem Ipsum Event 2', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c='Draft');
        Content__c news1                 = new Content__c(RecordTypeId = getRTId('Content__c-Article').Id,           Name = 'DUMMY_News 1',                ExternalId__c = 'DUMMY_cont_News1',       Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_PeriféricosdePC'), Title__c = 'Lorem Ipsum News 1', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c = 'Draft');
        Content__c news2                 = new Content__c(RecordTypeId = getRTId('Content__c-Article').Id,           Name = 'DUMMY_News 1',                ExternalId__c = 'DUMMY_cont_News2',       Cluster__c = getId('On_Eu'),   Category__c = getId('DUMMY_ImpresorasyAccesorios'), Title__c = 'Lorem Ipsum News 2', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',  Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c = 'Draft');
        Content__c faq1                  = new Content__c(RecordTypeId = getRTId('Content__c-FAQ').Id,               Name = 'DUMMY_FAQ 1',                 ExternalId__c = 'DUMMY_cont_FAQ1',        Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_CelularesyTelefonos'), Title__c = 'What is Lorem Ipsum?', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Status__c = 'Draft');
        Content__c faq2                  = new Content__c(RecordTypeId = getRTId('Content__c-FAQ').Id,               Name = 'DUMMY_FAQ 1',                 ExternalId__c = 'DUMMY_cont_FAQ2',        Cluster__c = getId('On_Am'),  Category__c = null, Title__c = 'Why do we use it?', Extract__c = 'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.', Status__c = 'Draft');
 
        //templates
        Content__c advanceContTemplate   = new Content__c(RecordTypeId = getRTId('Content__c-AdvanceContent').Id,    Name = 'DUMMY_Advnce Content 1 Template',      ExternalId__c = 'DUMMY_cont_AC1Template',         Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_ComponentesdePC'), HTMLContent__c = '<iframe width="560" height="315" src="https://www.youtube.com/embed/zeSxHleDbxA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><br/><br/><!-- Menú de navegación del sitio --><ul class="navbar">  <li><a href="indice.html">Página principal</a>  <li><a href="meditaciones.html">Meditaciones</a>  <li><a href="ciudad.html">Mi ciudad</a>  <li><a href="enlaces.html">Enlaces</a></ul><br/><!-- Contenido principal --><h1>BIENVENIDO [!user.name] (Tu jefe es: [!user.manager.name]): Mi primera página con estilo</h1><p>¡Bienvenido a mi primera página con estilo!<p>No tiene imágenes, pero tiene estilo.También tiene enlaces, aunque no te lleven aningún sitio…<p>Debería haber más cosas aquí, pero todavía no séqué poner.<br/><br/><!-- Firma y fecha de la página, ¡sólo por cortesía! --><address>Creada el 5 de abril de 2004<br>  por mí mismo.</address>', Status__c='Draft', IsTemplate__c = true, TemplateDescription__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.');
        Content__c event1Template        = new Content__c(RecordTypeId = getRTId('Content__c-Event').Id,             Name = 'DUMMY_Event 1 Template',               ExternalId__c = 'DUMMY_cont_Event1Template',      Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_notebooksyAccesorios'), Title__c = 'Lorem Ipsum Event 1', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c = 'Draft', IsTemplate__c = true, TemplateDescription__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.');
        Content__c event2Template        = new Content__c(RecordTypeId = getRTId('Content__c-Event').Id,             Name = 'DUMMY_Event 2 Template',               ExternalId__c = 'DUMMY_cont_Event2Template',      Cluster__c = getId('On_Am'),  Category__c = getId('DUMMY_ImpresorasyAccesorios'), Title__c = 'Lorem Ipsum Event 2', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c = 'Draft', IsTemplate__c = true, TemplateDescription__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.');
        Content__c news1Template         = new Content__c(RecordTypeId = getRTId('Content__c-Article').Id,              Name = 'DUMMY_News 1 Template',                ExternalId__c = 'DUMMY_cont_News1Template',       Cluster__c = getId('DONTG'),   Category__c = getId('DUMMY_PeriféricosdePC'), Title__c = 'Lorem Ipsum News 1', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c = 'Draft', IsTemplate__c = true, TemplateDescription__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.');
        Content__c news2Template         = new Content__c(RecordTypeId = getRTId('Content__c-Article').Id,              Name = 'DUMMY_News 1 Template',                ExternalId__c = 'DUMMY_cont_News2Template',       Cluster__c = getId('On_Eu'),   Category__c = getId('DUMMY_ImpresorasyAccesorios'), Title__c = 'Lorem Ipsum News 2', Extract__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',  Body__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.', Status__c = 'Draft', IsTemplate__c = true, TemplateDescription__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.');

        
        contentsList.add(banner1);
        contentsList.add(banner2);
        contentsList.add(advanceContent);
        contentsList.add(event1);
        contentsList.add(event2);
        contentsList.add(news1);
        contentsList.add(news2);
        contentsList.add(faq1);
        contentsList.add(faq2);
        contentsList.add(advanceContTemplate);
        contentsList.add(event1Template);
        contentsList.add(event2Template);
        contentsList.add(news1Template);
        contentsList.add(news2Template);
        
        List<Database.UpsertResult> result = Database.upsert(contentsList, Content__c.Fields.ExternalId__c, true);
        
        addToMapRecords(contentsList);
        
        /* Inserta 16 Contents - END */
        
        /* Inserta 24 MediaElementAssignment - BEGIN */
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = banner1.Id, MediaElement__c = getId('DUMMY_meUSA'), ExternalId__c = 'DUMMY_Banner_meUSA_MeAs', Placement__c = 'BannerImage'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = banner1.Id, MediaElement__c = getId('DUMMY_meBSAS'), ExternalId__c = 'DUMMY_Banner_meBSAS_MeAs', Placement__c = 'BannerImage'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = banner2.Id, MediaElement__c = getId('DUMMY_meColina'), ExternalId__c = 'DUMMY_Banner2_meColina_MeAs', Placement__c = 'BannerImage'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = banner2.Id, MediaElement__c = getId('DUMMY_meEstatuas'), ExternalId__c = 'DUMMY_Banner2_meEstatuas_MeAs', Placement__c = 'BannerImage'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news1.Id, MediaElement__c = getId('DUMMY_meEstatuas'), ExternalId__c = 'DUMMY_News_meEstatuasList_MeAs', Placement__c = 'NewsImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news1.Id, MediaElement__c = getId('DUMMY_meEstatuas'), ExternalId__c = 'DUMMY_News_meEstatuasDet_MeAs', Placement__c = 'NewsImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news2.Id, MediaElement__c = getId('DUMMY_meAbeja'), ExternalId__c = 'DUMMY_News2_meAbejaList_MeAs', Placement__c = 'NewsImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news2.Id, MediaElement__c = getId('DUMMY_meAbeja'), ExternalId__c = 'DUMMY_News2_meAbejaDet_MeAs', Placement__c = 'NewsImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event1.Id, MediaElement__c = getId('DUMMY_meVeleros'), ExternalId__c = 'DUMMY_Event_meVelerosList_MeAs', Placement__c = 'EventImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event1.Id, MediaElement__c = getId('DUMMY_meVeleros'), ExternalId__c = 'DUMMY_Event_meVelerosDet_MeAs', Placement__c = 'EventImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event2.Id, MediaElement__c = getId('DUMMY_meOtonio'), ExternalId__c = 'DUMMY_Event2_meOtonioList_MeAs', Placement__c = 'EventImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event2.Id, MediaElement__c = getId('DUMMY_meOtonio'), ExternalId__c = 'DUMMY_Event2_meOtonioDet_MeAs', Placement__c = 'EventImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news1Template.Id, MediaElement__c = getId('DUMMY_meEstatuas'), ExternalId__c = 'DUMMY_News_meEstatuasList_MeAsTemplate', Placement__c = 'NewsImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news1Template.Id, MediaElement__c = getId('DUMMY_meEstatuas'), ExternalId__c = 'DUMMY_News_meEstatuasDet_MeAsTemplate', Placement__c = 'NewsImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news2Template.Id, MediaElement__c = getId('DUMMY_meAbeja'), ExternalId__c = 'DUMMY_News2_meAbejaList_MeAsTemplate', Placement__c = 'NewsImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = news2Template.Id, MediaElement__c = getId('DUMMY_meAbeja'), ExternalId__c = 'DUMMY_News2_meAbejaDet_MeAsTemplate', Placement__c = 'NewsImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event1Template.Id, MediaElement__c = getId('DUMMY_meVeleros'), ExternalId__c = 'DUMMY_Event_meVelerosList_MeAsTemplate', Placement__c = 'EventImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event1Template.Id, MediaElement__c = getId('DUMMY_meVeleros'), ExternalId__c = 'DUMMY_Event_meVelerosDet_MeAsTemplate', Placement__c = 'EventImageDetail'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event2Template.Id, MediaElement__c = getId('DUMMY_meOtonio'), ExternalId__c = 'DUMMY_Event2_meOtonioList_MeAsTemplate', Placement__c = 'EventImageList'));
        mediaElementAssignmentList.add(new MediaElementAssignment__c(Content__c = event2Template.Id, MediaElement__c = getId('DUMMY_meOtonio'), ExternalId__c = 'DUMMY_Event2_meOtonioDet_MeAsTemplate', Placement__c = 'EventImageDetail'));
        
        result = Database.upsert(mediaElementAssignmentList, MediaElementAssignment__c.Fields.ExternalId__c, true);
        /* Inserta 24 MediaElementAssignment - END */
        
        /* Inserta 3 TagAssignment - BEGIN */
        tagAssignmentList.add(new TagAssignment__c(Tag__c = getId('DUMMY_home'), Content__c = banner1.Id, ExternalId__c = 'DUMMY_home_Banner1_TagAs'));
        
        result = Database.upsert(tagAssignmentList, TagAssignment__c.Fields.ExternalId__c, true);
        /* Inserta 3 TagAssignment - END */
    }

    private static void upsertComponents(){
        /* Inserta 11 Components - BEGIN */
        
        List<Component__c> componentsList = new List<Component__c>();
        List<CategoryAssignment__c> categoryAssignmentList = new List<CategoryAssignment__c>();
        List<ContentAssignment__c> contentAssignmentList = new List<ContentAssignment__c>();
        List<TagAssignment__c> tagAssignmentList = new List<TagAssignment__c>();
        
        Component__c comp_Banner            = new Component__c(RecordTypeId = getRTId('Component__c-Banner').Id,            Name = 'DUMMY_Banner',            ExternalId__c = 'DUMMY_CBanner',           Cluster__c = getId('DONTG'), Datasource__c = 'Tags', HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC', AutomaticTransition__c = true, Orientation__c = 'Horizontal-Landscape', BannerTransitionTime__c = 2.000, BannerType__c = 'Carousel', Loop__c = false, BannerFrameType__c = 'Hero', ShowBullets__c = true, Direction__c = 'Right', LinkDetail__c = null , Status__c='Inactive');
        Component__c comp_Event             = new Component__c(RecordTypeId = getRTId('Component__c-EventList').Id,             Name = 'DUMMY_Event',             ExternalId__c = 'DUMMY_CEvent',            Cluster__c = getId('DONTG'), Datasource__c = 'All Events',        HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC', ExcludePastEvents__c  = false, EventsType__c = 'Landscape', PageSize__c = 3, PagingType__c = 'Carousel', LinkDetail__c  = getId('DUMMY_Nav_eventDetail') , Status__c='Inactive');
        Component__c comp_EventDetail       = new Component__c(RecordTypeId = getRTId('Component__c-EventDetail').Id,       Name = 'DUMMY_Event Detail',      ExternalId__c = 'DUMMY_CEventDetail',      Cluster__c = getId('DONTG'), Status__c='Inactive');
        Component__c comp_RelatedEvent      = new Component__c(RecordTypeId = getRTId('Component__c-EventsRelated').Id,     Name = 'DUMMY_Related Event',     ExternalId__c = 'DUMMY_CRelatedEvent',     Cluster__c = getId('DONTG'), Datasource__c = 'ParentComponentBehaviour', HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC', ExcludePastEvents__c  = false, EventsType__c = 'Landscape', PageSize__c = 3, PagingType__c = 'Carousel', LinkDetail__c  = getId('DUMMY_Nav_eventDetail'), Status__c='Inactive' );
        Component__c comp_News              = new Component__c(RecordTypeId = getRTId('Component__c-ArticleList').Id,              Name = 'DUMMY_News',              ExternalId__c = 'DUMMY_CNews',             Cluster__c = getId('DONTG'), Datasource__c = 'ManualAssignment', HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC', ArticleType__c = 'Landscape', PageSize__c = 3, PagingType__c = 'Carousel', LinkDetail__c  = getId('DUMMY_Nav_newsDetail'), Status__c='Inactive');
        Component__c comp_NewsDetail        = new Component__c(RecordTypeId = getRTId('Component__c-ArticleDetail').Id,        Name = 'DUMMY_News Detail',       ExternalId__c = 'DUMMY_CNewsDetail',       Cluster__c = getId('DONTG'),  Status__c='Inactive');
        Component__c comp_RelatedNews       = new Component__c(RecordTypeId = getRTId('Component__c-ArticlesRelated').Id,       Name = 'DUMMY_Related News',      ExternalId__c = 'DUMMY_CRelatedNews',      Cluster__c = getId('DONTG'), Datasource__c = 'ParentComponentBehaviour', HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC', ArticleType__c = 'Landscape', PageSize__c = 3, PagingType__c = 'Carousel', LinkDetail__c  = getId('DUMMY_Nav_newsDetail') , Status__c='Inactive');
        Component__c comp_AdvanceContent    = new Component__c(RecordTypeId = getRTId('Component__c-AdvanceContent').Id,    Name = 'DUMMY_Advance Content',   ExternalId__c = 'DUMMY_CAdvanceContent',   Cluster__c = getId('DONTG'), Datasource__c = 'ManualAssignment', HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC' , Status__c='Inactive');
        Component__c comp_FAQ               = new Component__c(RecordTypeId = getRTId('Component__c-FAQ').Id,               Name = 'DUMMY_FAQ',               ExternalId__c = 'DUMMY_CFAQ',              Cluster__c = getId('DONTG'), Datasource__c = 'Categories', HierarchicalOrderBy__c = '', OrderBy__c = 'Name DESC' , Status__c='Inactive');
        Component__c comp_ClusterSelector   = new Component__c(RecordTypeId = getRTId('Component__c-ClusterSelector').Id,  Name = 'DUMMY_Cluster Selector',  ExternalId__c = 'DUMMY_CClusterSelector',  Cluster__c = getId('DONTG'), FirstCluster__c = getId('DONTG') , Status__c='Inactive');
        Component__c comp_Menu              = new Component__c(RecordTypeId = getRTId('Component__c-Menu').Id,              Name = 'DUMMY_Menu',              ExternalId__c = 'DUMMY_CMenu',             Cluster__c = getId('DONTG'), NavigationMode__c = 'Horizontal-Simple', HasDelay__c = true, DelayTime__c = 500 , Status__c='Inactive');
        Component__c comp_Search            = new Component__c(RecordTypeId = getRTId('Component__c-Search').Id,            Name = 'DUMMY_Search',            ExternalId__c = 'DUMMY_CSearch',           Cluster__c = getId('DONTG'), SearchPlaceholder__c = 'GlobalSearchPlaceholder', PredictiveSearchEnabled__c = true, Status__c='Inactive');
        Component__c comp_LanguageSelector  = new Component__c(RecordTypeId = getRTId('Component__c-LanguageSelector').Id, Name = 'DUMMY_Language Selector', ExternalId__c = 'DUMMY_CLanguageSelector', Cluster__c = getId('DONTG'), FirstCluster__c = getId('DONTG'), Status__c='Inactive' );

        componentsList.add(comp_Banner);
        componentsList.add(comp_Event);
        componentsList.add(comp_EventDetail);
        componentsList.add(comp_RelatedEvent);
        componentsList.add(comp_News);
        componentsList.add(comp_NewsDetail);
        componentsList.add(comp_RelatedNews);
        componentsList.add(comp_AdvanceContent);
        componentsList.add(comp_FAQ);
        componentsList.add(comp_ClusterSelector);
        componentsList.add(comp_Menu);
        componentsList.add(comp_LanguageSelector);
        componentsList.add(comp_Search);
        
        List<Database.UpsertResult> result = Database.upsert(componentsList, Component__c.Fields.ExternalId__c, true);
        
        addToMapRecords(componentsList);
    /* Inserta 11 Components - END */
        
        /* Inserta 1 CategoryAssignment - BEGIN */
        categoryAssignmentList.add(new CategoryAssignment__c(Category__c = getId('DUMMY_CelularesyTelefonos'), Component__c = comp_FAQ.Id, ExternalId__c = 'DUMMY_CelularesyTelefonos_CatAs'));
        
        result = Database.upsert(categoryAssignmentList, CategoryAssignment__c.Fields.ExternalId__c, true);
        addToMapRecords(categoryAssignmentList);
        /* Inserta 1 CategoryAssignment - END */
        
        
        /* Inserta 1 TagAssignment - BEGIN */
        tagAssignmentList.add(new TagAssignment__c(Tag__c = getId('DUMMY_home'), Component__c = comp_Banner.Id, ExternalId__c = 'DUMMY_home_TagAs'));
        
        result = Database.upsert(tagAssignmentList, TagAssignment__c.Fields.ExternalId__c, true);
        addToMapRecords(tagAssignmentList);
        /* Inserta 1 TagAssignment - END */
        
        
        /* Inserta 2 ContentAssignment - BEGIN */
        contentAssignmentList.add(new ContentAssignment__c(Content__c = getId('DUMMY_cont_AC1'), Component__c = comp_AdvanceContent.Id, ExternalId__c = 'DUMMY_cont_AC1_ContAs'));
        contentAssignmentList.add(new ContentAssignment__c(Content__c = getId('DUMMY_cont_News1'), Component__c = getId('DUMMY_CNews'), ExternalId__c = 'DUMMY_CNews_ContAs'));
        
        result = Database.upsert(contentAssignmentList, ContentAssignment__c.Fields.ExternalId__c, true);
        addToMapRecords(contentAssignmentList);
        /* Inserta 2 ContentAssignment - END */
        
    }

    private static void upsertSearchDetails(){
        List<SearchSetting__c> dsList = new List<SearchSetting__c>();
        
        /* Inserta 3 SearchDetail - BEGIN */
        dsList.add(new SearchSetting__c(
                                                            Name                                = 'Banner',
                                                            ExternalId__c                       = 'Dummy_SearchBanner',
                                                            Component__c                        = getId('DUMMY_CSearch'),
                                                            Cluster__c                          = getId('DONTG'),
                                                            Navigation__c                       = null,//DUMMY_Nav_newsDetail
                                                            ObjectAPIName__c                    = 'Content__c',
                                                            FieldsToSearch__c                   = 'Name',
                                                            FieldsToShow__c                     = 'Name,Description__c',
                                                            RecordTypeDevName__c                = 'Banner',
                                                            Filter__c                           = null,
                                                            IconName__c                         = 'standard:customer_portal_users',
                                                            PredictiveSearchRecordsNumber__c    = 3,
                                                            URLParameterField__c                = 'Id',
                                                            URLParameterName__c                 = 'Id',
                                                            Active__c                           = true));

        dsList.add(new SearchSetting__c(
                                                            Name                                = 'Event',
                                                            ExternalId__c                       = 'Dummy_SearchEvent',
                                                            Component__c                        = getId('DUMMY_CSearch'),
                                                            Cluster__c                          = getId('DONTG'),
                                                            Navigation__c                       = null,//DUMMY_Nav_newsDetail
                                                            ObjectAPIName__c                    = 'Content__c',
                                                            FieldsToSearch__c                   = 'Name',
                                                            FieldsToShow__c                     = 'Name,Description__c,Status__c',
                                                            RecordTypeDevName__c                = 'Event',
                                                            Filter__c                           = null,
                                                            IconName__c                         = 'standard:event',
                                                            PredictiveSearchRecordsNumber__c    = 3,
                                                            URLParameterField__c                = 'Id',
                                                            URLParameterName__c                 = 'Id',
                                                            Active__c                           = true));

        dsList.add(new SearchSetting__c(
                                                            Name                                = 'News',
                                                            ExternalId__c                       = 'Dummy_SearchNews',
                                                            Component__c                        = getId('DUMMY_CSearch'),
                                                            Cluster__c                          = getId('DONTG'),
                                                            Navigation__c                       = null,//DUMMY_Nav_newsDetail
                                                            ObjectAPIName__c                    = 'Content__c',
                                                            FieldsToSearch__c                   = 'Name',
                                                            FieldsToShow__c                     = 'Name,Description__c,Status__c',
                                                            RecordTypeDevName__c                = 'Article',
                                                            Filter__c                           = null,
                                                            IconName__c                         = 'standard:customer_portal_users',
                                                            PredictiveSearchRecordsNumber__c    = 3,
                                                            URLParameterField__c                = 'Id',
                                                            URLParameterName__c                 = 'Id',
                                                            Active__c                           = true));
        
        List<Database.UpsertResult> results = Database.upsert(dsList, SearchSetting__c.Fields.ExternalId__c, true);
         
        addToMapRecords(dsList);
        /* Inserta 3 SearchDetail - END */
    }

   /* private static void upsertBrands() {
        List<Brand__c> brandList = new List<Brand__c>();
        
        Brand__c Brand1 = new Brand__c(Name='Brand 1', ExternalId__c='DUMMY_Brand1', BrandContent__c = getId('DUMMY_cont_Estatuas'), Cluster__c = getId('DONTG'), Status__c = 'Inactive');
        Brand__c Brand2 = new Brand__c(Name='Brand 2', ExternalId__c = 'DUMMY_Brand2', BrandContent__c = getId('DUMMY_cont_Colina'), Cluster__c = getId('On_Am'), RecordTypeId = getRTId('Brand__c-Brand').Id, Status__c='Inactive');
        Brand__c Brand3 = new Brand__c(Name='Brand 3', ExternalId__c = 'DUMMY_Brand3', BrandContent__c = getId('DUMMY_cont_AC1'), Cluster__c = getId('On_Eu'), RecordTypeId = getRTId('Brand__c-BrandVariant').Id, Status__c='Inactive');
        
        brandList.add(Brand1);
        brandList.add(Brand2);
        brandList.add(Brand3);
                
        List<Database.UpsertResult> result = Database.upsert(brandList, Brand__c.Fields.ExternalId__c, true);
        
        addToMapRecords(brandList);
    }*/
        
/*    private static void upsertContentCartItems(){
        List<ContentCartItem__c> contentCartList = new List<ContentCartItem__c>();


        ContentCartItem__c ContentCartItem1 =  new ContentCartItem__c(Name='ContentCartItem1', Content__c = getId('DUMMY_cont_FAQ1'), ExternalId__c = 'DUMMY_ContentCartItem1', User__c = UserInfo.getUserId());
        ContentCartItem__c ContentCartItem2 =  new ContentCartItem__c(Name='ContentCartItem2', Content__c = getId('DUMMY_cont_FAQ2'), ExternalId__c = 'DUMMY_ContentCartItem2', User__c = UserInfo.getUserId());
        ContentCartItem__c ContentCartItem3 =  new ContentCartItem__c(Name='ContentCartItem3', Content__c = getId('DUMMY_cont_News2'), ExternalId__c = 'DUMMY_ContentCartItem3', User__c = UserInfo.getUserId());
            
        
        
        contentCartList.add(ContentCartItem1);
        contentCartList.add(ContentCartItem2);
        contentCartList.add(ContentCartItem3);
        
        List<Database.UpsertResult> result = Database.upsert(contentCartList, ContentCartItem__c.Fields.ExternalId__c, true);
        
        addToMapRecords(contentCartList);
         Inserta 3 ContentCartItems - END 
    }*/
    
    private static void upsertTranslation(){
        /* Inserta 3 Translation - BEGIN */
        List<Translation__c> translationList= new List<Translation__c>();
        Translation__c Translation1 =  new Translation__c(Name = 'Translation1', Content__c = getId('DUMMY_cont_FAQ1'),  FieldApiName__c = 'Name',FieldType__c = 'Text', LanguageCode__c = 'it', ExternalId__c='DUMMY_Translation1');
        Translation__c Translation2 =  new Translation__c(Name = 'Translation2', Content__c = getId('DUMMY_cont_FAQ2'),  FieldApiName__c = 'Name',FieldType__c = 'Text', LanguageCode__c = 'it', ExternalId__c='DUMMY_Translation2');
        Translation__c Translation3 =  new Translation__c(Name = 'Translation3', Content__c = getId('DUMMY_cont_News2'),  FieldApiName__c = 'Name',FieldType__c = 'Text', LanguageCode__c = 'it', ExternalId__c='DUMMY_Translation3');
        translationList.add(Translation1);
        translationList.add(Translation2);
        translationList.add(Translation3);
        
        List<Database.UpsertResult> result = Database.upsert(translationList, Translation__c.Fields.ExternalId__c, true);
        
        addToMapRecords(translationList);
        /* Inserta 3 Translation - END */
    }
    
    private static void upsertMenuAssigment(){
        /* Inserta 3 MenuAssignment - BEGIN */
        List<MenuAssignment__c> menuAssignmentList = new List<MenuAssignment__c>();
        
        MenuAssignment__c MenuAssignment1 =  new MenuAssignment__c(Name = 'DUMMY_MenuAssignment1', Menu__c = getId('DUMMY_Menu_home'), ExternalId__c='DUMMY_ExMenuAssignment1', Component__c = getId('DUMMY_CBanner'));
        MenuAssignment__c MenuAssignment2 =  new MenuAssignment__c(Name = 'DUMMY_MenuAssignment2', Menu__c = getId('DUMMY_Menu_support'), ExternalId__c='DUMMY_ExMenuAssignment2', Component__c = getId('DUMMY_CEvent'));
        MenuAssignment__c MenuAssignment3 =  new MenuAssignment__c(Name = 'DUMMY_MenuAssignment3', Menu__c = getId('DUMMY_Menu_clients'), ExternalId__c='DUMMY_ExMenuAssignment3', Component__c = getId('DUMMY_CEventDetail'));
        
        
        menuAssignmentList.add(MenuAssignment1);
        menuAssignmentList.add(MenuAssignment2);
        menuAssignmentList.add(MenuAssignment3);
        
        List<Database.UpsertResult> result = Database.upsert(menuAssignmentList, MenuAssignment__c.Fields.ExternalId__c, true);
        
        addToMapRecords(menuAssignmentList);
        /* Inserta 3 MenuAssignment - END */
    }
    
    /*private static void upsertRecipe(){ 
         Inserta 2 Recipe__c - BEGIN 
        List<Recipe__c> recipeList = new List<Recipe__c>();
        
        Recipe__c recipe1 =  new Recipe__c(Name = 'DUMMY_Recipe1', ExternalId__c='DUMMY_Ex_Recipe1', Content__c = getId('DUMMY_cont_Recipe'), Cluster__c = getId('DONTG'), Status__c='Inactive');
        Recipe__c recipe2 =  new Recipe__c(Name = 'DUMMY_Recipe2', ExternalId__c='DUMMY_Ex_Recipe2', Content__c = getId('DUMMY_cont_Recipe_2'), Cluster__c = getId('On_Am'), Status__c='Inactive');
        
        recipeList.add(recipe1);
        recipeList.add(recipe2);
        
        List<Database.UpsertResult> result = Database.upsert(recipeList, Recipe__c.Fields.ExternalId__c, true);
        
        addToMapRecords(recipeList);

    }*/
    
    /*private static void upsertRecipeStep(){
         
        List<RecipeStep__c> recipeStepList = new List<RecipeStep__c>();
        
        RecipeStep__c recipeStep1 =  new RecipeStep__c(Name = 'DUMMY_RecipeStep1', ExternalId__c='DUMMY_Ex_RecipeStep1', Order__c =1, Step__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Recipe__c = getId('DUMMY_Ex_Recipe1'));
        RecipeStep__c recipeStep2 =  new RecipeStep__c(Name = 'DUMMY_RecipeStep2', ExternalId__c='DUMMY_Ex_RecipeStep2', Order__c =1, Step__c = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry', Recipe__c = getId('DUMMY_Ex_Recipe2'));
        
        recipeStepList.add(recipeStep1);
        recipeStepList.add(recipeStep2);
        
        List<Database.UpsertResult> result = Database.upsert(recipeStepList, RecipeStep__c.Fields.ExternalId__c, true);
        
        addToMapRecords(recipeStepList);
 
    }*/
    
    /*private static void upsertRecipeIngredient(){
         Inserta 4 RecipeIngredient__c - BEGIN 
        List<RecipeIngredient__c> recipeIngList = new List<RecipeIngredient__c>();
        
        RecipeIngredient__c recipeIng1 =  new RecipeIngredient__c(Name = 'DUMMY_RecipeIngredient1', ExternalId__c='DUMMY_Ex_RecipeIngredient1', Order__c =1, RecordTypeId = getRTId('RecipeIngredient__c-BrandIngredient').Id , Recipe__c = getId('DUMMY_Ex_Recipe1'), Brand__c = getId('DUMMY_Brand2'), BrandVariant__c =  getId('DUMMY_Brand3'));
        RecipeIngredient__c recipeIng2 =  new RecipeIngredient__c(Name = 'DUMMY_RecipeIngredient2', ExternalId__c='DUMMY_Ex_RecipeIngredient2', Order__c =1, RecordTypeId = getRTId('RecipeIngredient__c-BrandIngredient').Id , Recipe__c = getId('DUMMY_Ex_Recipe2'), Brand__c = getId('DUMMY_Brand2'), BrandVariant__c =  getId('DUMMY_Brand3'));           
        
        RecipeIngredient__c recipeIng3 =  new RecipeIngredient__c(Name = 'DUMMY_RecipeIngredient3', ExternalId__c='DUMMY_Ex_RecipeIngredient3', Order__c =2, RecordTypeId = getRTId('RecipeIngredient__c-CustomIngredient').Id , Recipe__c = getId('DUMMY_Ex_Recipe1'), OtherIngredient__c = 'DUMMY_INGREDIENT_1');
        RecipeIngredient__c recipeIng4 =  new RecipeIngredient__c(Name = 'DUMMY_RecipeIngredient4', ExternalId__c='DUMMY_Ex_RecipeIngredient4', Order__c =2, RecordTypeId = getRTId('RecipeIngredient__c-CustomIngredient').Id , Recipe__c = getId('DUMMY_Ex_Recipe2'), OtherIngredient__c = 'DUMMY_INGREDIENT_1');   
        
        recipeIngList.add(recipeIng1);
        recipeIngList.add(recipeIng2);
        recipeIngList.add(recipeIng3);
        recipeIngList.add(recipeIng4);
        
        List<Database.UpsertResult> result = Database.upsert(recipeIngList, RecipeIngredient__c.Fields.ExternalId__c, true);
        
        addToMapRecords(recipeIngList);
        /* Inserta 4 RecipeIngredient__c - END 
    }*/
    
    private static void upsertListViews() {
        /* Inserta 1 ListView__c - BEGIN */
        List<Datatable__c> datatablesList = new List<Datatable__c>();
        List<DatatableElement__c> datatableElementsList = new List<DatatableElement__c>();
        List<DatatableAction__c> datatableActionsList = new List<DatatableAction__c>();
        
        Datatable__c datatable = new Datatable__c(ActionLabel__c = ''
                                                , Cluster__c = getId('DONTG')
                                                , Description__c = 'This is a dummy list view'
                                                , ExternalId__c = 'DatatableTest1'
                                                , Name = 'DatatableTest1'
                                                , NoRecordsMessage__c = 'There are no records to display'
                                                , NumberOfColumns__c = '2'
                                                , ObjectApiName__c = 'Component__c'
                                                , PagingType__c = 'Bottom'
                                                , RecordsPerPage__c = 2
                                                , Title__c = 'Component List'
                                                , WhereCondition__c = '');
        
        datatablesList.add(datatable);
        
        Database.upsert(datatablesList, Datatable__c.Fields.ExternalId__c, true);
        
        addToMapRecords(datatablesList);
        /* Inserta 1 Datatable__c - END */
        
        /* Inserta 2 DatatableElement__c - BEGIN */
        DatatableElement__c datatableElement = new DatatableElement__c(ColumnInformation__c = 'Dummy column 1'
                                                                    , DisplaySettings__c = 'Desktop'
                                                                    , ExternalId__c = 'DatatableElementTest1'
                                                                    , FieldApiName__c = 'Name'
                                                                    , Filtrable__c = false
                                                                    , Label__c = 'Name'
                                                                    , Datatable__c = getId('DatatableTest1')
                                                                    , Name = 'DatatableElementTest1'
                                                                    , Order__c = 1
                                                                    , Searchable__c = true
                                                                    , Sortable__c = true
                                                                    , Type__c = '');
        
        datatableElementsList.add(datatableElement);
        
        datatableElement = new datatableElement__c(ColumnInformation__c = 'Dummy column 2'
                                                                    , DisplaySettings__c = 'Desktop'
                                                                    , ExternalId__c = 'DatatablelementTest2'
                                                                    , FieldApiName__c = 'Datasource__c'
                                                                    , Filtrable__c = false
                                                                    , Label__c = 'Component Type'
                                                                    , Datatable__c = getId('DatatableTest1')
                                                                    , Name = 'DatatableElementTest2'
                                                                    , Order__c = 2
                                                                    , Searchable__c = true
                                                                    , Sortable__c = true
                                                                    , Type__c = '');
        //type is now picklist and cannot be searched as the required type is string
        //datatableElementsList.add(datatableElement);
        
        Database.upsert(datatableElementsList, datatableElement__c.Fields.ExternalId__c, true);
        
        addToMapRecords(DatatableElementsList);
        /* Inserta 1 DatatableElement__c - END */
        
        /* Inserta 1 DatatableAction__c - BEGIN */
        DatatableAction__c DatatableAction = new DatatableAction__c(Component__c = 'CG_ClusterSelector'
                                                                    , DisplaySettings__c = 'Desktop'
                                                                    , ExternalId__c = 'DatatableRowActionDummy1'
                                                                    //, Icon__c = ''
                                                                    , Label__c = 'Action 1'
                                                                    , Datatable__c = getId('DatatableTest1')
                                                                    , Name = 'DatatableRowActionDummy1'
                                                                    //, Navigation__c = ''
                                                                    , RecordTypeId = getRTId('DatatableAction__c-RowAction').Id
                                                                    , SelectableRow__c = true
                                                                    , Type__c = 'Custom');
        
        datatableActionsList.add(datatableAction);
        
        datatableAction = new DatatableAction__c(DisplaySettings__c = 'Desktop'
                                                   , ExternalId__c = 'DatatableRowActionDummy2'
                                                   //, Icon__c = ''
                                                   , Label__c = 'Action 2'
                                                   , Datatable__c = getId('DatatableTest1')
                                                   , Name = 'DatatableRowActionDummy2'
                                                   , Navigation__c = getId('DUMMY_Nav_home')
                                                   , RecordTypeId = getRTId('DatatableAction__c-RowAction').Id
                                                   , SelectableRow__c = true
                                                   , Type__c = 'Navigation');
        
        datatableActionsList.add(datatableAction);
        
        datatableAction = new datatableAction__c(DisplaySettings__c = 'Desktop'
                                                   , ExternalId__c = 'DatatableGlobalActionDummy1'
                                                   //, Icon__c = ''
                                                   , Label__c = 'Global Action 1'
                                                   , Datatable__c = getId('DatatableTest1')
                                                   , Name = 'DatatableGlobalActionDummy1'
                                                   , Navigation__c = getId('DUMMY_Nav_home')
                                                   , RecordTypeId = getRTId('DatatableAction__c-RowAction').Id
                                                   , SelectableRow__c = true
                                                   , Type__c = 'Navigation');
        
        datatableActionsList.add(datatableAction);
        
        Database.upsert(datatableActionsList, DatatableAction__c.Fields.ExternalId__c, true);
        
        addToMapRecords(datatableActionsList);
        /* Inserta 1 DatatableAction__c - END */
    }
    @future
    public static void createUsersAndPermissionSetAssignment(){        
        Set<User> usersSet = new Set<User>();
        List<User> usersToInsertList = new List<User>();
        List<User> usersToUpdateList = new List<User>();
        List<PermissionSetAssignment> permissionSetAssignmentToUpsertList = new List<PermissionSetAssignment>();
        
        Map<String,Id> ProfileNameToIdMap = new Map<String,Id>();
        for (Profile profile : [SELECT id, Name FROM Profile]){
            ProfileNameToIdMap.put(profile.Name, profile.Id);
        }
        
        Map<String,String> userAliasToIdMap = new Map<String,String>();
        for(User user : [SELECT Id, Alias FROM User]){
            userAliasToIdMap.put(user.Alias, user.Id);
        }
        
        Map<String,Id> permissionSetnameToIdMap = new Map<String,Id>();
        for(PermissionSet permissionSet : [SELECT Id, Name FROM PermissionSet]){
            permissionSetnameToIdMap.put(permissionSet.Name, permissionSet.Id);
        }
        
        String UserAdminProfileAlias = [SELECT Id, Alias FROM User WHERE ProfileId = :ProfileNameToIdMap.get('System Administrator') LIMIT 1].Alias;
        
        //setup users
        User cmsAdmin = new User (Alias='cadmi', LastName = 'Admin', FirstName='CMS',Username ='cmsadmin@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(cmsAdmin);
        User contentApprover = new User (Alias='cappr', LastName = 'Approver', FirstName='Content',Username ='contentapprover@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(contentApprover);
        User mediaElementManagent = new User (Alias='meman', LastName = 'Management', FirstName='MediaElement',Username ='mediaelementmanagement@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(mediaElementManagent);
        User communityManager = new User (Alias='cmana', LastName = 'Manager', FirstName='Community',Username ='communitymanager@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(communityManager);
        User contentManager = new User (Alias='cman', LastName = 'Manager', FirstName='Content',Username ='contentmanager@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(contentManager);
        User readOnly = new User (Alias='ronly', LastName = 'Only', FirstName='Read',Username ='readonly@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(readOnly);
        User userCMS = new User (Alias='ccms', LastName = 'User', FirstName='CMS', Username ='cmsuser@cloudgaia.com.' + UserAdminProfileAlias, Email = 'cms@cloudgaia.com', ProfileId = ProfileNameToIdMap.get('Standard User'), TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', isActive = true);
        usersSet.add(userCMS);
        
        for(User user : usersSet){
            if( userAliasToIdMap.keySet().contains(user.Alias) ){
                user.Id = userAliasToIdMap.get(user.Alias);
                usersToUpdateList.add(user);
            } else {
                usersToInsertList.add(user);
            }
        }
        
        if( !usersToInsertList.isEmpty() )
			Database.insert(usersToInsertList, true);
        if( !usersToUpdateList.isEmpty() )
			Database.update(usersToUpdateList, true);
        
        //PermissionSet process
        Map<String,Set<String>> userIdToSetofPermissionSetIdMap = new  Map<String,Set<String>>();
        for(PermissionSetAssignment psa :[SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :usersSet]){
            if( !userIdToSetofPermissionSetIdMap.containsKey(psa.AssigneeId) ){
                userIdToSetofPermissionSetIdMap.put(psa.AssigneeId, new Set<String>{psa.PermissionSetId});
            } else {
                userIdToSetofPermissionSetIdMap.get(psa.AssigneeId).add(psa.PermissionSetId);
            }
        }
        
        for(User user : usersSet){
            PermissionSetAssignment actual = new PermissionSetAssignment();
            
            if(user.Alias == 'cadmi'){//cmsAdmin
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('CMSAdmin'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('CMSAdmin');
                }
            }
            if(user.Alias == 'cappr'){//contentApprover
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('ContentApprover'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('ContentApprover');
                }
            }
            if(user.Alias == 'meman'){//mediaElementManagent
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('MediaElementManagement'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('MediaElementManagement');
                }
            }
            if(user.Alias == 'cmana'){//communityManager
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('CommunityManager'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('CommunityManager');
                }
            }
            if(user.Alias == 'cman'){//contentManager
                
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('ContentManager'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('ContentManager');
                }
            }
            if(user.Alias == 'ronly'){//readOnly
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('ReadOnly'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('ReadOnly');
                }
            }
            if(user.Alias == 'ccms'){//userCMS
                if(userIdToSetofPermissionSetIdMap.containsKey(user.Id) && !userIdToSetofPermissionSetIdMap.get(user.Id).contains(permissionSetnameToIdMap.get('CMSUser'))){
                    actual.AssigneeId = user.id;
                    actual.PermissionSetId = permissionSetnameToIdMap.get('CMSUser');
                }
            }
            
            if(actual.AssigneeId != null && actual.PermissionSetId != null)
                permissionSetAssignmentToUpsertList.add(actual);
        }
        
        if( !permissionSetAssignmentToUpsertList.isEmpty() )
			Database.insert(permissionSetAssignmentToUpsertList, true);
        
        //update all user desactivate
        List<User> updateDesactiveUsersList = new List<User>();
        updateDesactiveUsersList.addAll(usersToInsertList);
        updateDesactiveUsersList.addAll(usersToUpdateList);
        
        for (User userToDesactivate : updateDesactiveUsersList){
            userToDesactivate.IsActive = false;
        }
        if( !updateDesactiveUsersList.isEmpty() )
       		Database.update(updateDesactiveUsersList, true);
        
    }
    
}
