public class InventoryManager {

    
    public static void processOrderStock(List<Re_Plastic_Innovations_Order__c> orderList) {
       
    }

   
    public static void processRestockApproval(List<Re_Plastic_Innovations_Restock_Request__c> approvedRestocks) {
        Set<Id> productIds = new Set<Id>();

        for (Re_Plastic_Innovations_Restock_Request__c restock : approvedRestocks) {
            if (restock.Product__c != null) {
                productIds.add(restock.Product__c);
            }
        }

        if (productIds.isEmpty()) {
            return; 
        }

        
        Map<Id, Re_Plastic_Innovations_Recycled_Product__c> productMap = new Map<Id, Re_Plastic_Innovations_Recycled_Product__c>(
            [SELECT Id, Stock_Level__c 
             FROM Re_Plastic_Innovations_Recycled_Product__c 
             WHERE Id IN :productIds]
        );

        List<Re_Plastic_Innovations_Recycled_Product__c> productsToUpdate = new List<Re_Plastic_Innovations_Recycled_Product__c>();

        for (Re_Plastic_Innovations_Restock_Request__c restock : approvedRestocks) {
            Re_Plastic_Innovations_Recycled_Product__c product = productMap.get(restock.Product__c);

            if (product != null) {
                // Add approved quantity to stock
                product.Stock_Level__c += restock.Requested_Quantity__c;
                productsToUpdate.add(product);
            }
        }

        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
}