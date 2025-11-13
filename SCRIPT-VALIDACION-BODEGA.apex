// ========================================================================
// RCG - 13/11/2025 - Ticket N° 00024376
// Script de validación rápida para Custom Metadata Type y lógica de bodega
// ========================================================================
//
// INSTRUCCIONES:
// 1. Abrir Developer Console
// 2. Debug > Open Execute Anonymous Window
// 3. Copiar y pegar este script completo
// 4. Check "Open Log"
// 5. Click "Execute"
// 6. Ver resultados en el log
//
// ========================================================================

System.debug('=============================================================');
System.debug('🧪 INICIANDO VALIDACIÓN - TICKET 00024376');
System.debug('=============================================================\n');

// ========================================================================
// PARTE 1: Validar que el Custom Metadata Type existe y tiene registros
// ========================================================================

System.debug('📋 PARTE 1: Validando Custom Metadata Type "Bodega_SAP__mdt"');
System.debug('-------------------------------------------------------------');

List<Bodega_SAP__mdt> configs = [
    SELECT Label, Linea_Negocio__c, Region_Despacho__c, 
           Requiere_HES__c, Codigo_Bodega_SAP__c, Prioridad__c, Activo__c
    FROM Bodega_SAP__mdt
    ORDER BY Prioridad__c ASC
];

System.debug('✅ Total configuraciones encontradas: ' + configs.size());

if (configs.isEmpty()) {
    System.debug('❌ ERROR: No se encontraron configuraciones. Debes crear los registros manualmente.');
} else {
    System.debug('\n📊 Configuraciones cargadas:\n');
    for (Bodega_SAP__mdt config : configs) {
        String activo = config.Activo__c ? '✅' : '❌';
        System.debug(activo + ' [Pri ' + config.Prioridad__c + '] ' + config.Label);
        System.debug('   ├─ Línea Negocio: ' + config.Linea_Negocio__c);
        System.debug('   ├─ Región: ' + config.Region_Despacho__c);
        System.debug('   ├─ Requiere HES: ' + config.Requiere_HES__c);
        System.debug('   └─ Bodega SAP: ' + config.Codigo_Bodega_SAP__c + '\n');
    }
}

// ========================================================================
// PARTE 2: Probar la lógica de determinación de bodega
// ========================================================================

System.debug('\n📋 PARTE 2: Probando lógica de determinación de bodega');
System.debug('-------------------------------------------------------------\n');

