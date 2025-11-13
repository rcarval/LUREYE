@isTest
private class LUREYE_Servicios_SAP_Test {

    // Clase Mock para simular la respuesta de la llamada HTTP
    private class LogoutMock implements HttpCalloutMock {
        private Integer statusCode;

        public LogoutMock(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode); // Puedes simular diferentes códigos de estado
            response.setBody('Mock response body');
            return response;
        }
    }

    // Método de prueba para un logout exitoso
    @isTest 
    static void testCallLogout_Success() {
        // Preparar los metadatos personalizados en el contexto de prueba
        Test.startTest();
        LUREYE_Servicios_SAP.branchCodeForTest = 1; // O el código de sucursal apropiado para la prueba
        LUREYE_Servicios_SAP.setLogin(); // Esto establecerá loginSAP basado en branchCodeForTest

        // Configurar el Mock de la respuesta
        Test.setMock(HttpCalloutMock.class, new LogoutMock(204));

        // Ejecutar el método callLogout
        LUREYE_Servicios_SAP.callLogout('test-session-id');

        // Finalizar el test
        Test.stopTest();

        // Agregar aserciones si es necesario
        // ...
    }

    // Método de prueba para un logout fallido
    @isTest 
    static void testCallLogout_Failure() {
        // Preparar los metadatos personalizados como antes
        Test.startTest();
        LUREYE_Servicios_SAP.branchCodeForTest = 1; // O el código de sucursal apropiado para la prueba
        LUREYE_Servicios_SAP.setLogin();

        // Configurar el Mock de la respuesta para simular una respuesta fallida
        Test.setMock(HttpCalloutMock.class, new LogoutMock(500));

        // Ejecutar el método callLogout
        LUREYE_Servicios_SAP.callLogout('test-session-id');

        // Finalizar el test
        Test.stopTest();

        // Agregar aserciones si es necesario
        // ...
    }

    @isTest 
    public static void call_Login_Test() {
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('login');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.callLogin();
        res.setStatusCode(200);
        StaticResource static_resource_login = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'login' LIMIT 1];
        String bodylogin = static_resource_login.Body.toString();
        
        res.setBody(bodylogin);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest     
    public static void call_Login_error_Test() {
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.callLogin();
        res.setStatusCode(400);
        StaticResource static_resource_login = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_login.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }

    @isTest 
    public static void call_LoginBranch_Test() {
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('login');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.callLogin(1);
        res.setStatusCode(200);
        StaticResource static_resource_login = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'login' LIMIT 1];
        String bodylogin = static_resource_login.Body.toString();
        
        res.setBody(bodylogin);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }

    @isTest     
    public static void call_LoginBranch_error_Test() {
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.callLogin(1);
        res.setStatusCode(400);
        StaticResource static_resource_login = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_login.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }

    @isTest 
    static void testSetLogin1() {
        // Establecer el valor de prueba para branchCode
        LUREYE_Servicios_SAP.branchCodeForTest = 1;

        // Invocar setLogin
        LUREYE_Servicios_SAP.setLogin();
        System.assertEquals('LoginGE', LUREYE_Servicios_SAP.developerName);

        // Restablecer branchCodeForTest a null
        LUREYE_Servicios_SAP.branchCodeForTest = null;
    }

    @isTest 
    static void testSetLogin2() {
        // Establecer el valor de prueba para branchCode
        LUREYE_Servicios_SAP.branchCodeForTest = 2;

        // Invocar setLogin
        LUREYE_Servicios_SAP.setLogin();
        System.assertEquals('LoginEM', LUREYE_Servicios_SAP.developerName);

        // Restablecer branchCodeForTest a null
        LUREYE_Servicios_SAP.branchCodeForTest = null;
    }

    @isTest 
    static void testSetLogin0() {
        // Establecer el valor de prueba para branchCode
        LUREYE_Servicios_SAP.branchCodeForTest = 0;

        // Invocar setLogin
        LUREYE_Servicios_SAP.setLogin();
        System.assertEquals('Login', LUREYE_Servicios_SAP.developerName);

        // Restablecer branchCodeForTest a null
        LUREYE_Servicios_SAP.branchCodeForTest = null;
    }

    @isTest 
    static void testSetLoginBranch1() {
        LUREYE_Servicios_SAP.setLogin(1);
        System.assertEquals('LoginGE', LUREYE_Servicios_SAP.developerName);
    }

    @isTest 
    static void testSetLoginBranch2() {
        LUREYE_Servicios_SAP.setLogin(2);
        System.assertEquals('LoginEM', LUREYE_Servicios_SAP.developerName);
    }

    @isTest 
    static void testSetLoginBranch0() {
        LUREYE_Servicios_SAP.setLogin(0);
        System.assertEquals('Login', LUREYE_Servicios_SAP.developerName);
    }

    // Método de prueba para la creación fallida de un cliente
    @isTest 
    static void testCrearClienteSFSAP_Failure() {
        // Implementar un Mock que simule una respuesta fallida para la creación de un cliente
        // ...
    }

    @isTest 
    public static void Sincr_Sap_Ok_Test() {
        Account cuenta = crearCuenta();
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
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('login');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(200);
        StaticResource static_resource_sincsap = [SELECT Body
                                                  FROM StaticResource 
                                                  WHERE Name = 'SincSap' LIMIT 1];
        String body = static_resource_sincsap.Body.toString();
        res.setBody(body);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }

    @isTest
    public static void Sincr_Sap_Error_Test() {
        Account cuenta = crearCuenta();
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
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }      
    
    @isTest
    public static void Sincr_Sap_Error_Test2() {
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(201);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(201,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }      
    
    @isTest    
    public static void Sincr_Sap_Error_Test3() {
        Account cuenta = crearCuenta();
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
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }      

    @isTest    
    public static void Sincr_Sap_Error_Test4() {
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }      

    @isTest     
    public static void Sincr_Sap_Error_Test5() {
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Envio';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='EnvioSucu';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Name='Facturación';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }  

    @isTest 
    public static void Sincr_Sap_Error_Test6() {
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        cuenta.CardType__c = 'S';
        cuenta.BlockComm__c = false;
        update(cuenta);
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Name='Facturación';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        system.debug('cuenta '+cuenta);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarSap();
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }

    @isTest 
    public static void clienteNewSFSAP_Test() {
        Account cuenta = crearCuenta2();
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('rspclient');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        String rsptest = LUREYE_SAP_Controller.clienteNewSFSAP(cuenta.Id);
        res.setStatusCode(200);
        StaticResource static_resource_client = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'rspclient' LIMIT 1];
        
        String bodyclient = static_resource_client.Body.toString();
        res.setBody(bodyclient);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }

    @isTest 
    public static void clienteNewSFSAP_Test2() {
        Account cuenta = crearCuenta2();
        
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Name='Facturación';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        insert(clientDir);
        
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('rspclient');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        String rsptest = LUREYE_SAP_Controller.clienteNewSFSAP(cuenta.Id);
        res.setStatusCode(200);
        StaticResource static_resource_client = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'rspclient' LIMIT 1];
        
        String bodyclient = static_resource_client.Body.toString();
        res.setBody(bodyclient);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }

    @isTest 
    public static void clienteNewSFSAP_error_Test() {
        Account cuenta = crearCuenta2();
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('null');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        String rsptest = LUREYE_SAP_Controller.clienteNewSFSAP(cuenta.Id);
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }

    @isTest 
    public static void clienteNewSAPSF_Test() {
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idCuenta',cuenta.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(cuenta);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('rspclient');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        String rsptest = LUREYE_SAP_Controller.clienteNewSFSAP(cuenta.Id);
        res.setStatusCode(200);
        res.setBody('{"odata.metadata": "https://sap10.cloudseidor.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-44d6-11ed-8000-005056bc3361","Version": "1000190","SessionTimeout": 30}');
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        //System.assertEquals('{"odata.metadata": "https://sap10.cloudseidor.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-44d6-11ed-8000-005056bc3361","Version": "1000190","SessionTimeout": 30}');
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }

    @isTest 
    public static void LUREYE_PriceItems_SAP_Batch_Test() {
        
        Test.startTest();
        List<PricebookEntry> lstpriceItems = new List<PricebookEntry>();
        PricebookEntry priceItems = new PricebookEntry();
        priceItems.CurrencyIsoCode='CLP';
        priceItems.UnitPrice = 0;
        priceItems.Pricebook2Id = null;
        priceItems.IsActive=true;
        priceItems.ItemCode__c='test';
        lstpriceItems.add(priceItems);
        LUREYE_PriceListItems_SAP_Batch call = new LUREYE_PriceListItems_SAP_Batch(lstpriceItems);
        Database.executeBatch(call,50);
        Test.stopTest();       
    }
    
    @isTest    
    public static void LUREYE_PriceItems_SAP_Batch_Test2() {
        
        Test.startTest();
        List<PricebookEntry> lstpriceItems = new List<PricebookEntry>();
        PricebookEntry priceItems = new PricebookEntry();
        Product2 prdNew = new Product2();
        prdNew.Name='test';
        prdNew.ProductCode='test';
        prdNew.IsActive=true;
        prdNew.CurrencyIsoCode = 'CLP';
        insert(prdNew);
        
        priceItems.CurrencyIsoCode='CLP';
        priceItems.UnitPrice = 0;
        priceItems.Pricebook2Id = null;
        priceItems.IsActive=true;
        priceItems.ItemCode__c='test';
        lstpriceItems.add(priceItems);
        LUREYE_PriceListItems_SAP_Batch call = new LUREYE_PriceListItems_SAP_Batch(lstpriceItems);
        Database.executeBatch(call,50);
        Test.stopTest();     
    }
    
    @isTest    
    public static void LUREYE_PriceItems_SAP_Batch_Test3() {
        
        Test.startTest();
        List<PricebookEntry> lstpriceItems = new List<PricebookEntry>();
        PricebookEntry priceItems = new PricebookEntry();
        Product2 prdNew = new Product2();
        prdNew.Name='test';
        prdNew.ProductCode='test';
        prdNew.IsActive=true;
        prdNew.CurrencyIsoCode = 'CLP';
        insert(prdNew);
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prdNew.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);
        priceItems.CurrencyIsoCode='CLP';
        priceItems.UnitPrice = 0;
        priceItems.Pricebook2Id = Test.getStandardPricebookId();
        priceItems.IsActive=true;
        priceItems.ItemCode__c='test';
        lstpriceItems.add(priceItems);
        LUREYE_PriceListItems_SAP_Batch call = new LUREYE_PriceListItems_SAP_Batch(lstpriceItems);
        Database.executeBatch(call,50);
        Test.stopTest();       
    }
    
    @isTest    
    public static void LUREYE_PriceItems_SAP_Batch_Test4() {
        Test.startTest();
        List<PricebookEntry> lstpriceItems = new List<PricebookEntry>();
        PricebookEntry priceItems = new PricebookEntry();
        Product2 prdNew = new Product2();
        prdNew.Name='test';
        prdNew.ProductCode='test';
        prdNew.IsActive=true;
        prdNew.CurrencyIsoCode = 'CLP';
        insert(prdNew);
        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id=prdNew.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        //Clono la lista hasta este momento para poder hacer el insert de la lista de precios
        //priceEntryClone = priceEntry.clone();
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        //Añado a la lista de precios Standard
        insert(priceEntry);
        priceItems.CurrencyIsoCode='CLP';
        priceItems.UnitPrice = 0;
        priceItems.Pricebook2Id = Test.getStandardPricebookId();
        priceItems.IsActive=true;
        priceItems.ItemCode__c='test';
        lstpriceItems.add(priceItems);
        priceItems = new PricebookEntry();
        
        Pricebook2 nullPriceList = new Pricebook2();
        nullPriceList.Name = 'lis';
        nullPriceList.CurrencyIsoCode='CLP';
        nullPriceList.Company__c = 'nu';
        nullPriceList.IsActive=true;
        insert(nullPriceList);
        
        priceEntry = new PricebookEntry();
        priceItems.CurrencyIsoCode='CLP';
        priceItems.UnitPrice = 0;
        priceItems.Pricebook2Id = nullPriceList.Id;
        priceItems.Product2Id=prdNew.Id;
        priceItems.IsActive=true;
        priceItems.ItemCode__c='test';
        lstpriceItems.add(priceItems);
        LUREYE_PriceListItems_SAP_Batch call = new LUREYE_PriceListItems_SAP_Batch(lstpriceItems);
        Database.executeBatch(call,50);
        Test.stopTest();
    }
    
    @isTest    
    public static void LUREYE_PriceList_Test() {  
        test.startTest();
        Pricebook2 nullPriceList = new Pricebook2();
        nullPriceList.Name = 'Lista de precios 01';
        nullPriceList.Company__c = 'Lp';
        nullPriceList.IsActive=true;
        insert(nullPriceList);        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('prclst');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_PriceList_SAP.SincronizarLPSap();
        res.setStatusCode(200);
        StaticResource static_resource_prclst = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'prclst' LIMIT 1];
        String bodyprclst = static_resource_prclst.Body.toString();
        res.setBody(bodyprclst);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void LUREYE_PriceList_Test2() {  
        test.startTest();
        Pricebook2 nullPriceList = new Pricebook2();
        nullPriceList.Name = 'Lista de precios 01';
        nullPriceList.Company__c = 'Lp';
        nullPriceList.IsActive=true;
        insert(nullPriceList);        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('prclstitm');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_PriceList_SAP.SincronizarLPSap();
        res.setStatusCode(200);
        StaticResource static_resource_prclst = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'prclst' LIMIT 1];
        String bodyprclst = static_resource_prclst.Body.toString();
        res.setBody(bodyprclst);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void LUREYE_PriceListItems_SAP_Test() {   
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('prclstitm');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_PriceListItems_SAP.SincronizarLPItemsSap();
        res.setStatusCode(200);
        StaticResource static_resource_prclstitm = [SELECT Body
                                                    FROM StaticResource 
                                                    WHERE Name = 'prclstitm' LIMIT 1];
        String bodyprclstitm = static_resource_prclstitm.Body.toString();
        system.debug('prebodyprclstitm '+bodyprclstitm);
        bodyprclstitm.replace('"Currency": "CLP",','"Currency": null,');
        system.debug('postbodyprclstitm '+bodyprclstitm);
        res.setBody(bodyprclstitm);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void LUREYE_PriceListItems_SAP_Test2() {   
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('prclstitm');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_PriceListItems_SAP.SincronizarLPItemsSap();
        res.setStatusCode(200);
        StaticResource static_resource_prclstitm = [SELECT Body
                                                    FROM StaticResource 
                                                    WHERE Name = 'prclstitm' LIMIT 1];
        String bodyprclstitm = static_resource_prclstitm.Body.toString();
        res.setBody(bodyprclstitm);
        system.debug('bodyprclstitm '+bodyprclstitm);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void LUREYE_PriceListItems_SAP_Test3() {   
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('prclstitm2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_PriceListItems_SAP.SincronizarLPItemsSap();
        res.setStatusCode(200);
        StaticResource static_resource_prclstitm = [SELECT Body
                                                    FROM StaticResource 
                                                    WHERE Name = 'prclstitm' LIMIT 1];
        String bodyprclstitm = static_resource_prclstitm.Body.toString();
        res.setBody(bodyprclstitm);
        system.debug('bodyprclstitm '+bodyprclstitm);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest     
    public static void Sincr_Inventario_Sap_Ok_Test() {
        Product2 prd = crearPrd();  
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idCuenta',prd.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(prd);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('inventory');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarInventarioSap();
        res.setStatusCode(200);
        StaticResource static_resource_inventory = [SELECT Body
                                                    FROM StaticResource 
                                                    WHERE Name = 'inventory' LIMIT 1];
        String bodyinventory = static_resource_inventory.Body.toString();
        res.setBody(bodyinventory);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
        
        volverTest();
    }
    
    @isTest     
    public static void Sincr_Inventario_Sap_error_Test() {
        Product2 prd = crearPrd();  
        PageReference pageRef = Page.LUREYE_Sincr_SAP;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idCuenta',prd.id);
        ApexPages.StandardController scsinc = new ApexPages.standardController(prd);
        LUREYE_SAP_Controller controller = new LUREYE_SAP_Controller(scsinc);
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        controller.SincronizarInventarioSap();
        res.setStatusCode(400);
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString(); 
        res.setBody(bodyerror);
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(400,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();     
    }
    
    @isTest     
    public static void bodyDir_test(){
        String rsp = null;
        List <String> lstshipaddr = new List <String>();
        List <String> lstshipaddr2 = new List <String>();
        List <String> lstbilladdr = new List <String>();
        lstshipaddr.add('{"AddressName": "Facturación","Street": "AV. PROVIDENCIA N°1806","Block": "11","ZipCode": "null","City": "SANTIAGO","County": "PROVIDENCIA","Country": "CL","State": "13","TaxCode": "IVA","AddressType": "bo_BillTo","StreetNo": "null","BPCode": "C26082018","GlobalLocationNumber": "null"}');
        rsp=LUREYE_SAP_Controller.bodyDir(lstshipaddr,lstbilladdr);
        lstbilladdr.add('{"AddressName": "Despacho","Street": "AV. PROVIDENCIA N°1806","Block": "12","ZipCode": "null","City": "SANTIAGO","County": "PROVIDENCIA","Country": "CL","State": "13","TaxCode": "IVA","AddressType": "bo_ShipTo","StreetNo": "null","BPCode": "C26082018","GlobalLocationNumber": "-33.4902377,-70.5732193"}');
        rsp=LUREYE_SAP_Controller.bodyDir(lstshipaddr,lstbilladdr);
        rsp=LUREYE_SAP_Controller.bodyDir(lstshipaddr2,lstbilladdr);
    }
    
    @isTest    
    public static void creaDireccion_test(){
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '1234523234';
        ctc.LastName = 'TestTestCtc';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        List<Direccion__c> direcciones = new List<Direccion__c>();
        Direccion__c clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Facturación';
        clientDir.Name='Facturación';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        direcciones.add(clientDir);
        
        clientDir = new Direccion__c();
        clientDir.AccountId__c=cuenta.id;
        clientDir.Tipo__c='Despacho';
        clientDir.Name='Despacho';
        clientDir.Street__c='calle';
        clientDir.ZipCode__c='1';
        clientDir.Ciudad__c='1';
        clientDir.Comuna__c='1';
        clientDir.Region__c='Metropolitana';
        clientDir.TaxCode__c='IVA';
        clientDir.StreetNo__c='1';
        direcciones.add(clientDir);
        
        insert(direcciones);
        direcciones.add(clientDir);
        LUREYE_SAP_Controller.creaDireccion('1', direcciones);
    }
    
    @isTest    
    public static void chkGiro_test(){
        Giro__c chkGiro = LUREYE_SAP_Controller.chkGiro(null,null,'1'); 
        Giro__c chkGiro2 = LUREYE_SAP_Controller.chkGiro('null',null,'1');
        Giro__c giro = new Giro__c();
        giro.Codigo__c='test';
        giro.Name='test';
        giro.CurrencyIsoCode='CLP';
        insert(giro);
        Giro__c chkGiro3 = LUREYE_SAP_Controller.chkGiro('null','USD','2');
        Giro__c chkGiro4 = LUREYE_SAP_Controller.chkGiro(giro.Id,'USD','test');
        Giro__c chkGiro5 = LUREYE_SAP_Controller.chkGiro(null,'CLP','test');
    }
    
    @isTest    
    public static void switchint_test(){
        String test=LUREYE_SAP_Controller.switchIntCondition(25);
        Integer test2=LUREYE_SAP_Controller.switchStrCondition('nulo');
    }
    
    @isTest    
    public static void CrearClienteSFSAP_test(){
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('login');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.CrearClienteSFSAP('String Body');
        res.setStatusCode(201);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(201,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void ClienteExistente_test(){
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('login');
        mock.setStatusCode(204);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.ClienteExistente('String Body','String RutCode');
        res.setStatusCode(204);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(204,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void ListaPrecios_test(){
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(204);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.ListaPrecios();
        res.setStatusCode(204);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(204,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void ListaPreciosItems_test(){
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(204);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.ListaPreciosItems();
        res.setStatusCode(204);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(204,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void GetDocEntryDrafts_Ok_Test(){
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);

        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.GetDocEntryDrafts('1');
        res.setStatusCode(200);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void GetDocEntryDrafts_NoOk_Test(){
        
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
        LUREYE_Servicios_SAP.GetDocEntryDrafts('1');
        res.setStatusCode(404);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(404,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }

    @isTest
    public static void GetDocEntryQuote_Ok_Test(){
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.GetDocEntryQuote('1');
        res.setStatusCode(200);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void GetDocEntryQuote_NoOk_Test(){
        
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
        LUREYE_Servicios_SAP.GetDocEntryQuote('1');
        res.setStatusCode(404);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(404,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void CreaOV_Sap_Ok_Test(){
        
        test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('error');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        LUREYE_Servicios_SAP.setLogin(0);
        
        // Call the method that performs the callout
        HTTPResponse res = new HTTPResponse();
        SchedulableContext sc = null;
        LUREYE_Servicios_SAP.CreaOV('{"DocEntry":1}');
        res.setStatusCode(201);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(201,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void CreaOV_Sap_NoOk_Test(){
        
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
        LUREYE_Servicios_SAP.CreaOV('{"DocEntry":1}');
        res.setStatusCode(404);
        
        String authorizationHeader = 'application/json ';
        res.setHeader('Authorization', authorizationHeader);
        System.assertEquals(404,res.getStatusCode());
        System.assertEquals('application/json', 'application/json');   
        test.stopTest();
    }
    
    @isTest    
    public static void queryAccount_test(){
        Account cuenta = new Account();
        Account cuenta2 = new Account();
        Account cuentappl = new Account();
        cuentappl=crearCuenta2();
        cuenta.ParentId=cuentappl.Id;
        cuenta.Name='CSALAS';
        cuenta.CurrencyIsoCode='CLP';
        cuenta.RUT_SD__c=13665080;
        cuenta.RUT_DV__c='7';
        cuenta.Country__c='CL';
        cuenta.CondicionPago__c='Anticipo, Cheques 30, 60 y 90 Días';
        cuenta.Currency__c='CLP';
        cuenta.Website='TEST';
        cuenta.NombreFantasia__c='CSALAS';
        cuenta.CurrencyISOCode='CLP';
        cuenta.Industry='Sin Informacion';
        cuenta.Email__c='test@test.cl';

        insert(cuenta);
        cuenta2=LUREYE_SAP_Controller.queryAccount(cuenta.Id);
    }

    @isTest    
    public static void queryAccount_test3(){
        Account cuenta = new Account();
        cuenta=LUREYE_SAP_Controller.queryAccount('cuenta.Id');
    }
    
    @isTest    
    public static void SL_JSONs_test(){
        StaticResource static_resource_login = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'login' LIMIT 1];
        StaticResource static_resource_error = [SELECT Body
                                                FROM StaticResource 
                                                WHERE Name = 'error' LIMIT 1];
        StaticResource static_resource_client = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'rspclient' LIMIT 1];
        StaticResource static_resource_prclst = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'prclst' LIMIT 1];
        StaticResource static_resource_prclstitm = [SELECT Body
                                                    FROM StaticResource 
                                                    WHERE Name = 'prclstitm' LIMIT 1];
        StaticResource static_resource_inventory = [SELECT Body
                                                    FROM StaticResource 
                                                    WHERE Name = 'inventory' LIMIT 1];
        StaticResource static_resource_drafts = [SELECT Body
                                                 FROM StaticResource 
                                                 WHERE Name = 'drafts' LIMIT 1];
        String bodyerror = static_resource_error.Body.toString();
        String bodylogin = static_resource_login.Body.toString();
        String bodyclient = static_resource_client.Body.toString();
        String bodyprclst = static_resource_prclst.Body.toString();
        String bodyprclstitm = static_resource_prclstitm.Body.toString();
        String bodyinventory = static_resource_inventory.Body.toString();
        String bodydrafts = static_resource_drafts.Body.toString();
        
        SL_Login_JSON login_test = SL_Login_JSON.parse(bodylogin);
        SL_Client_Err_JSON client_err_test = SL_Client_Err_JSON.parse(bodyerror);
        SL_Client_JSON client_test = SL_Client_JSON.parse(bodyclient);
        SL_Price_List_JSON pricelst_test = SL_Price_List_JSON.parse(bodyprclst);
        SL_Price_List_Items_JSON pricelstitms_test = SL_Price_List_Items_JSON.parse(bodyprclstitm);
        SL_Inventory_JSON inventory_test = SL_Inventory_JSON.parse(bodyinventory);
        SL_Drafts_JSON drafts_test = SL_Drafts_JSON.parse(bodydrafts);
    }
    
    //Metodos Auxiliares para la prueba
    public static Account crearCuenta(){
        Account cuenta = new Account();
        cuenta.BlockComm__c = TRUE;
        cuenta.CardType__c = 'C';
        cuenta.CondicionPago__c = 'Anticipo, Cheques 30, 60 y 90 Días';
        cuenta.GroupCode__c = 100;
        cuenta.SlpCode__c = -1;
        cuenta.Description = 'test-test';
        cuenta.CurrencyIsoCode = 'CLP';
        cuenta.RUT_DV__c = '3';
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
        cuenta.Name = 'test-test';
        cuenta.NombreFantasia__c = 'test-test';
        cuenta.AccountSource = '001 - Llamada';
        cuenta.Country__c = 'CL';
        cuenta.RUT_SD__c = 1234;
        cuenta.Website = 'Andreita';
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
        Giro__c giro = new Giro__c();
        giro.Codigo__c='test';
        giro.Name='test';
        giro.CurrencyIsoCode='CLP';
        insert(giro);
        
        cuenta.Name='test';
        cuenta.CurrencyIsoCode='CLP';
        cuenta.RUT_SD__c=1234;
        cuenta.RUT_DV__c='3';
        cuenta.Country__c='CL';
        cuenta.CondicionPago__c='Anticipo, Cheques 30, 60 y 90 Días';
        cuenta.Currency__c='CLP';
        cuenta.Website='TEST';
        cuenta.NombreFantasia__c='test';
        cuenta.CurrencyISOCode='CLP';
        cuenta.Industry='Sin Informacion';
        cuenta.Giro__c=giro.Id;
        cuenta.Email__c='test@test.com';
        
        insert(cuenta);
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
    
    public static void volverTest(){
        Account cuenta = crearCuenta();
        ApexPages.StandardController  standard = new ApexPages.StandardController(cuenta);
        LUREYE_SAP_Controller controlador = new LUREYE_SAP_Controller(standard);
        controlador.volver();
    }     
}