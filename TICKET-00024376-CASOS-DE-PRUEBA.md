# 📋 Ticket 00024376 - Casos de Prueba y Validación

**Fecha:** 13 Noviembre 2025  
**Desarrollador:** Rodrigo Carvallo  
**Ambiente:** Sandbox UAT (`admin.seidor@lureye.com.uat`)  
**Tiempo estimado:** 45-60 minutos

---

## 🎯 OBJETIVO DE LAS PRUEBAS

Validar que la **asignación dinámica de bodegas SAP** funciona correctamente según:
1. **Línea de Negocio** del usuario
2. **Región de Despacho** de la dirección
3. **Condición HES** (`RequiereHES__c`)

---

## ✅ PRE-REQUISITOS

### 1. Validar que el Custom Metadata Type existe

**Ir a:** Setup > Custom Metadata Types > Bodega SAP

**Validar:**
- ✅ Custom Metadata Type "Bodega SAP" existe
- ✅ 7 campos custom creados
- ✅ 6 registros de configuración activos

### 2. Validar que las clases están deployadas

**Ir a:** Setup > Apex Classes

**Buscar:**
- ✅ `LUREYE_Bodega_SAP_Service`
- ✅ `LUREYE_Bodega_SAP_Service_Test`
- ✅ `LUREYE_Drafts_SAP` (modificado)

### 3. Validar que los tests pasaron

Ya ejecutados: **17/17 tests passed (100%)** ✅

---

## 🧪 CASOS DE PRUEBA

### CASO 1: HES/802 → Bodega VTADFL10 (Prioridad Máxima)

**Escenario:** Condición de pago HES o 802 **siempre** debe ir a `VTADFL10` sin importar línea de negocio o región.

#### Datos del Usuario
- **Perfil:** Vendedor GE
- **Línea de Negocio:** 21000 (Relacional)
- **Branch:** Cualquiera (ej: 93141000-8)

#### Datos de la Cuenta
- **RUT:** 76123456-7
- **Razón Social:** Test HES Cliente
- **Dirección Despacho:**
  - Región: `13` (Metropolitana)
  - Ciudad: Santiago
  - Calle: Av. Test 123

#### Datos de la Cotización
- **Nombre:** Test HES-802
- **Glosa:** Prueba bodega HES
- **N° Orden Compra:** OC-HES-001
- **Condición de Pago:** Contado
- **RequiereHES:** `HES` o `802`
- **DirDespacho:** Seleccionar la dirección creada
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `VTADFL10`
- **Debug log debe mostrar:**
  ```
  🏭 [BODEGA] Línea Negocio: 21000
  🏭 [BODEGA] RegionDespacho: 13
  🏭 [BODEGA] RequiereHES: HES
  🔍 [BODEGA] Evaluando: HES-802 Override (Prioridad: 1)
  ✅ [BODEGA] Match encontrado: VTADFL10
  🏭 [BODEGA] Bodega asignada: VTADFL10
  ```

#### 🔍 Validación en SAP (después de crear Draft)
1. Login a SAP
2. Buscar el Draft creado (número aparece en el mensaje de éxito)
3. Abrir el Draft
4. **Ir a:** Línea de pedido (DocumentLines)
5. **Validar:** Campo `WarehouseCode` = `VTADFL10`

---

### CASO 2: GE Relacional → Bodega VTLE

**Escenario:** Línea de negocio 21000 (Relacional) con venta normal debe ir a `VTLE`.

#### Datos del Usuario
- **Perfil:** Vendedor GE
- **Línea de Negocio:** `21000` (Relacional)
- **Branch:** 93141000-8

#### Datos de la Cuenta
- **RUT:** 76234567-8
- **Razón Social:** Test GE Relacional
- **Dirección Despacho:**
  - Región: `13` (Metropolitana)
  - Ciudad: Santiago
  - Calle: Av. GE Test 456

#### Datos de la Cotización
- **Nombre:** Test GE Relacional
- **Glosa:** Prueba bodega VTLE
- **N° Orden Compra:** OC-GE-REL-001
- **Condición de Pago:** Contado
- **RequiereHES:** `Venta Normal`
- **DirDespacho:** Seleccionar dirección con Región 13
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `VTLE`
- **Debug log debe mostrar:**
  ```
  🏭 [BODEGA] Línea Negocio: 21000
  🏭 [BODEGA] RegionDespacho: 13
  🏭 [BODEGA] RequiereHES: Venta Normal
  🔍 [BODEGA] Evaluando: HES-802 Override (Prioridad: 1)
    ❌ No cumple RequiereHES
  🔍 [BODEGA] Evaluando: GE Ventas VTLE (Prioridad: 2)
  ✅ [BODEGA] Match encontrado: VTLE
  🏭 [BODEGA] Bodega asignada: VTLE
  ```

