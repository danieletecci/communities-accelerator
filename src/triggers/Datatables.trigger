trigger Datatables on Datatable__c (before insert, before update, after insert, after update) {
    new DatatableTriggers(trigger.new, trigger.old).run();
}