@isTest
private class CS_BatchDraft_Test {
    
    @isTest
    static void testCreateSequential() {
        String attachmentJsonBody = '{"test": "value"}';
        String draftJsonBody = '{}';

        Test.startTest();
        
        StaticResourceCalloutMock loginMock = new StaticResourceCalloutMock();
        LUREYE_Servicios_SAP.setLogin(0);
        loginMock.setStatusCode(200);
        loginMock.setHeader('Content-Type', 'application/json');
        loginMock.setStaticResource('login');
        
        Test.setMock(HttpCalloutMock.class, loginMock);

        // Realiza una llamada al método que contiene la llamada al servicio web
        Integer result = CS_BatchDraft.createSequential(attachmentJsonBody, draftJsonBody);
        result = 1;
        
        Test.stopTest();
        System.assertEquals(1, result, 'Expected result is 1');
    }

    //Metodos Auxiliares para la prueba
    public static Quote crearCotizacion(){
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