# Ticket 00024376 - Asignación Dinámica de Bodegas SAP para WMS

**Proyecto:** LUREYE  
**Cliente:** Interno (WMS)  
**Prioridad:** URGENTE  
**Desarrollador:** Rodrigo Carvallo  
**Fecha:** 13 de Noviembre 2025  

---

## 📋 ÍNDICE

1. [Contexto General](#1-contexto-general)
2. [Problema Actual](#2-problema-actual)
3. [Solución Propuesta](#3-solución-propuesta)
4. [Requerimientos del Cliente - Implementación Paso a Paso](#4-requerimientos-del-cliente)
5. [Datos Confirmados de Producción](#5-datos-confirmados-de-producción)
6. [Decisiones de Diseño](#6-decisiones-de-diseño)
7. [Plan de Implementación](#7-plan-de-implementación)

---

## 1. CONTEXTO GENERAL

### 1.1. Flujo Actual de Creación de Orden de Venta (OV) en SAP

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario crea Quote (Cotización) en Salesforce           │
│    - Asociada a Oportunidad                                 │
│    - Contiene productos (QuoteLineItem)                     │
│    - Requiere archivos adjuntos                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Usuario hace click en botón "Crear Draft en SAP"        │
│    - Botón visible solo si cumple condiciones               │
│    - Ejecuta Visualforce Page                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. LUREYE_Drafts_SAP.CrearDrafts(quoteId)                 │
│    ┌─────────────────────────────────────────────────────┐ │
│    │ a) Consulta Quote y datos relacionados              │ │
│    │ b) Consulta User (CreatedById) para obtener:        │ │
│    │    - Linea_Negocio__c                                │ │
│    │    - Sucursal__c                                     │ │
│    │    - Branch__c, CodigoUN__c, etc.                   │ │
│    │ c) Consulta Account (cliente)                        │ │
│    │ d) Consulta Direccion__c (facturación y despacho)   │ │
│    │ e) Sube archivos a Google Drive                      │ │
│    │ f) Determina bodega (ACTUAL: solo HES-802)          │ │
│    │ g) Construye JSON completo                           │ │
│    └─────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. LUREYE_Items_SAP.createQuoteLI()                        │
│    - Construye array DocumentLines                          │
│    - Agrega WarehouseCode SI bodega != null                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. CS_BatchDraft.createSequential()                        │
│    - Crea attachments en SAP                                │
│    - Crea Order en SAP                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. LUREYE_Servicios_SAP.CreaDrafts(body)                  │
│    - Endpoint: POST /Orders                                 │
│    - Cookie: B1SESSION                                      │
│    - Body: JSON completo                                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. SAP Business One                                         │
│    - Recibe Order                                            │
│    - Valida datos                                            │
│    - Crea Draft                                              │
│    - Retorna: 201 + DocEntry                                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. Actualiza Quote en Salesforce                           │
│    - Quote.DocEntry__c = SAP DocEntry                       │
│    - Quote.Estado_en_SAP__c = "Documento Pendiente"        │
└─────────────────────────────────────────────────────────────┘
```

### 1.2. Campos y Objetos Clave

**Quote (Cotización):**
- `ClienteId__c` - Fórmula que retorna `Opportunity.AccountId`
- `DirDespacho__c` - Lookup a `Direccion__c` (tipo Despacho)
- `DirFacturacion__c` - Lookup a `Direccion__c` (tipo Facturación)
- `RequiereHES__c` - Picklist: "Venta Normal", "HES", "802", "801" (OBLIGATORIO)
- `CondicionPago__c` - Picklist con condiciones de pago
- `DocEntry__c` - Número de documento en SAP
- `Estado_en_SAP__c` - Estado del documento

**User (Usuario - CreatedById):**
- `Linea_Negocio__c` - Number(5,0): 10000, 15000, 16000, 17000, 21000, 22000, etc.
- `Sucursal__c` - Text(5): Código numérico (13101, 02201, 08201, 10301, 10900)
- `CodigoUN__c` - Text(2): "GE", "EM", "SE", "LA"
- `Branch__c` - Number: 1 (GE/SE) o 2 (EM)

**Direccion__c (Dirección personalizada):**
- `Ciudad__c` - Text(100): Santiago, Antofagasta, Puerto Montt, Concepción, etc.
- `Region__c` - Picklist: "2" (Antofagasta), "8" (Bío Bío), "10" (Los Lagos), "13" (Metropolitana)
- `AccountId__c` - Lookup a Account
- `Tipo__c` - Picklist: "Despacho", "Facturación"

---

## 2. PROBLEMA ACTUAL

### 2.1. Comportamiento Actual

El campo `WarehouseCode` **SOLO se envía** en un caso:

**Código actual** (`LUREYE_Drafts_SAP.cls`, líneas 173-182):
```apex
if (qryQuote.Propiedades__c != null){
    propiedades = qryQuote.Propiedades__c;
    propHES     = qryQuote.RequiereHES__c;

    if(propHES == 'HES' || propHES == '802') {
        bodega = 'VTADFL10';
    }        
}
```

**Resultado:**
- ✅ Quote con `RequiereHES__c = 'HES'` o `'802'` → Bodega `VTADFL10`
- ❌ **Todos los demás casos** → `bodega = null` → No se envía `WarehouseCode` → SAP usa bodega por defecto

### 2.2. Impacto en WMS

Sin el `WarehouseCode` correcto:
- ❌ Inventario se asigna a bodega incorrecta
- ❌ Picking se hace desde bodega equivocada
- ❌ Tiempos de despacho se alargan
- ❌ Reportería de stock por bodega es incorrecta
- ❌ Requiere movimientos manuales de inventario

### 2.3. Ejemplos Concretos

**Caso 1: Venta de Generación desde Santiago**
- Usuario: Patricio Garrido (`Linea_Negocio__c = 21000`, `Sucursal__c = 13101`)
- Quote con productos de Generación
- **Actual:** No se envía bodega → SAP usa default (probablemente "01" Almacén general)
- **Esperado:** `WarehouseCode = "VTLE"` (Bodega Ventas Generación Lo Espejo)

**Caso 2: Servicio Técnico desde Antofagasta**
- Usuario: Paola Gutierrez (`Linea_Negocio__c = 22000`, `Sucursal__c = 02201`)
- Dirección despacho en Antofagasta
- **Actual:** No se envía bodega
- **Esperado:** `WarehouseCode = "STA10"` (Bodega Servicios Antofagasta)

---

## 3. SOLUCIÓN PROPUESTA

### 3.1. Criterios para Determinar Bodega

La bodega se determina por **TRES factores en orden de prioridad**:

#### Prioridad 1 (MÁXIMA): Condición de Pago Especial
```
SI Quote.RequiereHES__c = 'HES' o '802'
ENTONCES bodega = 'VTADFL10'
FIN (No evaluar más reglas)
```

#### Prioridad 2: Línea de Negocio GE (RELACIONAL, PROYECTO, TRANSACCIONAL)
```
SI User.Linea_Negocio__c IN (21000, 15000, 10000)
  Y Quote.RequiereHES__c != 'HES' y != '802'
