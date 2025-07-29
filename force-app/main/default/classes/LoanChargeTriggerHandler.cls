public class LoanChargeTriggerHandler {
    public static void beforeInsert(List<Loan_Charge__c> charges) {
        Set<Id> loanIds = new Set<Id>();
        for (Loan_Charge__c ch : charges) {
            loanIds.add(ch.Loan__c);
        }

        Map<Id, Loan_Charge__c> releaseChargeMap = LoanService.getReleaseChargesForLoans(loanIds);

        for (Loan_Charge__c ch : charges) {
            if (ch.Charge_Type__c == 'Release Charge' && releaseChargeMap.containsKey(ch.Loan__c)) {
                ch.addError('A Release Charge already exists for this loan.');
            } else if (ch.Charge_Type__c != 'Release Charge') {
                Loan_Charge__c existingRelease = releaseChargeMap.get(ch.Loan__c);
                if (existingRelease != null && ch.Date__c >= existingRelease.Date__c) {
                    existingRelease.Date__c = existingRelease.Date__c.addMonths(1);
                    update existingRelease;
                }
            }
        }
    }

    public static void updateLoanBalances(List<Loan_Charge__c> charges) {
        Set<Id> loanIds = new Set<Id>();
        for (Loan_Charge__c ch : charges) {
            loanIds.add(ch.Loan__c);
        }

        Map<Id, Loan__c> loans = new Map<Id, Loan__c>([
            SELECT Id, Gross_Loan_Amount__c, Total_Charges_on_Loan__c FROM Loan__c WHERE Id IN :loanIds
        ]);

        Map<Id, Decimal> chargeSums = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Loan__c loanId, SUM(Amount__c) total
            FROM Loan_Charge__c WHERE Loan__c IN :loanIds
            GROUP BY Loan__c
        ]) {
            chargeSums.put((Id)ar.get('loanId'), (Decimal)ar.get('total'));
        }

        List<Loan__c> updates = new List<Loan__c>();
        for (Id loanId : loanIds) {
            Loan__c loan = loans.get(loanId);
            loan.Total_Charges_on_Loan__c = chargeSums.get(loanId) != null ? chargeSums.get(loanId) : 0;
            loan.Balance_of_the_Loan__c = loan.Gross_Loan_Amount__c + loan.Total_Charges_on_Loan__c;
            updates.add(loan);
        }

        update updates;
    }
}