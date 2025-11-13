@IsTest
private class CS_EventNotifyBatch_Test {
    @IsTest
    static void testExecute() {

        // Crea datos de prueba
        List<Quote> quotes = new List<Quote>();
        Quote quote = crearCotizacion_Success();
        quotes.add(quote);

        // Crea una instancia de la clase en prueba
        CS_EventNotifyBatch batch = new CS_EventNotifyBatch(1);
        Iterable<Quote> scope = quotes;

        // Establece el mock de respuesta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Ejecuta el método start y execute del lote
        Test.startTest();
        Database.BatchableContext batchContext;
        batch.start(batchContext);
        batch.execute(batchContext, (List<Quote>) scope);
        Test.stopTest();

        // Verifica que se haya llamado al método postDraftToDocument()
        System.assertNotEquals(null, batch.login_c);

        // Verifica que se haya creado la orden de venta
        System.assertNotEquals(null, quote.OVDocNum__c);

        // Obtiene la respuesta simulada y deserializa
        SL_EstadosQuery_JSON response = (SL_EstadosQuery_JSON) JSON.deserialize(new MockHttpResponseGenerator().responseBody, SL_EstadosQuery_JSON.class);
        SL_EstadosQuery_JSON.Value result = response.value[0];

        // Verifica que los registros de Quote se hayan actualizado correctamente
        List<Quote> updatedQuotes = [SELECT Id, Estado_en_SAP__c, ovDocEntry__c, OVDocNum__c FROM Quote];
        System.assertEquals('Documento Pendiente', updatedQuotes[0].Estado_en_SAP__c);
        System.assertEquals(result.OVDocEntry, updatedQuotes[0].ovDocEntry__c);
        System.assertEquals(1111, updatedQuotes[0].OVDocNum__c);
    }

    // Clase de prueba simulando una respuesta HTTP
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseBody;
        
        public MockHttpResponseGenerator() {
            this.responseBody = getMockResponseBody();
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(this.responseBody);
            return res;
        }  
        
        private String getMockResponseBodyDatos() {
            SL_EstadosQuery_JSON response = new SL_EstadosQuery_JSON();
            SL_EstadosQuery_JSON.Value value = new SL_EstadosQuery_JSON.Value();
            value.CANCELED = 'N';
            value.Comments = 'SF:0Q053000000HcJACA0';
            value.DocEntry = 759;
            value.DocNum = 10000092;
            value.DocStatus = 'C';
            value.OVDocEntry = 1245;
            value.OVDocNum = 10000092;
            value.OVDocStatus = 'O';
            value.OVWddStatus = 'P';
            value.U_IDCajaHisto = 'SF:0Q053000000HcJACA0';
            value.WddStatus = '-';
            
            response.value = new List<SL_EstadosQuery_JSON.Value>{value};            
            return JSON.serialize(response);
        }
        
        private String getMockResponseBody() {
            SL_EstadosQuery_JSON response = new SL_EstadosQuery_JSON();
            SL_EstadosQuery_JSON.Value value = new SL_EstadosQuery_JSON.Value();
            value.CANCELED = null;
            value.Comments = null;
            value.DocEntry = null;
            value.DocNum = null;
            value.DocStatus = null;
            value.OVDocEntry = null;
            value.OVDocNum = null;
            value.OVDocStatus = null;
            value.OVWddStatus = null;
            value.U_IDCajaHisto = null;
            value.WddStatus = null;
            response.value = new List<SL_EstadosQuery_JSON.Value>{value};
            return JSON.serialize(response);
        }        
    }

    //Metodos Auxiliares para la prueba
    public static Quote crearCotizacion_Success(){

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
        usr.Negocio__c = '10000 TRANSACCIONAL';
        usr.IsActive = true;
        insert(usr);

        Quote qte = new Quote();
        qte.Glosa__c = 'prueba';
        qte.Name = 'test';
        qte.OpportunityId = opp.id;
        qte.CurrencyIsoCode = 'CLP';
       	qte.Status = 'Approved';
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
        qteLI.QLBI__c = 1;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert(qteLI);

        System.assertEquals('prueba', qte.Glosa__c, 'La glosa de la cotización coincide');
        System.assertEquals('Approved', qte.Status, 'El estado de la cotización coincide');
        
        List<QuoteLineItem> qteLIs = [SELECT QLBI__c, Quantity, UnitPrice, PricebookEntryId, Product2Id FROM QuoteLineItem WHERE QuoteId = :qte.Id];
        System.assertEquals(1, qteLIs.size(), 'La cantidad de ítems de la cotización no coincide');
        System.assertEquals(1, qteLIs[0].QLBI__c, 'El valor del campo personalizado QLBI__c no coincide');
        System.assertEquals(1, qteLIs[0].Quantity, 'La cantidad del ítem de la cotización no coincide');
        System.assertEquals(100, qteLIs[0].UnitPrice, 'El precio unitario del ítem de la cotización no coincide');
        System.assertEquals(priceEntry.Id, qteLIs[0].PricebookEntryId, 'El PricebookEntryId del ítem de la cotización no coincide');
        System.assertEquals(prd.Id, qteLIs[0].Product2Id, 'El Product2Id del ítem de la cotización no coincide');    
        
        return qte;
    }   

    public static Account crearCuenta(){

        Account cuenta = new Account();
        cuenta.Name = 'FALADEUDA';
        cuenta.RUT_SD__c = 95304000;
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
        return cuenta;
    }

    public static Product2 crearPrd(){
        Product2 prd = new Product2();
        prd.Name='prd230519';
        prd.StockKeepingUnit='prd230519';
        prd.Family='Flanges Motores Siemens IEC';
        prd.cod_proveedor__c='CZF:583';
        insert(prd);
        return prd;
    }
}