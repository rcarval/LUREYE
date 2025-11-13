// ========================================================================
// RCG - 13/11/2025 - Ticket N° 00024376 - INICIO
// Clase helper para determinar bodega SAP según reglas de negocio
// ========================================================================
public with sharing class LUREYE_Bodega_SAP_Service {
	
	/**
	 * Determina el código de bodega SAP según reglas de negocio configuradas en Custom Metadata
	 * @param lineaNegocio - Código de línea de negocio del usuario (User.Linea_Negocio__c)
	 * @param regionDespacho - Código de región de la dirección de despacho (Direccion__c.Region__c)
	 * @param requiereHES - Valor del campo Quote.RequiereHES__c
	 * @return Código de bodega SAP (WarehouseCode) o null si no encuentra match
	 */
	public static String determinarBodega(Decimal lineaNegocio, String regionDespacho, String requiereHES) {
		
		System.debug('🏭 [BODEGA] ========== INICIO DETERMINACIÓN BODEGA ==========');
		System.debug('🏭 [BODEGA] LineaNegocio: ' + lineaNegocio);
		System.debug('🏭 [BODEGA] RegionDespacho: ' + regionDespacho);
		System.debug('🏭 [BODEGA] RequiereHES: ' + requiereHES);
		
		// Obtener todas las configuraciones activas ordenadas por prioridad
		List<Bodega_SAP__mdt> configuraciones = obtenerConfiguracionesActivas();
		
		if (configuraciones.isEmpty()) {
			System.debug('⛔ [BODEGA] No hay configuraciones activas en Custom Metadata');
			return null;
		}
		
		String lineaNegocioStr = lineaNegocio != null ? String.valueOf(lineaNegocio).split('\\.')[0] : null;
		
		// Recorrer configuraciones en orden de prioridad
		for (Bodega_SAP__mdt config : configuraciones) {
			
			System.debug('🔍 [BODEGA] Evaluando: ' + config.Label + ' (Prioridad: ' + config.Prioridad__c + ')');
			
			// Validar RequiereHES
			if (!validarRequiereHES(config.Requiere_HES__c, requiereHES)) {
				System.debug('  ❌ No cumple RequiereHES. Config: ' + config.Requiere_HES__c + ' vs Quote: ' + requiereHES);
				continue;
			}
			
			// Validar Línea de Negocio
			if (!validarLineaNegocio(config.Linea_Negocio__c, lineaNegocioStr)) {
				System.debug('  ❌ No cumple LineaNegocio. Config: ' + config.Linea_Negocio__c + ' vs User: ' + lineaNegocioStr);
				continue;
			}
			
			// Validar Región
			if (!validarRegion(config.Region_Despacho__c, regionDespacho)) {
				System.debug('  ❌ No cumple Región. Config: ' + config.Region_Despacho__c + ' vs Despacho: ' + regionDespacho);
				continue;
			}
			
			// Si llegó aquí, encontró match
			System.debug('✅ [BODEGA] MATCH ENCONTRADO: ' + config.Codigo_Bodega_SAP__c + ' - ' + config.Nombre_Bodega__c);
			System.debug('🏭 [BODEGA] ========== FIN DETERMINACIÓN BODEGA ==========');
			return config.Codigo_Bodega_SAP__c;
		}
		
		// No encontró ninguna configuración que haga match
		System.debug('⚠️ [BODEGA] No se encontró configuración que coincida con los criterios');
		System.debug('🏭 [BODEGA] ========== FIN DETERMINACIÓN BODEGA (NULL) ==========');
		return null;
	}
	
	/**
	 * Obtiene todas las configuraciones activas ordenadas por prioridad
	 */
	@TestVisible
	private static List<Bodega_SAP__mdt> obtenerConfiguracionesActivas() {
		return [
			SELECT Label, Linea_Negocio__c, Region_Despacho__c, Requiere_HES__c, 
				   Codigo_Bodega_SAP__c, Nombre_Bodega__c, Prioridad__c, Activo__c
			FROM Bodega_SAP__mdt
			WHERE Activo__c = true
			ORDER BY Prioridad__c ASC, DeveloperName ASC
		];
	}
	
	/**
	 * Valida si el valor de RequiereHES cumple con la configuración
	 * @param configHES - Valores configurados (ej: "HES,802", "VENTA_NORMAL", "TODAS")
	 * @param quoteHES - Valor del campo Quote.RequiereHES__c
	 * @return true si cumple la condición
	 */
	@TestVisible
	private static Boolean validarRequiereHES(String configHES, String quoteHES) {
		
		if (String.isBlank(configHES)) {
			return true; // Sin restricción
		}
		
		if (configHES.trim().equalsIgnoreCase('TODAS')) {
			return true;
		}
		
		// Si config dice VENTA_NORMAL, acepta "Venta Normal" o null
		if (configHES.trim().equalsIgnoreCase('VENTA_NORMAL')) {
			return (quoteHES == 'Venta Normal' || String.isBlank(quoteHES));
		}
		
		// Buscar coincidencia en lista separada por comas
		List<String> valoresConfig = configHES.split(',');
		for (String valor : valoresConfig) {
			if (valor.trim().equalsIgnoreCase(quoteHES)) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Valida si la línea de negocio cumple con la configuración
	 * @param configLineas - Líneas configuradas (ej: "21000,15000,10000", "22000", "TODAS")
	 * @param userLinea - Línea de negocio del usuario (solo número: "21000")
	 * @return true si cumple la condición
	 */
	@TestVisible
	private static Boolean validarLineaNegocio(String configLineas, String userLinea) {
		
		if (String.isBlank(configLineas)) {
			return true; // Sin restricción
		}
		
		if (configLineas.trim().equalsIgnoreCase('TODAS')) {
			return true;
		}
		
		if (String.isBlank(userLinea)) {
			return false; // Usuario sin línea de negocio no puede hacer match
		}
		
		// Buscar coincidencia en lista separada por comas
		List<String> lineasConfig = configLineas.split(',');
		for (String linea : lineasConfig) {
			if (linea.trim() == userLinea.trim()) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Valida si la región de despacho cumple con la configuración
	 * @param configRegiones - Regiones configuradas (ej: "13", "2,8,10", "TODAS")
	 * @param despachoRegion - Región de la dirección de despacho (ej: "13", "2")
	 * @return true si cumple la condición
	 */
	@TestVisible
	private static Boolean validarRegion(String configRegiones, String despachoRegion) {
		
		if (String.isBlank(configRegiones)) {
			return true; // Sin restricción
		}
		
		if (configRegiones.trim().equalsIgnoreCase('TODAS')) {
			return true;
		}
		
		if (String.isBlank(despachoRegion)) {
			// Si la configuración requiere región específica pero no hay región, no cumple
			// EXCEPCIÓN: Si config dice TODAS, ya retornó true arriba
			return false;
		}
		
		// Buscar coincidencia en lista separada por comas
		List<String> regionesConfig = configRegiones.split(',');
		for (String region : regionesConfig) {
			if (region.trim() == despachoRegion.trim()) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Obtiene la configuración de una bodega específica (útil para debugging)
	 * @param codigoBodega - Código de bodega SAP
	 * @return Configuración de la bodega o null si no existe
	 */
	public static Bodega_SAP__mdt obtenerConfiguracion(String codigoBodega) {
		
		if (String.isBlank(codigoBodega)) {
			return null;
		}
		
		List<Bodega_SAP__mdt> configs = [
			SELECT Label, Linea_Negocio__c, Region_Despacho__c, Requiere_HES__c,
				   Codigo_Bodega_SAP__c, Nombre_Bodega__c, Prioridad__c, Activo__c
			FROM Bodega_SAP__mdt
			WHERE Codigo_Bodega_SAP__c = :codigoBodega 
			  AND Activo__c = true
			LIMIT 1
		];
		
		return configs.isEmpty() ? null : configs[0];
	}
}
// ========================================================================
// RCG - 13/11/2025 - Ticket N° 00024376 - FIN
// ========================================================================

