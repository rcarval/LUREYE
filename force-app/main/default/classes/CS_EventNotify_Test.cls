@IsTest
public class CS_EventNotify_Test {
    // Clase Mock para simular la respuesta HTTP
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }

    @testSetup
    static void setupData() {
        // Crear y insertar Giro (si es necesario)
        Giro__c giro = new Giro__c();
        giro.Codigo__c = 'test';
        giro.Name = 'test';
        giro.CurrencyIsoCode = 'CLP';
        insert giro;

        // Crear y insertar Cuenta
        Account cuenta = new Account();
        cuenta.Name = 'FALADEUDA';
        cuenta.RUT_SD__c = 8569880;
        cuenta.RUT_DV__c = 'K';
        cuenta.BlockComm__c = TRUE;
        cuenta.CardType__c = 'C';
        cuenta.CondicionPago__c = 'Contado';
        cuenta.GroupCode__c = 100;
        cuenta.SlpCode__c = -1;
        cuenta.Description = 'test-test';
        cuenta.CurrencyIsoCode = 'CLP';
        cuenta.Email__c = 'test@test.com';
        cuenta.NumberOfEmployees = -1;
        cuenta.EstadoSAP__c = 'Validado por SAP';
        cuenta.Giro__c = giro.Id;
        cuenta.Industry = 'Sin Informacion';
        cuenta.CreditLine__c = 0;
        cuenta.DebtLine__c = 0;
        cuenta.Currency__c = 'CLP';
        cuenta.NombreFantasia__c = 'test-test';
        cuenta.AccountSource = '001 - Llamada';
        cuenta.Country__c = 'CL';
        cuenta.Website = 'www.faladeuda.com';
        cuenta.Phone = '123456789';
        insert cuenta;

        // Crear y insertar Producto
        Product2 prd = new Product2();
        prd.Name = 'prd';
        prd.StockKeepingUnit = 'prd';
        prd.Family = 'Flanges Motores Siemens IEC';
        prd.cod_proveedor__c = 'CZF:583';
        insert prd;

        // Crear y insertar PricebookEntry
        PricebookEntry priceEntry = new PricebookEntry();
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UseStandardPrice = false;
        priceEntry.UnitPrice = 100;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert priceEntry;

        // Crear y insertar Contacto asociado a la cuenta
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '123456789';
        ctc.LastName = 'TEST';
        ctc.AccountId = cuenta.id;
        insert ctc;

        // Crear una Cotización correcta
        Opportunity opp     = new Opportunity();
        opp.Name            = 'Oportunidad EventNotify';      
        opp.StageName       = 'Definición necesidad';
        opp.AccountId       = cuenta.Id;
        opp.Pricebook2Id    = Test.getStandardPricebookId();
        opp.CloseDate       = Date.valueOf('2030-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);        
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);     
        
        // Crear un nuevo usuario activo para ser utilizado como propietario
        User usr = new User();
        usr.Alias = 'standt';
        usr.Email = 'standarduser@testorg.com';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LastName = 'Testing';
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';
        // Asignar el perfil "10 - Vendedor"
        Profile vendedorProfile = [SELECT Id FROM Profile WHERE Name = '10 - Vendedor' LIMIT 1];
        usr.ProfileId = vendedorProfile.Id;
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        // Generar un UserName único
        DateTime now = DateTime.now();
        String uniqueUsername = 'standarduser' + now.getTime() + '@testorg.com';
        usr.UserName = uniqueUsername;
        usr.IsActive = true;
        usr.Negocio__c = '10000 TRANSACCIONAL';
        insert(usr);

        Quote qte = new Quote();        
        qte.Name = 'Oportunidad EventNotify';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Approved';        
        qte.Glosa__c = 'prueba';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.NOrdenCompra__c = '555OC';
        qte.Estado_en_SAP__c = 'Documento Pendiente';
        qte.DocEntry__c = 1234;
        qte.OVDocNum__c = 1111;        
        qte.OwnerId = usr.Id;
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.QLBI__c = 500;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);

        // Crear una Cotización incorrecta
        Opportunity opp2     = new Opportunity();
        opp2.Name            = 'Oportunidad EventNotify Fallida';
        opp2.StageName       = 'Definición necesidad';
        opp2.AccountId       = cuenta.Id;
        opp2.Pricebook2Id    = Test.getStandardPricebookId();
        opp2.CloseDate       = Date.valueOf('2050-12-10');
        opp2.CurrencyIsoCode = 'CLP';
        insert(opp2);
        
        OpportunityLineItem opptitem2 = new OpportunityLineItem();
        opptitem2.Product2Id = prd.Id;
        opptitem2.Quantity = 1;
        opptitem2.OpportunityId = opp2.Id;
        insert(opptitem2);
        
        opp2.StageName = 'Cotización';
        update(opp2);
        
        Quote qte2 = new Quote();
        qte2.Name = 'Cotización EventNotify Fallida';
        qte2.Glosa__c = 'prueba';
        qte2.OpportunityId = opp.id;
        qte2.CurrencyIsoCode = 'CLP';
        qte2.Status = 'Draft';
        qte2.CondicionPago__c = 'Contado';
        qte2.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte2.NOrdenCompra__c = '555OC';
        qte2.RequiereHES__c = 'Venta Normal';
        insert(qte2);
        
        QuoteLineItem qteLI2 = new QuoteLineItem();
        qteLI2.QLBI__c = 500;
        qteLI2.Quantity = 1;
        qteLI2.QuoteId = qte2.Id;
        qteLI2.UnitPrice = 100;
        qteLI2.PricebookEntryId = priceEntry.Id;
        qteLI2.Product2Id = prd.Id;
        insert(qteLI2);        
    }

    @isTest 
    static void testGetStatusQuote_Success() {
        // Crea los datos de prueba necesarios
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Oportunidad EventNotify' LIMIT 1];
        quote.ovDocEntry__c = 5678;
        quote.OVDocNum__c   = 1111;
    
        // Crea una instancia de CS_EventNotify
        SL_Login_JSON login_c = new SL_Login_JSON();
        login_c.sessionId = 'e413fb8e-61';
    
        // Establece el resultado esperado de la llamada HTTP
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"value":[{"DocEntry":1234,"CANCELED":"N","DocStatus":"O","WddStatus":"Y"}]}');
    
        // Simula la llamada HTTP en un entorno de prueba
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
    
        // Llama al método a probar
        CS_EventNotify en = new CS_EventNotify();
        String status = en.getStatusQuote('123');
        Test.stopTest();
    
        // Verifica los resultados esperados
        System.assertNotEquals(null, status, 'El estado no debe ser nulo');
        // Asegúrate de adaptar el siguiente assertion de acuerdo a la lógica de tu método getStatusQuote
        System.assertEquals('Documento Pendiente', status, 'El estado no se ha actualizado correctamente');
    }    

    @isTest
    static void testGetListStatus_Success() {
        // Crea los datos de prueba necesarios
        List<Quote> quotes = new List<Quote>();
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Oportunidad EventNotify' LIMIT 1];
        quote.ovDocEntry__c = 5678;
        quote.OVDocNum__c   = 1111;
        quotes.add(quote);
    
        SL_Login_JSON login_c = (SL_Login_JSON) JSON.deserialize(
            '{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',
            SL_Login_JSON.class);
    
        // Establece el resultado esperado de la llamada HTTP
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"value":[{"DocEntry":5678,"CANCELED":"N","DocStatus":"O","WddStatus":"Y"}, {"DocEntry":1234,"CANCELED":"N","DocStatus":"O","WddStatus":"Y"}]}');
    
        // Simula la llamada HTTP en un entorno de prueba
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
   
        SL_EstadosQuery_JSON statusList = CS_EventNotify.getListStatus(login_c);
        Test.stopTest();
    
        // Verifica los resultados esperados
        System.assertNotEquals(null, statusList, 'El mapa de estados no debe ser nulo');

        // Primero, verifica que la lista de "value" en "statusList" tiene los dos elementos esperados.
        System.assertEquals(2, statusList.value.size(), 'La lista de estados debe tener dos elementos');

        // Ahora verifica el primer elemento de la lista
        SL_EstadosQuery_JSON.Value firstStatus = statusList.value[0];
        System.assertEquals(5678, firstStatus.DocEntry, 'El DocEntry de la primera cotización no se ha actualizado correctamente');
        System.assertEquals('O', firstStatus.DocStatus, 'El DocStatus de la primera cotización no se ha actualizado correctamente');
        System.assertEquals(null, firstStatus.OVDocNum, 'El OVDocNum de la primera cotización no se ha actualizado correctamente');
        System.assertEquals('N', firstStatus.CANCELED, 'El campo CANCELED de la primera cotización no se ha actualizado correctamente');
        System.assertEquals('Y', firstStatus.WddStatus, 'El WddStatus de la primera cotización no se ha actualizado correctamente');

        // Ahora verifica el segundo elemento de la lista
        SL_EstadosQuery_JSON.Value secondStatus = statusList.value[1];
        System.assertEquals(1234, secondStatus.DocEntry, 'El DocEntry de la segunda cotización no se ha actualizado correctamente');
        System.assertEquals('O', secondStatus.DocStatus, 'El DocStatus de la segunda cotización no se ha actualizado correctamente');
        System.assertEquals(null, secondStatus.OVDocNum, 'El OVDocNum de la segunda cotización no se ha actualizado correctamente');
        System.assertEquals('N', secondStatus.CANCELED, 'El campo CANCELED de la segunda cotización no se ha actualizado correctamente');
        System.assertEquals('Y', secondStatus.WddStatus, 'El WddStatus de la segunda cotización no se ha actualizado correctamente');
    }
    
    @isTest
    static void testGetOVDocNum_Success() {
        // Crea los datos de prueba necesarios
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Oportunidad EventNotify' LIMIT 1];
        quote.ovDocEntry__c = 5678;
    
        SL_Login_JSON login_c = (SL_Login_JSON) JSON.deserialize(
            '{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',
            SL_Login_JSON.class);
    
        // Establece el resultado esperado de la llamada HTTP
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"value":[{"DocEntry":5678,"DocNum":9999,"CANCELED":"N","DocStatus":"O","WddStatus":"Y"}]}');
    
        // Simula la llamada HTTP en un entorno de prueba
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
    
        // Llama al método a probar
        SL_EstadosQuery_JSON OVDocNum = CS_EventNotify.getOVDocNum((Integer)quote.ovDocEntry__c, login_c);
        Test.stopTest();
    
        // Verifica los resultados esperados
        System.assertNotEquals(null, OVDocNum, 'OVDocNum no debería ser nulo');
        System.assertEquals(9999, OVDocNum.value[0].DocNum, 'OVDocNum no se ha actualizado correctamente');
    }
    
    @isTest
    static void testPostDraftToDocument_Success() {
        // Crea los datos de prueba necesarios
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Oportunidad EventNotify' LIMIT 1];
        quote.ovDocEntry__c = 5678;
        quote.OVDocNum__c = 1111;
    
        SL_Login_JSON login_c = (SL_Login_JSON) JSON.deserialize(
            '{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',
            SL_Login_JSON.class);
    
        // Establece el resultado esperado de la llamada HTTP
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"value":[{"DocEntry":5678,"DocNum":9999,"CANCELED":"N","DocStatus":"O","WddStatus":"Y"}]}');
    
        // Simula la llamada HTTP en un entorno de prueba
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
    
        // Llama al método a probar
        CS_EventNotify.postDraftToDocument((Integer)quote.ovDocEntry__c, login_c);
        Test.stopTest();
    
        // Verifica los resultados esperados
        System.assertNotEquals(null, quote.ovDocEntry__c, 'ovDocEntry__c no debería ser nulo');
        System.assertEquals(5678, quote.ovDocEntry__c, 'ovDocEntry__c no se ha actualizado correctamente');
        System.assertEquals(1111, quote.OVDocNum__c, 'OVDocNum__c no se ha actualizado correctamente');
    }    

    @IsTest
    static void testGetOnlyStatusQuote_DocumentoPendiente() {
        String status = CS_EventNotify.getOnlyStatusQuote(null, 'N', 'C', 'N');
        System.assertEquals('Documento Pendiente', status, 'El estado debería ser Documento Pendiente');
    }

    @IsTest
    static void testGetOnlyStatusQuote_OrdenVentaCancelada() {
        String status = CS_EventNotify.getOnlyStatusQuote(1, 'Y', 'O', 'Y');
        System.assertEquals('Orden de Venta Cancelada', status, 'El estado debería ser Orden de Venta Cancelada');
    }

    @IsTest
    static void testGetOnlyStatusQuote_OrdenVentaCreada() {
        String status = CS_EventNotify.getOnlyStatusQuote(1, 'N', 'O', 'N');
        System.assertEquals('Orden de Venta Creada', status, 'El estado debería ser Orden de Venta Creada');
    }

    @IsTest
    static void testGetOnlyStatusQuote_DocumentoRechazado() {
        String status = CS_EventNotify.getOnlyStatusQuote(null, 'N', 'O', 'N');
        System.assertEquals('Documento Rechazado', status, 'El estado debería ser Documento Rechazado');
    }

    @IsTest
    static void testGetOnlyStatusQuote_DocumentoCancelado() {
        String status = CS_EventNotify.getOnlyStatusQuote(null, 'N', 'O', 'C');
        System.assertEquals('Documento Cancelado', status, 'El estado debería ser Documento Cancelado');
    }

    @IsTest
    static void testGetOnlyStatusQuote_DocumentoAutorizado() {
        String status = CS_EventNotify.getOnlyStatusQuote(null, 'N', 'O', 'Y');
        System.assertEquals('Documento Autorizado', status, 'El estado debería ser Documento Autorizado');
    }
}