---

### CASO 3: Servicio Santiago → Bodega ST10

**Escenario:** Línea de negocio 22000 (Servicio) en Región 13 (Santiago) debe ir a `ST10`.

#### Datos del Usuario
- **Perfil:** Vendedor Servicio
- **Línea de Negocio:** `22000` (Servicio)
- **Branch:** 93141000-8

#### Datos de la Cuenta
- **RUT:** 76345678-9
- **Razón Social:** Test Servicio Santiago
- **Dirección Despacho:**
  - Región: `13` (Metropolitana) ← **IMPORTANTE**
  - Ciudad: Santiago
  - Calle: Av. Servicio 789

#### Datos de la Cotización
- **Nombre:** Test Servicio Santiago
- **Glosa:** Prueba bodega ST10
- **N° Orden Compra:** OC-SRV-STG-001
- **Condición de Pago:** Crédito
- **RequiereHES:** `Venta Normal`
- **DirDespacho:** Dirección con Región 13
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `ST10`
- **Debug log debe mostrar:**
  ```
  🏭 [BODEGA] Línea Negocio: 22000
  🏭 [BODEGA] RegionDespacho: 13
  🏭 [BODEGA] RequiereHES: Venta Normal
  🔍 [BODEGA] Evaluando: HES-802 Override (Prioridad: 1)
    ❌ No cumple RequiereHES
  🔍 [BODEGA] Evaluando: GE Ventas VTLE (Prioridad: 2)
    ❌ No cumple Línea Negocio
  🔍 [BODEGA] Evaluando: Servicio Santiago ST10 (Prioridad: 3)
  ✅ [BODEGA] Match encontrado: ST10
  🏭 [BODEGA] Bodega asignada: ST10
  ```

---

### CASO 4: Servicio Antofagasta → Bodega STA10

**Escenario:** Línea de negocio 22000 (Servicio) en Región 2 (Antofagasta) debe ir a `STA10`.

#### Datos del Usuario
- **Perfil:** Vendedor Servicio
- **Línea de Negocio:** `22000` (Servicio)
- **Branch:** 93141000-8

#### Datos de la Cuenta
- **RUT:** 76456789-0
- **Razón Social:** Test Servicio Antofagasta
- **Dirección Despacho:**
  - Región: `2` (II - Antofagasta) ← **IMPORTANTE**
  - Ciudad: Antofagasta
  - Calle: Av. Norte 1234

#### Datos de la Cotización
- **Nombre:** Test Servicio Antofagasta
- **Glosa:** Prueba bodega STA10
- **N° Orden Compra:** OC-SRV-ANT-001
- **Condición de Pago:** Crédito
- **RequiereHES:** `Venta Normal`
- **DirDespacho:** Dirección con Región 2
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `STA10`

---

### CASO 5: Servicio Puerto Montt → Bodega STSP10

**Escenario:** Línea de negocio 22000 (Servicio) en Región 10 (Los Lagos) debe ir a `STSP10`.

#### Datos del Usuario
- **Perfil:** Vendedor Servicio
- **Línea de Negocio:** `22000` (Servicio)
- **Branch:** 93141000-8

#### Datos de la Cuenta
- **RUT:** 76567890-1
- **Razón Social:** Test Servicio Puerto Montt
- **Dirección Despacho:**
  - Región: `10` (X - Los Lagos) ← **IMPORTANTE**
  - Ciudad: Puerto Montt
  - Calle: Av. Sur 5678

#### Datos de la Cotización
- **Nombre:** Test Servicio Puerto Montt
- **Glosa:** Prueba bodega STSP10
- **N° Orden Compra:** OC-SRV-PM-001
- **Condición de Pago:** Crédito
- **RequiereHES:** `Venta Normal`
- **DirDespacho:** Dirección con Región 10
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `STSP10`

---

### CASO 6: Servicio Concepción → Bodega STC10

**Escenario:** Línea de negocio 22000 (Servicio) en Región 8 (Bío Bío) debe ir a `STC10`.

#### Datos del Usuario
- **Perfil:** Vendedor Servicio
- **Línea de Negocio:** `22000` (Servicio)
- **Branch:** 93141000-8

