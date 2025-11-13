@IsTest
public class SL_EstadosQuery_JSON_Test {
    
    @IsTest
    public static void testParse() {
        // JSON de prueba
        String json = '{"odatametadata": "", "SqlText": "SELECT * FROM Table", "value": [{"CANCELED": "No", "Comments": "Test", "DocEntry": 123, "DocNum": 456, "DocStatus": "Open", "OVDocEntry": 789, "OVDocNum": 987, "OVDocStatus": "Closed", "OVWddStatus": "Approved", "U_IDCajaHisto": "12345", "WddStatus": "Pending"}]}';
        
        // Llamar al método parse de la clase SL_EstadosQuery_JSON
        SL_EstadosQuery_JSON result = SL_EstadosQuery_JSON.parse(json);
        
        // Verificar que el objeto result no sea nulo
        System.assertNotEquals(null, result, 'El objeto result debería ser no nulo');
        
        // Verificar los valores del objeto result
        System.assertEquals('', result.odatametadata, 'El valor de odatametadata no coincide');
        System.assertEquals('SELECT * FROM Table', result.SqlText, 'El valor de SqlText no coincide');
        
        // Verificar los valores del objeto Value dentro de result
        List<SL_EstadosQuery_JSON.Value> values = result.value;
        System.assertEquals(1, values.size(), 'El tamaño de la lista value no es el esperado');
        SL_EstadosQuery_JSON.Value value = values[0];
        System.assertEquals('No', value.CANCELED, 'El valor de CANCELED no coincide');
        System.assertEquals('Test', value.Comments, 'El valor de Comments no coincide');
        System.assertEquals(123, value.DocEntry, 'El valor de DocEntry no coincide');
        System.assertEquals(456, value.DocNum, 'El valor de DocNum no coincide');
        System.assertEquals('Open', value.DocStatus, 'El valor de DocStatus no coincide');
        System.assertEquals(789, value.OVDocEntry, 'El valor de OVDocEntry no coincide');
        System.assertEquals(987, value.OVDocNum, 'El valor de OVDocNum no coincide');
        System.assertEquals('Closed', value.OVDocStatus, 'El valor de OVDocStatus no coincide');
        System.assertEquals('Approved', value.OVWddStatus, 'El valor de OVWddStatus no coincide');
        System.assertEquals('12345', value.U_IDCajaHisto, 'El valor de U_IDCajaHisto no coincide');
        System.assertEquals('Pending', value.WddStatus, 'El valor de WddStatus no coincide');
    }
}