@isTest
private class LoanChargeTriggerHandlerTest {

    @isTest
    static void testAddChargeExtendsReleaseChargeDate() {
        Account acc = TestDataFactory.createPersonAccount('Brown');
        Loan__c loan = TestDataFactory.createLoan(acc, 15000, Date.today(), 6);
        Loan_Charge__c release = TestDataFactory.getReleaseCharge(loan.Id);
        Date originalReleaseDate = release.Date__c;

        List<Map<String, Object>> charges = new List<Map<String, Object>>{
            new Map<String, Object>{ 'type' => 'Interest Charge', 'amount' => 100, 'date' => originalReleaseDate }
        };
        TestDataFactory.createCharges(loan.Id, charges);

        Loan_Charge__c updatedRelease = [SELECT Date__c FROM Loan_Charge__c WHERE Id = :release.Id];
        System.assertEquals(originalReleaseDate.addMonths(1), updatedRelease.Date__c);
    }

    @isTest
    static void testLoanBalanceIncludesAllCharges() {
        Account acc = TestDataFactory.createPersonAccount('Green');
        Loan__c loan = TestDataFactory.createLoan(acc, 15000, Date.today(), 6);

        List<Map<String, Object>> charges = new List<Map<String, Object>>{
            new Map<String, Object>{ 'type' => 'Interest Charge', 'amount' => 250, 'date' => Date.today() },
            new Map<String, Object>{ 'type' => 'Legal Fee', 'amount' => 400, 'date' => Date.today().addDays(1) }
        };
        TestDataFactory.createCharges(loan.Id, charges);

        Loan__c updatedLoan = [SELECT Balance_of_the_Loan__c FROM Loan__c WHERE Id = :loan.Id];
        Decimal expected = 15000 + 500 + 250 + 400;
        System.assertEquals(expected, updatedLoan.Balance_of_the_Loan__c);
    }

    @isTest
    static void testDuplicateReleaseChargeIsBlocked() {
        Account acc = TestDataFactory.createPersonAccount('Williams');
        Loan__c loan = TestDataFactory.createLoan(acc, 10000, Date.today(), 12);

        Test.startTest();
        try {
            Loan_Charge__c dup = new Loan_Charge__c(
                Loan__c = loan.Id,
                Charge_Type__c = 'Release Charge',
                Amount__c = 500,
                Date__c = Date.today().addMonths(12)
            );
            insert dup;
            System.assert(false, 'Should throw error for duplicate Release Charge');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('already exists'), 'Error must mention duplicate');
        }
        Test.stopTest();
    }
}