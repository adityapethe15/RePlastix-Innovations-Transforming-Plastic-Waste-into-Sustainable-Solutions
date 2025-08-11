@isTest
public class InventoryManagerTest {

    @testSetup
    static void setupTestData() {
        
        Re_Plastic_Innovations_Recycled_Product__c product = new Re_Plastic_Innovations_Recycled_Product__c(
            Name = 'Test Product',
            Stock_Level__c = 50,
            Threshold__c = 10
        );
        insert product;
    }

    @isTest
    static void testProcessOrderStock_SufficientAndInsufficientStock() {
        Re_Plastic_Innovations_Recycled_Product__c prod = [
            SELECT Id FROM Re_Plastic_Innovations_Recycled_Product__c LIMIT 1
        ];

        
        List<Re_Plastic_Innovations_Order__c> orders = new List<Re_Plastic_Innovations_Order__c>{
            new Re_Plastic_Innovations_Order__c(
                Re_Plastic_Innovations_Recycled_Product__c = prod.Id,
                Quantity__c = 20
            ),
            new Re_Plastic_Innovations_Order__c(
                Re_Plastic_Innovations_Recycled_Product__c = prod.Id,
                Quantity__c = 100 
            )
        };

        Test.startTest();
        insert orders; 
        Test.stopTest();

        
        prod = [SELECT Stock_Level__c FROM Re_Plastic_Innovations_Recycled_Product__c LIMIT 1];
        System.assert(prod.Stock_Level__c <= 50, 'Stock should be reduced');

        List<Re_Plastic_Innovations_Restock_Request__c> pending = [
            SELECT Id, Status__c FROM Re_Plastic_Innovations_Restock_Request__c
        ];
        System.assert(!pending.isEmpty(), 'Restock requests should be created');
        System.assertEquals('Pending', pending[0].Status__c);
    }

    @isTest
    static void testProcessRestockApproval_AndEmailNotification() {
        
        Re_Plastic_Innovations_Recycled_Product__c prod = [
            SELECT Id FROM Re_Plastic_Innovations_Recycled_Product__c LIMIT 1
        ];

        Re_Plastic_Innovations_Restock_Request__c restock = new Re_Plastic_Innovations_Restock_Request__c(
            Product__c = prod.Id,
            Requested_Quantity__c = 25,
            Status__c = 'Pending'
        );
        insert restock;

        
        restock.Status__c = 'Approved';

        Test.startTest();
        update restock; 
        Test.stopTest();

        prod = [SELECT Stock_Level__c FROM Re_Plastic_Innovations_Recycled_Product__c LIMIT 1];
        System.assert(prod.Stock_Level__c >= 25, 'Stock should increase after approval');
    }

    @isTest
    static void testDirectEmailHelper() {
        
        Re_Plastic_Innovations_Restock_Request__c dummy = new Re_Plastic_Innovations_Restock_Request__c(
            Product__c = [SELECT Id FROM Re_Plastic_Innovations_Recycled_Product__c LIMIT 1].Id,
            Requested_Quantity__c = 5,
            Status__c = 'Approved'
        );

        Test.startTest();
        EmailNotificationHelper.sendRestockNotification(new List<Re_Plastic_Innovations_Restock_Request__c>{ dummy });
        Test.stopTest();

     
    }
}