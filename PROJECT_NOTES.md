# Convenciones Apex - LUREYE

## Nomenclatura

### Clases
- **PascalCase** con prefijo `LUREYE_`
- Ejemplos: `LUREYE_Product_Synch_from_SAP`, `LUREYE_Servicios_SAP`

### Métodos
- **camelCase**
- Ejemplos: `syncProductsWithSAP()`, `getProductsFromSAP()`

### Variables
- **camelCase**
- Ejemplos: `sapLoginDeveloperName`, `productosModificadosHoy`

## Logs y Debug

Usar emojis para identificar rápidamente el tipo de mensaje:

- ✔️ `System.debug('✔️ ...')` - Operación exitosa
- ⚠️ `System.debug('⚠️ ...')` - Advertencia o situación no crítica
- ⛔ `System.debug('⛔ ...')` - Error o fallo
- 🔄 `System.debug('🔄 ...')` - Update de registros
- 🆕 `System.debug('🆕 ...')` - Insert de registros
- 🔌 `System.debug('🔌 ...')` - Llamadas HTTP/Callouts
- 📧 `System.debug('📧 ...')` - Envío de emails
- 🔎 `System.debug('🔎 ...')` - Búsquedas/Queries

## Testing

### Cobertura
- **Mínima requerida**: 75%
- **Recomendada**: 85%+

### Buenas prácticas
- Siempre usar `Test.startTest()` y `Test.stopTest()` para resetear límites
- Mockear llamadas HTTP usando variables estáticas como `testSAPProducts`
- Usar `@isTest` en vez de `testMethod`
- Nombrar métodos de test descriptivamente: `test_WhenX_ThenY()`

### Ejemplo de mock HTTP
```apex
LUREYE_Product_Synch_from_SAP.testSAPProducts = createMockSAPProducts();
```

## Integraciones SAP

### Autenticación
- Usar siempre `LUREYE_Servicios_SAP.setLoginByDeveloperName()`
- **LoginEM**: Electromecánica (Branch: 96971110-9)
- **LoginGE**: Generación (Branch: 93141000-8)

### Campos específicos por unidad de negocio

#### Electromecánica (LoginEM)
- `Negocio__c = 'Electromecánica'`
- `LineaComercial__c = sp.U_Categoria`
- `Branch__c = '96971110-9'`

#### Generación (LoginGE)
- `Negocio__c = 'Generación;Servicios'`
- `Motor__c = sp.U_MMotor`
- `Nodo__c = sp.U_PoNo`
- `SuppCatNum__c = sp.SupplierCatalogNo`
- `Aplicacion__c = sp.ForeignName`
- `Branch__c = '93141000-8'`

### Parámetros de sincronización
- `diasMenos = -1`: Trae productos desde ayer (recomendado para jobs diarios)
- `diasMenos = 0`: Solo productos de hoy
- `diasMenos = -7`: Últimos 7 días (recovery)

## Estructura de Clases de Integración

### Patrón estándar
1. Método invocable público
2. Método de obtención de datos de SAP
3. Método de mapeo/transformación
4. Métodos de notificación (separados por unidad de negocio)
5. Clases wrapper para deserialización JSON

### Ejemplo
```apex
@InvocableMethod
public static List<String> syncProductsWithSAP(List<Input> entradas) {
    // 1. Login SAP
    LUREYE_Servicios_SAP.setLoginByDeveloperName(sapLoginDeveloperName);
    
    // 2. Obtener datos
    List<SAPProduct> sapProducts = getProductsFromSAP(diasMenos);
    
    // 3. Transformar y guardar
    // ...
    
    // 4. Notificar
    if (sapLoginDeveloperName == 'LoginGE') {
        notifyUsersOfProducts_GE(productsToInsert);
    }
}
```

## Manejo de Errores

### Try-Catch completo
```apex
try {
    // código
} catch (Exception e) {
    System.debug('⛔ Error: ' + e.getMessage());
    System.debug('⛔ Stack: ' + e.getStackTraceString());
    System.debug('⛔ Cause: ' + e.getCause());
    System.debug('⛔ Line: ' + e.getLineNumber());
}
```

## Scripts NPM Disponibles

### Testing
- `npm run apex:test` - Ejecutar todos los tests Apex
- `npm run apex:test:class -- ClassName` - Ejecutar test de clase específica

### Deployment
- `npm run apex:deploy` - Desplegar a org
- `npm run apex:deploy:validate` - Validar sin desplegar

### Análisis
- `npm run apex:scan` - Análisis estático con PMD

### LWC
- `npm run test:unit` - Tests unitarios LWC
- `npm run test:unit:watch` - Tests en modo watch

## Notas Importantes

- Siempre validar que `sapLoginDeveloperName` sea `LoginEM` o `LoginGE`
- Los filtros de fecha usan `Date.today().addDays(diasMenos)`
- Productos modificados hoy en SF pueden ser protegidos de actualización (revisar lógica según caso)
- Las notificaciones usan Custom Notification Type `SAP_Producto_Creado`