// Caso 1: HES Override (Prioridad 1 - Máxima)
System.debug('🧪 CASO 1: HES Override');
String bodega1 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'HES');
System.debug('   Input: LN=21000, Región=13, HES=HES');
System.debug('   Output: ' + (bodega1 != null ? bodega1 : 'null'));
System.debug('   Esperado: VTADFL10');
System.debug('   Resultado: ' + (bodega1 == 'VTADFL10' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 2: 802 Override (debe funcionar igual que HES)
System.debug('🧪 CASO 2: 802 Override');
String bodega2 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', '802');
System.debug('   Input: LN=21000, Región=13, HES=802');
System.debug('   Output: ' + (bodega2 != null ? bodega2 : 'null'));
System.debug('   Esperado: VTADFL10');
System.debug('   Resultado: ' + (bodega2 == 'VTADFL10' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 3: GE Relacional (21000)
System.debug('🧪 CASO 3: GE Relacional');
String bodega3 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'Venta Normal');
System.debug('   Input: LN=21000, Región=13, HES=Venta Normal');
System.debug('   Output: ' + (bodega3 != null ? bodega3 : 'null'));
System.debug('   Esperado: VTLE');
System.debug('   Resultado: ' + (bodega3 == 'VTLE' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 4: GE Proyecto (15000)
System.debug('🧪 CASO 4: GE Proyecto');
String bodega4 = LUREYE_Bodega_SAP_Service.determinarBodega(15000, '13', 'Venta Normal');
System.debug('   Input: LN=15000, Región=13, HES=Venta Normal');
System.debug('   Output: ' + (bodega4 != null ? bodega4 : 'null'));
System.debug('   Esperado: VTLE');
System.debug('   Resultado: ' + (bodega4 == 'VTLE' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 5: GE Transaccional (10000)
System.debug('🧪 CASO 5: GE Transaccional');
String bodega5 = LUREYE_Bodega_SAP_Service.determinarBodega(10000, '13', 'Venta Normal');
System.debug('   Input: LN=10000, Región=13, HES=Venta Normal');
System.debug('   Output: ' + (bodega5 != null ? bodega5 : 'null'));
System.debug('   Esperado: VTLE');
System.debug('   Resultado: ' + (bodega5 == 'VTLE' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 6: Servicio Santiago (22000 + Región 13)
System.debug('🧪 CASO 6: Servicio Santiago');
String bodega6 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '13', 'Venta Normal');
System.debug('   Input: LN=22000, Región=13, HES=Venta Normal');
System.debug('   Output: ' + (bodega6 != null ? bodega6 : 'null'));
System.debug('   Esperado: ST10');
System.debug('   Resultado: ' + (bodega6 == 'ST10' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 7: Servicio Antofagasta (22000 + Región 2)
System.debug('🧪 CASO 7: Servicio Antofagasta');
String bodega7 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '2', 'Venta Normal');
System.debug('   Input: LN=22000, Región=2, HES=Venta Normal');
System.debug('   Output: ' + (bodega7 != null ? bodega7 : 'null'));
System.debug('   Esperado: STA10');
System.debug('   Resultado: ' + (bodega7 == 'STA10' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 8: Servicio Puerto Montt (22000 + Región 10)
System.debug('🧪 CASO 8: Servicio Puerto Montt');
String bodega8 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '10', 'Venta Normal');
System.debug('   Input: LN=22000, Región=10, HES=Venta Normal');
System.debug('   Output: ' + (bodega8 != null ? bodega8 : 'null'));
System.debug('   Esperado: STSP10');
System.debug('   Resultado: ' + (bodega8 == 'STSP10' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 9: Servicio Concepción (22000 + Región 8)
System.debug('🧪 CASO 9: Servicio Concepción');
String bodega9 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '8', 'Venta Normal');
System.debug('   Input: LN=22000, Región=8, HES=Venta Normal');
System.debug('   Output: ' + (bodega9 != null ? bodega9 : 'null'));
System.debug('   Esperado: STC10');
System.debug('   Resultado: ' + (bodega9 == 'STC10' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 10: Sin Match (Línea no configurada)
System.debug('🧪 CASO 10: Sin Match (Línea 30000 no configurada)');
String bodega10 = LUREYE_Bodega_SAP_Service.determinarBodega(30000, '5', 'Venta Normal');
System.debug('   Input: LN=30000, Región=5, HES=Venta Normal');
System.debug('   Output: ' + (bodega10 != null ? bodega10 : 'null'));
System.debug('   Esperado: null');
System.debug('   Resultado: ' + (bodega10 == null ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 11: Sin Dirección de Despacho (región null)
System.debug('🧪 CASO 11: Sin Dirección de Despacho');
String bodega11 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, null, 'Venta Normal');
System.debug('   Input: LN=21000, Región=null, HES=Venta Normal');
System.debug('   Output: ' + (bodega11 != null ? bodega11 : 'null'));
System.debug('   Esperado: VTLE (TODAS las regiones)');
System.debug('   Resultado: ' + (bodega11 == 'VTLE' ? '✅ PASS' : '❌ FAIL') + '\n');

// Caso 12: HES sobreescribe a GE (prioridad)
System.debug('🧪 CASO 12: HES sobreescribe a GE (Prioridad 1 > Prioridad 2)');
String bodega12 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'HES');
System.debug('   Input: LN=21000 (también match VTLE), Región=13, HES=HES');
System.debug('   Output: ' + (bodega12 != null ? bodega12 : 'null'));
System.debug('   Esperado: VTADFL10 (no VTLE, por prioridad)');
System.debug('   Resultado: ' + (bodega12 == 'VTADFL10' ? '✅ PASS' : '❌ FAIL') + '\n');

// ========================================================================
// RESUMEN FINAL
// ========================================================================

System.debug('\n=============================================================');
System.debug('📊 RESUMEN DE VALIDACIÓN');
System.debug('=============================================================');

Integer totalCasos = 12;
Integer casosPass = 0;

if (bodega1 == 'VTADFL10') casosPass++;
if (bodega2 == 'VTADFL10') casosPass++;
if (bodega3 == 'VTLE') casosPass++;
if (bodega4 == 'VTLE') casosPass++;
if (bodega5 == 'VTLE') casosPass++;
if (bodega6 == 'ST10') casosPass++;
if (bodega7 == 'STA10') casosPass++;
if (bodega8 == 'STSP10') casosPass++;
if (bodega9 == 'STC10') casosPass++;
if (bodega10 == null) casosPass++;
if (bodega11 == 'VTLE') casosPass++;
if (bodega12 == 'VTADFL10') casosPass++;

System.debug('Total casos probados: ' + totalCasos);
System.debug('Casos PASS: ' + casosPass + ' ✅');
System.debug('Casos FAIL: ' + (totalCasos - casosPass) + ' ❌');
System.debug('Pass Rate: ' + ((casosPass * 100) / totalCasos) + '%');

if (casosPass == totalCasos) {
    System.debug('\n🎉🎉🎉 ¡TODAS LAS VALIDACIONES PASARON! 🎉🎉🎉');
    System.debug('✅ La lógica de determinación de bodega funciona correctamente.');
    System.debug('✅ Puedes proceder con las pruebas manuales en Quotes.');
} else {
    System.debug('\n⚠️ ATENCIÓN: Algunos casos fallaron.');
    System.debug('❌ Revisa las configuraciones del Custom Metadata Type.');
    System.debug('❌ Verifica que los 6 registros estén activos y con datos correctos.');
}

System.debug('\n=============================================================');
System.debug('🏁 FIN DE VALIDACIÓN');
System.debug('=============================================================');

