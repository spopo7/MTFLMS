public class LoanService {
    public static Loan_Charge__c getReleaseChargeForLoan(Id loanId) {
        List<Loan_Charge__c> charges = [
            SELECT Id, Date__c FROM Loan_Charge__c 
            WHERE Loan__c = :loanId AND Charge_Type__c = 'Release Charge' LIMIT 1
        ];
        return charges.isEmpty() ? null : charges[0];
    }

    public static Map<Id, Loan_Charge__c> getReleaseChargesForLoans(Set<Id> loanIds) {
        Map<Id, Loan_Charge__c> result = new Map<Id, Loan_Charge__c>();
        for (Loan_Charge__c ch : [
            SELECT Id, Loan__c, Date__c FROM Loan_Charge__c
            WHERE Loan__c IN :loanIds AND Charge_Type__c = 'Release Charge'
        ]) {
            result.put(ch.Loan__c, ch);
        }
        return result;
    }
}