ENTONCES bodega = 'VTLE'
```

#### Prioridad 3: Línea de Negocio SERVICIO por Región
```
SI User.Linea_Negocio__c = 22000
  Y Quote.RequiereHES__c != 'HES' y != '802'
ENTONCES:
  SI DirDespacho__r.Region__c = '2' ENTONCES bodega = 'STA10'  (Antofagasta)
  SI DirDespacho__r.Region__c = '8' ENTONCES bodega = 'STC10'  (Concepción)
  SI DirDespacho__r.Region__c = '10' ENTONCES bodega = 'STSP10' (Puerto Montt)
  SI DirDespacho__r.Region__c = '13' ENTONCES bodega = 'ST10'  (Santiago)
FIN SI
```

#### Default: Sin bodega
```
SI no cumple ninguna regla ENTONCES bodega = null
(SAP usará su bodega por defecto)
```

### 3.2. Arquitectura Técnica

**Opción elegida:** Custom Metadata Type `Bodega_SAP__mdt`

**Ventajas:**
- ✅ Configurable sin código
- ✅ Sin deploy para cambios
- ✅ Administradores pueden editar
- ✅ Versionable y auditable
- ✅ Se puede exportar/importar entre orgs

**Estructura:**
```
Bodega_SAP__mdt
├── Linea_Negocio__c (Text): "21000,15000,10000" o "22000" o "TODAS"
├── Region_Despacho__c (Text): "2,13" o "TODAS"
├── Requiere_HES__c (Text): "HES,802" o "VENTA_NORMAL" o "TODAS"
├── Codigo_Bodega_SAP__c (Text): "VTLE", "ST10", etc.
├── Nombre_Bodega__c (Text): Nombre descriptivo
├── Activo__c (Checkbox): true/false
└── Prioridad__c (Number): 1=máxima, 99=mínima
```

---

## 4. REQUERIMIENTOS DEL CLIENTE

### 4.1. Mapeo Confirmado de Regiones

**Basándome en datos de producción:**

| Código Region | Nombre Región | Ciudades Principales |
|---------------|---------------|----------------------|
| 2 | II - Antofagasta | Antofagasta |
| 8 | VIII - Bío Bío | Concepción, Talcahuano |
| 10 | X - Los Lagos | Puerto Montt |
| 13 | Metropolitana | Santiago |

**Códigos de Sucursal en User (referencia):**
- `02201` → Antofagasta (Región 2)
- `08201` → Concepción/Talcahuano (Región 8)
- `10301` → Puerto Montt (Región 10)
- `13101` → Santiago (Región 13)
- `10900` → Sin mapear (ignorar)

**⚠️ IMPORTANTE:** NO usaremos `User.Sucursal__c` directamente. Usaremos **`Quote.DirDespacho__r.Region__c`** porque:
- Es más preciso (dirección real de entrega)
- Está estandarizado (picklist con valores fijos)
- Ya se consulta en la integración actual

---

### Req. 1: Venta de GE - Líneas RELACIONAL, PROYECTO, TRANSACCIONAL

#### Descripción del Cliente
> "Venta de GE - RELACIONAL, PROYECTO, TRANSACCIONAL - TODAS las sucursales → Bodega VTLE"

#### Criterios Técnicos
```
User.Linea_Negocio__c IN (21000, 15000, 10000)
AND Quote.RequiereHES__c NOT IN ('HES', '802')
```

#### Bodega Asignada
- **Código SAP:** `VTLE`
- **Nombre:** BODEGA VENTAS GENERACION LO ESPEJO
- **Confirmado en SAP:** ✅ Existe

#### Implementación Paso a Paso

**Paso 1:** Crear registro en Custom Metadata Type

Navegar a: **Setup > Custom Metadata Types > Bodega SAP > Manage Records > New**

```
Label: GE_Ventas_VTLE
Bodega SAP Name: GE_Ventas_VTLE

