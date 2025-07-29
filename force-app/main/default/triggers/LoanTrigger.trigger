trigger LoanTrigger on Loan__c (before insert, before update, after insert, after update) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            LoanTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            LoanTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}