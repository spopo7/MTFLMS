@isTest
private class LoanTriggerHandlerTest {

    @isTest
    static void testLoanInsertCreatesReleaseCharge() {
        Account acc = TestDataFactory.createPersonAccount('Smith');
        Loan__c loan = TestDataFactory.createLoan(acc, 10000, Date.today(), 12);

        Loan_Charge__c release = TestDataFactory.getReleaseCharge(loan.Id);
        System.assertNotEquals(null, release);
        System.assertEquals('Release Charge', release.Charge_Type__c);
        System.assertEquals(500, release.Amount__c);
        System.assertEquals(Date.today().addMonths(12), release.Date__c);
    }

    @isTest
    static void testLoanTermChangeCreatesAdminFeeAndUpdatesReleaseCharge() {
        Account acc = TestDataFactory.createPersonAccount('Jones');
        Loan__c loan = TestDataFactory.createLoan(acc, 20000, Date.today(), 6);

        loan.Term__c = 18;
        update loan;

        List<Loan_Charge__c> charges = [SELECT Charge_Type__c, Date__c FROM Loan_Charge__c WHERE Loan__c = :loan.Id];
        Boolean foundAdmin = false;
        Boolean releaseDateUpdated = false;

        for (Loan_Charge__c ch : charges) {
            if (ch.Charge_Type__c == 'Admin Fee') {
                foundAdmin = true;
                System.assertEquals(300, ch.Amount__c);
                System.assertEquals(Date.today(), ch.Date__c);
            }
            if (ch.Charge_Type__c == 'Release Charge') {
                releaseDateUpdated = (ch.Date__c == Date.today().addMonths(18));
            }
        }

        System.assert(foundAdmin, 'Admin Fee should be created');
        System.assert(releaseDateUpdated, 'Release Charge date should update');
    }
}