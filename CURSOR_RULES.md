# Reglas Globales de Cursor para Salesforce

Copia y pega este contenido en: **Cursor Settings > General Rules**

---

## Salesforce Development Rules

### Lenguaje
- Responde siempre en español
- Usa terminología técnica en inglés cuando sea apropiado

### Apex Code Standards

**Nomenclatura:**
- Clases: PascalCase con prefijo del proyecto
- Métodos: camelCase
- Variables: camelCase
- Constantes: UPPER_SNAKE_CASE

**Best Practices:**
- Siempre usar bulkification (evitar DML/SOQL en loops)
- Limitar SOQL queries: máximo 100 por transacción
- Limitar DML statements: máximo 150 por transacción
- Usar try-catch con logs detallados: getMessage(), getStackTraceString(), getCause(), getLineNumber()
- Tests: incluir Test.startTest() y Test.stopTest()

**Testing:**
- Cobertura mínima: 75%
- Usar @isTest en vez de testMethod
- Mockear callouts HTTP
- Nombres descriptivos: test_WhenCondition_ThenExpectedResult

**SOQL/DML:**
- Usar SOQL For Loops para grandes volúmenes
- Verificar permisos con WITH SECURITY_ENFORCED cuando sea apropiado
- Database.insert/update con allOrNone=false cuando sea necesario

**Security:**
- Usar 'with sharing' o 'without sharing' explícitamente
- Validar inputs de usuarios
- Escapar strings en consultas dinámicas
- @AuraEnabled(cacheable=true) para métodos de lectura

### LWC Standards

**Estructura:**
- Un componente = una responsabilidad
- Archivos en camelCase
- Eventos custom para comunicación

**JavaScript:**
- const/let, nunca var
- Destructuring para props
- Async/await para operaciones asíncronas
- Try-catch para errores

**HTML:**
- Usar slots para composición
- if:true/if:false sobre for:each cuando sea posible
- Accesibilidad: labels, aria-*, roles

### Integration Patterns

**REST Callouts:**
- Usar Named Credentials
- Implementar retry logic
- Timeout apropiados (120s default)
- Logging de requests/responses

**Error Handling:**
- Capturar excepciones específicas antes que Exception
- Logs completos con stack trace
- Notificar errores críticos

### Code Generation

**Al generar Apex:**
1. Incluir comentarios explicativos
2. Respetar convenciones del proyecto
3. Manejo de errores robusto
4. Considerar límites del governor
5. Sugerir tests unitarios

**Al generar tests:**
1. @TestSetup para datos comunes
2. Tests independientes
3. Aserciones claras
4. Mockear dependencias externas

### Performance

- Usar indexes en campos de filtro
- Evitar fórmulas complejas
- Platform Events para procesos asíncronos
- Batch Apex para >50k records

### Documentation

- JavaDoc en métodos públicos
- README.md para proyectos complejos
- Diagramas para integraciones

### Deployment

- Validar antes de deploy a producción
- CI/CD o changesets
- Tests actualizados
- Documentar dependencias

