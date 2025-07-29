@isTest
public class TestDataFactory {

    public static Account createPersonAccount(String AccName) {
        Account acc = new Account(
            Name = AccName
        );
        insert acc;
        return acc;
    }

    public static Loan__c createLoan(Account acc, Decimal grossAmount, Date issueDate, Integer termMonths) {
        Loan__c loan = new Loan__c(
            Name = 'Test Loan',
            Account__c = acc.Id,
            Gross_Loan_Amount__c = grossAmount,
            Date_Loan_Issued__c = issueDate,
            Term__c = termMonths
        );
        insert loan;
        return loan;
    }

    public static List<Loan_Charge__c> createCharges(Id loanId, List<Map<String, Object>> chargeData) {
        List<Loan_Charge__c> charges = new List<Loan_Charge__c>();
        for (Map<String, Object> data : chargeData) {
            charges.add(new Loan_Charge__c(
                Loan__c = loanId,
                Charge_Type__c = (String)data.get('type'),
                Amount__c = (Decimal)data.get('amount'),
                Date__c = (Date)data.get('date')
            ));
        }
        insert charges;
        return charges;
    }

    public static Loan_Charge__c getReleaseCharge(Id loanId) {
        return [SELECT Id, Charge_Type__c, Amount__c, Date__c FROM Loan_Charge__c WHERE Loan__c = :loanId AND Charge_Type__c = 'Release Charge' LIMIT 1];
    }
}