# ⚡ Guía Rápida de Testing - Ticket 00024376

**Tiempo total:** 30-45 minutos  
**Ambiente:** Sandbox UAT

---

## 🚀 VALIDACIÓN AUTOMÁTICA (5 min)

### PASO 1: Ejecutar Script de Validación

1. **Abrir Developer Console:**
   - Setup > Developer Console

2. **Abrir Execute Anonymous:**
   - Debug > Open Execute Anonymous Window

3. **Copiar el contenido completo del archivo:**
   - `SCRIPT-VALIDACION-BODEGA.apex`

4. **Ejecutar:**
   - ✅ Check "Open Log"
   - Click "Execute"

5. **Ver resultados en el log:**
   - Buscar: `RESUMEN DE VALIDACIÓN`
   - Debe decir: `🎉🎉🎉 ¡TODAS LAS VALIDACIONES PASARON!`

**Si pasa:** ✅ Continúa con pruebas manuales  
**Si falla:** ❌ Revisar configuraciones del Custom Metadata Type

---

## 🧪 TESTING MANUAL (25-40 min)

### PREPARACIÓN: Crear Datos Base (10 min - UNA SOLA VEZ)

#### A. Crear Account de Prueba

```
Setup > Object Manager > Account > New (desde la UI o Data Import)

RUT_SD__c:        12345678
RUT_DV__c:        9
Name:             CLIENTE TEST TICKET 24376
CurrencyIsoCode:  CLP
```

#### B. Crear Dirección Santiago (Región 13)

```
Related > Direcciones > New

Tipo:      Despacho
Name:      Despacho Santiago
Street:    AV PRUEBA
StreetNo:  123
Ciudad:    SANTIAGO
Comuna:    PROVIDENCIA
Region__c: 13                    ← CRÍTICO
TaxCode:   IVA
```

#### C. Crear Dirección Antofagasta (Región 2)

```
Related > Direcciones > New

Tipo:      Despacho
Name:      Despacho Antofagasta
Street:    AV NORTE
StreetNo:  456
Ciudad:    ANTOFAGASTA
Comuna:    ANTOFAGASTA
Region__c: 2                     ← CRÍTICO
TaxCode:   IVA
```

#### D. Crear Dirección Facturación

```
Related > Direcciones > New

Tipo:      Facturación
Name:      Facturación
Street:    AV FACTURAS
StreetNo:  789
Ciudad:    SANTIAGO
Comuna:    LAS CONDES
Region__c: 13
TaxCode:   IVA
```

---

## 📋 PRUEBA 1: HES Override → VTADFL10 (10 min)

### A. Configurar Usuario
1. **Editar tu usuario** (o crear uno de prueba):
   - Linea_Negocio__c: `21000`
   - Branch__c: `93141000-8`
   - CodigoUN__c: `GE`
   - Codigo_SAP__c: `100`

### B. Crear Opportunity
1. **Desde el Account:** New Opportunity
   ```
   Opportunity Name:  Opp Test HES
   Stage:            Definición necesidad
   Close Date:       31/12/2025
   Record Type:      GE Comercial - Industrial
   ```
2. **Agregar Producto:**
   - Add Products
   - Seleccionar 1 producto activo
   - Quantity: 1
   - Sales Price: 100000
   - Save

3. **Cambiar Stage:**
   - Edit > Stage: `Cotización` > Save

### C. Crear Quote
1. **Desde la Opportunity:** New Quote
   ```
   Quote Name:        Test HES Override
   Glosa:            Prueba bodega VTADFL10
   N° Orden Compra:   OC-TEST-HES-001
   Condición de Pago: Contado
   RequiereHES:       HES                    ← CRÍTICO
   Fecha Entrega:     31/12/2025
   DirDespacho:       Despacho Santiago (Región 13)
   DirFacturacion:    Facturación
   ```
2. **Save**

