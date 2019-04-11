/*
-----------------------------------------------------------------------------------------------------------------------------------------------

The triggers framework "Master Loop" was thought mainly to solve performance problems. It is based on the fact that any business requirement can be solved with only 2 loops ("Master" and "Final" loops) of the records involved in a trigger.

The framework was designed and developed to enhance the following points:
- Standardization of design patterns for triggers
- Distinction between architecture and business logic
- Standardization of records iteration and amount of iterations ("Master Loop & Final Loop")
- Standardization on "steps" of triggers
- Standardization on general variables naming
- Easy reuse of variables and queries
- Easy usage of "New record" and "Old record"
- General bypass of triggers and trigger methods
- Bypass by user on triggers and methods
- Bypass on "runtime" of triggers and methods
- Native capabilities for Multi-Country and Multi-Business
- Recursivity control
- Execution path debug. You can activate declaratively this functionality
- Capabilities to do "Self Update" of records in trigger

Execution order:
1. triggerPreparing: This methods is used to do an aditional filter on the list "trigger new/old" or, for example, instantiate global variables
2. masterLoops: First loop of all the records involved in the trigger
3. dataPreparing: This method must contain all the SOQL queries and process the queries data to make collections that will then be used in DMLs or finalLoops
4. executeDMLs: This method must contain all the DMLs (always trying to group the collections of the same types)
5. finalLoops: Second and last loop of all the records involved in the trigger
6. triggerFinish: This method is used to execute DMLs that need more than one loop of the records, webservices executions or global action for the trigger
7. * selfupdate: This method will be executed only if is necessary to update a record involved in the same trigger

-----------------------------------------------------------------------------------------------------------------------------------------------
*/


