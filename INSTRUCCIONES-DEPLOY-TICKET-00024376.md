# Instrucciones de Deploy - Ticket 00024376

## ⚠️ IMPORTANTE

Debido a limitaciones del Salesforce CLI con Custom Metadata Types, el deploy debe hacerse en **2 pasos**:

---

## PASO 1: Crear Custom Metadata Type manualmente en Salesforce (10 min)

### 1.1. Login a Sandbox
https://test.salesforce.com
Usuario: admin.seidor@lureye.com.uat

### 1.2. Ir a Setup > Custom Metadata Types
Setup > Custom Metadata Types > New Custom Metadata Type

### 1.3. Crear el Type
- **Label:** Bodega SAP
- **Plural Label:** Bodegas SAP
- **Object Name:** Bodega_SAP
- **Description:** Configuración de bodegas SAP para asignación dinámica en Órdenes de Venta según línea de negocio, región y condición de pago
- **Visibility:** Public
- Click **Save**

### 1.4. Crear 7 campos (New en la sección Fields)

#### Campo 1: Línea de Negocio
- **Data Type:** Text Area
- **Field Label:** Línea de Negocio
- **Field Name:** Linea_Negocio
- **Length:** 255
- **Description:** Códigos de línea de negocio separados por coma. Ejemplos: "21000,15000,10000" o "TODAS"
- **Field Manageability:** Developer Controlled
- Click **Save & New**

#### Campo 2: Región Despacho
- **Data Type:** Text
- **Field Label:** Región Despacho
- **Field Name:** Region_Despacho
- **Length:** 100
- **Description:** Código de región separados por coma. Ejemplos: "13", "2", "TODAS"
- **Field Manageability:** Developer Controlled
- Click **Save & New**

#### Campo 3: Requiere HES
- **Data Type:** Text
- **Field Label:** Requiere HES
- **Field Name:** Requiere_HES
- **Length:** 50
- **Description:** Valores: "HES,802", "VENTA_NORMAL", "TODAS"
- **Field Manageability:** Developer Controlled
- Click **Save & New**

#### Campo 4: Código Bodega SAP
- **Data Type:** Text
- **Field Label:** Código Bodega SAP
- **Field Name:** Codigo_Bodega_SAP
- **Length:** 20
- **Description:** Código de bodega en SAP (WarehouseCode). Ejemplos: VTLE, ST10
- **Field Manageability:** Developer Controlled
- **Required:** ✓ (checked)
- Click **Save & New**

#### Campo 5: Nombre Bodega
- **Data Type:** Text
- **Field Label:** Nombre Bodega
- **Field Name:** Nombre_Bodega
- **Length:** 100
- **Description:** Nombre descriptivo de la bodega en SAP
- **Field Manageability:** Developer Controlled
- Click **Save & New**

#### Campo 6: Activo
- **Data Type:** Checkbox
- **Field Label:** Activo
- **Field Name:** Activo
- **Default Value:** Checked
- **Description:** Indica si esta configuración está activa
- **Field Manageability:** Developer Controlled
- Click **Save & New**

#### Campo 7: Prioridad
- **Data Type:** Number
- **Field Label:** Prioridad
- **Field Name:** Prioridad
- **Length:** 2 dígitos, 0 decimales
- **Description:** Orden de evaluación. Menor número = mayor prioridad
- **Field Manageability:** Developer Controlled
- Click **Save**

### 1.5. Crear 6 registros de configuración

Ir a: Setup > Custom Metadata Types > Bodega SAP > Manage Records > New

#### Registro 1: HES 802 Override
- **Label:** HES 802 Override
- **Bodega SAP Name:** HES_802_Override
- **Línea de Negocio:** TODAS
- **Región Despacho:** TODAS
- **Requiere HES:** HES,802
- **Código Bodega SAP:** VTADFL10
- **Nombre Bodega:** BODEGA VENTA DESFASADAS GEN
- **Activo:** ✓
- **Prioridad:** 1
- Click **Save & New**

#### Registro 2: GE Ventas VTLE
- **Label:** GE Ventas VTLE
- **Bodega SAP Name:** GE_Ventas_VTLE
- **Línea de Negocio:** 21000,15000,10000
- **Región Despacho:** TODAS
- **Requiere HES:** VENTA_NORMAL
- **Código Bodega SAP:** VTLE
- **Nombre Bodega:** BODEGA VENTAS GENERACION LO ESPEJO
- **Activo:** ✓
- **Prioridad:** 2
- Click **Save & New**

#### Registro 3: Servicio Santiago ST10
- **Label:** Servicio Santiago ST10
- **Bodega SAP Name:** Servicio_Santiago_ST10
- **Línea de Negocio:** 22000
- **Región Despacho:** 13
- **Requiere HES:** VENTA_NORMAL
- **Código Bodega SAP:** ST10
- **Nombre Bodega:** BOD. DE REPTO. CENTRAL SERVICIO TECNICO
- **Activo:** ✓
- **Prioridad:** 3
- Click **Save & New**