#### Datos de la Cuenta
- **RUT:** 76678901-2
- **Razón Social:** Test Servicio Concepción
- **Dirección Despacho:**
  - Región: `8` (VIII - Bío Bío) ← **IMPORTANTE**
  - Ciudad: Concepción
  - Calle: Av. Este 9012

#### Datos de la Cotización
- **Nombre:** Test Servicio Concepción
- **Glosa:** Prueba bodega STC10
- **N° Orden Compra:** OC-SRV-CON-001
- **Condición de Pago:** Crédito
- **RequiereHES:** `Venta Normal`
- **DirDespacho:** Dirección con Región 8
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `STC10`

---

### CASO 7: Sin Match → Bodega NULL (Default SAP)

**Escenario:** Configuración que no coincide con ninguna regla debe enviar `null` (SAP usa su bodega default).

#### Datos del Usuario
- **Perfil:** Vendedor EM
- **Línea de Negocio:** `30000` (Otra línea no configurada)
- **Branch:** 93141000-8

#### Datos de la Cuenta
- **RUT:** 76789012-3
- **Razón Social:** Test Sin Configuración
- **Dirección Despacho:**
  - Región: `5` (V - Valparaíso)
  - Ciudad: Valparaíso
  - Calle: Av. Oeste 3456

#### Datos de la Cotización
- **Nombre:** Test Sin Match
- **Glosa:** Prueba sin bodega configurada
- **N° Orden Compra:** OC-NOMATCH-001
- **Condición de Pago:** Crédito
- **RequiereHES:** `Venta Normal`
- **DirDespacho:** Dirección con Región 5
- **DirFacturacion:** Seleccionar una dirección
- **Fecha Entrega:** Cualquier fecha futura
- **Productos:** 1 producto activo con precio

#### ✅ Resultado Esperado
- **Bodega asignada:** `null` (no se envía a SAP)
- **Debug log debe mostrar:**
  ```
  🏭 [BODEGA] Bodega asignada: SIN BODEGA (SAP usará default)
  ```
- **En SAP:** El Draft se crea sin `WarehouseCode` específico

---

## 📝 PASOS PARA CREAR Y PROBAR CADA CASO

### PASO 1: Crear/Validar Usuario de Prueba (5 min)

1. **Ir a:** Setup > Users
2. **Buscar o Crear** un usuario con:
   - `Linea_Negocio__c` = valor del caso (21000, 22000, etc.)
   - `Branch__c` = 93141000-8
   - `CodigoUN__c` = GE o EM según corresponda
   - `Codigo_SAP__c` = Cualquier valor (ej: 100)

**NOTA:** Si no tienes permisos para crear usuarios, usa tu propio usuario y **cambia temporalmente** el campo `Linea_Negocio__c` para cada prueba.

---

### PASO 2: Crear Account y Direcciones (5 min por caso)

1. **Ir a:** Tab Cuentas > New

2. **Llenar datos del Account:**
   - RUT_SD__c: Número del caso
   - RUT_DV__c: Dígito verificador
   - Name: Nombre del caso
   - CurrencyIsoCode: CLP

3. **Guardar**

4. **Crear Dirección de Facturación:**
   - Related > Direcciones > New
   - Tipo: `Facturación`
   - Name: Facturación
   - Street: CALLE PRUEBA
   - StreetNo: 123
   - Ciudad: SANTIAGO
   - Comuna: SANTIAGO
   - Region__c: `13` (Metropolitana)
   - TaxCode: IVA
   - Guardar

5. **Crear Dirección de Despacho:**
   - Related > Direcciones > New
   - Tipo: `Despacho`
   - Name: Despacho
   - Street: CALLE DESPACHO
   - StreetNo: 456
   - Ciudad: Según caso
   - Comuna: Según caso
   - **Region__c:** **Usar el valor del caso** (13, 2, 10, 8, etc.) ← **MUY IMPORTANTE**
   - TaxCode: IVA
   - Guardar

---

### PASO 3: Crear Oportunidad (3 min)

1. **Desde el Account:** Related > Opportunities > New

2. **Llenar:**
   - Opportunity Name: Opp Test [Nombre del Caso]
   - Stage: Definición necesidad
   - Close Date: Fecha futura
   - Record Type: GE Comercial - Industrial (o el que corresponda)
   - CurrencyIsoCode: CLP
   - Guardar

3. **Agregar Producto:**
   - Related > Products > Add Products
   - Seleccionar 1 producto activo
   - Quantity: 1
   - Sales Price: 100000
   - Guardar

