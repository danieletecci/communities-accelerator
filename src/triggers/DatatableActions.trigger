trigger DatatableActions on DatatableAction__c (before insert, before update, after insert, after update) {
    new DatatableActionTriggers(trigger.new, trigger.old).run();
}