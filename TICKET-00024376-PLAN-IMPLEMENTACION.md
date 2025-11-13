# Plan de Implementación - Ticket 00024376

## 🎯 Objetivo
Asignar dinámicamente el código de bodega SAP (`WarehouseCode`) en las Órdenes de Venta según línea de negocio, región de despacho y condición de pago.

---

## 📦 FASE 1: Custom Metadata Type (1 hora)

### Tarea 1.1: Crear objeto `Bodega_SAP__mdt`
- Archivo: `force-app/main/default/objects/Bodega_SAP__mdt/Bodega_SAP__mdt.object-meta.xml`
- Crear estructura base del Custom Metadata

### Tarea 1.2: Crear 7 campos
Archivos en `force-app/main/default/objects/Bodega_SAP__mdt/fields/`:
1. `Linea_Negocio__c.field-meta.xml` - TextArea
2. `Region_Despacho__c.field-meta.xml` - Text(100)
3. `Requiere_HES__c.field-meta.xml` - Text(50)
4. `Codigo_Bodega_SAP__c.field-meta.xml` - Text(20) **OBLIGATORIO**
5. `Nombre_Bodega__c.field-meta.xml` - Text(100)
6. `Activo__c.field-meta.xml` - Checkbox
7. `Prioridad__c.field-meta.xml` - Number(2,0)

---

## 📝 FASE 2: Registros de Configuración (30 min)

### Crear 6 registros
Archivos en `force-app/main/default/customMetadata/`:

1. **`Bodega_SAP.HES_802_Override.md-meta.xml`**
   - Prioridad: 1 (máxima)
   - Línea: TODAS
   - Región: TODAS
   - HES: HES,802
   - Bodega: VTADFL10

2. **`Bodega_SAP.GE_Ventas_VTLE.md-meta.xml`**
   - Prioridad: 2
   - Línea: 21000,15000,10000
   - Región: TODAS
   - HES: VENTA_NORMAL
   - Bodega: VTLE

3. **`Bodega_SAP.Servicio_Santiago_ST10.md-meta.xml`**
   - Prioridad: 3
   - Línea: 22000
   - Región: 13
   - HES: VENTA_NORMAL
   - Bodega: ST10

4. **`Bodega_SAP.Servicio_Antofagasta_STA10.md-meta.xml`**
   - Prioridad: 3
   - Línea: 22000
   - Región: 2
   - Bodega: STA10

5. **`Bodega_SAP.Servicio_PuertoMontt_STSP10.md-meta.xml`**
   - Prioridad: 3
   - Línea: 22000
   - Región: 10
   - Bodega: STSP10

6. **`Bodega_SAP.Servicio_Concepcion_STC10.md-meta.xml`**
   - Prioridad: 3
   - Línea: 22000
   - Región: 8
   - Bodega: STC10

---

## 💻 FASE 3: Clase Helper (2 horas)

### Tarea 3.1: Crear `LUREYE_Bodega_SAP_Service.cls`

**Métodos principales:**

```apex
public static String determinarBodega(Decimal lineaNegocio, String regionDespacho, String requiereHES)
```
- Consulta Custom Metadata ordenado por prioridad
- Evalúa reglas en orden
- Retorna código de bodega o null

**Métodos privados:**
- `validarRequiereHES()` - Match de HES
- `validarLineaNegocio()` - Match de línea
- `validarRegion()` - Match de región

**Líneas:** ~150

### Tarea 3.2: Logs y debugging
- Logs detallados en cada evaluación
- Debug de configuración consultada
- Warning si no hay match

---

## 🧪 FASE 4: Tests Unitarios (2 horas)

### Tarea 4.1: Crear `LUREYE_Bodega_SAP_Service_Test.cls`

**11 test methods:**
1. `test_HES_RetornaVTADFL10()` - HES debe dar VTADFL10
2. `test_802_RetornaVTADFL10()` - 802 debe dar VTADFL10
3. `test_HES_SobreescribeGE()` - HES override sobre GE
4. `test_GE_Relacional_RetornaVTLE()` - LineaNegocio 21000
5. `test_GE_Proyecto_RetornaVTLE()` - LineaNegocio 15000
6. `test_GE_Transaccional_RetornaVTLE()` - LineaNegocio 10000
7. `test_Servicio_Santiago_RetornaST10()` - 22000 + Región 13
8. `test_Servicio_Antofagasta_RetornaSTA10()` - 22000 + Región 2
9. `test_Servicio_PuertoMontt_RetornaSTSP10()` - 22000 + Región 10
10. `test_Servicio_Concepcion_RetornaSTC10()` - 22000 + Región 8
11. `test_LineaNoConfigurada_RetornaNull()` - Sin match

**Cobertura esperada:** >95%

---

## 🔧 FASE 5: Modificar Integración (1 hora)

### Tarea 5.1: Modificar `LUREYE_Drafts_SAP.cls`

**Ubicación:** Método `CrearDrafts()`, líneas ~173-217

**Cambios:**

#### Cambio 1: Consultar región de despacho (NUEVO)
Después de consultar Quote (línea ~131), agregar:

