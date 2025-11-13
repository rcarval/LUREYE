# 📋 Instrucciones: Crear Custom Metadata Type "Bodega SAP"

**Tiempo estimado:** 10-15 minutos  
**Usuario:** `admin.seidor@lureye.com.uat`

---

## 🎯 PASO 1: Crear el Custom Metadata Type (2 min)

1. **Login** a la org: https://test.salesforce.com
   - Usuario: `admin.seidor@lureye.com.uat`

2. Ir a **Setup** (Configuración)

3. En el Quick Find, buscar: **Custom Metadata Types**

4. Click en **New Custom Metadata Type**

5. Llenar el formulario:
   ```
   Label:                Bodega SAP
   Plural Label:         Bodegas SAP
   Object Name:          Bodega_SAP
   Description:          Configuración de bodegas SAP para asignación dinámica 
                        en Órdenes de Venta según línea de negocio, región y 
                        condición de pago
   ```

6. **Visibility:** Dejar en `All Apex code and APIs can use the type, and it's visible in Setup`

7. Click **Save**

---

## 📝 PASO 2: Crear 7 Campos Custom (7 min)

### Campo 1: Activo

1. En la página del Custom Metadata Type, ir a **Fields & Relationships**
2. Click **New**
3. Seleccionar **Checkbox**
4. Click **Next**
5. Llenar:
   ```
   Field Label:          Activo
   Field Name:           Activo
   Default Value:        ✓ Checked (activado)
   Description:          Indica si esta configuración de bodega está activa
   Help Text:            Solo las configuraciones activas se evalúan
   ```
6. Click **Next** > **Save**

---

### Campo 2: Código Bodega SAP

1. Click **New**
2. Seleccionar **Text**
3. Click **Next**
4. Llenar:
   ```
   Field Label:          Código Bodega SAP
   Field Name:           Codigo_Bodega_SAP
   Length:               50
   Description:          Código de la bodega en SAP (ej: VTLE, ST10, STA10)
   Help Text:            Este código se enviará a SAP en el campo WarehouseCode
   ```
5. **Required:** ☑️ Marcar como Required
6. Click **Next** > **Save**

---

### Campo 3: Línea Negocio

1. Click **New**
2. Seleccionar **Text**
3. Click **Next**
4. Llenar:
   ```
   Field Label:          Línea Negocio
   Field Name:           Linea_Negocio
   Length:               100
   Description:          Líneas de negocio aplicables (separadas por coma) o "TODAS"
   Help Text:            Ej: "21000,15000,10000" o "TODAS"
   ```
5. Click **Next** > **Save**

---

### Campo 4: Nombre Bodega

1. Click **New**
2. Seleccionar **Text**
3. Click **Next**
4. Llenar:
   ```
   Field Label:          Nombre Bodega
   Field Name:           Nombre_Bodega
   Length:               255
   Description:          Nombre descriptivo de la bodega para referencia
   Help Text:            Nombre legible para identificar la bodega
   ```
5. Click **Next** > **Save**

---

### Campo 5: Prioridad

1. Click **New**
2. Seleccionar **Number**
3. Click **Next**
4. Llenar:
   ```
   Field Label:          Prioridad
   Field Name:           Prioridad
   Length:               3
   Decimal Places:       0
   Description:          Prioridad de evaluación (menor = mayor prioridad)
   Help Text:            Se evalúan en orden ascendente. Prioridad 1 es la más alta
   ```
5. **Required:** ☑️ Marcar como Required
6. Click **Next** > **Save**

---

### Campo 6: Región Despacho

1. Click **New**
2. Seleccionar **Text**
3. Click **Next**
4. Llenar:
   ```
   Field Label:          Región Despacho
   Field Name:           Region_Despacho
   Length:               100
   Description:          Regiones aplicables (separadas por coma) o "TODAS"
   Help Text:            Ej: "13" (Santiago), "2" (Antofagasta), o "TODAS"
   ```
5. Click **Next** > **Save**

---

### Campo 7: Requiere HES

1. Click **New**
2. Seleccionar **Text**
3. Click **Next**
4. Llenar:
   ```
   Field Label:          Requiere HES
   Field Name:           Requiere_HES
   Length:               100
   Description:          Condiciones de pago aplicables (separadas por coma) o "TODAS"
   Help Text:            Ej: "HES,802" o "VENTA_NORMAL" o "TODAS"
   ```
5. Click **Next** > **Save**

---

## 🏭 PASO 3: Crear 6 Registros de Configuración (5 min)

