@isTest
public class EM_OportunidadProducto_Test {

    @IsTest
    static void testGetOpportunities() {
        // Crear la oportunidad y sus registros relacionados
        Opportunity testOpportunity = crearOportunidad();

        Test.startTest();
        List<EM_OportunidadProducto.OpportunityWrapper> resultWrappers = EM_OportunidadProducto.getOpportunities(testOpportunity.AccountId);
        Test.stopTest();

        // Verificaciones
        System.assertEquals(1, resultWrappers.size(), 'Debe devolver solo una oportunidad que tenga elementos.');
        EM_OportunidadProducto.OpportunityWrapper testWrapper = resultWrappers[0];
        System.assertEquals(testOpportunity.Id, testWrapper.opp.Id, 'Los ID de las oportunidades deben coincidir.');
        System.assertEquals('productoOP', testWrapper.productName, 'Los nombres de los productos deben coincidir.');
        System.assertEquals(1, testWrapper.Quantity, 'Las cantidades deben coincidir.');
    }

    //Metodos Auxiliares para la prueba
    public static Opportunity crearOportunidad(){
        Account cuenta = crearCuenta();    
        Product2 prd = crearPrd();
    
        // Creación de PricebookEntry
        PricebookEntry priceEntry = new PricebookEntry();
        priceEntry.Product2Id = prd.Id;
        priceEntry.IsActive = true;
        priceEntry.CurrencyIsoCode = 'CLP';
        priceEntry.UnitPrice = 1.0;
        priceEntry.UseStandardPrice = false;
        priceEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert priceEntry;
    
        // Creación de la oportunidad
        Opportunity opp = new Opportunity();
        opp.OwnerId     = UserInfo.getUserId();
        opp.StageName   = 'Definición necesidad';
        opp.AccountId   = cuenta.Id;
        opp.Name        = 'oppOP';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CloseDate = Date.valueOf('2050-12-10');
        opp.CurrencyIsoCode = 'CLP';
        insert opp;
    
        // Creación de OpportunityLineItem
        OpportunityLineItem opptitem = new OpportunityLineItem();
        opptitem.Product2Id = prd.Id;
        opptitem.Quantity = 1;
        opptitem.OpportunityId = opp.Id;
        insert opptitem;
    
        return opp; // Devuelve la oportunidad creada
    }

    public static Account crearCuenta(){
        Account cuenta = new Account();
        cuenta.Name = 'RIPLEX';
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
        giro.Codigo__c='testOP';
        giro.Name='testOP';
        giro.CurrencyIsoCode='CLP';
        insert giro;

        cuenta.Giro__c = giro.Id;
        cuenta.Industry = 'Sin Informacion';
        cuenta.CreditLine__c = 0;
        cuenta.DebtLine__c = 0;
        cuenta.Currency__c = 'CLP';

        cuenta.NombreFantasia__c = 'RIPLEX';
        cuenta.AccountSource = '001 - Llamada';
        cuenta.Country__c = 'CL';

        cuenta.Website = 'www.riplex.com';
        cuenta.Phone = '123456789';
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        insert cuenta;

        return cuenta;
    }

    public static Product2 crearPrd(){
        Product2 prd = new Product2();
        prd.Name = 'productoOP';
        prd.StockKeepingUnit = 'productoOP';
        prd.Family = 'Flanges Motores Siemens IEC';
        prd.cod_proveedor__c = 'CZF:583';
        insert prd;
        return prd;
    }
}