Campos:
- Linea_Negocio__c: "21000,15000,10000"
- Region_Despacho__c: "TODAS"
- Requiere_HES__c: "VENTA_NORMAL"
- Codigo_Bodega_SAP__c: "VTLE"
- Nombre_Bodega__c: "BODEGA VENTAS GENERACION LO ESPEJO"
- Activo__c: ✓ (checked)
- Prioridad__c: 2
```

**Paso 2:** Código en clase helper

```apex
// En LUREYE_Bodega_SAP_Service.determinarBodega()
// Si lineaNegocio es 21000, 15000 o 10000 y no es HES
if (lineasGE.contains(String.valueOf(lineaNegocio)) && !esHES) {
    return 'VTLE';
}
```

**Paso 3:** Test unitario

```apex
@isTest
static void test_GE_Relacional_RetornaVTLE() {
    // Usuario GE Relacional
    Decimal lineaNegocio = 21000;
    String region = '13'; // Santiago
    String requiereHES = 'Venta Normal';
    
    Test.startTest();
    String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, region, requiereHES);
    Test.stopTest();
    
    System.assertEquals('VTLE', bodega);
}
```

**Paso 4:** Validación en Sandbox

Crear Quote con:
- Usuario: LineaNegocio = 21000 (RELACIONAL)
- RequiereHES = "Venta Normal"
- Ejecutar "Crear Draft en SAP"
- Verificar en SAP: `GET /Orders({DocEntry})` → `DocumentLines[0].WarehouseCode = "VTLE"`

---

### Req. 2: Venta de Servicio - SANTIAGO

#### Descripción del Cliente
> "Venta de Mesón y Venta de Servicios - SERVICIO - SANTIAGO → Bodega ST10"

#### Criterios Técnicos
```
User.Linea_Negocio__c = 22000
AND Quote.DirDespacho__r.Region__c = '13' (Metropolitana)
AND Quote.RequiereHES__c NOT IN ('HES', '802')
```

#### Bodega Asignada
- **Código SAP:** `ST10`
- **Nombre:** BOD. DE REPTO. CENTRAL SERVICIO TECNICO
- **Confirmado en SAP:** ✅ Existe

#### Implementación Paso a Paso

**Paso 1:** Custom Metadata

```
Label: Servicio_Santiago_ST10
Bodega SAP Name: Servicio_Santiago_ST10

Campos:
- Linea_Negocio__c: "22000"
- Region_Despacho__c: "13"
- Requiere_HES__c: "VENTA_NORMAL"
- Codigo_Bodega_SAP__c: "ST10"
- Nombre_Bodega__c: "BOD. DE REPTO. CENTRAL SERVICIO TECNICO"
- Activo__c: ✓
- Prioridad__c: 3
```

**Paso 2:** Modificar `LUREYE_Drafts_SAP.CrearDrafts()`

Cambiar línea 217 de:
```apex
bodyQuoteLI = LUREYE_Items_SAP.createQuoteLI(prdMap, qryQuoteLineItem, null, costingcode, sucursal, lineaN, glosa, bodega);
```

A:
```apex
// Consultar región de despacho
String regionDespacho = null;
if (qryQuote.DirDespacho__c != null) {
    Direccion__c dirDesp = [SELECT Region__c FROM Direccion__c WHERE Id = :qryQuote.DirDespacho__c LIMIT 1];
    regionDespacho = dirDesp.Region__c;
}

// Determinar bodega con nueva lógica
bodega = LUREYE_Bodega_SAP_Service.determinarBodega(userqry.Linea_Negocio__c, regionDespacho, propHES);

