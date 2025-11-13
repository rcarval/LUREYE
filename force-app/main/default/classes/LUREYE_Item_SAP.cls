global with sharing class LUREYE_Item_SAP {

 /**
  * @author MindShore 
  * @description Método que se llama desde el flow 	GE - Actualiza Campo Nodo del Producto 
  * @param IdProducto
  */
    @InvocableMethod(label='actualizarNodoProducto' description='' callout='true')
    global static void actualizaNodoProducto(List<Id> idProducto)
    {
        Product2 producto = [SELECT Id, ProductCode, Nodo__c
                                FROM Product2 
                                WHERE Id IN : idProducto
                                WITH SECURITY_ENFORCED]; 
         // Llamada al servicio SAP ItemCode                       
        String nodoProducto = MS_Servicios.obtenerNodoProducto(producto.ProductCode);
        if (nodoProducto != null) 
        {
            // Actualización del campo Nodo en el producto
            producto.Nodo__c =  nodoProducto;
            if (!Test.isRunningTest()) { 
                if(producto.getSObjectType().getDescribe().fields.getMap().get('Nodo__c').getDescribe().isUpdateable())
                { 
                    update producto;
                }
        	}	
    	}
	}
}