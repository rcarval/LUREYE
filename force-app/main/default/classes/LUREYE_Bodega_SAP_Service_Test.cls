// ========================================================================
// RCG - 13/11/2025 - Ticket N° 00024376 - INICIO
// Tests para LUREYE_Bodega_SAP_Service
// ========================================================================
@isTest
private class LUREYE_Bodega_SAP_Service_Test {
	
	@isTest
	static void test_HES_RetornaVTADFL10() {
		// Arrange
		Decimal lineaNegocio = 21000;
		String regionDespacho = '13';
		String requiereHES = 'HES';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('VTADFL10', bodega, 'HES debe retornar VTADFL10 siempre (prioridad máxima)');
	}
	
	@isTest
	static void test_802_RetornaVTADFL10() {
		// Arrange
		Decimal lineaNegocio = 22000;
		String regionDespacho = '2';
		String requiereHES = '802';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('VTADFL10', bodega, '802 debe retornar VTADFL10 siempre');
	}
	
	@isTest
	static void test_HES_SobreescribeGE() {
		// Arrange - Aunque sea GE Relacional, HES debe ganar
		Decimal lineaNegocio = 21000; // Normalmente sería VTLE
		String regionDespacho = '13';
		String requiereHES = 'HES';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('VTADFL10', bodega, 'HES debe sobrescribir cualquier otra regla (incluso GE)');
	}
	
	@isTest
	static void test_GE_Relacional_RetornaVTLE() {
		// Arrange
		Decimal lineaNegocio = 21000; // RELACIONAL
		String regionDespacho = '13'; // Santiago
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('VTLE', bodega, 'GE Relacional (21000) debe retornar VTLE');
	}
	
	@isTest
	static void test_GE_Proyecto_RetornaVTLE() {
		// Arrange
		Decimal lineaNegocio = 15000; // PROYECTOS
		String regionDespacho = '2'; // Antofagasta
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('VTLE', bodega, 'GE Proyecto (15000) debe retornar VTLE independiente de región');
	}
	
	@isTest
	static void test_GE_Transaccional_RetornaVTLE() {
		// Arrange
		Decimal lineaNegocio = 10000; // TRANSACCIONAL
		String regionDespacho = '8'; // Concepción
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('VTLE', bodega, 'GE Transaccional (10000) debe retornar VTLE');
	}
	
	@isTest
	static void test_Servicio_Santiago_RetornaST10() {
		// Arrange
		Decimal lineaNegocio = 22000; // SERVICIO
		String regionDespacho = '13'; // Región Metropolitana (Santiago)
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('ST10', bodega, 'Servicio en Santiago (región 13) debe retornar ST10');
	}
	
	@isTest
	static void test_Servicio_Antofagasta_RetornaSTA10() {
		// Arrange
		Decimal lineaNegocio = 22000; // SERVICIO
		String regionDespacho = '2'; // II Región (Antofagasta)
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('STA10', bodega, 'Servicio en Antofagasta (región 2) debe retornar STA10');
	}
	
	@isTest
	static void test_Servicio_PuertoMontt_RetornaSTSP10() {
		// Arrange
		Decimal lineaNegocio = 22000; // SERVICIO
		String regionDespacho = '10'; // X Región (Los Lagos - Puerto Montt)
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('STSP10', bodega, 'Servicio en Puerto Montt (región 10) debe retornar STSP10');
	}
	
	@isTest
	static void test_Servicio_Concepcion_RetornaSTC10() {
		// Arrange
		Decimal lineaNegocio = 22000; // SERVICIO
		String regionDespacho = '8'; // VIII Región (Bío Bío - Concepción/Talcahuano)
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals('STC10', bodega, 'Servicio en Concepción (región 8) debe retornar STC10');
	}
	
	@isTest
	static void test_LineaNoConfigurada_RetornaNull() {
		// Arrange - Línea de negocio no configurada (ej: CANAL KAM)
		Decimal lineaNegocio = 17000; // CANAL KAM (no configurado)
		String regionDespacho = '13'; // Santiago
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals(null, bodega, 'Línea de negocio no configurada debe retornar null (SAP usa default)');
	}
	
	@isTest
	static void test_ServicioSinRegion_RetornaNull() {
		// Arrange - Servicio sin región de despacho
		Decimal lineaNegocio = 22000; // SERVICIO
		String regionDespacho = null; // Sin dirección de despacho
		String requiereHES = 'Venta Normal';
		
		// Act
		Test.startTest();
		String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, regionDespacho, requiereHES);
		Test.stopTest();
		
		// Assert
		System.assertEquals(null, bodega, 'Servicio sin región debe retornar null');
	}
	
	@isTest
	static void test_ObtenerConfiguracion_Existente() {
		// Act
		Test.startTest();
		Bodega_SAP__mdt config = LUREYE_Bodega_SAP_Service.obtenerConfiguracion('VTLE');
		Test.stopTest();
		
		// Assert
		System.assertNotEquals(null, config, 'Debe encontrar configuración de VTLE');
		System.assertEquals('VTLE', config.Codigo_Bodega_SAP__c);
	}
	
	@isTest
	static void test_ObtenerConfiguracion_NoExiste() {
		// Act
		Test.startTest();
		Bodega_SAP__mdt config = LUREYE_Bodega_SAP_Service.obtenerConfiguracion('BODEGA_INEXISTENTE');
		Test.stopTest();
		
		// Assert
		System.assertEquals(null, config, 'Bodega inexistente debe retornar null');
	}
	
	@isTest
	static void test_ValidarRequiereHES_TODAS() {
		// Act
		Test.startTest();
		Boolean resultado = LUREYE_Bodega_SAP_Service.validarRequiereHES('TODAS', 'Venta Normal');
		Test.stopTest();
		
		// Assert
		System.assertEquals(true, resultado, 'TODAS debe aceptar cualquier valor');
	}
	
	@isTest
	static void test_ValidarLineaNegocio_Multiple() {
		// Act
		Test.startTest();
		Boolean resultado1 = LUREYE_Bodega_SAP_Service.validarLineaNegocio('21000,15000,10000', '21000');
		Boolean resultado2 = LUREYE_Bodega_SAP_Service.validarLineaNegocio('21000,15000,10000', '15000');
		Boolean resultado3 = LUREYE_Bodega_SAP_Service.validarLineaNegocio('21000,15000,10000', '22000');
		Test.stopTest();
		
		// Assert
		System.assertEquals(true, resultado1, '21000 debe estar en la lista');
		System.assertEquals(true, resultado2, '15000 debe estar en la lista');
		System.assertEquals(false, resultado3, '22000 NO debe estar en la lista');
	}
	
	@isTest
	static void test_ValidarRegion_Multiple() {
		// Act
		Test.startTest();
		Boolean resultado1 = LUREYE_Bodega_SAP_Service.validarRegion('2,8,10', '2');
		Boolean resultado2 = LUREYE_Bodega_SAP_Service.validarRegion('2,8,10', '13');
		Test.stopTest();
		
		// Assert
		System.assertEquals(true, resultado1, 'Región 2 debe estar en la lista');
		System.assertEquals(false, resultado2, 'Región 13 NO debe estar en la lista');
	}
}
// ========================================================================
// RCG - 13/11/2025 - Ticket N° 00024376 - FIN
// ========================================================================

