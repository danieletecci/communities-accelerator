trigger DatatableElements on DatatableElement__c (before insert, before update, after insert, after update) {
    new DatatableElementTriggers(trigger.new, trigger.old).run();
}