```apex
String regionDespacho = null;
if (qryQuote.DirDespacho__c != null) {
    try {
        Direccion__c dirDesp = [SELECT Region__c, Ciudad__c 
                                FROM Direccion__c 
                                WHERE Id = :qryQuote.DirDespacho__c 
                                LIMIT 1];
        regionDespacho = dirDesp.Region__c;
        System.debug('🏭 Región despacho: ' + dirDesp.Region__c + ' (' + dirDesp.Ciudad__c + ')');
    } catch (Exception e) {
        System.debug('⚠️ Error obteniendo región: ' + e.getMessage());
    }
}
```

#### Cambio 2: Reemplazar lógica de bodega (líneas 173-182)

```apex
// ELIMINAR esto:
if (qryQuote.Propiedades__c != null){
    propiedades = qryQuote.Propiedades__c;
    propHES     = qryQuote.RequiereHES__c;
    if(propHES == 'HES' || propHES == '802') {
        bodega = 'VTADFL10';
    }        
}

// REEMPLAZAR por esto:
if (qryQuote.Propiedades__c != null){
    propiedades = qryQuote.Propiedades__c;
    propHES     = qryQuote.RequiereHES__c;
}

// Determinar bodega usando nueva lógica
bodega = LUREYE_Bodega_SAP_Service.determinarBodega(
    userqry.Linea_Negocio__c, 
    regionDespacho, 
    propHES
);

System.debug('🏭 Bodega asignada: ' + (bodega != null ? bodega : 'SAP DEFAULT'));
```

**Total líneas modificadas:** ~25

---

## 🧪 FASE 6: Testing en Sandbox (1 día)

### Tarea 6.1: Tests Automáticos
```bash
sf apex run test --class-names LUREYE_Bodega_SAP_Service_Test --result-format human
```

### Tarea 6.2: Tests Manuales de Integración

Crear 4 quotes de prueba y validar bodega en SAP:

| Test | Usuario | Línea | Región | HES | Bodega Esperada |
|------|---------|-------|--------|-----|-----------------|
| 1 | GE | 21000 | 13 | Normal | VTLE |
| 2 | SE | 22000 | 13 | Normal | ST10 |
| 3 | SE | 22000 | 2 | Normal | STA10 |
| 4 | GE | 21000 | 13 | HES | VTADFL10 |

**Validación en SAP:**
```bash
GET /Orders({DocEntry})
# Verificar: DocumentLines[0].WarehouseCode
```

---

## 🚀 FASE 7: Deployment a Producción (0.5 día)

### Checklist
- [ ] Tests >75% cobertura
- [ ] Validación exitosa en sandbox
- [ ] 4 tests manuales aprobados
- [ ] Backup de código actual
- [ ] Plan de rollback

### Componentes a Deployar
1. Custom Metadata Type (1 objeto, 7 campos)
2. Custom Metadata Records (6 registros)
3. Apex Class nueva: `LUREYE_Bodega_SAP_Service`
4. Apex Class nueva: `LUREYE_Bodega_SAP_Service_Test`
5. Apex Class modificada: `LUREYE_Drafts_SAP`

### Script
```bash
sf project deploy start --source-dir force-app
```

---

## 📊 FASE 8: Monitoreo (5 días)

### Días 1-3: Intensivo
- Revisar debug logs de todas las OV creadas
- Validar bodegas con equipo WMS
- Buscar errores o asignaciones incorrectas

### Días 4-5: Validación
- Confirmar con WMS que picking es más eficiente
- Validar reportería de stock por bodega
- Cerrar ticket si todo OK

---

## 📋 LISTA DE COMPONENTES

| # | Componente | Tipo | Estado | Líneas |
|---|------------|------|--------|--------|
| 1 | Bodega_SAP__mdt | Custom Metadata Type | ⏳ Crear | N/A |
| 2 | 7 campos de CMT | Custom Fields | ⏳ Crear | N/A |
| 3 | 6 registros config | Custom Metadata | ⏳ Crear | N/A |
| 4 | LUREYE_Bodega_SAP_Service | Apex Class | ⏳ Crear | ~150 |
| 5 | LUREYE_Bodega_SAP_Service_Test | Apex Test | ⏳ Crear | ~200 |
| 6 | LUREYE_Drafts_SAP | Apex Class | ⏳ Modificar | ~25 |

**Total desarrollo:** ~375 líneas de código nuevo + 25 líneas modificadas

---

## ⚠️ RIESGOS

| Riesgo | Mitigación |
|--------|------------|
| Bodega no existe en SAP | ✅ Validado: todas las bodegas existen |
| Región de despacho null | Fallback a null (SAP default) |
| Performance | Custom Metadata en caché (sin impacto) |

---

## ✅ CRITERIOS DE ÉXITO

- [ ] OV de GE van a VTLE
- [ ] OV de Servicio van a bodega por región
- [ ] OV con HES-802 van a VTADFL10
- [ ] Sin errores en producción
- [ ] WMS confirma bodegas correctas

---

**¿Aprobado para desarrollo?** 🚀