3. **Agregar Producto:**
   - Edit Lines
   - Seleccionar el producto
   - Quantity: 1
   - Sales Price: 100000
   - Save

### D. Ejecutar Creación de Draft

1. **Habilitar Debug Log:**
   - Setup > Debug Logs > New
   - User: Tu usuario
   - Start Time: Now
   - Expiration: 1 hora
   - Save

2. **Abrir la Quote**

3. **Click:** Botón `Crear Draft en SAP` (arriba a la derecha)

4. **Esperar mensaje:**
   - ✅ "¡Se ha creado el Draft XXXX exitosamente en SAP!"
   - ❌ Si hay error, revisar mensaje y corregir

### E. Validar Debug Log

1. **Ir a:** Setup > Debug Logs
2. **Abrir el último log**
3. **Buscar:** `[BODEGA]`
4. **Debe mostrar:**
   ```
   🏭 [BODEGA] Región de despacho: 13 (SANTIAGO)
   🏭 [BODEGA] Línea Negocio: 21000
   🏭 [BODEGA] RegionDespacho: 13
   🏭 [BODEGA] RequiereHES: HES
   🔍 [BODEGA] Evaluando: HES-802 Override (Prioridad: 1)
   ✅ [BODEGA] Match encontrado: VTADFL10
   🏭 [BODEGA] Bodega asignada: VTADFL10
   ```

### F. Validar JSON enviado

1. **En el mismo log, buscar:** `BODY CREADO`
2. **Copiar el JSON**
3. **Formatear** en un JSON viewer
4. **Buscar:** `"WarehouseCode"`
5. **Debe decir:** `"WarehouseCode": "VTADFL10"`

### ✅ CRITERIO DE ÉXITO

- ✅ Draft creado exitosamente
- ✅ Log muestra evaluación de regla HES-802
- ✅ Bodega asignada: VTADFL10
- ✅ JSON contiene `"WarehouseCode": "VTADFL10"`

---

## 📋 PRUEBA 2: Servicio Santiago → ST10 (5 min)

**Reutiliza el mismo Account y direcciones.**

### A. Cambiar Usuario
```
Linea_Negocio__c: 22000     ← Cambiar a Servicio
CodigoUN__c:     SE         ← Cambiar a Servicio
```

### B. Crear Nueva Opportunity
```
Opportunity Name: Opp Test Servicio Santiago
Stage:           Cotización
Producto:        1 producto activo
```

### C. Crear Nueva Quote
```
Quote Name:        Test Servicio Santiago
Glosa:            Prueba bodega ST10
N° Orden Compra:   OC-TEST-SRV-STG-001
RequiereHES:       Venta Normal        ← Normal, NO HES
DirDespacho:       Despacho Santiago (Región 13) ← IMPORTANTE
```

### D. Crear Draft y Validar

**Debe asignar:** `ST10`

**Log esperado:**
```
🏭 [BODEGA] Región de despacho: 13 (SANTIAGO)
🏭 [BODEGA] Línea Negocio: 22000
🔍 [BODEGA] Evaluando: HES-802 Override (Prioridad: 1)
  ❌ No cumple RequiereHES
🔍 [BODEGA] Evaluando: GE Ventas VTLE (Prioridad: 2)
  ❌ No cumple Línea Negocio
🔍 [BODEGA] Evaluando: Servicio Santiago ST10 (Prioridad: 3)
✅ [BODEGA] Match encontrado: ST10
```

---

## 📋 PRUEBA 3: Servicio Antofagasta → STA10 (5 min)

**Mismo usuario (Línea 22000).**

### Crear Nueva Quote
```
Quote Name:        Test Servicio Antofagasta
Glosa:            Prueba bodega STA10
N° Orden Compra:   OC-TEST-SRV-ANT-001
RequiereHES:       Venta Normal
DirDespacho:       Despacho Antofagasta (Región 2) ← IMPORTANTE
```

**Debe asignar:** `STA10`

---

