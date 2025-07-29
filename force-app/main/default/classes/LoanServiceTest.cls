@isTest
private class LoanServiceTest {

    @isTest
    static void testGetReleaseChargeForLoan() {
        Account acc = TestDataFactory.createPersonAccount('Taylor');
        Loan__c loan = TestDataFactory.createLoan(acc, 5000, Date.today(), 3);

        Loan_Charge__c release = LoanService.getReleaseChargeForLoan(loan.Id);
        System.assertNotEquals(null, release);
        System.assertEquals('Release Charge', release.Charge_Type__c);
    }

    @isTest
    static void testGetReleaseChargesForLoans() {
        Account acc1 = TestDataFactory.createPersonAccount('One');
        Account acc2 = TestDataFactory.createPersonAccount('Two');
        Loan__c loan1 = TestDataFactory.createLoan(acc1, 6000, Date.today(), 4);
        Loan__c loan2 = TestDataFactory.createLoan(acc2, 7000, Date.today(), 5);

        Map<Id, Loan_Charge__c> releases = LoanService.getReleaseChargesForLoans(new Set<Id>{loan1.Id, loan2.Id});
        System.assertEquals(2, releases.size());
        for (Loan_Charge__c charge : releases.values()) {
            System.assertEquals('Release Charge', charge.Charge_Type__c);
        }
    }
}