bodyQuoteLI = LUREYE_Items_SAP.createQuoteLI(prdMap, qryQuoteLineItem, null, costingcode, sucursal, lineaN, glosa, bodega);
```

**Paso 3:** Test

```apex
@isTest
static void test_Servicio_Santiago_RetornaST10() {
    Decimal lineaNegocio = 22000;
    String region = '13'; // Santiago/Metropolitana
    String requiereHES = 'Venta Normal';
    
    Test.startTest();
    String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, region, requiereHES);
    Test.stopTest();
    
    System.assertEquals('ST10', bodega);
}
```

---

### Req. 3: Venta de Servicio - ANTOFAGASTA

#### Criterios Técnicos
```
User.Linea_Negocio__c = 22000
AND Quote.DirDespacho__r.Region__c = '2' (II Región)
AND Quote.RequiereHES__c NOT IN ('HES', '802')
```

#### Bodega Asignada
- **Código SAP:** `STA10`
- **Nombre:** BODEGA SERVICIOS ANTOFAGASTA
- **Confirmado:** ✅

#### Implementación

**Custom Metadata:**
```
Label: Servicio_Antofagasta_STA10
Linea_Negocio__c: "22000"
Region_Despacho__c: "2"
Requiere_HES__c: "VENTA_NORMAL"
Codigo_Bodega_SAP__c: "STA10"
Nombre_Bodega__c: "BODEGA SERVICIOS ANTOFAGASTA"
Activo__c: ✓
Prioridad__c: 3
```

---

### Req. 4: Venta de Servicio - PUERTO MONTT

#### Criterios Técnicos
```
User.Linea_Negocio__c = 22000
AND Quote.DirDespacho__r.Region__c = '10' (X Región)
AND Quote.RequiereHES__c NOT IN ('HES', '802')
```

#### Bodega Asignada
- **Código SAP:** `STSP10`
- **Nombre:** BODEGA DE SURTIDOS SERVICIOS TECNICO PTO. MONTT
- **Confirmado:** ✅

**Nota:** En SAP dice "SURTIDOS" no "SERVICIOS" pero es el código correcto según el requerimiento.

#### Implementación

**Custom Metadata:**
```
Label: Servicio_PuertoMontt_STSP10
Linea_Negocio__c: "22000"
Region_Despacho__c: "10"
Requiere_HES__c: "VENTA_NORMAL"
Codigo_Bodega_SAP__c: "STSP10"
Nombre_Bodega__c: "BODEGA DE SURTIDOS SERVICIOS TECNICO PTO. MONTT"
Activo__c: ✓
Prioridad__c: 3
```

---

### Req. 5: Venta de Servicio - TALCAHUANO/CONCEPCIÓN

#### Criterios Técnicos
```
User.Linea_Negocio__c = 22000
AND Quote.DirDespacho__r.Region__c = '8' (VIII Región - Bío Bío)
AND Quote.RequiereHES__c NOT IN ('HES', '802')
```

#### Bodega Asignada
- **Código SAP:** `STC10`
- **Nombre:** BODEGA SERVICIOS CONCEPCION
- **Confirmado:** ✅

#### Implementación

**Custom Metadata:**
```
Label: Servicio_Concepcion_STC10
Linea_Negocio__c: "22000"
Region_Despacho__c: "8"
Requiere_HES__c: "VENTA_NORMAL"
Codigo_Bodega_SAP__c: "STC10"
Nombre_Bodega__c: "BODEGA SERVICIOS CONCEPCION"
Activo__c: ✓
Prioridad__c: 3
```

---

### Req. 6: Condición de Pago HES-802 (OVERRIDE TOTAL)

#### Descripción del Cliente
> "SN con condición de pago HES-802 - TODAS las líneas - TODAS las sucursales → VTADFL10"

#### Criterios Técnicos
```
Quote.RequiereHES__c IN ('HES', '802')
(Ignora cualquier otra condición)
```

#### Bodega Asignada
- **Código SAP:** `VTADFL10`
- **Nombre:** BODEGA VENTA DESFASADAS GEN
- **Confirmado:** ✅

#### Implementación

**Custom Metadata:**
```
Label: HES_802_Override
Linea_Negocio__c: "TODAS"
Region_Despacho__c: "TODAS"
Requiere_HES__c: "HES,802"
Codigo_Bodega_SAP__c: "VTADFL10"
Nombre_Bodega__c: "BODEGA VENTA DESFASADAS GEN"
Activo__c: ✓
Prioridad__c: 1  // MÁXIMA PRIORIDAD
```

**Código:**
```apex
// Esta validación va PRIMERO, antes que cualquier otra
if (requiereHES == 'HES' || requiereHES == '802') {
    System.debug('🏭 Bodega HES-802 override: VTADFL10');
    return 'VTADFL10';
}
```

**Test:**
```apex
@isTest
static void test_HES_SobreescribeTodo() {
    // Aunque sea GE Relacional (VTLE), HES debe ganar
    Decimal lineaNegocio = 21000; // Normalmente sería VTLE
    String region = '13';
    String requiereHES = 'HES';
    
    Test.startTest();
    String bodega = LUREYE_Bodega_SAP_Service.determinarBodega(lineaNegocio, region, requiereHES);
    Test.stopTest();
    
    System.assertEquals('VTADFL10', bodega, 'HES debe sobrescribir cualquier otra regla');
}
```

---

## 5. DATOS CONFIRMADOS DE PRODUCCIÓN

### 5.1. Líneas de Negocio en Uso

| Código | Label | CodigoUN | Bodega Asignada | Acción |
|--------|-------|----------|-----------------|--------|
| 10000 | TRANSACCIONAL | GE | VTLE | ✅ Configurar |
| 15000 | PROYECTOS | GE | VTLE | ✅ Configurar |
| 16000 | CANAL TELEFONICO | EM | N/A | ❌ Ignorar |
| 17000 | CANAL KAM | EM | N/A | ❌ Ignorar |
| 21000 | RELACIONAL | GE | VTLE | ✅ Configurar |
| 22000 | SERVICIO | SE/GE | ST10/STA10/etc | ✅ Configurar |

### 5.2. Bodegas Confirmadas en SAP

✅ Todas las bodegas del requerimiento existen en SAP:

```json
{
    "WarehouseCode": "VTLE",
    "WarehouseName": "BODEGA VENTAS GENERACION LO ESPEJO"
},
{
    "WarehouseCode": "ST10",
    "WarehouseName": "BOD. DE REPTO. CENTRAL SERVICIO TECNICO"
},
{
    "WarehouseCode": "STA10",
    "WarehouseName": "BODEGA SERVICIOS  ANTOFAGASTA"
},
{
    "WarehouseCode": "STSP10",
    "WarehouseName": "BODEGA DE SURTIDOS  SERVICIOS TECNICO PTO. MONTT"
},
{
    "WarehouseCode": "STC10",
    "WarehouseName": "BODEGA SERVICIOS  CONCEPCION"
},
{
    "WarehouseCode": "VTADFL10",
    "WarehouseName": "BODEGA VENTA DESFASADAS GEN"
}
```

### 5.3. Distribución de Usuarios por Línea y Región

**Datos de producción:**

| Sucursal (User) | Región Inferida | CodigoUN | Línea Negocio | # Usuarios |
|-----------------|-----------------|----------|---------------|------------|
| 02201 | 2 (Antofagasta) | GE | 21000 | 1 |
| 02201 | 2 (Antofagasta) | SE | 22000 | 2 |
| 08201 | 8 (Bío Bío) | GE | 21000 | 2 |
| 08201 | 8 (Bío Bío) | SE | 22000 | 2 |
| 10301 | 10 (Los Lagos) | GE | 21000, 22000 | 2 |
| 13101 | 13 (Metropolitana) | GE | 10000, 15000, 21000, 22000 | 8 |
| 13101 | 13 (Metropolitana) | EM | 16000, 17000 | 38 |
| 13101 | 13 (Metropolitana) | SE | 22000 | 5 |

---

## 6. DECISIONES DE DISEÑO

### 6.1. Usar Region de Direccion__c, NO User.Sucursal__c

**Razón:**
- `User.Sucursal__c` tiene códigos numéricos inconsistentes (13101 para múltiples regiones)
- `Direccion__c.Region__c` es estandarizado (picklist con valores fijos 1-16)
- La bodega debe estar cerca de donde se DESPACHA, no donde trabaja el vendedor

**Impacto en código:**
```apex
// ANTES (no funciona):
String sucursal = userqry.Sucursal__c; // "13101", "02201", etc.

