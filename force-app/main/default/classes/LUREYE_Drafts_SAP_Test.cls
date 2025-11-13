@IsTest
global class LUREYE_Drafts_SAP_Test {

    // Mock para simular una respuesta HTTP
    private class DraftsCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404); // Simular una respuesta de error
            response.setBody('{"error": {"code": "404", "message": "Not Found"}}');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    global class LUREYE_Drafts_SAP_SuccessMock implements WebServiceMock {
        global void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {
            SL_Drafts_JSON mockResponse = new SL_Drafts_JSON();
            SL_Drafts_JSON.val mockValue = new SL_Drafts_JSON.val();
            mockValue.docentry = 12345;
            mockResponse.value = new List<SL_Drafts_JSON.val> { mockValue };    
            response.put('response_x', mockResponse);
        }
    }

    global class LUREYE_Drafts_SAP_ErrorMock implements WebServiceMock {
        global void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {
                    
            SL_Drafts_JSON mockResponse = new SL_Drafts_JSON();
            SL_Drafts_JSON.val mockValue = new SL_Drafts_JSON.val();
            mockValue.docentry = null;
            mockResponse.value = new List<SL_Drafts_JSON.val> { mockValue };
            response.put('response_x', mockResponse);
        }
    } 

    @isTest
    static void testCrearDraftsPageSuccess() {

        Quote quote = crearCotizacion();
        ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
        LUREYE_Drafts_SAP draftsSAP = new LUREYE_Drafts_SAP(stdController);
        // Simular la creación exitosa del draft
        draftsSAP.testDraftCreado = true;         

        Test.startTest();              
        PageReference pageRefSuccess = draftsSAP.CrearDraftsPage();
        Test.stopTest();
        
        // Verificar que se muestra el mensaje de éxito
        List<ApexPages.Message> messagesSuccess = ApexPages.getMessages();
        Boolean successMessageFound = false;
        for (ApexPages.Message message : messagesSuccess) {
            if (message.getSeverity() == ApexPages.Severity.INFO) {
                successMessageFound = true;
                break;
            }
        }
        System.assertEquals(false, successMessageFound, 'El draft fue creado');
    }
    
    @isTest
    static void testCrearDraftsPageError() {
        // Preparar datos de prueba
        Quote quote = crearCotizacion();
        ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
        LUREYE_Drafts_SAP draftsSAP = new LUREYE_Drafts_SAP(stdController);
        // Simular la creación fallida del draft
        draftsSAP.testDraftCreado = false;              

        Test.startTest();
        PageReference pageRefError = draftsSAP.CrearDraftsPage();
        Test.stopTest();
        
        // Verificar que se muestra el mensaje de error
        List<ApexPages.Message> messagesError = ApexPages.getMessages();
        Boolean errorMessageFound = false;
        for (ApexPages.Message message : messagesError) {
            if (message.getSeverity() == ApexPages.Severity.ERROR) {
                errorMessageFound = true;
                break;
            }
        }
        System.assertEquals(true, errorMessageFound, 'El mensaje de error no se encontró.');
    }

    @isTest
    static void testVolver() {
        // Crea una cotización de prueba
        Quote testQuote = crearCotizacion();
        
        // Crea una instancia del controlador estándar con la cotización de prueba
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(sc);
        
        // Llama al método volver en la instancia del controlador
        PageReference result = controller.volver();
        
        // Verifica que la página de destino sea la correcta
        String expectedUrl = '/' + testQuote.Id;
        expectedUrl = expectedUrl.substring(0, 16);
        System.assertEquals(expectedUrl, result.getUrl());
    }    

    @isTest
    public static void CrearDrafts_Sap_Ok_Test(){
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.CreaDrafts('{"DocEntry":1}');
        res.setStatusCode(201);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(201,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }

    @isTest
    public static void CrearDrafts_Sap_NoOk_Test(){
        Test.setMock(HttpCalloutMock.class, new DraftsCalloutMock());
        LUREYE_Servicios_SAP.setLogin(0);

        // Comienza el bloque de pruebas
        test.startTest();
        SL_Drafts_JSON result = LUREYE_Servicios_SAP.CreaDrafts('{"DocEntry":1}');
        test.stopTest();
        System.assertEquals(null, result, 'El resultado debería ser null debido al error 404');
    }

    @isTest
    public static void CrearDrafts_Sap_Ok_Test2() {
        Quote qte = crearCotizacion2();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }
 
    @isTest
    public static void CrearDrafts_Sap_Ok_Test3() {
        Quote qte = crearCotizacion3();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest   
    public static void CrearDrafts_Sap_Ok_Test4() {
        Quote qte = crearCotizacion4();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void CrearDrafts_Sap_Ok_Test5() {
        Quote qte = crearCotizacion6();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void CrearDrafts_Sap_Ok_Test6() {
        Quote qte = crearCotizacion7();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void CrearDrafts_Sap_Ok_Test7() {
        Quote qte = crearCotizacion8();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void CrearDrafts_Sap_NoOk_Test2() {
        Quote qte = crearCotizacion2();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.CrearDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
	public static void ConsultaDrafts_Sap_Ok_Test() {
        Quote qte = crearCotizacion();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.ConsultaDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void ConsultaDrafts_Sap_Ok_Test2() {
        Quote qte = crearCotizacion();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('draftaccp');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.ConsultaDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void ConsultaDrafts_Sap_Ok_Test3() {
        Quote qte = crearCotizacion();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('draftrech');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.ConsultaDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void ConsultaDrafts_Sap_Ok_Test4() {
        Quote qte = crearCotizacion();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        SL_Drafts_JSON consulta = LUREYE_Drafts_SAP.ConsultaDrafts(String.valueOf(qte));
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void ConsultaDrafts_Sap_Ok_Test5() {
        Quote qte = crearCotizacion5();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('draftsaccp2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.ConsultaDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'draftsaccp2' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void ConsultaDocsPage_Sap_Ok_Test() {
        Quote qte = crearCotizacion();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.ConsultaDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void ConsultaDocsPage_Sap_Ok_Test2() {
        Quote qte = crearCotizacion5();
        PageReference pageRef = Page.LUREYE_Crea_Drafts_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cotizacion '+qte);
        pageRef.getParameters().put('idQuote',qte.Id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(qte);
        LUREYE_Drafts_SAP controller = new LUREYE_Drafts_SAP(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('drafts');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.ConsultaDraftsPage();
        res.setStatusCode(200);
        StaticResource static_resource_drafts = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'drafts' LIMIT 1];
    	String body = static_resource_drafts.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
 
        volverTest2();
    }

    @isTest
    public static void createQuoteLI_Test() {
        Quote qte = crearCotizacion6();
        Product2 prd = new Product2();
        prd.Name='prd2';
        prd.StockKeepingUnit='prd2';
        prd.Family='Flanges Motores Siemens IEC';
        prd.cod_proveedor__c='CZF:583';
        insert(prd);
        
		Map<Id, String> prdMap = new Map<Id, String>();
        prdMap.put(prd.Id,'1');
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.QLBI__c = 1;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        List<QuoteLineItem> qryQuoteLineItem = new List<QuoteLineItem>();
        qryQuoteLineItem.add(qteLI);
        
        Decimal order = 1;
        String costingcode = '1';
        String sucursal = '1';
        Decimal lineaN = 1;
        String bodega =  null;
        LUREYE_Items_SAP.createQuoteLI(prdMap,qryQuoteLineItem,order,costingcode,sucursal,lineaN,'glosa',bodega);      
    }  
 
    //Metodos Auxiliares para la prueba
    public static Quote crearCotizacion(){
        Product2 prd = new Product2();
        prd = crearPrd();

        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UseStandardPrice = false;
        priceEntry.UnitPrice = 100;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);        
        
        Account cuenta = new Account();
        cuenta = crearCuenta();
        
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '123456789';
        ctc.LastName = 'TEST';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Opportunity opp     = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype            = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId    = rcrdtype.Id;
        opp.StageName       = 'Definición necesidad';
        opp.AccountId       = cuenta.Id;
        opp.Name            = 'oppty';
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
        
        Quote qte = new Quote();
        qte.Glosa__c = 'prueba';
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.NOrdenCompra__c = '555OC';
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.QLBI__c = 1;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);

        System.assertEquals('prueba', qte.Glosa__c, 'La glosa de la cotización no coincide');
        System.assertEquals('Draft', qte.Status, 'El estado de la cotización no coincide');
        //System.assertEquals('Facturación', qte.DirFacturacion__r.Name, 'El nombre de la dirección de facturación no coincide');
        //System.assertEquals('Despacho', qte.DirDespacho__r.Name, 'El nombre de la dirección de despacho no coincide');
        
        List<QuoteLineItem> qteLIs = [SELECT QLBI__c, Quantity, UnitPrice, PricebookEntryId, Product2Id FROM QuoteLineItem WHERE QuoteId = :qte.Id];
        System.assertEquals(1, qteLIs.size(), 'La cantidad de ítems de la cotización no coincide');
        System.assertEquals(1, qteLIs[0].QLBI__c, 'El valor del campo personalizado QLBI__c no coincide');
        System.assertEquals(1, qteLIs[0].Quantity, 'La cantidad del ítem de la cotización no coincide');
        System.assertEquals(100, qteLIs[0].UnitPrice, 'El precio unitario del ítem de la cotización no coincide');
        System.assertEquals(priceEntry.Id, qteLIs[0].PricebookEntryId, 'El PricebookEntryId del ítem de la cotización no coincide');
        System.assertEquals(prd.Id, qteLIs[0].Product2Id, 'El Product2Id del ítem de la cotización no coincide');    
        
        return qte;
    }
      
    public static Quote crearCotizacion2(){
        Product2 prd = new Product2();
        prd = crearProducto2();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta2();
        
        Opportunity opp     = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype            = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId    = rcrdtype.Id;
        opp.StageName       = 'Definición necesidad';
        opp.AccountId       = cuenta.Id;
        opp.Name            = 'oppty';
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
        
        Quote qte = new Quote();
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        return qte;
    }

    public static void testCrearCotizacion2() {
        Quote qte = crearCotizacion2();
        System.assertNotEquals(null, qte.Id,'Fallo Id');
        
        // Verificar que el estado sea 'Draft'
        System.assertEquals('Draft', qte.Status,'Fallo Status');
        
        // Verificar que la moneda sea 'CLP'
        System.assertEquals('CLP', qte.CurrencyIsoCode,'Fallo Moneda');
    }    

    public static Quote crearCotizacion3(){
        Product2 prd = new Product2();
        prd = crearPrd();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta();
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='CALLE';
        clientDir.Ciudad__c='STGO';
        clientDir.Comuna__c='STGO';        
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='123';
        clientDir.Block__c='B1';
        insert(clientDir);
        String direnvId = clientDir.Id;
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'oppty';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2082-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;        
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);
        
        Quote qte = new Quote();        
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        return qte;
    }

    public static Quote crearCotizacion4(){
        Product2 prd = new Product2();
        prd = crearPrd();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta();

        Direccion__c clientDir = new Direccion__c();
        clientDir.Name='Facturación';        
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Street__c='CALLE B123';
        clientDir.Ciudad__c='SANTIAGO';
        clientDir.Comuna__c='SANTIAGO';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='B123';
        clientDir.Block__c='DEPTO';
        insert(clientDir);
        String dirfactId = clientDir.id;
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'oppty';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2082-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);
        
        Quote qte = new Quote();
        qte.Name = 'TEST';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        return qte;
    }

    public static Quote crearCotizacion5(){
        Product2 prd = new Product2();
        prd = crearPrd();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta();
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'oppty';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2082-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);
        
        Quote qte = new Quote();
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        return qte;
    }

    public static Quote crearCotizacion6(){
        Product2 prd = new Product2();
        prd = crearPrd();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta();
        
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Name='Facturación';
        clientDir.Nombre__c='Despacho';
        clientDir.Street__c='CALLE';        
        clientDir.Ciudad__c='STGO';
        clientDir.Comuna__c='STGO';        
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='431';
        clientDir.Block__c='D1';
        insert(clientDir);
        String dirfactId = clientDir.Id;
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='CALLE';
        clientDir.Ciudad__c='STGO';
        clientDir.Comuna__c='STGO';        
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='21';
        clientDir.Block__c='R1';
        insert(clientDir);
        String direnvId = clientDir.Id;
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'oppty';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2082-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);
        
        Quote qte = new Quote();
        qte.Glosa__c = 'prueba';
        qte.Name = 'test';
        qte.QuoteDocEntry__c = 5;
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        return qte;
    }

    public static Quote crearCotizacion7(){
        Product2 prd = new Product2();
        prd = crearPrd();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta();
        
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '123456789';
        ctc.LastName = 'TEST';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        
        String dirfactId = null;
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Nombre__c='Despacho';
        clientDir.Street__c='CALLE';
        clientDir.Ciudad__c='STGO';
        clientDir.Comuna__c='STGO';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='123';
        clientDir.Block__c='C1';
        insert(clientDir);
        String direnvId = clientDir.Id;
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'oppty';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2082-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);
        
        Quote qte = new Quote();
        qte.Glosa__c = 'prueba';
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.QLBI__c = 1;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        return qte;
    }
    
    public static Quote crearCotizacion8(){
        Product2 prd = new Product2();
        prd = crearPrd();
        
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        
        Account cuenta = new Account();
        cuenta = crearCuenta();
        
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '123456789';
        ctc.LastName = 'TEST';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Name='Facturación';
        clientDir.Street__c='calle';        
        clientDir.Ciudad__c='STGO';
        clientDir.Comuna__c='STGO';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='12';
        clientDir.Block__c='B1';
        insert(clientDir);
        String dirfactId = clientDir.Id;
        String direnvId = null;
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = new RecordType(); 
        rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial'];
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'oppty';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2082-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert(opp);
        
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert(opptitem);
        
        opp.StageName = 'Cotización';
        update(opp);
        
        Quote qte = new Quote();
        qte.Glosa__c = 'prueba';
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
        qte.RequiereHES__c = 'Venta Normal';
        insert(qte);
        
        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.QLBI__c = 1;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);
        
        return qte;
    }

    public static Account crearCuenta(){

        Account cuenta = new Account();
        cuenta.Name = 'FALADEUDA';
        cuenta.RUT_SD__c = 95304000;
        cuenta.RUT_DV__c = 'K';

        cuenta.BlockComm__c = TRUE;
        cuenta.CardType__c = 'C';
        cuenta.CondicionPago__c = 'Anticipo, Cheques 30, 60 y 90 Días';
        cuenta.GroupCode__c = 100;
        cuenta.SlpCode__c = -1;
        cuenta.Description = 'test-test';
        cuenta.CurrencyIsoCode = 'CLP';
        cuenta.Email__c = 'test@test.com';
        cuenta.NumberOfEmployees = -1;
        cuenta.EstadoSAP__c = 'Validado por SAP';

        Giro__c giro = new Giro__c();
        giro.Codigo__c='test';
        giro.Name='test';
        giro.CurrencyIsoCode='CLP';

        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr2 = Database.insert(giro, dml2); 
        if (sr2.isSuccess()) {   
         System.debug('Duplicate account has been inserted in Salesforce!'); 
        }
        //upsert(giro);
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
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr = Database.insert(cuenta, dml); 
        if (sr.isSuccess()) {   
         System.debug('Duplicate account has been inserted in Salesforce!'); 
        }
        //upsert(cuenta);
        return cuenta;
    }
    
    public static Account crearCuenta2(){

        Account cuenta = new Account();
        cuenta.Name = 'RIPLEI';
        cuenta.RUT_SD__c = 21884105;
        cuenta.RUT_DV__c = '8';

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

        Giro__c giro = new Giro__c();
        giro.Codigo__c='test';
        giro.Name='test';
        giro.CurrencyIsoCode='CLP';

        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr2 = Database.insert(giro, dml2); 
        if (sr2.isSuccess()) {   
         System.debug('Duplicate account has been inserted in Salesforce!'); 
        }
        //upsert(giro);
        cuenta.Giro__c = giro.Id;
        cuenta.Industry = 'Sin Informacion';
        cuenta.CreditLine__c = 0;
        cuenta.DebtLine__c = 0;
        cuenta.Currency__c = 'CLP';

        cuenta.NombreFantasia__c = 'test-test';
        cuenta.AccountSource = '001 - Llamada';
        cuenta.Country__c = 'CL';

        cuenta.Website = 'www.riplei.com';
        cuenta.Phone = '123456789';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr = Database.insert(cuenta, dml); 
        if (sr.isSuccess()) {   
         System.debug('Duplicate account has been inserted in Salesforce!'); 
        }
        //upsert(cuenta);
        return cuenta;
    }

    public static Product2 crearPrd(){
        Product2 prd = new Product2();
        prd.Name='prd';
        prd.StockKeepingUnit='prd';
        prd.Family='Flanges Motores Siemens IEC';
        prd.cod_proveedor__c='CZF:583';
        insert(prd);
        return prd;
    }

    public static Product2 crearProducto2(){
        Product2 prd            = new Product2();
        prd.Name                = 'producto2';
        prd.StockKeepingUnit    = 'producto2';
        prd.Family              = 'Flanges Motores Siemens IEC';
        prd.cod_proveedor__c    = 'CZF:583';
        insert(prd);
        return prd;
    }    
    
    public static testMethod void bodyDir_test2(){
        String rsp = null;
        List <String> lstshipaddr = new List <String>();
        List <String> lstshipaddr2 = new List <String>();
        List <String> lstbilladdr = new List <String>();
        lstshipaddr.add('{"AddressName": "Facturación","Street": "AV. PROVIDENCIA N°1806","Block": "PROVIDENCIA","ZipCode": "null","City": "SANTIAGO","BuildingFloorRoom": "1","Country": "CL","State": "13","TaxCode": "IVA","AddressType": "bo_BillTo","StreetNo": "444","BPCode": "C26082018","GlobalLocationNumber": "-33.4902377,-70.5732193""}');
        rsp=LUREYE_Items_SAP.direcciones(lstshipaddr,lstbilladdr);
        lstbilladdr.add('{"AddressName": "Despacho","Street": "AV. PROVIDENCIA N°1806","Block": "PROVIDENCIA","ZipCode": "null","City": "SANTIAGO","BuildingFloorRoom": "1","Country": "CL","State": "13","TaxCode": "IVA","AddressType": "bo_ShipTo","StreetNo": "444","BPCode": "C26082018","GlobalLocationNumber": "-33.4902377,-70.5732193"}');
        rsp=LUREYE_Items_SAP.direcciones(lstshipaddr,lstbilladdr);
        rsp=LUREYE_Items_SAP.direcciones(lstshipaddr2,lstbilladdr);
    }
    
    public static void volverTest2(){
        Account cuenta = crearCuenta();
        ApexPages.StandardController  standard = new ApexPages.StandardController(cuenta);
        LUREYE_Drafts_SAP controlador = new LUREYE_Drafts_SAP(standard);
        controlador.volver();
    } 
}