### Registro 1: HES-802 Override (Prioridad 1 - MÁS ALTA)

1. Ir a **Setup** > Quick Find: **Custom Metadata Types**
2. Click en **Bodega SAP**
3. Click en **Manage Records**
4. Click **New**
5. Llenar:
   ```
   Label:                HES-802 Override
   Bodega SAP Name:      HES_802_Override
   
   Activo:               ✓ Checked
   Código Bodega SAP:    VTADFL10
   Línea Negocio:        TODAS
   Nombre Bodega:        BODEGA VENTA DESFASADAS GEN
   Prioridad:            1
   Región Despacho:      TODAS
   Requiere HES:         HES,802
   ```
6. Click **Save**

---

### Registro 2: GE Ventas VTLE (Prioridad 2)

1. Click **New**
2. Llenar:
   ```
   Label:                GE Ventas VTLE
   Bodega SAP Name:      GE_Ventas_VTLE
   
   Activo:               ✓ Checked
   Código Bodega SAP:    VTLE
   Línea Negocio:        21000,15000,10000
   Nombre Bodega:        BODEGA VENTAS GENERACION LO ESPEJO
   Prioridad:            2
   Región Despacho:      TODAS
   Requiere HES:         VENTA_NORMAL
   ```
3. Click **Save**

---

### Registro 3: Servicio Santiago (Prioridad 3)

1. Click **New**
2. Llenar:
   ```
   Label:                Servicio Santiago ST10
   Bodega SAP Name:      Servicio_Santiago_ST10
   
   Activo:               ✓ Checked
   Código Bodega SAP:    ST10
   Línea Negocio:        22000
   Nombre Bodega:        BOD. DE REPTO. CENTRAL SERVICIO TECNICO
   Prioridad:            3
   Región Despacho:      13
   Requiere HES:         VENTA_NORMAL
   ```
3. Click **Save**

---

### Registro 4: Servicio Antofagasta (Prioridad 3)

1. Click **New**
2. Llenar:
   ```
   Label:                Servicio Antofagasta STA10
   Bodega SAP Name:      Servicio_Antofagasta_STA10
   
   Activo:               ✓ Checked
   Código Bodega SAP:    STA10
   Línea Negocio:        22000
   Nombre Bodega:        BODEGA SERVICIOS ANTOFAGASTA
   Prioridad:            3
   Región Despacho:      2
   Requiere HES:         VENTA_NORMAL
   ```
3. Click **Save**

---

### Registro 5: Servicio Puerto Montt (Prioridad 3)

1. Click **New**
2. Llenar:
   ```
   Label:                Servicio Puerto Montt STSP10
   Bodega SAP Name:      Servicio_PuertoMontt_STSP10
   
   Activo:               ✓ Checked
   Código Bodega SAP:    STSP10
   Línea Negocio:        22000
   Nombre Bodega:        BODEGA SERVICIOS PTO. MONTT
   Prioridad:            3
   Región Despacho:      10
   Requiere HES:         VENTA_NORMAL
   ```
3. Click **Save**

---

### Registro 6: Servicio Concepción (Prioridad 3)

1. Click **New**
2. Llenar:
   ```
   Label:                Servicio Concepcion STC10
   Bodega SAP Name:      Servicio_Concepcion_STC10
   
   Activo:               ✓ Checked
   Código Bodega SAP:    STC10
   Línea Negocio:        22000
   Nombre Bodega:        BODEGA SERVICIOS CONCEPCION
   Prioridad:            3
   Región Despacho:      8
   Requiere HES:         VENTA_NORMAL
   ```
3. Click **Save**

---

## ✅ VALIDACIÓN

Después de crear todo, deberías ver:

1. **Custom Metadata Type:** `Bodega_SAP`
   - Con 7 campos custom

2. **Manage Records:** 6 registros activos
   - 1 con Prioridad 1 (HES-802)
   - 1 con Prioridad 2 (GE Ventas)
   - 4 con Prioridad 3 (Servicios)

---

## 🚀 SIGUIENTE PASO

Una vez completado todo, **dime "Listo"** y yo procederé a:
1. Desplegar `LUREYE_Bodega_SAP_Service.cls`
2. Desplegar `LUREYE_Bodega_SAP_Service_Test.cls`
3. Ejecutar tests (16 casos de prueba)
4. Desplegar `LUREYE_Drafts_SAP.cls` (modificación)

---

**Última actualización:** 13 Noviembre 2025