// DESPUÉS (correcto):
String regionDespacho = null;
if (qryQuote.DirDespacho__c != null) {
    Direccion__c dirDesp = [SELECT Region__c FROM Direccion__c WHERE Id = :qryQuote.DirDespacho__c LIMIT 1];
    regionDespacho = dirDesp.Region__c; // "2", "8", "10", "13"
}
```

### 6.2. Bodega por defecto (Fallback)

**Decisión:** Opción C - Crear sin WarehouseCode

Si no hay match:
```apex
if (bodega == null) {
    System.debug('⚠️ No se determinó bodega, SAP usará default');
    // No setear bodega
    // SAP usará su bodega por defecto (probablemente "01" - Almacén general)
}
```

**Razón:**
- No bloquea el proceso de venta
- Mantiene compatibilidad con flujo actual
- Permite crear OV para líneas de negocio no configuradas (16000, 17000, etc.)

### 6.3. Prioridad de Evaluación

**Orden de evaluación:**
1. HES-802 (Prioridad 1) - Sobrescribe TODO
2. GE (Relacional/Proyecto/Transaccional) (Prioridad 2) - Independiente de región
3. Servicio por región (Prioridad 3) - Específico por región

**Implementación en código:**
```apex
public static String determinarBodega(Decimal lineaNegocio, String regionDespacho, String requiereHES) {
    
    // PRIORIDAD 1: HES-802 (override absoluto)
    if (requiereHES == 'HES' || requiereHES == '802') {
        return 'VTADFL10';
    }
    
    // PRIORIDAD 2: GE (independiente de región)
    Set<String> lineasGE = new Set<String>{'21000', '15000', '10000'};
    if (lineasGE.contains(String.valueOf(lineaNegocio).split('\\.')[0])) {
        return 'VTLE';
    }
    
    // PRIORIDAD 3: Servicio por región
    if (String.valueOf(lineaNegocio) == '22000') {
        if (regionDespacho == '13') return 'ST10';      // Santiago
        if (regionDespacho == '2')  return 'STA10';     // Antofagasta
        if (regionDespacho == '10') return 'STSP10';    // Puerto Montt
        if (regionDespacho == '8')  return 'STC10';     // Concepción
    }
    
    // Sin match: retornar null (SAP usa default)
    return null;
}
```

### 6.4. Líneas de Negocio NO configuradas

**Líneas que se ignoran** (no se configura bodega):
- 14000 EQUIPOS USADOS
- 16000 CANAL TELEFONICO (EM)
- 17000 CANAL KAM (EM)
- 18000 ARRIENDOS AMOBLADOS
- 19000 ARRIENDOS SIN AMOBLAR
- 20000 FEE
- 99000 NUEVOS NEGOCIOS

**Comportamiento:** Si crean OV con estas líneas, `bodega = null`, SAP usa su default.

---

## 7. PLAN DE IMPLEMENTACIÓN

### Fase 1: Crear Custom Metadata Type (20 min)

**Archivo:** `force-app/main/default/objects/Bodega_SAP__mdt/Bodega_SAP__mdt.object-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Bodega SAP</label>
    <pluralLabel>Bodegas SAP</pluralLabel>
    <visibility>Public</visibility>
</CustomObject>
```

**Campos** (crear 7 archivos XML en `/fields/`):
- `Linea_Negocio__c.field-meta.xml`
- `Region_Despacho__c.field-meta.xml`
- `Requiere_HES__c.field-meta.xml`
- `Codigo_Bodega_SAP__c.field-meta.xml`
- `Nombre_Bodega__c.field-meta.xml`
- `Activo__c.field-meta.xml`
- `Prioridad__c.field-meta.xml`

---

### Fase 2: Crear registros de Custom Metadata (30 min)

**Archivos a crear** (en `force-app/main/default/customMetadata/`):

1. `Bodega_SAP.HES_802_Override.md-meta.xml`
2. `Bodega_SAP.GE_Ventas_VTLE.md-meta.xml`
3. `Bodega_SAP.Servicio_Santiago_ST10.md-meta.xml`
4. `Bodega_SAP.Servicio_Antofagasta_STA10.md-meta.xml`
5. `Bodega_SAP.Servicio_PuertoMontt_STSP10.md-meta.xml`
6. `Bodega_SAP.Servicio_Concepcion_STC10.md-meta.xml`

---

### Fase 3: Crear clase helper `LUREYE_Bodega_SAP_Service.cls` (1 hora)

**Métodos:**
- `determinarBodega(Decimal, String, String)` - Lógica principal
- `obtenerConfiguracion(String)` - Helper para debugging

**Líneas de código:** ~150

---

### Fase 4: Crear test `LUREYE_Bodega_SAP_Service_Test.cls` (1 hora)

**Test cases:**
- test_HES_RetornaVTADFL10 ✅
- test_802_RetornaVTADFL10 ✅
- test_GE_Relacional_RetornaVTLE ✅
- test_GE_Proyecto_RetornaVTLE ✅
- test_GE_Transaccional_RetornaVTLE ✅
- test_Servicio_Santiago_RetornaST10 ✅
- test_Servicio_Antofagasta_RetornaSTA10 ✅
- test_Servicio_PuertoMontt_RetornaSTSP10 ✅
- test_Servicio_Concepcion_RetornaSTC10 ✅
- test_LineaNoConfigurada_RetornaNull ✅
- test_HES_SobreescribeGE ✅ (HES con lineaNegocio=21000 debe dar VTADFL10)

**Cobertura esperada:** 95%+

---

### Fase 5: Modificar `LUREYE_Drafts_SAP.cls` (30 min)

**Cambios:**

**Línea ~173-182:** Reemplazar lógica actual

```apex
// ELIMINAR:
if (qryQuote.Propiedades__c != null){
    propiedades = qryQuote.Propiedades__c;
    propHES     = qryQuote.RequiereHES__c;
    if(propHES == 'HES' || propHES == '802') {
        bodega = 'VTADFL10';
    }        
}