4. **Cambiar Stage:**
   - Edit Opportunity
   - Stage: `Cotización`
   - Guardar

---

### PASO 4: Crear Cotización (5 min)

1. **Desde la Oportunidad:** Related > Quotes > New Quote

2. **Llenar campos obligatorios:**
   ```
   Quote Name:          [Nombre del Caso]
   Glosa:              [Glosa del Caso]
   N° Orden Compra:    [OC del Caso]
   Condición de Pago:   Contado o Crédito
   RequiereHES:        HES / 802 / Venta Normal (según caso)
   Fecha Entrega:       Fecha futura (ej: 31/12/2025)
   DirDespacho:        Seleccionar la dirección con la REGIÓN correcta ← CRÍTICO
   DirFacturacion:     Seleccionar dirección de facturación
   ```

3. **Guardar**

4. **Agregar Productos a la Quote:**
   - Edit Lines
   - Seleccionar el producto de la Opportunity
   - Quantity: 1
   - Sales Price: 100000
   - Guardar

---

### PASO 5: Ejecutar Creación de Draft (2 min)

1. **Abrir la Cotización** creada

2. **Click en el botón:** `Crear Draft en SAP`
   - Ubicación: Arriba a la derecha (junto a "Submit for Approval", etc.)

3. **Esperar:** Aparecerá un modal con mensaje de carga

4. **Ver resultado:**
   - ✅ **Éxito:** "¡Se ha creado el Draft XXXX exitosamente en SAP!"
   - ❌ **Error:** Mensaje de error (falta algún campo obligatorio)

---

### PASO 6: Ver Debug Logs (3 min)

1. **Ir a:** Setup > Debug Logs

2. **Habilitar tu usuario:**
   - Debug Logs > New
   - User: Tu usuario
   - Start Time: Now
   - Expiration: 1 hora
   - Guardar

3. **Ejecutar** la creación de Draft nuevamente (o crear una nueva cotización)

4. **Refrescar** Debug Logs

5. **Abrir el último log**

6. **Buscar en el log:** `[BODEGA]`

7. **Validar** que los mensajes debug muestran:
   - Línea de Negocio recibida
   - Región de Despacho recibida
   - RequiereHES recibido
   - Evaluación de cada regla
   - Bodega final asignada

---

### PASO 7: Validar en SAP (5 min)

1. **Login a SAP Business One:**
   - URL: https://lureye.exxiscloud.com:50000
   - Usuario: [Credenciales SAP]

2. **Ir a:** Ventas > Oportunidades de venta > Borrador de documento de marketing

3. **Buscar el Draft** por número (aparece en el mensaje de éxito de Salesforce)

4. **Abrir el Draft**

5. **Ir a la pestaña:** Contenido / Líneas / DocumentLines

6. **Validar cada línea de producto:**
   - Click en una línea
   - Ver el campo `Almacén` o `WarehouseCode`
   - **Debe coincidir** con el valor esperado del caso

---

## 🔍 VALIDACIONES ADICIONALES

### Validación 1: Ver el JSON enviado a SAP

Si quieres ver exactamente qué se envió a SAP:

1. **Ir a:** Setup > Debug Logs
2. **Buscar en el log:** `BODY CREADO`
3. **Copiar el JSON**
4. **Buscar:** `"WarehouseCode"`
5. **Validar:** El valor coincide con lo esperado

**Ejemplo de JSON esperado:**

```json
{
  "DocumentLines": [
    {
      "ItemCode": "300004184",
      "Quantity": 1,
      "UnitPrice": 100000,
      "WarehouseCode": "VTLE"  ← Debe aparecer aquí
    }
  ]
}
```

---

### Validación 2: Quote sin Dirección de Despacho

**Escenario:** Quote sin `DirDespacho__c` debe asignar bodega solo por Línea de Negocio y HES.

**Prueba:**
1. Crear una Quote sin asignar `DirDespacho__c`
2. Línea de Negocio: 21000
3. RequiereHES: Venta Normal
4. **Resultado esperado:** `VTLE` (porque "TODAS" las regiones aplican para GE)

**Debug esperado:**
```
⚠️ [BODEGA] Quote sin dirección de despacho
🏭 [BODEGA] Bodega asignada: VTLE
```

---

## 📊 MATRIZ DE VALIDACIÓN

Usa esta tabla para marcar los resultados:

