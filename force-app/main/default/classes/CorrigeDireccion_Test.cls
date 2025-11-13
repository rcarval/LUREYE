@IsTest
public class CorrigeDireccion_Test {

    @TestSetup
    static void creaCuenta(){
        Account cuenta = new Account(Name = 'Test Account', RUT_SD__c = 95304000, RUT_DV__c = 'K');
        insert cuenta;
    }

    public static Direccion__c creaDireccion1(Account cuenta){
        Direccion__c dir = new Direccion__c(
            AccountId__c = cuenta.Id,
            Name = 'facturacion',
            Street__c = 'calle',
            StreetNo__c = 'san ignacio 123',
            Block__c = 'bloque',
            Ciudad__c = 'ciudad',
            Comuna__c = 'comuna',
            Tipo__c = 'Facturación'
        );
        return dir;
    }

    @IsTest
    static void testDireccionBeforeInsert() {
        // Recuperar la cuenta creada en @TestSetup
        Account cuenta = [SELECT Id FROM Account LIMIT 1];

        // Crear un registro Direccion__c para insertar
        Direccion__c dir = creaDireccion1(cuenta);

        // Realizar la inserción, lo que activará el trigger
        Test.startTest();
        insert dir;
        Test.stopTest();

        // Recuperar el registro insertado y verificar las aserciones
        dir = [SELECT Name, Street__c, StreetNo__c, Block__c, Ciudad__c, Comuna__c FROM Direccion__c WHERE Id = :dir.Id];

        System.assertEquals('Facturación', dir.Name, 'El nombre debe ser corregido a Facturación');
        System.assertEquals('CALLE', dir.Street__c, 'La calle debe estar en mayúsculas');
        System.assertEquals('SAN IGNACIO 123', dir.StreetNo__c, 'El número de calle debe estar en mayúsculas');
        System.assertEquals('BLOQUE', dir.Block__c, 'El bloque debe estar en mayúsculas');
        System.assertEquals('CIUDAD', dir.Ciudad__c, 'La ciudad debe estar en mayúsculas');
        System.assertEquals('COMUNA', dir.Comuna__c, 'La comuna debe estar en mayúsculas');
    }

    @IsTest
    static void testDireccionBeforeUpdate() {
        // Recuperar la cuenta creada en @TestSetup
        Account cuenta = [SELECT Id FROM Account LIMIT 1];

        // Crear un registro Direccion__c para insertar
        Direccion__c dir = creaDireccion1(cuenta);
        insert dir;

        Direccion__c dirUpd = [SELECT Id FROM Direccion__c WHERE AccountId__c = :cuenta.Id LIMIT 1];
        dirUpd.Name = 'despacho';
        dirUpd.Street__c = 'otra calle';

        Test.startTest();
        update dirUpd;
        Test.stopTest();

        // Recuperar el registro actualizado para verificar los cambios
        dirUpd = [SELECT Name, Street__c FROM Direccion__c WHERE Id = :dirUpd.Id];

        System.assertEquals('Despacho', dirUpd.Name, 'El nombre debe ser corregido a Despacho');
        System.assertEquals('OTRA CALLE', dirUpd.Street__c, 'La calle debe estar en mayúsculas');
    }

    @IsTest
    static void testDireccionDuplicada() {
        // Recuperar la cuenta creada en @TestSetup
        Account cuenta = [SELECT Id FROM Account LIMIT 1];

        // Crear un registro Direccion__c para insertar
        Direccion__c dir = creaDireccion1(cuenta);
        insert dir;

        // Intentar insertar otra dirección con el mismo nombre y tipo, lo que debería fallar
        Direccion__c dirDuplicada = new Direccion__c(
            AccountId__c = cuenta.Id,
            Name = 'Facturación',
            Tipo__c = 'Facturación'
        );

        Boolean errorCapturado = false;
        try {
            insert dirDuplicada;
        } catch (DmlException e) {
            errorCapturado = true;
            System.assert(e.getDmlMessage(0).contains('Ya existe una dirección con el mismo nombre y tipo en esta cuenta.'),
                          'El mensaje de error no es el esperado.');
        }
        System.assert(errorCapturado, 'Debería capturar un error al insertar una dirección duplicada');
    }
}