## 📊 CHECKLIST RÁPIDO

Usa esta tabla para ir marcando:

| # | Prueba | Línea | Región | HES | Bodega | Status | Notas |
|---|--------|-------|--------|-----|--------|--------|-------|
| 1 | Script Validación | - | - | - | - | ⬜ | Ejecutar en Dev Console |
| 2 | HES Override | 21000 | 13 | HES | VTADFL10 | ⬜ | |
| 3 | GE Relacional | 21000 | 13 | Normal | VTLE | ⬜ | |
| 4 | Servicio Santiago | 22000 | 13 | Normal | ST10 | ⬜ | |
| 5 | Servicio Antofagasta | 22000 | 2 | Normal | STA10 | ⬜ | |
| 6 | Servicio Puerto Montt | 22000 | 10 | Normal | STSP10 | ⬜ | Requiere dirección Región 10 |
| 7 | Servicio Concepción | 22000 | 8 | Normal | STC10 | ⬜ | Requiere dirección Región 8 |

**Mínimo requerido:** Pruebas 1, 2, 3, 4 (4 de 7)

---

## ⚠️ PROBLEMAS COMUNES

### Error: "El campo 'Glosa' está vacío"
**Solución:** Llenar campo `Glosa__c` en la Quote

### Error: "El campo 'N° Orden de Compra' está vacío"
**Solución:** Llenar campo `NOrdenCompra__c` en la Quote

### Error: "El campo 'Branch' en el usuario está vacío"
**Solución:** Editar usuario y llenar `Branch__c`

### No aparece el botón "Crear Draft en SAP"
**Solución:**
1. Setup > Object Manager > Quote > Page Layouts
2. Editar el layout que uses
3. Salesforce Mobile and Lightning Experience Actions
4. Agregar `Crear_Draft_en_SAP` desde la paleta

### Debug Log vacío
**Solución:**
1. Setup > Debug Logs > New
2. Traced Entity Type: User
3. Traced Entity: Tu usuario
4. Start Time: Now
5. Expiration: 1 hora

### Bodega incorrecta asignada
**Solución:**
1. Validar que `Region__c` en `Direccion__c` tenga el valor numérico correcto (no texto)
2. Validar que `Linea_Negocio__c` en User tenga el valor numérico correcto
3. Validar que `RequiereHES__c` en Quote coincida con los valores configurados

---

## 📧 REPORTE A ENVIAR

Después de probar, completa esto:

```
TESTING TICKET 00024376 - SANDBOX UAT
======================================

Ejecutado por: [Tu nombre]
Fecha: [Fecha]
Tiempo total: [X minutos]

RESULTADOS:
✅ Script de validación: PASS (12/12)
✅ Prueba HES Override: PASS
✅ Prueba GE Relacional: PASS
✅ Prueba Servicio Santiago: PASS
✅ Prueba Servicio Antofagasta: PASS

DRAFTS CREADOS EN SAP:
- Draft 12345 (HES) → Bodega VTADFL10 ✅
- Draft 12346 (GE) → Bodega VTLE ✅
- Draft 12347 (Servicio STG) → Bodega ST10 ✅
- Draft 12348 (Servicio ANT) → Bodega STA10 ✅

BUGS ENCONTRADOS: Ninguno

OBSERVACIONES:
- Funcionamiento correcto en todos los casos
- Debug logs claros y útiles
- JSON enviado a SAP correcto

LISTO PARA PRODUCCIÓN: SÍ ✅
```

---

## 🎯 SIGUIENTE PASO

Si todas las pruebas pasan:

1. ✅ Enviar reporte a Marcelo
2. ✅ Programar deploy a producción
3. ✅ Crear CMT en producción (mismos pasos)
4. ✅ Deployar clases a producción
5. ✅ Hacer 1 prueba final con Quote real
6. ✅ Cerrar ticket

---

**Última actualización:** 13 Noviembre 2025, 23:00

