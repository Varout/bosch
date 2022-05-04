/**
 * Class: BatchGDPRCleanerTest.cls
 * @desc: Unit test class for BatchGDPRCleaner.cls
 */
@isTest
private class BatchGDPRCleanerTest {

    @TestSetup
    static void makeData() {
        Account testAccountSixMonths = new Account(
            Name = 'Six months old'
        );
        Account testAccountOneYear = new Account(
            Name = 'One year old'
        );
        insert new List<Account>{ testAccountSixMonths, testAccountOneYear };

        Contact testContactSixMonths = new Contact(
            FirstName = 'Mx.',
            LastName = 'Tester 0.5',
            MailingStreet = 'Six month road',
            MailingCity = 'Cleaning'
        );
        Contact testContactOneYear = new Contact(
            FirstName = 'Mx.',
            LastName = 'Tester 1.0',
            MailingStreet = 'One year road',
            MailingCity = 'Cleaning'
        );
        insert new List<Contact>{ testContactSixMonths, testContactOneYear };

        Case testCaseSixMonths = new Case(
            AccountId = testAccountSixMonths.Id,
            ContactId = testContactSixMonths.Id,
            Status = 'Closed',
            TestClosedDate__c = System.today().addMonths(-6)
        );
        Case testCaseOneYear = new Case(
            AccountId = testAccountOneYear.Id,
            ContactId = testContactOneYear.Id,
            Status = 'Closed',
            TestClosedDate__c = System.today().addYears(-1).addDays(-1)
        );
        insert new List<Case>{ testCaseSixMonths, testCaseOneYear };
    }

    /**
     *
     */
    @isTest
    static void testFunctionOne() {
        UtilityGDPRCleaner.metadataFieldsAccount = new Map<String, String>();
        UtilityGDPRCleaner.metadataFieldsAccount.put('Name', 'Text');

        UtilityGDPRCleaner.metadataFieldsCase = new Map<String, String>();
        UtilityGDPRCleaner.metadataFieldsCase.put('AccountId', 'Lookup');
        UtilityGDPRCleaner.metadataFieldsCase.put('ContactId', 'Lookup');
        UtilityGDPRCleaner.metadataFieldsCase.put('Description', 'Text');

        UtilityGDPRCleaner.metadataFieldsContact = new Map<String, String>();
        UtilityGDPRCleaner.metadataFieldsContact.put('FirstName', 'Text');
        UtilityGDPRCleaner.metadataFieldsContact.put('LastName', 'Text');
        UtilityGDPRCleaner.metadataFieldsContact.put('MailingStreet', 'Text');
        UtilityGDPRCleaner.metadataFieldsContact.put('MailingCity', 'Text');
        UtilityGDPRCleaner.metadataFieldsContact.put('Phone', 'Number');

        Test.startTest();
        Database.executeBatch(new BatchGDPRCleaner());
        Test.stopTest();

        List<Account> testAccounts = [SELECT Id, Name FROM Account];
        System.debug(testAccounts);
        List<Case> testCases = [SELECT Id, AccountId, ContactId, Status, TestClosedDate__c, Description FROM Case];
        System.debug(testCases);
        List<Contact> testContacts = [SELECT Id, FirstName, LastName, MailingStreet, MailingCity FROM Contact];
        System.debug(testContacts);
        // List<Debug_Log__c> testDebugLogs
    }

}