trigger CorrigeDireccion on Direccion__c (before insert, before update) {
    // Se recorre la lista de registros para realizar la conversión a mayúsculas
    for (Direccion__c dir : Trigger.new) {

        // Corrige el nombre en caso de que sea Facturación o Despacho
        if(dir.Name != null) {
            String nameLower = dir.Name.toLowerCase();
            if(nameLower == 'facturacion' || nameLower == 'facturación') {
                dir.Name = 'Facturación';
            }
            else if(nameLower == 'despacho') {
                dir.Name = 'Despacho';
            } 
        }

        // Transforma el campo Street__c a mayúsculas antes de insertar o actualizar el registro
        if (dir.Street__c != null) {
            dir.Street__c = dir.Street__c.toUpperCase();
        }
        // Transforma el campo StreetNo__c a mayúsculas antes de insertar o actualizar el registro
        if (dir.StreetNo__c != null) {
            dir.StreetNo__c = dir.StreetNo__c.toUpperCase();
        }
        // Transforma el campo Block__c a mayúsculas antes de insertar o actualizar el registro
        if (dir.Block__c != null) {
            dir.Block__c = dir.Block__c.toUpperCase();
        }
        // Transforma el campo Ciudad__c a mayúsculas antes de insertar o actualizar el registro
        if (dir.Ciudad__c != null) {
            dir.Ciudad__c = dir.Ciudad__c.toUpperCase();
        }
        // Transforma el campo Comuna__c a mayúsculas antes de insertar o actualizar el registro
        if (dir.Comuna__c != null) {
            dir.Comuna__c = dir.Comuna__c.toUpperCase();
        }

        // Verificar si existe otra direccion con el mismo nombre del mismo tipo y en la misma cuenta
        Integer vCount = 0;
        if (Trigger.isUpdate){
            vCount = [SELECT COUNT() FROM Direccion__c WHERE AccountId__c = :dir.AccountId__c AND Tipo__c = :dir.Tipo__c AND Name = :dir.Name AND Id != :dir.Id];
        }
        else{
            vCount = [SELECT COUNT() FROM Direccion__c WHERE AccountId__c = :dir.AccountId__c AND Tipo__c = :dir.Tipo__c AND Name = :dir.Name];
        }
        if(vCount > 0){
            dir.Name.addError('Ya existe una dirección con el mismo nombre y tipo en esta cuenta.');
        }
    }
}