@isTest
public class CorrigeAccount_Test {

    // Método de prueba para verificar que el RUT_DV__c se convierta en mayúsculas
    @isTest
    static void testUpperCaseRutDv() {
        // Crear un registro de cuenta con RUT_DV__c en minúsculas
        Account acc = new Account(Name = 'CMPC maderas SPA', RUT_SD__c =95304000, RUT_DV__c = 'k');
        insert acc;
        
        // Verificar que el valor de RUT_DV__c se ha convertido en mayúsculas
        acc = [SELECT RUT_DV__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('K', acc.RUT_DV__c,'Fallo RUT_DV');
    }
    
    // Método de prueba para verificar que el nombre de cuenta se convierta en mayúsculas
    @isTest
    static void testUpperCaseAccountName() {
        // Crear un registro de cuenta con Name en minúsculas
        Account acc = new Account(Name = 'CMPC maderas SPA', RUT_SD__c = 95304000, RUT_DV__c = 'k');
        insert acc;
        
        // Verificar que el valor de Name se ha convertido en mayúsculas
        acc = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('CMPC MADERAS SPA', acc.Name,'Fallo Name');
    }
    
    // Método de prueba para verificar que el valor de NombreFantasia__c se convierta en mayúsculas
    @isTest
    static void testUpperCaseNombreFantasia() {
        // Crear un registro de cuenta con NombreFantasia__c en minúsculas
        Account acc = new Account(Name = 'CMPC maderas SPA', NombreFantasia__c = 'test', RUT_SD__c = 95304000, RUT_DV__c = 'k');
        insert acc;
        
        // Verificar que el valor de NombreFantasia__c se ha convertido en mayúsculas
        acc = [SELECT NombreFantasia__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('TEST', acc.NombreFantasia__c,'Fallo NombreFantasia');
    }
}