public without sharing virtual class TriggersHandler {

    @TestVisible private map<String, set<String>> mapExecution_forTest;

    private String triggerName;
    private Boolean allowRecursivity;
    private Boolean runDebugs;

    public Boolean allow_masterLoop_BeforeInsert = false;
    public Boolean allow_masterLoop_AfterInsert = false;
    public Boolean allow_masterLoop_BeforeUpdate = false;
    public Boolean allow_masterLoop_AfterUpdate = false;
    public Boolean allow_masterLoop_BeforeDelete = false;
    public Boolean allow_masterLoop_AfterDelete = false;
    public Boolean allow_masterLoop_AfterUndelete = false;
    public Boolean allow_dataPreparing = false;
    public Boolean allow_executeDMLs = false;
    public Boolean allow_finalLoop_BeforeInsert = false;
    public Boolean allow_finalLoop_BeforeUpdate = false;
    public Boolean allow_finalLoop_AfterInsert = false;
    public Boolean allow_finalLoop_AfterUpdate = false;
    public Boolean allow_finalLoop_BeforeDelete = false;
    public Boolean allow_finalLoop_AfterDelete = false;
    public Boolean allow_finalLoop_AfterUndelete = false;
    public Boolean allow_triggerFinish = false;
    public Boolean allow_selfUpdate = false;

    @TestVisible public List<SObject> triggerNew;
    @TestVisible public List<SObject> triggerOld;
    @TestVisible public map<Id, SObject> triggerOldMap;
    @TestVisible private Boolean triggerIsBefore;
    @TestVisible private Boolean triggerIsAfter;
    @TestVisible private Boolean triggerIsInsert;
    @TestVisible private Boolean triggerIsUpdate;
    @TestVisible private Boolean triggerIsUndelete;
    @TestVisible private Boolean triggerIsDelete;

    @TestVisible private static Boolean isTriggersHandlerTest = false;

    private map<Id, SObject> mapRecordsToSelfUpdate;
    private Schema.DescribeSObjectResult objDesc;
    
    //CONSTRUCTORS
    public TriggersHandler(List<SObject> p_triggerNew, List<SObject> p_triggerOld, Boolean allowRecursivity) {
        init(p_triggerNew, p_triggerOld, allowRecursivity);
    }

    public TriggersHandler(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        init(p_triggerNew, p_triggerOld, true);
    }

    //INITIALIZATION METHOD
    private void init(List<SObject> p_triggerNew, List<SObject> p_triggerOld, Boolean allowRecursivity){
        this.allowRecursivity = allowRecursivity;
        mapRecordsToSelfUpdate = new map<Id, SObject>();
        mapExecution_forTest = new map<String, set<String>>();

        triggerNew = p_triggerNew;
        triggerOld = p_triggerOld;

        if(!isTriggersHandlerTest){triggerIsBefore   = trigger.isBefore;}
        if(!isTriggersHandlerTest){triggerIsAfter    = trigger.isAfter;}
        if(!isTriggersHandlerTest){triggerIsInsert   = trigger.isInsert;}
        if(!isTriggersHandlerTest){triggerIsUpdate   = trigger.isUpdate;}
        if(!isTriggersHandlerTest){triggerIsUndelete = trigger.isUndelete;}
        if(!isTriggersHandlerTest){triggerIsDelete   = trigger.isDelete;}
        if(!isTriggersHandlerTest){triggerOldMap   = trigger.oldMap;}
    }

    //TEMPLATE METHODS ENABLED TO BE OVERWRITED
    /*
    public override void triggerPreparing() {}
    public override void masterLoop_BeforeInsert(SObject recNew) {}
    public override void masterLoop_AfterInsert(SObject recNew) {}
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public override void masterLoop_BeforeDelete(SObject recOld) {}
    public override void masterLoop_AfterDelete(SObject recOld) {}
    public override void masterLoop_AfterUndelete(SObject recOld) {}
    public override void dataPreparing() {}
    public override void executeDMLs() {}
    public override void finalLoop_BeforeInsert(SObject recNew) {}
    public override void finalLoop_AfterInsert(SObject recNew) {}
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public override void finalLoop_BeforeDelete(SObject recOld) {}
    public override void finalLoop_AfterDelete(SObject recOld) {}
    public override void finalLoop_AfterUndelete(SObject recNew) {}
    public override void triggerFinish() {}
    public override void selfUpdate() {}
    */

    public void run(){
        triggerName = String.valueOf(this).split(':')[0];

        runDebugs = TriggersHandlerManager.canAutoDebug(triggerName);

        if(runDebugs){system.debug('TRIGGER ' + triggerName);}

        //By Pass
        if(!TriggersHandlerManager.canTrigger(triggerName)){return;}

        if(!allowRecursivity){TriggersHandlerManager.byPassTrigger(triggerName);}

        exeMasterLoops();

        if(!allowRecursivity){TriggersHandlerManager.removeByPassTrigger(triggerName);}
    }

    private void exeMasterLoops() {
        //First method (trigger "setup")
        triggerPreparingMaster();

        if((triggerIsInsert || triggerIsUpdate || triggerIsUndelete) && triggerNew.isEmpty()){return;}
        if(triggerIsDelete && triggerOld.isEmpty()){return;}
        
        //Main loop of records to impact data by default in before events, or collect data for later operations
        masterLoop(false);
        
        //Method to execute queries and process data in collections
        dataPreparingMaster();

        //Method to execute DMLs
        executeDMLsMaster();

        //Final loop of records to impact data
        masterLoop(true);

        //Method to execute extra DMLs or global final processes
        triggerFinishMaster();
        
        //Method to update records involved in the same trigger
        selfUpdateMaster();
    }

    private void triggerPreparingMaster() {
        triggerPreparing();
    }

    private void masterLoop(Boolean isFinal) {
        
        //Insert loop
        if(allow_masterLoop_BeforeInsert || allow_finalLoop_BeforeInsert || allow_masterLoop_AfterInsert || allow_finalLoop_AfterInsert){
            if(triggerIsInsert){
                for(SObject recNew: (List<SObject>)triggerNew){
                    if(triggerIsBefore){
                        if(!isFinal && allow_masterLoop_BeforeInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE INSERT - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_BeforeInsert', recNew.Id);
                            masterLoop_BeforeInsert(recNew);
                        }else if(allow_finalLoop_BeforeInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE INSERT - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_BeforeInsert', recNew.Id);
                            finalLoop_BeforeInsert(recNew);
                        }
                    }
                    if(triggerIsAfter){
                        if(!isFinal && allow_masterLoop_AfterInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER INSERT - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_AfterInsert', recNew.Id);
                            masterLoop_AfterInsert(recNew);
                        }else if(allow_finalLoop_AfterInsert){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER INSERT - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_AfterInsert', recNew.Id);
                            finalLoop_AfterInsert(recNew);
                        }
                    }
                }
            }
        }

        //Update loop
        if(allow_masterLoop_BeforeUpdate || allow_finalLoop_BeforeUpdate || allow_masterLoop_AfterUpdate || allow_finalLoop_AfterUpdate){
            if(triggerIsUpdate){
                for(SObject recNew: (List<SObject>)triggerNew){
                    SObject recOld = triggerOldMap.get(String.valueOf(recNew.get('id')));
                    if(triggerIsBefore){
                        if(!isFinal && allow_masterLoop_BeforeUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE UPDATE - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_BeforeUpdate', recNew.Id);
                            masterLoop_BeforeUpdate(recNew, recOld);
                        }else if(allow_finalLoop_BeforeUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE UPDATE - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_BeforeUpdate', recNew.Id);
                            finalLoop_BeforeUpdate(recNew, recOld);
                        }
                    }
                    if(triggerIsAfter){
                        if(!isFinal && allow_masterLoop_AfterUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UPDATE - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_AfterUpdate', recNew.Id);
                            masterLoop_AfterUpdate(recNew, recOld);
                        }else if(allow_finalLoop_AfterUpdate){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UPDATE - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_AfterUpdate', recNew.Id);
                            finalLoop_AfterUpdate(recNew, recOld);
                        }
                    }
                }
            }
        }

        //Delete loop
        if(allow_masterLoop_BeforeDelete || allow_finalLoop_BeforeDelete || allow_masterLoop_AfterDelete || allow_finalLoop_AfterDelete){
            if(triggerIsDelete){
                for(SObject recOld: (List<SObject>)triggerOld){
                    if(triggerIsBefore){
                        if(!isFinal && allow_masterLoop_BeforeDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE DELETE - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_BeforeDelete', recOld.Id);
                            masterLoop_BeforeDelete(recOld);
                        }else if(allow_finalLoop_BeforeDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - BEFORE DELETE - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_BeforeDelete', recOld.Id);
                            finalLoop_BeforeDelete(recOld);
                        }
                        
                    }
                    if(triggerIsAfter){
                        if(!isFinal && allow_masterLoop_AfterDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER DELETE - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_AfterDelete', recOld.Id);
                            masterLoop_AfterDelete(recOld);
                        }else if(allow_finalLoop_AfterDelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER DELETE - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_AfterDelete', recOld.Id);
                            finalLoop_AfterDelete(recOld);
                        }
                    }
                }
            }
        }

        //Undelete loop
        if(allow_masterLoop_AfterUndelete || allow_finalLoop_AfterUndelete){
            if(triggerIsUndelete){
                for(SObject recNew: (List<SObject>)triggerNew){
                    if(triggerIsAfter){
                        if(!isFinal && allow_masterLoop_AfterUndelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UNDELETE - MASTER LOOP');}
                            addValueToMapMapExecution_forTest('masterLoop_AfterUndelete', recNew.Id);
                            masterLoop_AfterUndelete(recNew);
                        }else if(allow_finalLoop_AfterUndelete){
                            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - AFTER UNDELETE - FINAL LOOP');}
                            addValueToMapMapExecution_forTest('finalLoop_AfterUndelete', recNew.Id);
                            finalLoop_AfterUndelete(recNew);
                        }
                    }
                }
            }
        }

    }

    //QUERIES AND DATA PROCESSING
    private void dataPreparingMaster() {
        if(allow_dataPreparing){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - dataPreparing');}
            addValueToMapMapExecution_forTest('dataPreparing', '');
            dataPreparing();
        }
    }

    //DMLS
    private void executeDMLsMaster() {
        if(allow_executeDMLs){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - executeDMLs');}
            addValueToMapMapExecution_forTest('executeDMLs', '');
            executeDMLs();
        }
    }
    
    //EXTRA DMLS, @FUTURE METHODS, WEBSERVICES, ETC
    private void triggerFinishMaster() {
        if(allow_triggerFinish){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - triggerFinish');}
            addValueToMapMapExecution_forTest('triggerFinish', '');
            triggerFinish();
        }
    }

    //UPDATE FOR RECORDS INVOLVED IN THE TRIGGER
    private void selfUpdateMaster() {
        if(allow_selfUpdate || !mapRecordsToSelfUpdate.values().isEmpty()){
            if(runDebugs){system.debug('TRIGGER ' + triggerName + ' - selfUpdate');}
            addValueToMapMapExecution_forTest('selfUpdate', mapRecordsToSelfUpdate.keySet());
        }
        selfUpdate();
    }

    //METHODS ENABLED TO BE OVERWRITED
    public virtual void triggerPreparing() {}
    public virtual void masterLoop_BeforeInsert(SObject recNew) {}
    public virtual void masterLoop_AfterInsert(SObject recNew) {}
    public virtual void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public virtual void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public virtual void masterLoop_BeforeDelete(SObject recOld) {}
    public virtual void masterLoop_AfterDelete(SObject recOld) {}
    public virtual void masterLoop_AfterUndelete(SObject recOld) {}
    public virtual void dataPreparing() {}
    public virtual void executeDMLs() {}
    public virtual void finalLoop_BeforeInsert(SObject recNew) {}
    public virtual void finalLoop_AfterInsert(SObject recNew) {}
    public virtual void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {}
    public virtual void finalLoop_AfterUpdate(SObject recNew, SObject recOld) {}
    public virtual void finalLoop_BeforeDelete(SObject recOld) {}
    public virtual void finalLoop_AfterDelete(SObject recOld) {}
    public virtual void finalLoop_AfterUndelete(SObject recNew) {}
    public virtual void triggerFinish() {}

    public virtual void selfUpdate() {
        if(!mapRecordsToSelfUpdate.values().isEmpty()){
            update mapRecordsToSelfUpdate.values();
        }
    }

    //UTILITY METHODS
    public Boolean canMethod(String method){
        Boolean allowMethod = TriggersHandlerManager.canTrigger(triggerName + '.' + method);
        if(allowMethod){
            if(runDebugs){system.debug('TRIGGER METHOD ' + triggerName + '.' + method);}
        }
        return allowMethod;
    }

    public void recordSelfUpdate(Id recId, String fieldApiName, Object value){
        if(objDesc == null){
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(String.ValueOf(recId.getsobjecttype()));
            objDesc = objType.getDescribe();
        }

        SObject recClone;
        if(mapRecordsToSelfUpdate.containsKey(recId)){
            recClone = mapRecordsToSelfUpdate.get(recId);
            setFieldValueOnRecord(recClone, fieldApiName, value);
        }else{
            recClone = (SObject)Type.forName(String.ValueOf(recId.getsobjecttype())).newInstance();
            recClone.put('Id', recId);
            setFieldValueOnRecord(recClone, fieldApiName, value);
        }
        mapRecordsToSelfUpdate.put(recId, recClone);
    }

    private void setFieldValueOnRecord(SObject rec, String fieldApiName, Object value){
        Schema.DescribeFieldResult field = objDesc.fields.getMap().get(fieldApiName).getDescribe();
        Schema.SOAPType soapType = field.getSOAPType();
        if(soapType == Schema.SOAPType.String || soapType == Schema.SOAPType.anytype || soapType == Schema.SOAPType.ID ) {
            rec.put(fieldApiName, String.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.Integer ){
            rec.put(fieldApiName, Long.valueOf(String.ValueOf(value)));
        } else if ( soapType == Schema.SOAPType.Boolean ){
            rec.put(fieldApiName, Boolean.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.Date ){
            rec.put(fieldApiName, Date.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.DateTime ){
            rec.put(fieldApiName, Datetime.valueOf(value));
        } else if ( soapType == Schema.SOAPType.Double ){
            rec.put(fieldApiName, Double.ValueOf(value));
        } else if ( soapType == Schema.SOAPType.base64binary ){
            rec.put(fieldApiName, Blob.ValueOf(String.ValueOf(value)));
        }
    }

    private void addValueToMapMapExecution_forTest(String method, set<Id> setIds){
        if(Test.isRunningTest()){
            for(Id recId: setIds){
                addValueToMapMapExecution_forTest(method, recId);
            }
        }
    }

    private void addValueToMapMapExecution_forTest(String method, String recId){
        if(Test.isRunningTest()){
            if(mapExecution_forTest.containsKey(method)){
                mapExecution_forTest.get(method).add(recId);
            }else{
                mapExecution_forTest.put(method, new set<String>{recId});
            }
        }
    }

}