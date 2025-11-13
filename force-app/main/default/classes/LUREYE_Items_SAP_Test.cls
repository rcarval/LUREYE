@IsTest
public class LUREYE_Items_SAP_Test {
    
    @IsTest
    static void testCreateQuoteLI() {
        Quote qte = crearCotizacion();
        Product2 prd = new Product2();
        prd.Name = 'prd2';
        prd.StockKeepingUnit = 'prd2';
        prd.Family = 'Flanges Motores Siemens IEC';
        prd.cod_proveedor__c = 'CZF:583';
        insert prd;

        Map<Id, String> prdMap = new Map<Id, String>();
        prdMap.put(prd.Id, '1');

        PricebookEntry priceEntry = new PricebookEntry();
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert priceEntry;

        QuoteLineItem qteLI = new QuoteLineItem();
        qteLI.QLBI__c = 1;
        qteLI.Quantity = 1;
        qteLI.QuoteId = qte.Id;
        qteLI.UnitPrice = 100;
        qteLI.PricebookEntryId = priceEntry.Id;
        qteLI.Product2Id = prd.Id;
        insert qteLI;

        List<QuoteLineItem> qryQuoteLineItem = new List<QuoteLineItem>();
        qryQuoteLineItem.add(qteLI);

        Decimal order = 1;
        String costingcode = '1';
        String sucursal = '1';
        Decimal lineaN = 1;
        String glosa = 'glosa';
        String bodega = null;
        String result = LUREYE_Items_SAP.createQuoteLI(prdMap, qryQuoteLineItem, order, costingcode, sucursal, lineaN, glosa, bodega);

        System.assertNotEquals(null, result, 'El resultado del método createQuoteLI es nulo');    
    }
    
    @IsTest
    static void testDirecciones() {
        List<String> lstshipaddr = new List<String>{'Dirección de envío 1', 'Dirección de envío 2'};
        List<String> lstbilladdr = new List<String>{'Dirección de facturación 1', 'Dirección de facturación 2'};
        
        String result = LUREYE_Items_SAP.direcciones(lstshipaddr, lstbilladdr);
        
        System.assertNotEquals('', result, 'El resultado de la dirección no debe ser una cadena vacía');
        System.assertEquals('Dirección de envío 1,Dirección de envío 2,Dirección de facturación 1,Dirección de facturación 2', result, 'El resultado no es el esperado');

        System.assert(result.contains('Dirección de envío'), 'El resultado no contiene la dirección de envío');
        System.assert(result.contains('Dirección de facturación'), 'El resultado no contiene la dirección de facturación');
    }

    @IsTest
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
        
        Direccion__c clientFA = new Direccion__c();
        clientFA.AccountId__c=cuenta.id;
        clientFA.Tipo__c='Facturación';
        clientFA.Name='Facturación';
        clientFA.Street__c='CALLE';
        clientFA.Ciudad__c='SANTIAGO';
        clientFA.Comuna__c='SANTIAGO';    
        clientFA.TaxCode__c='IVA';
        clientFA.StreetNo__c='123';
        insert(clientFA);
        String dirfactId = clientFA.Id;
        
        Direccion__c clientDE = new Direccion__c();
        clientDE.AccountId__c=cuenta.id;
        clientDE.Tipo__c='Despacho';
        clientDE.Name='Despacho';
        clientDE.Street__c='CALLE';
        clientDE.Ciudad__c='SANTIAGO';
        clientDE.Comuna__c='SANTIAGO';
        clientDE.TaxCode__c='IVA';
        clientDE.StreetNo__c='123';
        insert(clientDE);
        String direnvId = clientDE.Id;
        
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
        //qte.DirFacturacion__c = dirfactId;
        //qte.DirDespacho__c = direnvId;    
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

    //Metodos Auxiliares para la prueba
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
}