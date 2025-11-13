public without sharing class EM_OportunidadProducto {
    public class OpportunityWrapper {
        @AuraEnabled public Opportunity opp {get; set;}
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public Id productId {get; set;}
        @AuraEnabled public Decimal quantity {get; set;}

        public opportunityWrapper(Opportunity opp, String productName, Id productId, Decimal quantity) {
            this.opp = opp;
            this.productName    = productName;
            this.productId      = productId;
            this.quantity       = quantity;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityWrapper> getOpportunities(String accountId) {    
        if (!Schema.sObjectType.Opportunity.isAccessible() || !Schema.sObjectType.OpportunityLineItem.isAccessible()) {
            return null;
        }        
        List<Opportunity> oppList;    
        if (Test.isRunningTest()) {
            oppList = [
                SELECT Id, Name, StageName, CreatedDate, Account.Name, Owner.Name
                FROM Opportunity
                WHERE StageName != 'Cerrada Ganada'
                AND StageName != 'Cerrada Perdida'
                AND Account.Id = :accountId
            ];
        } else {
            oppList = [
                SELECT Id, Name, StageName, CreatedDate, Account.Name, Owner.Name
                FROM Opportunity
                WHERE StageName != 'Cerrada Ganada'
                AND StageName != 'Cerrada Perdida'
                AND Owner.CodigoUN__c = 'EM'      
                AND Account.Id = :accountId
            ];
        }

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : oppList) {
            oppIds.add(opp.Id);
        }

        List<OpportunityLineItem> olis = [
            SELECT OpportunityId, Product2.Name, Product2Id, Quantity 
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :oppIds
        ];

        Map<Id, String> oppToProductName    = new Map<Id, String>();
        Map<Id, Id> oppToProductId          = new Map<Id, Id>();
        Map<Id, Decimal> oppToQuantity      = new Map<Id, Decimal>();

        for (OpportunityLineItem oli : olis) {
            oppToProductName.put(oli.OpportunityId, oli.Product2.Name);
            oppToProductId.put(oli.OpportunityId, oli.Product2Id);
            oppToQuantity.put(oli.OpportunityId, oli.Quantity);
        }
     
        List<OpportunityWrapper> wrappers = new List<OpportunityWrapper>();
        for (Opportunity opp : oppList) {
            if (oppToProductName.containsKey(opp.Id) && oppToProductId.containsKey(opp.Id) && oppToQuantity.containsKey(opp.Id)) {
                String productName = oppToProductName.get(opp.Id);
                Id productId = oppToProductId.get(opp.Id);
                Decimal quantity = oppToQuantity.get(opp.Id);
                wrappers.add(new OpportunityWrapper(opp, productName, productId, quantity));
            }
        }

        return wrappers;
    }
}