| # | Caso | Línea Neg. | Región | HES | Bodega Esperada | ✅/❌ | Notas |
|---|------|------------|--------|-----|-----------------|-------|-------|
| 1 | HES Override | 21000 | 13 | HES | VTADFL10 | | |
| 2 | GE Relacional | 21000 | 13 | Normal | VTLE | | |
| 3 | GE Proyecto | 15000 | 13 | Normal | VTLE | | |
| 4 | Servicio Santiago | 22000 | 13 | Normal | ST10 | | |
| 5 | Servicio Antofagasta | 22000 | 2 | Normal | STA10 | | |
| 6 | Servicio Puerto Montt | 22000 | 10 | Normal | STSP10 | | |
| 7 | Servicio Concepción | 22000 | 8 | Normal | STC10 | | |
| 8 | Sin Match | 30000 | 5 | Normal | null | | |
| 9 | Sin DirDespacho | 21000 | - | Normal | VTLE | | |

---

## 🚀 INSTRUCCIONES RÁPIDAS (RESUMEN)

### Para cada caso:

1. **Cambiar** `Linea_Negocio__c` del usuario (o usar usuario diferente)
2. **Crear Account** con direcciones (importante: `Region__c` correcta)
3. **Crear Opportunity** con producto
4. **Cambiar Stage** a "Cotización"
5. **Crear Quote** con todos los campos obligatorios
6. **Asignar** `DirDespacho__c` con la región correcta
7. **Click** en "Crear Draft en SAP"
8. **Ver Debug Log** para validar lógica
9. **Validar en SAP** el WarehouseCode
10. **Marcar** en la tabla de validación

---

## 🔧 TROUBLESHOOTING

### Error: "El campo 'X' está vacío, es un campo requerido en SAP"

**Causa:** Falta llenar campo obligatorio.

**Solución:** Validar que la Quote tenga:
- ✅ Glosa__c
- ✅ NOrdenCompra__c
- ✅ DirDespacho__c
- ✅ DirFacturacion__c
- ✅ FechaEntrega__c
- ✅ Al menos 1 QuoteLineItem

### Error: "El campo 'Branch' en el usuario está vacío"

**Causa:** Usuario no tiene `Branch__c`.

**Solución:** Editar el usuario y agregar valor en `Branch__c` (ej: 93141000-8).

### No aparece el botón "Crear Draft en SAP"

**Causa:** El botón es un Quick Action que debe estar en el layout.

**Solución:**
1. Setup > Object Manager > Quote
2. Page Layouts > [Tu Page Layout]
3. Salesforce Mobile and Lightning Experience Actions
4. Validar que `Crear_Draft_en_SAP` está en la lista
5. Si no está, agregarlo desde "Quick Actions" en la paleta

### Debug Log no muestra mensajes [BODEGA]

**Causa:** Debug Level no está configurado.

**Solución:**
1. Setup > Debug Logs
2. New
3. User: Tu usuario
4. Log Level: SFDC_DevConsole (o crear uno custom con Apex Code = DEBUG)
5. Start Time: Now
6. Expiration: 1 hora

---

## 📧 REPORTE DE RESULTADOS

Después de probar, crea un resumen con este formato:

```
TICKET 00024376 - RESULTADOS DE TESTING
========================================

Ambiente: Sandbox UAT
Fecha: [Fecha de prueba]
Ejecutado por: [Tu nombre]

CASOS PROBADOS:
✅ Caso 1: HES Override → VTADFL10 (OK)
✅ Caso 2: GE Relacional → VTLE (OK)
✅ Caso 3: Servicio Santiago → ST10 (OK)
❌ Caso 4: Servicio Antofagasta → Error: [descripción]

BUGS ENCONTRADOS:
- [Descripción si hay algún error]

OBSERVACIONES:
- [Cualquier comentario]

LISTO PARA PRODUCCIÓN: SÍ / NO
```

---

## 🎯 CRITERIOS DE ACEPTACIÓN

Para considerar las pruebas **exitosas**, todos estos puntos deben cumplirse:

- ✅ **Caso HES/802:** Asigna VTADFL10 independiente de línea y región
- ✅ **Casos GE (21000, 15000, 10000):** Asignan VTLE cuando RequiereHES = Normal
- ✅ **Caso Servicio + Santiago (Región 13):** Asigna ST10
- ✅ **Caso Servicio + Antofagasta (Región 2):** Asigna STA10
- ✅ **Caso Servicio + Puerto Montt (Región 10):** Asigna STSP10
- ✅ **Caso Servicio + Concepción (Región 8):** Asigna STC10
- ✅ **Caso sin match:** No asigna bodega (null), SAP usa default
- ✅ **Debug logs:** Muestran evaluación correcta de reglas
- ✅ **SAP:** WarehouseCode en Draft coincide con bodega asignada
- ✅ **Sin errores:** No hay excepciones ni errores de compilación