// AGREGAR:
if (qryQuote.Propiedades__c != null){
    propiedades = qryQuote.Propiedades__c;
    propHES     = qryQuote.RequiereHES__c;
}

// Consultar región de despacho para determinar bodega
String regionDespacho = null;
if (qryQuote.DirDespacho__c != null) {
    try {
        Direccion__c dirDesp = [SELECT Region__c, Ciudad__c 
                                FROM Direccion__c 
                                WHERE Id = :qryQuote.DirDespacho__c 
                                LIMIT 1];
        regionDespacho = dirDesp.Region__c;
        System.debug('🏭 Región de despacho: ' + dirDesp.Region__c + ' (' + dirDesp.Ciudad__c + ')');
    } catch (Exception e) {
        System.debug('⚠️ No se pudo obtener región de despacho: ' + e.getMessage());
    }
}

// Determinar bodega con nueva lógica
bodega = LUREYE_Bodega_SAP_Service.determinarBodega(
    userqry.Linea_Negocio__c, 
    regionDespacho, 
    propHES
);

System.debug('🏭 Bodega asignada: ' + (bodega != null ? bodega : 'SIN BODEGA (SAP default)'));
```

---

### Fase 6: Testing en Sandbox (2 horas)

#### Test Manual 1: GE Relacional → VTLE
1. Login como usuario: Patricio Garrido (LineaNegocio=21000, GE)
2. Crear Quote con productos de Generación
3. RequiereHES = "Venta Normal"
4. Click "Crear Draft en SAP"
5. Verificar en SAP:
   ```bash
   GET /Orders({DocEntry})
   ```
6. Validar: `DocumentLines[0].WarehouseCode = "VTLE"`

#### Test Manual 2: Servicio Santiago → ST10
1. Login como usuario: Franco Godoy (LineaNegocio=22000, SE, Sucursal=13101)
2. Crear Quote
3. Dirección despacho con Región = "13" (Metropolitana)
4. RequiereHES = "Venta Normal"
5. Click "Crear Draft en SAP"
6. Validar: `DocumentLines[0].WarehouseCode = "ST10"`

#### Test Manual 3: HES Override → VTADFL10
1. Login como usuario GE (cualquiera)
2. Crear Quote
3. RequiereHES = "HES"
4. Click "Crear Draft en SAP"
5. Validar: `DocumentLines[0].WarehouseCode = "VTADFL10"`

#### Test Manual 4: Sin configuración → null
1. Login como usuario EM (LineaNegocio=16000 o 17000)
2. Crear Quote
3. RequiereHES = "Venta Normal"
4. Click "Crear Draft en SAP"
5. Validar: `DocumentLines[0]` NO contiene campo `WarehouseCode` (SAP usa default)

---

### Fase 7: Deployment a Producción (1 hora)

#### Checklist Pre-Deploy

- [ ] Tests pasan con >75% cobertura
- [ ] Custom Metadata Type creada
- [ ] 6 registros de configuración creados y validados
- [ ] Clases nuevas: `LUREYE_Bodega_SAP_Service` + test
- [ ] Clase modificada: `LUREYE_Drafts_SAP`
- [ ] Testing exitoso en sandbox (4 casos mínimo)
- [ ] Logs revisados sin errores
- [ ] Backup de código actual
- [ ] Plan de rollback preparado

#### Componentes del Deployment

**Changeset / Package.xml debe incluir:**

```xml
<types>
    <members>Bodega_SAP__mdt</members>
    <name>CustomObject</name>
</types>
<types>
    <members>Bodega_SAP__mdt.Activo__c</members>
    <members>Bodega_SAP__mdt.Codigo_Bodega_SAP__c</members>
    <members>Bodega_SAP__mdt.Linea_Negocio__c</members>
    <members>Bodega_SAP__mdt.Nombre_Bodega__c</members>
    <members>Bodega_SAP__mdt.Prioridad__c</members>
    <members>Bodega_SAP__mdt.Region_Despacho__c</members>
    <members>Bodega_SAP__mdt.Requiere_HES__c</members>
    <name>CustomField</name>
</types>
<types>
    <members>Bodega_SAP.HES_802_Override</members>
    <members>Bodega_SAP.GE_Ventas_VTLE</members>
    <members>Bodega_SAP.Servicio_Santiago_ST10</members>
    <members>Bodega_SAP.Servicio_Antofagasta_STA10</members>
    <members>Bodega_SAP.Servicio_PuertoMontt_STSP10</members>
    <members>Bodega_SAP.Servicio_Concepcion_STC10</members>
    <name>CustomMetadata</name>
</types>
<types>
    <members>LUREYE_Bodega_SAP_Service</members>
    <members>LUREYE_Bodega_SAP_Service_Test</members>
    <members>LUREYE_Drafts_SAP</members>
    <name>ApexClass</name>
</types>
```

#### Orden de Deployment

1. Custom Metadata Type (`Bodega_SAP__mdt`)
2. Custom Metadata Records (6 registros)
3. Apex Classes nuevas (`LUREYE_Bodega_SAP_Service` + test)
4. Apex Classes modificadas (`LUREYE_Drafts_SAP`)

#### Script de Deployment

```bash
# Validar
npm run apex:deploy:validate

# Deploy
npm run apex:deploy

# Ejecutar tests
npm run apex:test:class -- LUREYE_Bodega_SAP_Service_Test
npm run apex:test:class -- LUREYE_Drafts_SAP_Test
```

---

### Fase 8: Monitoreo Post-Deploy (1 semana)

#### Día 1-3: Monitoreo Intensivo

**Configurar Debug Logs** para usuarios clave:
- Patricio Garrido (GE)
- Franco Godoy (SE)
- Usuarios de regiones (Antofagasta, Puerto Montt, Concepción)

**Buscar en logs:**
```
🏭 [BODEGA] Región de despacho: 13 (SANTIAGO)
🏭 [BODEGA] Bodega asignada: ST10
```

#### Día 4-7: Validación con WMS

- Confirmar con equipo WMS que las OV están llegando a bodegas correctas
- Revisar si hay OV en bodegas incorrectas
- Validar con usuarios que el proceso funciona transparente

#### Métricas a Monitorear

```apex
// Query para ver distribución de bodegas
SELECT COUNT(Id), 
       GROUPING(CreatedBy.Linea_Negocio__c) LineaNegocio,
       GROUPING(DirDespacho__r.Region__c) Region
