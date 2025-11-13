@isTest
public class LUREYE_Product_Synch_from_SAP_TEST {    
    
    @testSetup
    static void setupTestData() {
        Product2 existingProduct_GE = new Product2(
            Name = 'EXIST-001GE',
            StockKeepingUnit = 'EXIST-001GE',
            IsActive = true,
            Branch__c = '96971710-9',
            CurrencyIsoCode = 'CLP',
            QuantityUnitOfMeasure = 'CLP',
            Negocio__c = 'Generación'
        );
        insert existingProduct_GE;

        Product2 todayModifiedProduct_GE = new Product2(
            Name = 'MOD-HOY-001',
            StockKeepingUnit = 'MOD-HOY-001',
            IsActive = true,
            Branch__c = '96971110-9',
            CurrencyIsoCode = 'CLP',
            QuantityUnitOfMeasure = 'CLP',
            Negocio__c = 'Electromecánica'
        );
        insert todayModifiedProduct_GE;

        Product2 existingProduct_EM = new Product2(
            Name = 'EXIST-001EM',
            StockKeepingUnit = 'EXIST-001EM',
            IsActive = true,
            Branch__c = '96971117-8',
            CurrencyIsoCode = 'CLP',
            QuantityUnitOfMeasure = 'CLP',
            Negocio__c = 'Electromecánica'
        );
        insert existingProduct_EM;

        Product2 todayModifiedProduct_EM = new Product2(
            Name = 'MOD-HOY-002',
            StockKeepingUnit = 'MOD-HOY-002',
            IsActive = true,
            Branch__c = '96971110-9',
            CurrencyIsoCode = 'CLP',
            QuantityUnitOfMeasure = 'CLP',
            Negocio__c = 'Electromecánica'
        );
        insert todayModifiedProduct_EM;

        Product2 oldProduct_GE = new Product2(
            Name = 'OLD-GE-001',
            StockKeepingUnit = 'OLD-GE-001',
            IsActive = true,
            Branch__c = '9601298-9',
            CurrencyIsoCode = 'CLP',
            QuantityUnitOfMeasure = 'CLP',
            Negocio__c = 'Generación'
        );
        insert oldProduct_GE;

        // Simular que fue modificado hace 3 días
        Test.setCreatedDate(oldProduct_GE.Id, DateTime.now().addDays(-3));

        Product2 oldProduct_EM = new Product2(
            Name = 'Producto Antiguo',
            StockKeepingUnit = 'OLD-EM-001',
            IsActive = true,
            Branch__c = '9601298-9',
            CurrencyIsoCode = 'CLP',
            QuantityUnitOfMeasure = 'CLP',
            Negocio__c = 'Generación'
        );
        insert oldProduct_EM;

        // Simular que fue modificado hace 3 días
        Test.setCreatedDate(oldProduct_EM.Id, DateTime.now().addDays(-3));

        Profile p = [SELECT Id FROM Profile WHERE Name = '10 - Supervisor Servicios' LIMIT 1];

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'customer_success.cl@seidor.com',
            Username = 'testuser_' + System.currentTimeMillis() + '@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Bogota',
            LocaleSidKey = 'es',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'es_MX'
        );
        insert u;
    }

    @isTest
    static void test_GE_Insert_Nuevo() {
        List<LUREYE_Product_Synch_from_SAP.SAPProduct> mockSAP_EM = new List<LUREYE_Product_Synch_from_SAP.SAPProduct>();

        LUREYE_Product_Synch_from_SAP.SAPProduct newProductEM = new LUREYE_Product_Synch_from_SAP.SAPProduct();
        newProductEM.Valid = 'tYES';
        newProductEM.ItemCode = 'NEW-GE-002';
        newProductEM.U_SkuPre = 'SKU-GE-002';
        newProductEM.Mainsupplier = 'SUPPLIER-GE';
        newProductEM.ItemName = 'Producto Nuevo GE';
        newProductEM.U_Currency = 'USD';
        newProductEM.U_Family = 'Generación';
        newProductEM.U_Categoria = 'CategoriaGE';
        newProductEM.Manufacturer = 'MarcaEM';
        newProductEM.U_FamCod2 = 'FAM2';

        mockSAP_EM.add(newProductEM);
        System.debug('Mock SAP Products for GE: ' + newProductEM.ItemCode);
        System.debug('Mock SAP Products for GE***: ' + mockSAP_EM);

        LUREYE_Product_Synch_from_SAP.testSAPProducts = mockSAP_EM;

        LUREYE_Product_Synch_from_SAP.Input inp = new LUREYE_Product_Synch_from_SAP.Input();
        inp.sapLoginDeveloperName = 'LoginGE';
        inp.diasMenos = -1;
        
        Test.startTest();
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(
            new List<LUREYE_Product_Synch_from_SAP.Input>{ inp }
        );
        Test.stopTest();


        List<Product2> insertedProduct = [SELECT Id, Name, StockKeepingUnit, LineaComercial__c, Negocio__c FROM Product2 WHERE StockKeepingUnit = 'NEW-GE-002' LIMIT 1];
        System.debug('Inserted Product: ' + insertedProduct[0].StockKeepingUnit);
        System.assertEquals(1, insertedProduct.size());
        System.assertEquals('Generación;Servicios', insertedProduct[0].Negocio__c);
    }

    @isTest
    static void test_EM_Insert_Nuevo() {
        List<LUREYE_Product_Synch_from_SAP.SAPProduct> mockSAP_EM = new List<LUREYE_Product_Synch_from_SAP.SAPProduct>();

        LUREYE_Product_Synch_from_SAP.SAPProduct newProductEM = new LUREYE_Product_Synch_from_SAP.SAPProduct();
        newProductEM.Valid = 'tYES';
        newProductEM.ItemCode = 'NEW-EM-001';
        newProductEM.U_SkuPre = 'SKU-EM-001';
        newProductEM.Mainsupplier = 'SUPPLIER-EM';
        newProductEM.ItemName = 'Producto Nuevo EM';
        newProductEM.U_Currency = 'USD';
        newProductEM.U_Family = 'Electromecánica';
        newProductEM.U_Categoria = 'CategoriaEM';
        newProductEM.Manufacturer = 'MarcaEM';
        newProductEM.U_FamCod2 = 'FAM2';

        mockSAP_EM.add(newProductEM);
        System.debug('Mock SAP Products for EM: ' + newProductEM.ItemCode);
        System.debug('Mock SAP Products for EM***: ' + mockSAP_EM);

        LUREYE_Product_Synch_from_SAP.testSAPProducts = mockSAP_EM;

        LUREYE_Product_Synch_from_SAP.Input inp = new LUREYE_Product_Synch_from_SAP.Input();
        inp.sapLoginDeveloperName = 'LoginEM';
        inp.diasMenos = -1;
        
        Test.startTest();
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(
            new List<LUREYE_Product_Synch_from_SAP.Input>{ inp }
        );
        Test.stopTest();


        List<Product2> insertedProduct = [SELECT Id, Name, StockKeepingUnit, LineaComercial__c, Negocio__c FROM Product2 WHERE StockKeepingUnit = 'NEW-EM-001' LIMIT 1];
        System.debug('Inserted Product: ' + insertedProduct[0].StockKeepingUnit);
        System.assertEquals(1, insertedProduct.size());
        System.assertEquals('Electromecánica', insertedProduct[0].Negocio__c);
        System.assertEquals('CategoriaEM', insertedProduct[0].LineaComercial__c);
    }

    @isTest
    static void test_GE_Update_Existente() {
        List<LUREYE_Product_Synch_from_SAP.SAPProduct> mockSAP_GE = new List<LUREYE_Product_Synch_from_SAP.SAPProduct>();

        LUREYE_Product_Synch_from_SAP.SAPProduct existingProductGE = new LUREYE_Product_Synch_from_SAP.SAPProduct();
        existingProductGE.Valid = 'tYES';
        existingProductGE.ItemCode = 'EXIST-001GE';
        existingProductGE.U_SkuPre = 'EXIST-001GE';
        existingProductGE.Mainsupplier = 'SUPPLIER';
        existingProductGE.ItemName = 'Producto GE';
        existingProductGE.U_Currency = 'USD';
        existingProductGE.U_Family = 'Generación';
        existingProductGE.U_Categoria = 'Categoria';
        existingProductGE.Manufacturer = 'Marca';
        existingProductGE.U_FamCod2 = 'FAM2';
        existingProductGE.U_MMotor = 'Motor GE';
        existingProductGE.U_PoNo = 'PoNo GE';

        mockSAP_GE.add(existingProductGE);

        LUREYE_Product_Synch_from_SAP.testSAPProducts = mockSAP_GE;

        LUREYE_Product_Synch_from_SAP.Input inp = new LUREYE_Product_Synch_from_SAP.Input();
        inp.sapLoginDeveloperName = 'LoginGE';
        inp.diasMenos = -1;
        
        Test.startTest();
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(
            new List<LUREYE_Product_Synch_from_SAP.Input>{ inp }
        );
        Test.stopTest();


        List<Product2> updatedProduct = [SELECT Id, Name, StockKeepingUnit, Motor__c, Nodo__c, Description, Negocio__c FROM Product2 WHERE StockKeepingUnit = 'EXIST-001GE' LIMIT 1];
        System.debug('Updated Product: ' + updatedProduct[0].StockKeepingUnit);
        System.assertEquals(1, updatedProduct.size());
        System.assertEquals('Generación;Servicios', updatedProduct[0].Negocio__c);
    }

    @isTest
    static void test_EM_Update_Existente() {
        List<LUREYE_Product_Synch_from_SAP.SAPProduct> mockSAP_GE = new List<LUREYE_Product_Synch_from_SAP.SAPProduct>();

        LUREYE_Product_Synch_from_SAP.SAPProduct existingProductGE = new LUREYE_Product_Synch_from_SAP.SAPProduct();
        existingProductGE.Valid = 'tYES';
        existingProductGE.ItemCode = 'EXIST-001EM';
        existingProductGE.U_SkuPre = 'EXIST-001EM';
        existingProductGE.Mainsupplier = 'SUPPLIER';
        existingProductGE.ItemName = 'Producto EM';
        existingProductGE.U_Currency = 'USD';
        existingProductGE.U_Family = 'EM';
        existingProductGE.U_Categoria = 'Categoria';
        existingProductGE.Manufacturer = 'Marca';
        existingProductGE.U_FamCod2 = 'FAM2';
        existingProductGE.U_MMotor = 'Motor EM';
        existingProductGE.U_PoNo = 'PoNo EM';

        mockSAP_GE.add(existingProductGE);

        LUREYE_Product_Synch_from_SAP.testSAPProducts = mockSAP_GE;

        LUREYE_Product_Synch_from_SAP.Input inp = new LUREYE_Product_Synch_from_SAP.Input();
        inp.sapLoginDeveloperName = 'LoginEM';
        inp.diasMenos = -1;
        
        Test.startTest();
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(
            new List<LUREYE_Product_Synch_from_SAP.Input>{ inp }
        );
        Test.stopTest();

        List<Product2> updatedProduct = [SELECT Id, Name, StockKeepingUnit, Motor__c, Nodo__c, Description, Negocio__c FROM Product2 WHERE StockKeepingUnit = 'EXIST-001EM' LIMIT 1];
        System.debug('Updated Product: ' + updatedProduct[0].StockKeepingUnit);
        System.assertEquals(1, updatedProduct.size());
        System.assertEquals('Electromecánica', updatedProduct[0].Negocio__c);
    }

    @isTest
    static void test_GE_Update_Old_Existente() {
        List<LUREYE_Product_Synch_from_SAP.SAPProduct> mockSAP_GE = new List<LUREYE_Product_Synch_from_SAP.SAPProduct>();

        LUREYE_Product_Synch_from_SAP.SAPProduct existingProductGE = new LUREYE_Product_Synch_from_SAP.SAPProduct();
        existingProductGE.Valid = 'tYES';
        existingProductGE.ItemCode = 'OLD-GE-001';
        existingProductGE.U_SkuPre = 'OLD-GE-001';
        existingProductGE.Mainsupplier = 'SUPPLIER';
        existingProductGE.ItemName = 'Producto GE';
        existingProductGE.U_Currency = 'USD';
        existingProductGE.U_Family = 'Gneración';
        existingProductGE.U_Categoria = 'Categoria';
        existingProductGE.Manufacturer = 'Marca';
        existingProductGE.U_FamCod2 = 'FAM2';
        existingProductGE.U_MMotor = 'Motor GE';
        existingProductGE.U_PoNo = 'PoNo GE';

        mockSAP_GE.add(existingProductGE);

        LUREYE_Product_Synch_from_SAP.skipUpdateCheck = true;

        LUREYE_Product_Synch_from_SAP.testSAPProducts = mockSAP_GE;

        LUREYE_Product_Synch_from_SAP.Input inp = new LUREYE_Product_Synch_from_SAP.Input();
        inp.sapLoginDeveloperName = 'LoginGE';
        inp.diasMenos = -1;
        
        Test.startTest();
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(
            new List<LUREYE_Product_Synch_from_SAP.Input>{ inp }
        );
        Test.stopTest();

        List<Product2> updatedProduct = [SELECT Id, Name, StockKeepingUnit, Motor__c, Nodo__c, Description, Negocio__c FROM Product2 WHERE StockKeepingUnit = 'OLD-GE-001' LIMIT 1];
        System.debug('Updated Product: ' + updatedProduct[0].StockKeepingUnit);
        System.assertEquals(1, updatedProduct.size());
        System.assertEquals('Generación;Servicios', updatedProduct[0].Negocio__c);
    }
    
    @isTest
    static void test_EM_Update_Old_Existente() {
        List<LUREYE_Product_Synch_from_SAP.SAPProduct> mockSAP_GE = new List<LUREYE_Product_Synch_from_SAP.SAPProduct>();

        LUREYE_Product_Synch_from_SAP.SAPProduct existingProductGE = new LUREYE_Product_Synch_from_SAP.SAPProduct();
        existingProductGE.Valid = 'tYES';
        existingProductGE.ItemCode = 'OLD-EM-001';
        existingProductGE.U_SkuPre = 'OLD-EM-001';
        existingProductGE.Mainsupplier = 'SUPPLIER';
        existingProductGE.ItemName = 'Producto EM';
        existingProductGE.U_Currency = 'USD';
        existingProductGE.U_Family = 'EM';
        existingProductGE.U_Categoria = 'Categoria';
        existingProductGE.Manufacturer = 'Marca';
        existingProductGE.U_FamCod2 = 'FAM2';
        existingProductGE.U_MMotor = 'Motor EM';
        existingProductGE.U_PoNo = 'PoNo EM';

        mockSAP_GE.add(existingProductGE);

        LUREYE_Product_Synch_from_SAP.skipUpdateCheck = true;

        LUREYE_Product_Synch_from_SAP.testSAPProducts = mockSAP_GE;

        LUREYE_Product_Synch_from_SAP.Input inp = new LUREYE_Product_Synch_from_SAP.Input();
        inp.sapLoginDeveloperName = 'LoginEM';
        inp.diasMenos = -1;
        
        Test.startTest();
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(
            new List<LUREYE_Product_Synch_from_SAP.Input>{ inp }
        );
        Test.stopTest();

        List<Product2> updatedProduct = [SELECT Id, Name, StockKeepingUnit, Motor__c, Nodo__c, Description, Negocio__c FROM Product2 WHERE StockKeepingUnit = 'OLD-EM-001' LIMIT 1];
        System.debug('Updated Product: ' + updatedProduct[0].StockKeepingUnit);
        System.assertEquals(1, updatedProduct.size());
        System.assertEquals('Electromecánica', updatedProduct[0].Negocio__c);
    }
}