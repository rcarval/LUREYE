@isTest
private class MS_Servicios_Test {

    @isTest
    static void test_Success_obtenerNodoProducto_SAP(){
        Test.startTest();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('itemCode');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        LUREYE_Servicios_SAP.setLogin(1);        
        String nodoProducto = MS_Servicios.obtenerNodoProducto('701010126');

        System.assertEquals('16', nodoProducto);
        test.stopTest();
    }

    @isTest
    static void test_Null_obtenerNodoProducto_SAP(){
        Test.startTest();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('itemCodeUPoNoNull');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        // Call the method that performs the callout
        LUREYE_Servicios_SAP.setLogin(1);
        String nodoProducto = MS_Servicios.obtenerNodoProducto('123456');

        System.Assert.isNull(nodoProducto);
        test.stopTest();
    }
    
    @isTest
    static void test_ErrorResponse(){
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        LUREYE_Servicios_SAP.setLogin(1);
        String nodoProducto = MS_Servicios.obtenerNodoProducto('1');
        
        System.Assert.isNull(nodoProducto);
        test.stopTest();
    }
}