---

## 🚀 SIGUIENTE PASO DESPUÉS DE TESTING

Si **todas las pruebas pasan:**

1. ✅ Informar a Marcelo con los resultados
2. ✅ Crear el CMT en **producción** (repetir pasos 1, 2, 3 del documento `INSTRUCCIONES-CREAR-CMT-BODEGA-SAP.md`)
3. ✅ Deployar clases a **producción**
4. ✅ Ejecutar tests en **producción**
5. ✅ Hacer prueba con 1 Quote real
6. ✅ Cerrar ticket

---

## 💡 TIPS PARA PRUEBAS RÁPIDAS

### Script Anónimo para Validar Configuraciones

Ejecuta esto en Developer Console para ver todas las configuraciones activas:

```apex
List<Bodega_SAP__mdt> configs = [
    SELECT Label, Linea_Negocio__c, Region_Despacho__c, 
           Requiere_HES__c, Codigo_Bodega_SAP__c, Prioridad__c
    FROM Bodega_SAP__mdt
    WHERE Activo__c = true
    ORDER BY Prioridad__c ASC
];

for (Bodega_SAP__mdt config : configs) {
    System.debug('📋 ' + config.Label + 
                 ' | LN: ' + config.Linea_Negocio__c + 
                 ' | Región: ' + config.Region_Despacho__c + 
                 ' | HES: ' + config.Requiere_HES__c + 
                 ' → ' + config.Codigo_Bodega_SAP__c + 
                 ' (Pri: ' + config.Prioridad__c + ')');
}
```

**Resultado esperado:**
```
📋 HES-802 Override | LN: TODAS | Región: TODAS | HES: HES,802 → VTADFL10 (Pri: 1)
📋 GE Ventas VTLE | LN: 21000,15000,10000 | Región: TODAS | HES: VENTA_NORMAL → VTLE (Pri: 2)
📋 Servicio Santiago ST10 | LN: 22000 | Región: 13 | HES: VENTA_NORMAL → ST10 (Pri: 3)
📋 Servicio Antofagasta STA10 | LN: 22000 | Región: 2 | HES: VENTA_NORMAL → STA10 (Pri: 3)
📋 Servicio Puerto Montt STSP10 | LN: 22000 | Región: 10 | HES: VENTA_NORMAL → STSP10 (Pri: 3)
📋 Servicio Concepcion STC10 | LN: 22000 | Región: 8 | HES: VENTA_NORMAL → STC10 (Pri: 3)
```

---

### Script Anónimo para Probar Determinación de Bodega

```apex
// Caso 1: HES Override
String bodega1 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'HES');
System.debug('✅ Caso HES: ' + bodega1 + ' (esperado: VTADFL10)');

// Caso 2: GE Relacional
String bodega2 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'Venta Normal');
System.debug('✅ Caso GE: ' + bodega2 + ' (esperado: VTLE)');

// Caso 3: Servicio Santiago
String bodega3 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '13', 'Venta Normal');
System.debug('✅ Caso Servicio Santiago: ' + bodega3 + ' (esperado: ST10)');

// Caso 4: Servicio Antofagasta
String bodega4 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '2', 'Venta Normal');
System.debug('✅ Caso Servicio Antofagasta: ' + bodega4 + ' (esperado: STA10)');

// Caso 5: Sin match
String bodega5 = LUREYE_Bodega_SAP_Service.determinarBodega(30000, '5', 'Venta Normal');
System.debug('✅ Caso Sin Match: ' + bodega5 + ' (esperado: null)');
```

**Si todos los resultados coinciden con lo esperado, la lógica funciona perfectamente.** ✅

---

## 📞 ¿NECESITAS AYUDA?

Si encuentras algún problema durante las pruebas:
1. Revisa los debug logs completos
2. Verifica que todos los campos obligatorios están llenos
3. Valida que el usuario tiene `Linea_Negocio__c` correcto
4. Confirma que la dirección tiene `Region__c` correcto
5. Si persiste el error, escríbeme con:
   - Captura del error
   - Debug log completo
   - ID de la Quote

---

**Última actualización:** 13 Noviembre 2025, 23:00