FROM Quote
WHERE CreatedDate = LAST_N_DAYS:7
  AND DocEntry__c != null
GROUP BY CreatedBy.Linea_Negocio__c, DirDespacho__r.Region__c
```

---

## 8. MATRIZ DE REGLAS - RESUMEN EJECUTIVO

| # | Línea Negocio | Región Despacho | RequiereHES | Bodega | Prioridad |
|---|---------------|-----------------|-------------|--------|-----------|
| 1 | TODAS | TODAS | HES o 802 | VTADFL10 | 1 (MAX) |
| 2 | 21000, 15000, 10000 | TODAS | Venta Normal | VTLE | 2 |
| 3 | 22000 | 13 (Metropolitana) | Venta Normal | ST10 | 3 |
| 4 | 22000 | 2 (Antofagasta) | Venta Normal | STA10 | 3 |
| 5 | 22000 | 10 (Los Lagos) | Venta Normal | STSP10 | 3 |
| 6 | 22000 | 8 (Bío Bío) | Venta Normal | STC10 | 3 |
| 7 | Otras | Cualquiera | Venta Normal | null | N/A |

**Leyenda:**
- null = No se envía WarehouseCode, SAP usa su bodega por defecto

---

## 9. ENTREGABLES

### Código Fuente

- [ ] `Bodega_SAP__mdt` - Custom Metadata Type (7 campos)
- [ ] 6 registros de Custom Metadata (configuración de bodegas)
- [ ] `LUREYE_Bodega_SAP_Service.cls` - Clase helper (~150 líneas)
- [ ] `LUREYE_Bodega_SAP_Service_Test.cls` - Tests (~200 líneas)
- [ ] `LUREYE_Drafts_SAP.cls` - Modificada (cambio ~20 líneas)

### Documentación

- [x] Análisis técnico completo
- [x] Matriz de reglas
- [ ] Guía de configuración para admins
- [ ] Guía de troubleshooting

### Testing

- [ ] Tests unitarios (>75% cobertura)
- [ ] Tests de integración en sandbox (4 casos mínimo)
- [ ] Validación con equipo WMS

---

## 10. RIESGOS Y MITIGACIONES

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Bodega no existe en SAP | Baja | Alto | Validación pre-deploy de todos los códigos |
| Región de despacho null | Media | Medio | Fallback a bodega default (null) |
| Usuario sin LineaNegocio | Baja | Medio | Fallback a bodega default |
| Performance degradation | Baja | Bajo | Custom Metadata está en caché |
| Cambio rompe proceso actual | Baja | Alto | Tests exhaustivos, rollback plan |

---

## 11. CRITERIOS DE ACEPTACIÓN

### Funcionales

- [ ] OV de GE (RELACIONAL/PROYECTO/TRANSACCIONAL) van a bodega VTLE
- [ ] OV de SERVICIO van a bodega según región despacho
- [ ] OV con HES-802 van SIEMPRE a VTADFL10 (override)
- [ ] OV sin configuración se crean normalmente (sin bodega)
- [ ] Configuración es editable por admin sin deploy

### Técnicos

- [ ] Tests unitarios >75% cobertura
- [ ] No errores en logs de producción primera semana
- [ ] Performance < 200ms adicionales por ejecución
- [ ] Logging claro y trazable
- [ ] Código sigue estándares del proyecto

### Negocio

- [ ] Equipo WMS confirma bodegas correctas
- [ ] No hay OV rechazadas por bodega inválida
- [ ] Procesos de picking más eficientes
- [ ] Reportería de stock precisa

---

## 12. CONTACTOS Y STAKEHOLDERS

| Rol | Nombre | Email/Contacto | Responsabilidad |
|-----|--------|----------------|-----------------|
| Solicitante | Marcelo Pinto | marcelo.pinto@seidor.com | Definición de requerimientos |
| Desarrollador | Rodrigo Carvallo | - | Implementación |
| WMS Lead | Pendiente | - | Validación de bodegas |
| QA | Pendiente | - | Testing de integración |
| Product Owner | Pendiente | - | Aprobación final |

---

## 13. TIMELINE

| Fase | Duración | Inicio | Fin | Estado |
|------|----------|--------|-----|--------|
| 1. Crear CMT | 0.5 día | - | - | Pendiente |
| 2. Crear registros | 0.5 día | - | - | Pendiente |
| 3. Clase helper | 1 día | - | - | Pendiente |
| 4. Tests | 1 día | - | - | Pendiente |
| 5. Modificar integración | 0.5 día | - | - | Pendiente |
| 6. Testing sandbox | 1 día | - | - | Pendiente |
| 7. Deploy producción | 0.5 día | - | - | Pendiente |
| 8. Monitoreo | 5 días | - | - | Pendiente |

**Duración total:** 5 días hábiles + 5 días monitoreo

---

## 14. NOTAS TÉCNICAS ADICIONALES

### 14.1. ¿Por qué usar Region en vez de User.Sucursal__c?

**Datos de producción mostraron:**
- `User.Sucursal__c = 13101` tiene usuarios de Santiago, Puerto Montt Y Concepción
- El campo no es confiable para determinar ubicación geográfica
- La bodega debe estar cerca de donde se DESPACHA, no donde trabaja el vendedor

**Solución:**
- Usar `Quote.DirDespacho__r.Region__c`
- Campo picklist con valores estandarizados (1-16 regiones Chile)
- Más preciso y confiable

### 14.2. Manejo de Quote sin Dirección de Despacho

**Escenario:** `Quote.DirDespacho__c = null`

**Comportamiento:**
- `regionDespacho = null`
- Si es GE (21000, 15000, 10000) → Bodega = VTLE (no requiere región)
- Si es Servicio (22000) → Bodega = null (SAP usa default)

**Logging:**
```apex
if (qryQuote.DirDespacho__c == null) {
    System.debug('⚠️ Quote sin dirección de despacho');
}
```

### 14.3. Performance

**Impacto esperado:** Mínimo

- Custom Metadata está en **Application Cache** (no cuenta como query SOQL)
- Query adicional a `Direccion__c` (1 SOQL) - Ya se consulta actualmente para otros campos
- Método `determinarBodega()` es O(n) donde n = # de configuraciones (~6-10)
- **Tiempo adicional estimado:** <50ms

---

## 15. ANEXOS

### Anexo A: Ejemplo de JSON Completo Enviado a SAP

**CON WarehouseCode (después del cambio):**
```json
{
    "CardCode": "C16367215",
    "BPL_IDAssignedToInvoice": 1,
    "Series": "13",
    "DocDueDate": "2025-10-30",
    "DocCurrency": "$",
    "NumAtCard": "123745",
    "PaymentGroupCode": "5",
    "DocObjectCode": "17",
    "SalesPersonCode": "-1",
    "Comments": "Prueba productos GE",
    "U_IDCajaHisto": "SF:0Q0O5000001iWObKAM",
    "U_EXX_FE_TDBSII": "Venta Normal",
    "Name": "CLIENTE EJEMPLO",
    "U_URL_ANEXO": "https://drive.google.com/...",
    "DocumentLines": [
        {
            "ItemCode": "300004184",
            "Quantity": "2.00",
            "TaxCode": "IVA",
            "CostingCode": "...",
            "UnitPrice": "150000.00",
            "FreeText": "Producto de generación",
            "U_EXX_FE_QBLI": "1",
            "WarehouseCode": "VTLE"  // ← NUEVO: Bodega dinámica
        }
    ],
    "AddressExtension": {
        "ShipToStreet": "AV. LO ESPEJO 1300",
        "ShipToCity": "SANTIAGO",
        "ShipToState": "13",
        "ShipToCountry": "CL"
    }
}
```

### Anexo B: Respuesta de SAP

**Exitosa (201):**
```json
{
    "odata.metadata": "...",
    "DocEntry": 26658,
    "DocNum": 4154,
    "DocumentLines": [
        {
            "LineNum": 0,
            "ItemCode": "300004184",
            "WarehouseCode": "VTLE",  // ← Confirmado
            "Quantity": 2.0
        }
    ]
}
```

### Anexo C: Queries Útiles para Troubleshooting

**Ver últimas OV creadas y su bodega:**
```apex
SELECT Id, QuoteNumber, DocEntry__c, Estado_en_SAP__c,
       CreatedBy.Name, CreatedBy.Linea_Negocio__c,
       DirDespacho__r.Region__c, DirDespacho__r.Ciudad__c,
       RequiereHES__c,
       CreatedDate
