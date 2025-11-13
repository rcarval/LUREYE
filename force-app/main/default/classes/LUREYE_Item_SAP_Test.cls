@isTest
class LUREYE_Item_SAP_Test {

    @isTest
    static void test_Success_actualizaNodo() {
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name='productPrueba', ProductCode='701010126', Nodo__c='16'));
        insert products.get(0);
        
        test.startTest();
        // Mock del servicio
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('itemCode');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        List<Id> idProducts = new List<Id>();
        idProducts.add(products.get(0).Id);
        System.debug('idProducto' + idProducts );
        LUREYE_Servicios_SAP.setLogin(1);
        LUREYE_Item_SAP.actualizaNodoProducto(idProducts);
        test.stopTest();
        
    }
}