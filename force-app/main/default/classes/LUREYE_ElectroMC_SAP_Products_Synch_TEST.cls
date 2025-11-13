@isTest
public class LUREYE_ElectroMC_SAP_Products_Synch_TEST {
    @testSetup
    static void setupTestData() {
        Product2 existingProduct = new Product2(
            Name = 'Producto Existente',
            ProductCode = 'EXIST-001',
            IsActive = true,
            Branch__c = '96971110-9',
            CurrencyIsoCode = 'USD',
            QuantityUnitOfMeasure = 'UN',
            Negocio__c = 'Electromecánica'
        );
        insert existingProduct;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

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
    static void testSyncProductsWithSAP_InsertAndNotify() {
        List<LUREYE_ElectroMC_SAP_Products_Synch.SAPProduct> mockSAPProducts = new List<LUREYE_ElectroMC_SAP_Products_Synch.SAPProduct>();

        LUREYE_ElectroMC_SAP_Products_Synch.SAPProduct newProduct = new LUREYE_ElectroMC_SAP_Products_Synch.SAPProduct();
        newProduct.Valid = 'tYES';
        newProduct.ItemCode = 'NEW-001';
        newProduct.U_SkuPre = 'SKU-NEW-001';
        newProduct.Mainsupplier = 'SUPPLIER1';
        newProduct.ItemName = 'Producto Nuevo de Test';
        newProduct.U_Currency = 'USD';
        newProduct.U_Family = 'FamiliaTest';
        newProduct.U_Categoria = 'CategoriaTest';
        newProduct.Manufacturer = 'MarcaTest';
        newProduct.U_FamCod2 = 'FAM2';

        mockSAPProducts.add(newProduct);

        LUREYE_ElectroMC_SAP_Products_Synch.SAPProduct existingProduct = new LUREYE_ElectroMC_SAP_Products_Synch.SAPProduct();
        existingProduct.Valid = 'tYES';
        existingProduct.ItemCode = 'EXIST-001';
        existingProduct.U_SkuPre = 'EXIST-001';
        existingProduct.Mainsupplier = 'SUPPLIER2';
        existingProduct.ItemName = 'Producto Existente Actualizado';
        existingProduct.U_Currency = 'USD';
        existingProduct.U_Family = 'FamiliaExistente';
        existingProduct.U_Categoria = 'CategoriaExistente';
        existingProduct.Manufacturer = 'MarcaExistente';
        existingProduct.U_FamCod2 = 'FAM2';

        mockSAPProducts.add(existingProduct);

        LUREYE_ElectroMC_SAP_Products_Synch.testSAPProducts = mockSAPProducts;

        Test.startTest();
        LUREYE_ElectroMC_SAP_Products_Synch.syncProductsWithSAP();
        Test.stopTest();

        List<Product2> insertedProducts = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode = 'NEW-001'];
        System.debug('Productos insertados***: ' + insertedProducts);
        System.assertEquals(1, insertedProducts.size(), 'Debe haberse insertado el producto nuevo');

        List<Product2> updatedProducts = [SELECT Id, Name, ProductCode, Description FROM Product2 WHERE ProductCode = 'EXIST-001'];
        System.debug('Productos actualizados***: ' + updatedProducts);
        System.assertEquals(1, updatedProducts.size(), 'Debe existir el producto EXISTENTE actualizado');
        System.assertEquals('Producto Existente Actualizado', updatedProducts[0].Description, 'El producto EXISTENTE debió actualizarse');
    }
}