FROM Quote
WHERE DocEntry__c != null
  AND CreatedDate = LAST_N_DAYS:7
ORDER BY CreatedDate DESC
LIMIT 50
```

**Ver configuración activa de bodegas:**
```apex
List<Bodega_SAP__mdt> configs = [
    SELECT DeveloperName, Linea_Negocio__c, Region_Despacho__c, 
           Requiere_HES__c, Codigo_Bodega_SAP__c, Nombre_Bodega__c, 
           Prioridad__c, Activo__c
    FROM Bodega_SAP__mdt
    WHERE Activo__c = true
    ORDER BY Prioridad__c ASC
];
for (Bodega_SAP__mdt c : configs) {
    System.debug('Config: ' + c.DeveloperName + ' | Bodega: ' + c.Codigo_Bodega_SAP__c + 
                 ' | Línea: ' + c.Linea_Negocio__c + ' | Región: ' + c.Region_Despacho__c);
}
```

**Probar determinación de bodega manualmente:**
```apex
// Test 1: GE Relacional
String bodega1 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'Venta Normal');
System.assert(bodega1 == 'VTLE', 'Esperaba VTLE, obtuvo: ' + bodega1);

// Test 2: Servicio Antofagasta
String bodega2 = LUREYE_Bodega_SAP_Service.determinarBodega(22000, '2', 'Venta Normal');
System.assert(bodega2 == 'STA10', 'Esperaba STA10, obtuvo: ' + bodega2);

// Test 3: HES Override
String bodega3 = LUREYE_Bodega_SAP_Service.determinarBodega(21000, '13', 'HES');
System.assert(bodega3 == 'VTADFL10', 'Esperaba VTADFL10, obtuvo: ' + bodega3);
```

---

## 16. APROBACIONES

| Checkpoint | Aprobador | Fecha | Firma |
|------------|-----------|-------|-------|
| Diseño técnico aprobado | Marcelo Pinto | | |
| Códigos de bodega validados | Equipo WMS | | |
| Tests en sandbox exitosos | QA | | |
| Deploy a producción aprobado | Product Owner | | |

---

## ✅ CONCLUSIÓN

La solución propuesta:
- ✅ Cumple 100% con los requerimientos del cliente
- ✅ Es configurable sin código (Custom Metadata)
- ✅ Mantiene compatibilidad con flujo actual
- ✅ No rompe casos existentes (HES-802 sigue funcionando)
- ✅ Escalable para futuras bodegas/regiones
- ✅ Performance óptimo
- ✅ Testing comprehensivo

**Listo para iniciar desarrollo una vez aprobado el diseño.** 🚀

