public without sharing class LUREYE_Product_Synch_from_SAP {
	public static Boolean forceCallLoginInTest = false;
	public static Boolean skipUpdateCheck = false;
    
    public Class Input {
        @InvocableVariable(label='sapLoginDeveloperName')
        public String sapLoginDeveloperName;
        
        @InvocableVariable(label='diasMenos')
        public Integer diasMenos;
    }

	@InvocableMethod(label='Sincronizar Productos con SAP' description='Sincroniza productos desde SAP')
	public static List<String> syncProductsWithSAP(List<Input> entradas) {
		String message ='Integración exitosa';
		List<String> result = new List<String>();
		
		if (entradas.isEmpty()) {
            return null; 
        }

		String sapLoginDeveloperName = entradas[0].sapLoginDeveloperName;
        Integer diasMenos            = entradas[0].diasMenos;


		LUREYE_Servicios_SAP.setLoginByDeveloperName(sapLoginDeveloperName);
		List<Product2> productosModificadosHoy = new List<Product2>();
		List<Product2> productsToUpdate = new List<Product2>();
		List<Product2> productsToInsert = new List<Product2>();
		Set<String> sapProductCodes = new Set<String>();

		try {
			List<SAPProduct> sapProducts = getProductsFromSAP(diasMenos);
			System.debug('📔✔️ Productos obtenidos de SAP: ' + sapProducts.size());

			if (sapProducts == null || sapProducts.isEmpty()) {
				System.debug('📔⚠️ No se obtuvieron productos de SAP o la lista está vacía.');
				return null;
			}

			for (SAPProduct sp : sapProducts) {
				sapProductCodes.add(sp.ItemCode);
			}

			Map<String, Product2> existingProductsMap = getExistingProductsMap(sapProductCodes);
			for (SAPProduct sp : sapProducts) {
				if (existingProductsMap.containsKey(sp.ItemCode)) {
					Product2 productToUpdate = existingProductsMap.get(sp.ItemCode);
					Datetime fechaHoy = Date.today();
					Datetime fechaUltimaModificacion = productToUpdate.LastModifiedDate.date();
					/* RCG - 05/11/2025 -Se retira filtro de actualizaciones dentro del mismo día
					if (fechaHoy == fechaUltimaModificacion && (!Test.isRunningTest() || !skipUpdateCheck)) {						
						productosModificadosHoy.add(productToUpdate);
						System.debug('⚠️✔️ Producto modificado hoy, no se actualiza: ' + productToUpdate.ProductCode);
						continue;
					}
					*/
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
						productToUpdate.Negocio__c = 'Generación;Servicios';
						productToUpdate.Motor__c = sp.U_MMotor;
						productToUpdate.Nodo__c = sp.U_PoNo;
						productToUpdate.SuppCatNum__c = sp.SupplierCatalogNo;
						productToUpdate.Aplicacion__c = sp.ForeignName;
						productToUpdate.Branch__c = '93141000-8';
					} else {
						System.debug('⛔❌ SAP LoginDeveloperName no reconocido');
						
					}
					productToUpdate.Name = sp.ItemCode;
					productToUpdate.StockKeepingUnit = sp.ItemCode;
					productToUpdate.QuantityUnitOfMeasure = 'UN';

					productsToUpdate.add(productToUpdate);
					System.debug('🔄✔️ Producto a actualizar: ' + productToUpdate.ProductCode);

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
						productoToInsert.Negocio__c = 'Generación;Servicios';
						productoToInsert.Motor__c = sp.U_MMotor;
						productoToInsert.Nodo__c = sp.U_PoNo;
						productoToInsert.SuppCatNum__c = sp.SupplierCatalogNo;
						productoToInsert.Aplicacion__c	= sp.ForeignName;
						productoToInsert.Branch__c = '93141000-8';
					} else {
						System.debug('⛔❌ SAP LoginDeveloperName no reconocido');
					}
					productoToInsert.Name = sp.ItemCode; 
					productoToInsert.StockKeepingUnit = sp.ItemCode;
					productoToInsert.QuantityUnitOfMeasure = 'UN';

					productsToInsert.add(productoToInsert);
					System.debug('🆕✔️ Producto a insertar: ' + productoToInsert.ProductCode);
				}

			}
			System.debug('🔄✔️ Productos a actualizar: ' + productsToUpdate.size());
			System.debug('🆕✔️ Productos a insertar: ' + productsToInsert.size());
			if (productosModificadosHoy.size() > 0) {
				System.debug('⚠️✔️ Productos modificados hoy: ' + productosModificadosHoy.size());
			}

			update productsToUpdate;
			insert productsToInsert;
		
			if ((!productsToInsert.isEmpty() || !productosModificadosHoy.isEmpty()) && (productsToInsert.size() > 0 || productosModificadosHoy.size() > 0)) {
				 if (sapLoginDeveloperName == 'LoginGE') {
					notifyUsersOfProducts_GE(productsToInsert, productosModificadosHoy);
				} else if (sapLoginDeveloperName == 'LoginEM') {
					notifyUsersOfProducts_EM(productsToInsert, productosModificadosHoy);
				}
			} else {
				System.debug('🔄✔️ No hay productos nuevos o modificados hoy para notificar.');
			}
			result.add(message);

		} catch (Exception e) {
			System.debug('⛔❌Excepción: ' + e.getMessage());
			System.debug('⛔❌Stack Trace: ' + e.getStackTraceString());
			System.debug('⛔❌Cause: ' + e.getCause());
			System.debug('⛔❌Line Number: ' + e.getLineNumber());
			System.debug('⛔❌Type***: ' + e.getTypeName());
			message = 'Error al sincronizar productos con SAP: ' + e.getMessage();
			result.add(message);
		}
		return result;
	}

	public static List<SAPProduct> testSAPProducts = null;
	
	public static List<SAPProduct> getProductsFromSAP(Integer diasMenos) {
		SL_Login_JSON loginJson = new SL_Login_JSON();
		SAP__mdt loginSAP = new SAP__mdt();
		

		if (Test.isRunningTest() && testSAPProducts != null) {
			return testSAPProducts;
		}

		if (!Test.isRunningTest() || forceCallLoginInTest) {
            System.debug(LUREYE_Servicios_SAP.login);
			loginJson = LUREYE_Servicios_SAP.callLogin();
			System.debug('✔️ [getProductsFromSAP] Login exitoso: ' + loginJson.sessionId);

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

			Date ayer = Date.today().addDays(diasMenos);
            System.debug('ayer->'+ayer);
			String fecha = String.valueOf(ayer);
			//String fecha = '2025-09-24';
			System.debug('Fecha hoy***' + fecha);

			String filtro = 'UpdateDate ge \'' + fecha + '\'';
			String camposSelect;
			String consultaEM = System.Label.SAP_Campos_SAP_EM;
			String consultaGE = System.Label.SAP_Campos_SAP_GE;

			if (LUREYE_Servicios_SAP.developerName == 'LoginEM') {
				System.debug('✔️ DeveloperName***: LoginEM');
				camposSelect = consultaEM;
			} else if (LUREYE_Servicios_SAP.developerName == 'LoginGE') {
				System.debug('✔️ DeveloperName***: LoginGE');
				camposSelect = consultaGE;
			} else {
				System.debug('⛔❌ DeveloperName no reconocido***');
				//camposSelect = 'Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_Categoria,Manufacturer,U_FamCod2';
			}

			String endpoint = loginSAP.Endpoint__c + 'Items?$select=' + camposSelect + '&$filter=' + EncodingUtil.urlEncode(filtro, 'UTF-8');
			//String endpoint = loginSAP.Endpoint__c + 'Items(\'200001496\')';
			System.debug('LUREYE endpoint --->_ '+endpoint);

			//String endpoint = loginSAP.Endpoint__c + '/Items?$select=Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_Categoria,Manufacturer,U_FamCod2&$filter=' + EncodingUtil.urlEncode(filtro, 'UTF-8');
			request.setEndpoint(endpoint);

			request.setMethod('GET');
			request.setHeader('Accept', '*/*');
			request.setHeader('Cookie', 'B1SESSION=' + loginJson.sessionId + '; ROUTEID=.node1');

			response = http.send(request);
			System.debug('✔️ Request***->' + request.getEndpoint());

			if (response.getStatusCode() == 200) {
				System.debug('🔌✔️ Respuesta exitosa***');
				System.debug(response.getBody());
				LUREYE_Servicios_SAP.callLogout(loginJson.sessionId);
			} else {
				System.debug('⛔ Error al obtener los datos del producto***');
				System.debug('⛔ Response.getBody()***: ' + response.getBody());
			}
			SAPProductResponseWrapper wrapper = (SAPProductResponseWrapper) JSON.deserialize(response.getBody(), SAPProductResponseWrapper.class);
			return wrapper.value;
		}

		return null;
	}

	private static Map<String, Product2> getExistingProductsMap(Set<String> productCodes) {
		Map<String, Product2> productsMap = new Map<String, Product2>();
		
		List<Product2> porducts = [SELECT Id, IsActive, AMP__c, Branch__c, CreatedById ,ProductCode, CodigoJDE__c, Description, cod_proveedor__c, Aplicacion__c, SuppCatNum__c,
							DescripcionVenta__c,CurrencyIsoCode, Family,ExternalDataSourceId, ExternalId, Imagen__c, ImagenMax__c, 
							LineaComercial__c, Marca__c,Modelo__c,ModeloComercial__c, Motor__c, Negocio__c, Nodo__c, Name, ProductoNoMix__c, 
							StockKeepingUnit, Subfamilia__c, Subfamilia2__c, Tipo__c, Ultima_Actualizaci_n_Inventario__c, QuantityUnitOfMeasure, 
							DisplayUrl, LastModifiedDate, CreatedDate
							FROM Product2
						  WHERE ProductCode IN :productCodes];

		for (Product2 product : porducts) {
			productsMap.put(product.ProductCode, product);
		}

		System.debug('🔎☁️✔️ Productos encontrados en Salesforce***: ' + productsMap.keySet());
		System.debug('🔎☁️✔️ Cantidad de productos encontrados en Salesforce***: ' + productsMap.size());
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
		public String SupplierCatalogNo;
		public String ForeignName;
	}

	private static void notifyUsersOfProducts_GE(List<Product2> newProducts, List<Product2> productsModifiedToday) {
		List<Product2> productos_GE = new List<Product2>();
		List<Product2> productosGE_Hoy = new List<Product2>();

		for (Product2 p : newProducts) {
			if (p.Negocio__c != null && p.Negocio__c.contains('Generación')) productos_GE.add(p);
		}
		for (Product2 p : productsModifiedToday) {
			if (p.Negocio__c != null && p.Negocio__c.contains('Generación')) productosGE_Hoy.add(p);
		}

		notifyOnlyGE(productos_GE, productosGE_Hoy);
	}

	private static void notifyOnlyGE(List<Product2> productos_GE, List<Product2> productosGE_Hoy) {
		List<User> targetUsers_GE = [SELECT Id, Name, Email, Branch__c, IsActive FROM User WHERE Name IN ('Patricio Garrido', 'Jorge Diaz Acuña', 'Isidora Zuñiga Sepulveda') AND IsActive = true];

		Date fechaHoy = Date.today();
		String emailBody = '';
		String emailBody_Hoy = '';
		String notifBody = '';
		String notifBody_Hoy = '';
		List<Messaging.SingleEmailMessage> emailsToNotify = new List<Messaging.SingleEmailMessage>();
		Id notifTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'SAP_Producto_Creado' LIMIT 1].Id;
		
		String listViewRecentGE = 
		'{"type": "standard__webPage", ' +
		'"attributes": { ' +
		'    "url": "https://lureye.lightning.force.com/lightning/o/Product2/list?filterName=Generacion" ' +
		'} }';

		for (User u : targetUsers_GE) {
			if (!productos_GE.isEmpty() && productos_GE.size() > 0) {
				emailBody = 'Se han creado los siguientes productos sin precio asignado:<br/><br/>';
				notifBody = 'Se han creado los siguientes productos sin precio asignado:\n\n';
				for (Product2 p : productos_GE) {
					String productoLink = 'https://lureye.lightning.force.com/lightning/r/Product2/' + p.Id + '/view';
					emailBody += 'Código: ' + p.ProductCode + '<br/>';
					emailBody += 'Nombre: ' + p.Name + '<br/>';
					emailBody += 'Unidad de negocio: ' + p.Negocio__c + '<br/>';
					emailBody += 'Fecha de creación: ' + fechaHoy.format() + '<br/>';
					emailBody += 'Ver producto: <a href="' + productoLink + '">Click aquí</a><br/><br/>';

					notifBody += 'Código: ' + p.ProductCode + '\n';
					notifBody += 'Nombre: ' + p.Name + '\n';
					notifBody += 'Unidad de negocio: ' + p.Negocio__c + '\n';
					notifBody += 'Fecha de creación: ' + fechaHoy.format() + '\n\n';
				}
				emailBody += '<br/>Sistema de Integración SAP-Salesforce';
				notifBody += '\nSistema de Integración SAP-Salesforce';

				Messaging.SingleEmailMessage emailInsert_GE = new Messaging.SingleEmailMessage();
				emailInsert_GE.setToAddresses(new List<String> { u.Email });
				emailInsert_GE.setSubject('¡Producto/s Generación creado/s sin precio asignado.!');
				emailInsert_GE.setHtmlBody(emailBody);
				emailsToNotify.add(emailInsert_GE);
			} else {
				System.debug('⚠️ No se encontraron productos de Generación para notificar inserción.');
			}
			
			if (!productosGE_Hoy.isEmpty() && productosGE_Hoy.size() > 0) {	
				emailBody_Hoy = 'Los siguientes productos no han sido actualizados, ya que presentaron modificaciones en la fecha actual:<br/><br/>';
				notifBody_Hoy = 'Los siguientes productos no han sido actualizados, ya que presentaron modificaciones en la fecha actual:\n\n';		
				for (Product2 p : productosGE_Hoy) {
					String productoLink = 'https://lureye.lightning.force.com/lightning/r/Product2/' + p.Id + '/view';				
					emailBody_Hoy += 'Código: ' + p.ProductCode + '<br/>';
					emailBody_Hoy += 'Nombre: ' + p.Name + '<br/>';
					emailBody_Hoy += 'Unidad de negocio: ' + p.Negocio__c + '<br/>';
					emailBody_Hoy += 'Fecha de modificación: ' + p.LastModifiedDate + '<br/>';
					emailBody_Hoy += 'Ver producto: <a href="' + productoLink + '">Click aquí</a><br/><br/>';

					notifBody_Hoy += 'Código: ' + p.ProductCode + '\n';
					notifBody_Hoy += 'Nombre: ' + p.Name + '\n';
					notifBody_Hoy += 'Unidad de negocio: ' + p.Negocio__c + '\n';
					notifBody_Hoy += 'Fecha de modificación: ' + p.LastModifiedDate + '\n\n';
				}
				emailBody_Hoy += '<br/>Sistema de Integración SAP-Salesforce';
				notifBody_Hoy += '\nSistema de Integración SAP-Salesforce';

				
				Messaging.SingleEmailMessage emailUpdate_Hoy_GE = new Messaging.SingleEmailMessage();
				emailUpdate_Hoy_GE.setToAddresses(new List<String> { u.Email });
				emailUpdate_Hoy_GE.setSubject('¡Producto/s Generación modificado/s hoy, no se actualizan.!');
				emailUpdate_Hoy_GE.setHtmlBody(emailBody_Hoy);
				emailsToNotify.add(emailUpdate_Hoy_GE);
			
			} else {
				System.debug('⚠️ No se encontraron productos de Generación modificados hoy para notificar.');
			}
			
			Messaging.CustomNotification notifityInsert_GE = new Messaging.CustomNotification();
			Messaging.CustomNotification notifyBody_Hoy_GE = new Messaging.CustomNotification();						

			if (!String.isBlank(notifBody)) {
				try {
					notifityInsert_GE.setNotificationTypeId(notifTypeId);
					notifityInsert_GE.setTitle('¡Producto/s Generación creado/s sin precio asignado en Salesforce.!');
					notifityInsert_GE.setBody(notifBody);
					notifityInsert_GE.setTargetPageRef(listViewRecentGE);
					notifityInsert_GE.setSenderId(UserInfo.getUserId());
					notifityInsert_GE.send(new Set<String>{u.Id});
					System.debug('Notificación enviada a ' + u.Name);
				} catch (Exception e) {
					System.debug('Error al notificar a ' + u.Name + ': ' + e.getMessage());
					System.debug('Error al notificar a ' + u.Name + '- Stack: ' + e.getStackTraceString());
					System.debug('Error al notificar a ' + u.Name + '- Cause: ' + e.getCause());
					System.debug('Error al notificar a ' + u.Name + '- Line Number: ' + e.getLineNumber());
				}
			}

			if (!String.isBlank(notifBody_Hoy)) {			
				try {
					notifyBody_Hoy_GE.setNotificationTypeId(notifTypeId);
					notifyBody_Hoy_GE.setTitle('¡Producto/s Generación modificado/s hoy, no se actualizan.!');
					notifyBody_Hoy_GE.setBody(notifBody_Hoy);
					notifyBody_Hoy_GE.setTargetPageRef(listViewRecentGE);
					notifyBody_Hoy_GE.setSenderId(UserInfo.getUserId());
					notifyBody_Hoy_GE.send(new Set<String>{u.Id});
					System.debug('Notificación enviada a ' + u.Name);
				} catch (Exception e) {
					System.debug('Error al notificar a ' + u.Name + ': ' + e.getMessage());
					System.debug('Error al notificar a ' + u.Name + '- Stack: ' + e.getStackTraceString());
					System.debug('Error al notificar a ' + u.Name + '- Cause: ' + e.getCause());
					System.debug('Error al notificar a ' + u.Name + '- Line Number: ' + e.getLineNumber());
					
				}
			}			
		}
		try {
			if (!emailsToNotify.isEmpty()) {
				Messaging.sendEmail(emailsToNotify);
				System.debug('📧 Correos enviados a usuarios.');
				System.debug('📧 Cantidad de correos enviados: ' + emailsToNotify.size());
			} else {
				System.debug('⚠️ No se enviaron correos, lista de emailsToNotify vacía.');
			}
		} catch (Exception e) {
			System.debug('⛔ Error al enviar correos: ' + e.getMessage());
			System.debug('⛔ Stack Trace: ' + e.getStackTraceString());
			System.debug('⛔ Cause: ' + e.getCause());
			System.debug('⛔ Line Number: ' + e.getLineNumber());
			System.debug('⛔ Type: ' + e.getTypeName());
			
		}
	}

	private static void notifyUsersOfProducts_EM(List<Product2> newProducts, List<Product2> productsModifiedToday) {
		List<Product2> productos_EM = new List<Product2>();
		List<Product2> productosEM_Hoy = new List<Product2>();

		for (Product2 p : newProducts) {
			if (p.Negocio__c != null && p.Negocio__c.contains('Electromecánica')) productos_EM.add(p);
		}
		for (Product2 p : productsModifiedToday) {
			if (p.Negocio__c != null && p.Negocio__c.contains('Electromecánica')) productosEM_Hoy.add(p);
		}

		notifyOnlyEM(productos_EM, productosEM_Hoy);
	}


	private static void notifyOnlyEM(List<Product2> productos_EM, List<Product2> productosEM_Hoy) {
		List<User> targetUsers_EM = [SELECT Id, Name, Email, Branch__c, IsActive FROM User WHERE Name = 'Victoria Espina' AND IsActive = true];
		
		Date fechaHoy = Date.today();
		String emailBody = '';
		String emailBody_Hoy = '';
		String notifBody = '';
		String notifBody_Hoy = '';
		List<Messaging.SingleEmailMessage> emailsToNotify = new List<Messaging.SingleEmailMessage>();
		Id notifTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'SAP_Producto_Creado' LIMIT 1].Id;

		String listViewRecentEM = 
		'{"type": "standard__webPage", ' +
		'"attributes": { ' +
		'    "url": "https://lureye.lightning.force.com/lightning/o/Product2/list?filterName=Electromecanica" ' +
		'} }';

		
		for (User u : targetUsers_EM) {
			if (!productos_EM.isEmpty() && productos_EM.size() > 0) {
				emailBody = 'Se han creado los siguientes productos sin precio asignado:<br/><br/>';
				notifBody = 'Se han creado los siguientes productos sin precio asignado:\n\n';
				for (Product2 p : productos_EM) {
					String productoLink = 'https://lureye.lightning.force.com/lightning/r/Product2/' + p.Id + '/view';
					emailBody += 'Código: ' + p.ProductCode + '<br/>';
					emailBody += 'Nombre: ' + p.Name + '<br/>';
					emailBody += 'Unidad de negocio: ' + p.Negocio__c + '<br/>';
					emailBody += 'Fecha de creación: ' + fechaHoy.format() + '<br/>';
					emailBody += 'Ver producto: <a href="' + productoLink + '">Click aquí</a><br/><br/>';

					notifBody += 'Código: ' + p.ProductCode + '\n';
					notifBody += 'Nombre: ' + p.Name + '\n';
					notifBody += 'Unidad de negocio: ' + p.Negocio__c + '\n';
					notifBody += 'Fecha de creación: ' + fechaHoy.format() + '\n\n';
				}
				emailBody += '<br/>Sistema de Integración SAP-Salesforce';
				notifBody += '\nSistema de Integración SAP-Salesforce';

				Messaging.SingleEmailMessage emailInsert_EM = new Messaging.SingleEmailMessage();
				emailInsert_EM.setToAddresses(new List<String> { u.Email });
				emailInsert_EM.setSubject('Producto/s Electromecánica creado/s sin precio asignado.!');
				emailInsert_EM.setHtmlBody(emailBody);
				emailsToNotify.add(emailInsert_EM);
			} else {
				System.debug('⚠️ No se encontraron productos de Electromecánica para notificar inserción.');
			}
			
			if (!productosEM_Hoy.isEmpty() && productosEM_Hoy.size() > 0) {
				emailBody_Hoy = 'Los siguientes productos no han sido actualizados, ya que presentaron modificaciones en la fecha actual:<br/><br/>';
				notifBody_Hoy = 'Los siguientes productos no han sido actualizados, ya que presentaron modificaciones en la fecha actual:\n\n';
				for (Product2 p : productosEM_Hoy) {
					String productoLink = 'https://lureye.lightning.force.com/lightning/r/Product2/' + p.Id + '/view';
					emailBody_Hoy += 'Código: ' + p.ProductCode + '<br/>';
					emailBody_Hoy += 'Nombre: ' + p.Name + '<br/>';
					emailBody_Hoy += 'Unidad de negocio: ' + p.Negocio__c + '<br/>';
					emailBody_Hoy += 'Fecha de modificación: ' + p.LastModifiedDate + '<br/>';
					emailBody_Hoy += 'Ver producto: <a href="' + productoLink + '">Click aquí</a><br/><br/>';

					notifBody_Hoy += 'Código: ' + p.ProductCode + '\n';
					notifBody_Hoy += 'Nombre: ' + p.Name + '\n';
					notifBody_Hoy += 'Unidad de negocio: ' + p.Negocio__c + '\n';
					notifBody_Hoy += 'Fecha de modificación: ' + p.LastModifiedDate + '\n\n';
				}
				emailBody_Hoy += '<br/>Sistema de Integración SAP-Salesforce';
				notifBody_Hoy += '\nSistema de Integración SAP-Salesforce';

				Messaging.SingleEmailMessage emailHoy_EM = new Messaging.SingleEmailMessage();
				emailHoy_EM.setToAddresses(new List<String> { u.Email });
				emailHoy_EM.setSubject('Producto/s Electromecánica modificado/s hoy, no se actualizan.!');
				emailHoy_EM.setHtmlBody(emailBody_Hoy);
				emailsToNotify.add(emailHoy_EM);
			
			} else {
				System.debug('⚠️ No se encontraron productos de Electromecánica modificados hoy para notificar.');
			}
			Messaging.CustomNotification notifyInsert_EM = new Messaging.CustomNotification();
			Messaging.CustomNotification notifyBody_Hoy_EM = new Messaging.CustomNotification();			

			if (!String.isBlank(notifBody)) {
				try {
					notifyInsert_EM.setNotificationTypeId(notifTypeId);
					notifyInsert_EM.setTitle('¡Producto/s Electromecánica creado/s sin precio asignado en Salesforce.!');
					notifyInsert_EM.setBody(notifBody);
					notifyInsert_EM.setTargetPageRef(listViewRecentEM);
					notifyInsert_EM.setSenderId(UserInfo.getUserId());
					notifyInsert_EM.send(new Set<String>{u.Id});
					System.debug('Notificación enviada a ' + u.Name);
				} catch (Exception e) {
					System.debug('Error al notificar a ' + u.Name + '- Messahe: ' + e.getMessage());
					System.debug('Error al notificar a ' + u.Name + '- Stack: ' + e.getStackTraceString());
					System.debug('Error al notificar a ' + u.Name + '- Cause: ' + e.getCause());
					System.debug('Error al notificar a ' + u.Name + '- Line Number: ' + e.getLineNumber());

				}
			}
			if (!String.isBlank(notifBody_Hoy)) {
				try {
					notifyBody_Hoy_EM.setNotificationTypeId(notifTypeId);
					notifyBody_Hoy_EM.setTitle('¡Producto/s Electromecánica modificado/s hoy, no se actualizan.!');
					notifyBody_Hoy_EM.setBody(notifBody_Hoy);
					notifyBody_Hoy_EM.setTargetPageRef(listViewRecentEM);
					notifyBody_Hoy_EM.setSenderId(UserInfo.getUserId());
					notifyBody_Hoy_EM.send(new Set<String>{u.Id});
					System.debug('Notificación enviada a ' + u.Name);
				} catch (Exception e) {
					System.debug('Error al notificar a ' + u.Name + '- Message: ' + e.getMessage());
					System.debug('Error al notificar a ' + u.Name + '- Stack: ' + e.getStackTraceString());
					System.debug('Error al notificar a ' + u.Name + '- Cause: ' + e.getCause());
					System.debug('Error al notificar a ' + u.Name + '- Line Number: ' + e.getLineNumber());			

				}
			}
		}

		try {
			if (!emailsToNotify.isEmpty()) {
				Messaging.sendEmail(emailsToNotify);
				System.debug('📧 Correos enviados a usuarios.');
				System.debug('📧 Cantidad de correos enviados: ' + emailsToNotify.size());
			} else {
				System.debug('⚠️ No se enviaron correos, lista de emailsToNotify vacía.');
			}
		} catch (Exception e) {
			System.debug('⛔ Error al enviar correos: ' + e.getMessage());
			System.debug('⛔ Stack Trace: ' + e.getStackTraceString());
			System.debug('⛔ Cause: ' + e.getCause());
			System.debug('⛔ Line Number: ' + e.getLineNumber());
			System.debug('⛔ Type: ' + e.getTypeName());
		}

	}
}