#### Registro 4: Servicio Antofagasta STA10
- **Label:** Servicio Antofagasta STA10
- **Bodega SAP Name:** Servicio_Antofagasta_STA10
- **Línea de Negocio:** 22000
- **Región Despacho:** 2
- **Requiere HES:** VENTA_NORMAL
- **Código Bodega SAP:** STA10
- **Nombre Bodega:** BODEGA SERVICIOS ANTOFAGASTA
- **Activo:** ✓
- **Prioridad:** 3
- Click **Save & New**

#### Registro 5: Servicio Puerto Montt STSP10
- **Label:** Servicio Puerto Montt STSP10
- **Bodega SAP Name:** Servicio_PuertoMontt_STSP10
- **Línea de Negocio:** 22000
- **Región Despacho:** 10
- **Requiere HES:** VENTA_NORMAL
- **Código Bodega SAP:** STSP10
- **Nombre Bodega:** BODEGA DE SURTIDOS SERVICIOS TECNICO PTO. MONTT
- **Activo:** ✓
- **Prioridad:** 3
- Click **Save & New**

#### Registro 6: Servicio Concepción STC10
- **Label:** Servicio Concepcion STC10
- **Bodega SAP Name:** Servicio_Concepcion_STC10
- **Línea de Negocio:** 22000
- **Región Despacho:** 8
- **Requiere HES:** VENTA_NORMAL
- **Código Bodega SAP:** STC10
- **Nombre Bodega:** BODEGA SERVICIOS CONCEPCION
- **Activo:** ✓
- **Prioridad:** 3
- Click **Save**

---

## PASO 2: Desplegar clases Apex via CLI (2 min)

Una vez creado el Custom Metadata Type en Step 1, ejecutar:

```bash
cd /Users/rodrigoalonsocarvallogonzalez/Documents/SALESFORCE/LUREYE/LUREYE-DEV

# Desplegar clases nuevas
sf project deploy start --source-dir force-app/main/default/classes/LUREYE_Bodega_SAP_Service.cls --source-dir force-app/main/default/classes/LUREYE_Bodega_SAP_Service_Test.cls
```

---

## PASO 3: Ejecutar Tests (1 min)

```bash
# Ejecutar tests de la nueva clase
sf apex run test --class-names LUREYE_Bodega_SAP_Service_Test --result-format human --code-coverage

# Resultado esperado: 16 tests pasan, >95% cobertura
```

---

## PASO 4: Desplegar modificación a LUREYE_Drafts_SAP (1 min)

```bash
# Desplegar clase modificada
sf project deploy start --source-dir force-app/main/default/classes/LUREYE_Drafts_SAP.cls
```

---

## VALIDACIÓN FINAL

### Test Manual 1: GE Relacional
1. Login como usuario GE (Patricio Garrido)
2. Crear Quote
3. Click "Crear Draft en SAP"
4. Revisar logs: debe decir `🏭 [BODEGA] Bodega asignada: VTLE`
5. Verificar en SAP: `WarehouseCode = "VTLE"`

### Test Manual 2: Servicio Santiago
1. Login como usuario SE Santiago
2. Crear Quote con dirección despacho en Santiago (Región 13)
3. Click "Crear Draft en SAP"
4. Revisar logs: debe decir `🏭 [BODEGA] Bodega asignada: ST10`
5. Verificar en SAP: `WarehouseCode = "ST10"`

---

## ✅ CHECKLIST

- [ ] Custom Metadata Type creado en org
- [ ] 7 campos creados
- [ ] 6 registros de configuración creados
- [ ] Clases Apex desplegadas (LUREYE_Bodega_SAP_Service + Test)
- [ ] Tests ejecutados (16/16 pasan)
- [ ] LUREYE_Drafts_SAP desplegada (modificada)
- [ ] Test manual 1 exitoso (GE → VTLE)
- [ ] Test manual 2 exitoso (Servicio → ST10)
- [ ] Sin errores en logs

---

## 🚀 ALTERNATIVA: Deploy todo desde UI

Si CLI da problemas, puedes usar **VS Code** con la extensión de Salesforce:

1. Right-click en `force-app/main/default/objects/Bodega_SAP__mdt` > Deploy Source to Org
2. Right-click en `LUREYE_Bodega_SAP_Service.cls` > Deploy Source to Org
3. Right-click en `LUREYE_Bodega_SAP_Service_Test.cls` > Deploy Source to Org
4. Right-click en `LUREYE_Drafts_SAP.cls` > Deploy Source to Org

---

**Desarrollado por:** Rodrigo Carvallo  
**Rama Git:** Ticket-00024376  
**Commits:** 2 (initial + ajustes)

