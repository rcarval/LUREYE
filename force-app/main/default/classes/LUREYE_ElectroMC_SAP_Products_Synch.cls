public with sharing class LUREYE_ElectroMC_SAP_Products_Synch {
	public static void syncProductsWithSAP(String sapLoginDeveloperName) {
		LUREYE_Servicios_SAP.setLoginByDeveloperName(sapLoginDeveloperName);
		List<Product2> productosModificadosHoy = new List<Product2>();
		List<Product2> productsToUpdate = new List<Product2>();
		List<Product2> productsToInsert = new List<Product2>();
		Set<String> sapProductCodes = new Set<String>();

		try {
			List<SAPProduct> sapProducts = getProductsFromSAP();
			System.debug('🟢 [syncProductsWithSAP] Productos obtenidos de SAP: ' + sapProducts.size());

			if (sapProducts == null || sapProducts.isEmpty()) {
				return;
			}

			for (SAPProduct sp : sapProducts) {
				sapProductCodes.add(sp.ItemCode);
			}

			Map<String, Product2> existingProductsMap = getExistingProductsMap(sapProductCodes);
			for (SAPProduct sp : sapProducts) {
				if (existingProductsMap.containsKey(sp.ItemCode)) {
					Product2 productToUpdate = existingProductsMap.get(sp.ItemCode);
					Date fechaHoy = Date.today();
					Date fechaUltimaModificacion = productToUpdate.LastModifiedDate.date();

					if (fechaHoy == fechaUltimaModificacion && !Test.isRunningTest()) {
						productosModificadosHoy.add(productToUpdate);
						continue;
					}

					productToUpdate.IsActive = sp.Valid == 'tYES' ? true : false;
					productToUpdate.Branch__c = '96971110-9';
					productToUpdate.ProductCode = sp.ItemCode;
					productToUpdate.CodigoJDE__c = sp.U_SkuPre;
					productToUpdate.cod_proveedor__c = sp.Mainsupplier;
					productToUpdate.Description = sp.ItemName;
					productToUpdate.DescripcionVenta__c = sp.ItemName;
					productToUpdate.CurrencyIsoCode = sp.U_Currency;
					productToUpdate.Family = sp.U_Family;
					productToUpdate.Marca__c = sp.Manufacturer;
					if (sapLoginDeveloperName == 'LoginEM') {
						productToUpdate.Negocio__c = 'Electromecánica';
						productToUpdate.LineaComercial__c = sp.U_Categoria;
						productToUpdate.Branch__c = '96971110-9';
					} else if (sapLoginDeveloperName == 'LoginGE') {
						productToUpdate.Negocio__c = 'Generación, Servicios';
						productToUpdate.Motor__c = sp.U_MMotor;
						productToUpdate.Nodo__c = sp.U_PoNo;
						productToUpdate.Branch__c = '93141000-8';
					} else {
						System.debug('🟢 [syncProductsWithSAP] sapLoginDeveloperName no reconocido***');
						
					}
					productToUpdate.Name = sp.ItemName;
					productToUpdate.StockKeepingUnit = sp.ItemCode;
					productToUpdate.QuantityUnitOfMeasure = 'UN';

					productsToUpdate.add(productToUpdate);

				} else {
					Product2 productoToInsert = new Product2();
					productoToInsert.IsActive = sp.Valid == 'tYES' ? true : false;					
					productoToInsert.ProductCode = sp.ItemCode;
					productoToInsert.CodigoJDE__c = sp.U_SkuPre;
					productoToInsert.cod_proveedor__c = sp.Mainsupplier;
					productoToInsert.Description = sp.ItemName;
					productoToInsert.DescripcionVenta__c = sp.ItemName;
					productoToInsert.CurrencyIsoCode = sp.U_Currency;
					productoToInsert.Family = sp.U_Family;					
					productoToInsert.Marca__c = sp.Manufacturer;

					if (sapLoginDeveloperName == 'LoginEM') {
						productoToInsert.Negocio__c = 'Electromecánica';
						productoToInsert.LineaComercial__c = sp.U_Categoria;
						productoToInsert.Branch__c = '96971110-9';
					} else if (sapLoginDeveloperName == 'LoginGE') {
						productoToInsert.Negocio__c = 'Generación, Servicios';
						productoToInsert.Motor__c = sp.U_MMotor;
						productoToInsert.Nodo__c = sp.U_PoNo;
						productoToInsert.Branch__c = '93141000-8';
					} else {
						System.debug('🟢 [syncProductsWithSAP] sapLoginDeveloperName no reconocido***');
					}
					productoToInsert.Name = sp.ItemName; 
					productoToInsert.StockKeepingUnit = sp.ItemCode;
					productoToInsert.QuantityUnitOfMeasure = 'UN';

					productsToInsert.add(productoToInsert);
				}

			}
			System.debug('🟢 [syncProductsWithSAP] Productos a actualizar: ' + productsToUpdate.size());
			System.debug('🟢 [syncProductsWithSAP] Productos a insertar: ' + productsToInsert.size());
			if (productosModificadosHoy.size() > 0) {
				System.debug('🟢 [syncProductsWithSAP] Productos modificados hoy: ' + productosModificadosHoy.size());
				System.debug('🟢 [syncProductsWithSAP] Productos modificados hoy: ' + productosModificadosHoy);
			}

			//update productsToUpdate;
			//insert productsToInsert;
		
			/* if (!productsToInsert.isEmpty()) {
				notifyUsersOfNewProducts(productsToInsert);
			} */

		} catch (Exception e) {
			System.debug('🛑 [syncProductsWithSAP] Excepción***: ' + e.getMessage());
		}
	}

	public static List<SAPProduct> testSAPProducts = null;



	
	public static List<SAPProduct> getProductsFromSAP() {
		SL_Login_JSON loginJson = new SL_Login_JSON();
		SAP__mdt loginSAP = new SAP__mdt();
		

		if (Test.isRunningTest() && testSAPProducts != null) {
			return testSAPProducts;
		}

		if (!Test.isRunningTest()) {
			loginJson = LUREYE_Servicios_SAP.callLogin();
			System.debug('🟢 [getProductsFromSAP] Login exitoso: ' + loginJson.sessionId);

		} else {
			loginJson = (SL_Login_JSON) JSON.deserialize(
				'{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',
				SL_Login_JSON.class
			);
		}

		if (loginJson != null) {
			loginSAP = LUREYE_Servicios_SAP.login;
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			HttpResponse response = new HttpResponse();

			Date ayer = Date.today().addDays(-1);
			//String fecha = String.valueOf(ayer);
			String fecha = '2024-06-18';
			System.debug('FECHA AYER***' + fecha);

			String filtro = 'UpdateDate gt \'' + fecha + '\'';
			String camposSelect;
			String consultaEM = System.Label.SAP_Campos_SAP_EM;
			String consultaGE = System.Label.SAP_Campos_SAP_GE;

			if (LUREYE_Servicios_SAP.developerName == 'LoginEM') {
				System.debug('🟢 [getProductsFromSAP] DeveloperName***: LoginEM');
				camposSelect = consultaEM;
			} else if (LUREYE_Servicios_SAP.developerName == 'LoginGE') {
				System.debug('🟢 [getProductsFromSAP] DeveloperName***: LoginGE');
				camposSelect = consultaGE;
			} else {
				System.debug('🟢 [getProductsFromSAP] DeveloperName no reconocido***');
				//camposSelect = 'Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_Categoria,Manufacturer,U_FamCod2';
			}

			String endpoint = loginSAP.Endpoint__c + '/Items?$select=' + camposSelect + '&$filter=' + EncodingUtil.urlEncode(filtro, 'UTF-8');


			//String endpoint = loginSAP.Endpoint__c + '/Items?$select=Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_Categoria,Manufacturer,U_FamCod2&$filter=' + EncodingUtil.urlEncode(filtro, 'UTF-8');
			request.setEndpoint(endpoint);

			request.setMethod('GET');
			request.setHeader('Accept', '*/*');
			request.setHeader('Cookie', 'B1SESSION=' + loginJson.sessionId + '; ROUTEID=.node1');

			response = http.send(request);
			System.debug('🟢 req***->' + request.getEndpoint());

			if (response.getStatusCode() == 200) {
				System.debug('🟢 Respuesta exitosa***');
				System.debug(response.getBody());
				LUREYE_Servicios_SAP.callLogout(loginJson.sessionId);
			} else {
				System.debug('Error al obtener los datos del producto***');
				System.debug('response.getBody()***: ' + response.getBody());
			}
			SAPProductResponseWrapper wrapper = (SAPProductResponseWrapper) JSON.deserialize(response.getBody(), SAPProductResponseWrapper.class);
			return wrapper.value;
		}

		return null;
	}

	
	private static Map<String, Product2> getExistingProductsMap(Set<String> productCodes) {
		Map<String, Product2> productsMap = new Map<String, Product2>();
		
		List<Product2> porducts = [SELECT Id, IsActive, AMP__c, Branch__c, CreatedById ,ProductCode, CodigoJDE__c, Description, cod_proveedor__c,
							DescripcionVenta__c,CurrencyIsoCode, Family,ExternalDataSourceId, ExternalId, Imagen__c, ImagenMax__c, 
							LineaComercial__c, Marca__c,Modelo__c,ModeloComercial__c, Motor__c, Negocio__c, Nodo__c, Name, ProductoNoMix__c, 
							StockKeepingUnit, Subfamilia__c, Subfamilia2__c, Tipo__c, Ultima_Actualizaci_n_Inventario__c, QuantityUnitOfMeasure, 
							DisplayUrl, LastModifiedDate, CreatedDate
							FROM Product2
						  WHERE ProductCode IN :productCodes];

		for (Product2 product : porducts) {
			productsMap.put(product.ProductCode, product);
		}

		System.debug('🟢 [getExistingProductsMap] Productos encontrados***: ' + productsMap.keySet());
		return productsMap;      
	}

	public class SAPProductResponseWrapper {
		public List<SAPProduct> value;
	}
	public class SAPProduct {
		public String Valid;
		public String ItemCode;
		public String U_SkuPre;
		public String Mainsupplier;
		public String ItemName;
		public String U_Currency;
		public String U_Family;
		public String U_Categoria;
		public String U_MMotor;
		public String U_PoNo;
		public String Manufacturer;
		public String U_FamCod2;
	} 

	/*
	private static void notifyUsersOfNewProducts(List<Product2> newProducts) {

		//List<User> targetUsers = [SELECT Id, Name, Email FROM User WHERE Profile.Name = '60 - Ofertista' AND IsActive = true];
		List<User> targetUsers = [SELECT Id, Name, Email FROM User WHERE Email = 'customer_success.cl@seidor.com' AND IsActive = true];
		List<User> campanitaUsers = [SELECT Id, Name, Email FROM User WHERE Email = 'customer_success.cl@seidor.com' AND IsActive = true];


		System.debug('🟢 Usuarios a notificar: ' + targetUsers.size());

		if (targetUsers.isEmpty()) {
			System.debug('⚠️ No se encontraron usuarios para notificar.');
			return;
		}

		String emailBody = 'Estimado usuario,\n\nSe han creado los siguientes productos sin precio asignado:\n\n';
		String notifBody = 'Se han creado los siguientes productos sin precio asignado:\n\n';

		for (Product2 p : newProducts) {
			emailBody += 'Código: ' + p.ProductCode + '\n';
			emailBody += 'Nombre: ' + p.Name + '\n';
			emailBody += 'Unidad de Negocio: Electromecánica ' + '\n';
			emailBody += 'Fecha de creación: ' + p.CreatedDate + '\n';
			emailBody += 'Mensaje: Producto creado sin precio asignado. Favor ingresar a la lista de precios correspondiente.\n\n';

			notifBody += 'Código: ' + p.ProductCode + '\n';
			notifBody += 'Nombre: ' + p.Name + '\n';
			notifBody += 'Unidad de Negocio: Electromecánica' + '\n';
			notifBody += 'Fecha de creación: ' + p.CreatedDate + '\n';
			notifBody += 'Mensaje: Producto creado sin precio asignado. Favor ingresar a la lista de precios correspondiente.\n\n';
		}

		emailBody += '\nSaludos cordiales.\nSistema de Integración SAP-Salesforce';

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for (User u : targetUsers) {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(new List<String> { 'dewin1998vi@gmail.com' });
			email.setSubject('Notificación: Producto/s creado/s sin precio asignado en Salesforce');
			email.setPlainTextBody(emailBody);
			emails.add(email);
		}

		try {
			if (!emails.isEmpty()) {
				Messaging.sendEmail(emails);
				System.debug('📧 Correos enviados a usuarios.');
			} else {
				System.debug('⚠️ No se enviaron correos, lista de emails vacía.');
			}
		} catch (Exception e) {
			System.debug('🛑 Error al enviar correos: ' + e.getMessage());
		}        

		Id notifTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'SAP_Producto_Creado' LIMIT 1].Id;

		Messaging.CustomNotification notification = new Messaging.CustomNotification();
		String listView = '000000000000000AAA';
		string pageRef = '/lightning/o/Product2/list?filterName=TEST';
		String addressTest = 
		'{"type": "standard__webPage", ' +
		'"attributes": { ' +
		'    "url": "https://lureye--uat.sandbox.lightning.force.com/lightning/o/Product2/list?filterName=TEST" ' +
		'} }';


		for (User u : targetUsers) {            
			notification.setNotificationTypeId(notifTypeId);
			notification.setTitle('Notificación: Producto/s creado/s sin precio asignado en Salesforce');
			notification.setBody(notifBody);
			notification.setTargetPageRef(addressTest);
			notification.setSenderId(UserInfo.getUserId());                

			try {
				notification.send(new Set<String>{u.Id});
				System.debug('Notificación enviada a ' + u.Name);
			} catch (Exception e) {
				System.debug('Error al notificar a ' + u.Name + ': ' + e.getMessage());
			}
		}        
	}*/      
}