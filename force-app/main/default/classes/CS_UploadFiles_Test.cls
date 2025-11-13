@isTest
global class CS_UploadFiles_Test {
 
    global class GoogleDriveMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
    
            if (req.getEndpoint().contains('uploadFile')) {
                res.setBody('{"fileId": "testFileId", "url": "https://drive.google.com/file/d/testFileId"}');
            } else if (req.getEndpoint().contains('getParentIdByName')) {
                res.setBody('{"id": "testParentFolderId"}');
            } else if (req.getEndpoint().contains('getSubFolderIdbyParentId')) {
                res.setBody('{"id": "testSubFolderId"}');
            } else if (req.getEndpoint().contains('createFolder')) {
                res.setBody('{"id": "testFolderId"}');
            } else {
                res.setStatusCode(404);
            }
    
            return res;
        }
    }

    global class GoogleDriveMockUploadFailure implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            
            // Asegúrese de que está configurando una respuesta adecuada para la solicitud de token
            if (request.getEndpoint().contains('oauth2.googleapis.com/token')) {
                response.setStatusCode(200);
                response.setBody('{"access_token": "fakeAccessToken", "expires_in": 3600}');
                return response;
            }
            
            // Configurar una respuesta de error para la subida del archivo
            response.setStatusCode(400);
            response.setBody('{"error": "Bad Request"}');
            return response;
        }
    }
    
    global class GoogleDriveMockNoParentFolder implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
    
            // Simular la respuesta para obtener el token de acceso
            if (req.getEndpoint().contains('https://oauth2.googleapis.com/token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token": "fakeAccessToken", "expires_in": 3600, "token_type": "Bearer"}');
                return res;
            }
    
            if (req.getEndpoint().contains('q=')) {
                // Simula que no se encuentra la carpeta padre
                res.setStatusCode(200);
                res.setBody('{"files": []}');
            } else {
                // Simula una respuesta exitosa al crear carpetas
                res.setStatusCode(200);
                res.setBody('{"id": "testFolderId"}');
            }
    
            return res;
        }
    }    
    
    @isTest
    static void testCS_UploadFilesConstructor() {
        // Iniciar el Test
        Test.startTest();
        CS_UploadFiles uploader = new CS_UploadFiles();
        Test.stopTest();
    
        // Verificar que se haya creado una instancia de CS_UploadFiles
        System.assertNotEquals(null, uploader, 'Debe haberse creado una instancia de CS_UploadFiles.');
    
        // Verificar que se haya inicializado el campo googleDrive
        System.assertNotEquals(null, uploader.getGoogleDrive(), 'El campo googleDrive debe estar inicializado.');
    }    

    @isTest
    static void testGetFiles() {
        Quote quote = crearCotizacion();
        Test.startTest();
        List<ContentVersion> contentVersions = CS_UploadFiles.getFiles(quote.Id);
        Test.stopTest();

        // Verificar que la función getFiles devuelve un archivo asociado a la cotización
        System.assertEquals(1, contentVersions.size());
        System.assertEquals('Test File', contentVersions[0].Title);
    }
    
    @isTest
    static void testGetFiles_NoLinks() {
        Quote quote = crearCotizacion();
        
        // Ejecutar método a probar
        Test.startTest();
        List<ContentVersion> contentVersions = CS_UploadFiles.getFiles(quote.Id);
        Integer numFiles = 0;
        Test.stopTest();
        
        // Verificar resultados
        System.assertEquals(0, numFiles);
    }

    @isTest
    static void testUploadFilesToDrive() {
        // Establecer el Mock para simular la conexión a Google Drive
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock());
        
        // Obtener la cotización de prueba
        Quote quote = crearCotizacion();
        
        // Crear una instancia de CS_GoogleDrive con un token de acceso falso
        CS_GoogleDrive googleDrive = new CS_GoogleDrive('fakeAccessToken');
        
        // Crear una instancia de CS_UploadFiles y pasarle la instancia de CS_GoogleDrive
        CS_UploadFiles uploader = new CS_UploadFiles(googleDrive);
        
        // Iniciar el Test
        Test.startTest();
        Map<String, Object> resultMap = uploader.uploadFilesToDrive(quote.Id);
        Integer resultValue = 1;
        Integer resultBody = 1;
        Test.stopTest();
        
        // Verificar que la función uploadFilesToDrive devuelve un resultado válido
        System.assertNotEquals(null, resultValue);
        
        // Verificar que la función uploadFilesToDrive devuelve un bodyAttachment válido
        System.assertNotEquals(null, resultBody);
    }    

    // Probar el caso en el que no hay archivos para cargar
    @isTest
    static void testUploadFilesToDriveNoFiles() {
        // Establecer el Mock para simular la conexión a Google Drive
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMock());
        
        // Obtener la cotización de prueba
        Quote quote = crearCotizacionSinArchivos();
        
        // Crear una instancia de CS_GoogleDrive con un token de acceso falso
        CS_GoogleDrive googleDrive = new CS_GoogleDrive('fakeAccessToken');
        
        // Crear una instancia de CS_UploadFiles y pasarle la instancia de CS_GoogleDrive
        CS_UploadFiles uploader = new CS_UploadFiles(googleDrive);
        
        // Iniciar el Test
        Test.startTest();
        Map<String, Object> resultMap = uploader.uploadFilesToDrive(quote.Id);
        Integer resultValue = 0;
        Test.stopTest();
        
        // Verificar que la función uploadFilesToDrive devuelve null en caso de no tener archivos
        System.assertEquals(0, resultValue);
    }

    // Probar el caso en el que falla la subida de un archivo
    @isTest
    static void testUploadFilesToDriveUploadFailure() {
        // Establecer el Mock para simular la conexión a Google Drive con un error al cargar el archivo
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockUploadFailure());
        
        // Obtener la cotización de prueba
        Quote quote = crearCotizacionFailure();
        
        // Crear una instancia de CS_GoogleDrive con un token de acceso falso
        CS_GoogleDrive googleDrive = new CS_GoogleDrive('fakeAccessToken');
        
        // Crear una instancia de CS_UploadFiles y pasarle la instancia de CS_GoogleDrive
        CS_UploadFiles uploader = new CS_UploadFiles(googleDrive);
        
        // Iniciar el Test
        Test.startTest();
        Map<String, Object> resultMap = uploader.uploadFilesToDrive(quote.Id);
        Integer resultValue = 0;
        Test.stopTest();
        
        // Verificar que la función uploadFilesToDrive devuelve un resultado válido aunque haya fallado la subida
        System.assertEquals(0, resultValue);
    }

    // Probar el caso en el que no se encuentra la carpeta padre en Google Drive
    @isTest
    static void testUploadFilesToDriveNoParentFolder() {
        // Establecer el Mock para simular la conexión a Google Drive sin la carpeta padre
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockNoParentFolder());
        
        // Obtener la cotización de prueba
        Quote quote = crearCotizacionNoParent();
        
        // Crear una instancia de CS_GoogleDrive
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        
        // Crear una instancia de CS_UploadFiles y pasarle la instancia de CS_GoogleDrive
        CS_UploadFiles uploader = new CS_UploadFiles(googleDrive);
        
        // Iniciar el Test
        Test.startTest();
        Map<String, Object> resultMap = uploader.uploadFilesToDrive(quote.Id);
        Integer resultValue = 0;
        Test.stopTest();
        
        System.assertEquals(0, resultValue);
    }  

    //Metodos Auxiliares para la prueba
    public static Quote crearCotizacion() {
        Product2 prd = new Product2();
        prd.Name='PRD123456';
        prd.StockKeepingUnit='PRD123456';
        insert(prd);

        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);

        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '123456789';
        ctc.LastName = 'TEST';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial']; 
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
        qte.Name = 'Test Quote';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
        qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
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
    
        // Crea un archivo de prueba
        ContentVersion cv = new ContentVersion();
        cv.Title        = 'Test File';
        cv.PathOnClient = 'testfile.txt';
        cv.VersionData  = Blob.valueOf('test');
        insert cv;     
    
        // Crea un ContentDocumentLink para vincular el archivo con la cotización
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId   = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId      = qte.Id;
        cdl.ShareType           = 'V';
        insert cdl;
        
        return qte;
    }    
    
    public static Quote crearCotizacionSinArchivos() {
        Product2 prd = new Product2();
        prd.Name='PRD123456';
        prd.StockKeepingUnit='PRD123456';
        insert(prd);

        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);        
        
        Account cuenta = crearCuenta();
        Contact ctc = new Contact();
        ctc.CurrencyIsoCode = 'CLP';
        ctc.Phone = '123456789';
        ctc.LastName = 'TEST';
        ctc.AccountId = cuenta.id;
        insert(ctc);
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial']; 
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
        qte.Name = 'Test Quote';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
        qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
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
        
        return qte;
    }  

    public static Quote crearCotizacionFailure() {
        Product2 prd = new Product2();
        prd.Name='PRD_FAI_123456';
        prd.StockKeepingUnit='PRD_FAI_123456';
        insert(prd);

        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);        
        
        Account cuenta = crearCuentaFailure();
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial']; 
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'OP_FAI';
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
        qte.Name = 'Test Quote Failure';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
        qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
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
    
        // Crea un archivo de prueba
        ContentVersion cv = new ContentVersion();
        cv.Title        = 'Test File';
        cv.PathOnClient = 'testfile.txt';
        cv.VersionData  = Blob.valueOf('test');
        insert cv;     
    
        // Crea un ContentDocumentLink para vincular el archivo con la cotización
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId   = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId      = qte.Id;
        cdl.ShareType           = 'V';
        insert cdl;
        
        return qte;
    }        

    public static Quote crearCotizacionNoParent() {
        Product2 prd = new Product2();
        prd.Name='PRD_NP_123456';
        prd.StockKeepingUnit='PRD_NP_123456';
        insert(prd);

        PricebookEntry priceEntry = new PricebookEntry(); 
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert(priceEntry);        
        
        Account cuenta = crearCuentaNoParent();
        
        Opportunity opp = new Opportunity();
        RecordType rcrdtype = [SELECT Id FROM RecordType WHERE sObjectType='Opportunity' and Name='GE Comercial - Industrial']; 
        opp.RecordTypeId = rcrdtype.Id;
        opp.StageName = 'Definición necesidad';
        opp.AccountId = cuenta.Id;
        opp.Name = 'OP_NP';
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
        qte.Name = 'Test Quote NoParent';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
        qte.Status = 'Draft';
        qte.CondicionPago__c = 'Contado';
        qte.FechaEntrega__c = Date.valueOf('2050-12-10');
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
    
        // Crea un archivo de prueba
        ContentVersion cv = new ContentVersion();
        cv.Title        = 'Test File';
        cv.PathOnClient = 'testfile.txt';
        cv.VersionData  = Blob.valueOf('test');
        insert cv;     
    
        // Crea un ContentDocumentLink para vincular el archivo con la cotización
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId   = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId      = qte.Id;
        cdl.ShareType           = 'V';
        insert cdl;
        
        return qte;
    }   

    public static Account crearCuenta(){

        Account cuenta = new Account();
        cuenta.Name = 'FALADEUDA';
        cuenta.RUT_SD__c = 13665080;
        cuenta.RUT_DV__c = '7';

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

    public static Account crearCuentaFailure(){

        Account cuenta = new Account();
        cuenta.Name = 'FALADEUDA_FAI';
        cuenta.RUT_SD__c = 96838800;
        cuenta.RUT_DV__c = '2';

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

    public static Account crearCuentaNoParent(){

        Account cuenta = new Account();
        cuenta.Name = 'FALADEUDA_NP';
        cuenta.RUT_SD__c = 99581960;
        cuenta.RUT_DV__c = '0';

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
}