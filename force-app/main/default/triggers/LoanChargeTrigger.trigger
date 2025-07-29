trigger LoanChargeTrigger on Loan_Charge__c (before insert, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore && Trigger.isInsert) {
        LoanChargeTriggerHandler.beforeInsert(Trigger.new);
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete) {
            LoanChargeTriggerHandler.updateLoanBalances(
                Trigger.isDelete ? Trigger.old : Trigger.new
            );
        }
    }
}