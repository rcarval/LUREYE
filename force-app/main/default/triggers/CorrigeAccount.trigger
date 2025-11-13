trigger CorrigeAccount on Account (before insert, before update) {
    for (Account acc : Trigger.new) {
        // Convertir a mayúsculas el valor de RUT_DV__c
        if (acc.RUT_DV__c != null) {
            acc.RUT_DV__c = acc.RUT_DV__c.toUpperCase();
        }
        // Convertir a mayúsculas el valor de Name
        if (acc.Name != null) {
            acc.Name = acc.Name.toUpperCase();
        }
        // Convertir a mayúsculas el valor de NombreFantasia__c
        if (acc.NombreFantasia__c != null) {
            acc.NombreFantasia__c = acc.NombreFantasia__c.toUpperCase();
        }
    }
}