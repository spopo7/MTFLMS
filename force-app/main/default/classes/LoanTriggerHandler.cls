public class LoanTriggerHandler {
    public static void handleAfterInsert(List<Loan__c> newLoans) {
        List<Loan_Charge__c> chargesToCreate = new List<Loan_Charge__c>();

        for (Loan__c loan : newLoans) {
            Date releaseDate = loan.Date_Loan_Issued__c.addMonths(Integer.valueOf(loan.Term__c));
            chargesToCreate.add(new Loan_Charge__c(
                Loan__c = loan.Id,
                Charge_Type__c = 'Release Charge',
                Amount__c = 500,
                Date__c = releaseDate
            ));
        }

        insert chargesToCreate;
    }

    public static void handleAfterUpdate(List<Loan__c> newLoans, Map<Id, Loan__c> oldMap) {
        List<Loan_Charge__c> chargesToCreate = new List<Loan_Charge__c>();
        List<Loan_Charge__c> chargesToUpdate = new List<Loan_Charge__c>();

        for (Loan__c loan : newLoans) {
            Loan__c oldLoan = oldMap.get(loan.Id);
            if (loan.Term__c != oldLoan.Term__c) {
                // 1. Update Release Charge date
                Date newReleaseDate = loan.Date_Loan_Issued__c.addMonths(Integer.valueOf(loan.Term__c));

                Loan_Charge__c releaseCharge = LoanService.getReleaseChargeForLoan(loan.Id);
                if (releaseCharge != null) {
                    releaseCharge.Date__c = newReleaseDate;
                    chargesToUpdate.add(releaseCharge);
                }

                // 2. Add Admin Fee
                chargesToCreate.add(new Loan_Charge__c(
                    Loan__c = loan.Id,
                    Charge_Type__c = 'Admin Fee',
                    Amount__c = 300,
                    Date__c = Date.today()
                ));
            }
        }

        if (!chargesToUpdate.isEmpty()) update chargesToUpdate;
        if (!chargesToCreate.isEmpty()) insert chargesToCreate;
    }
}