#!/bin/bash

echo "🔧 Abriendo configuración de Cursor..."
echo ""

# Detectar si existe el archivo de configuración
CONFIG_FILE="$HOME/Library/Application Support/Cursor/User/settings.json"

if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Archivo de configuración encontrado"
    echo "📂 Ubicación: $CONFIG_FILE"
    echo ""
    echo "🚀 Abriendo archivo..."
    open "$CONFIG_FILE"
    echo ""
    echo "📋 INSTRUCCIONES:"
    echo ""
    echo "1. Se abrirá el archivo settings.json"
    echo "2. Busca si ya existe 'cursor.general.rules'"
    echo "3. Si NO existe, añade al final (antes del último }):"
    echo ""
    echo '   "cursor.general.rules": "AQUÍ VAN LAS REGLAS"'
    echo ""
    echo "4. Copia las reglas del archivo: REGLAS_PARA_COPIAR.txt"
    echo "5. Pégalas donde dice 'AQUÍ VAN LAS REGLAS'"
    echo "6. Guarda con Cmd+S"
    echo "7. Reinicia Cursor"
    echo ""
else
    echo "⚠️  Archivo de configuración NO encontrado"
    echo ""
    echo "Esto puede significar que:"
    echo "1. Cursor aún no ha creado el archivo (normal en primera instalación)"
    echo "2. La ubicación es diferente en tu sistema"
    echo ""
    echo "📝 SOLUCIÓN:"
    echo "1. Abre Cursor"
    echo "2. Presiona Cmd+Shift+P"
    echo "3. Escribe: 'Preferences: Open User Settings (JSON)'"
    echo "4. Presiona Enter"
    echo "5. Se creará/abrirá el archivo automáticamente"
    echo ""
fi

# Crear archivo con las reglas listas para copiar
cat > REGLAS_PARA_COPIAR.txt << 'EOF'
# Salesforce Development Rules

## Lenguaje
- Responde siempre en español
- Usa terminología técnica en inglés cuando sea apropiado

## Apex Code Standards

### Nomenclatura
- Clases: PascalCase con prefijo del proyecto
- Métodos: camelCase
- Variables: camelCase
- Constantes: UPPER_SNAKE_CASE

### Best Practices
- Siempre usar bulkification (evitar DML/SOQL en loops)
- Limitar SOQL queries: máximo 100 por transacción
- Limitar DML statements: máximo 150 por transacción
- Usar try-catch con logs detallados: getMessage(), getStackTraceString(), getCause(), getLineNumber()
- Tests: incluir Test.startTest() y Test.stopTest()

### Testing
- Cobertura mínima: 75%
- Usar @isTest en vez de testMethod
- Mockear callouts HTTP
- Nombres descriptivos: test_WhenCondition_ThenExpectedResult
- @TestSetup para datos comunes

### SOQL/DML
- Usar SOQL For Loops para grandes volúmenes (>50k records)
- Verificar permisos con WITH SECURITY_ENFORCED
- Database.insert/update con allOrNone=false cuando sea necesario
- Evitar SOQL/DML en loops

### Security
- Usar 'with sharing' o 'without sharing' explícitamente
- Validar inputs de usuarios
- Escapar strings en consultas dinámicas
- @AuraEnabled(cacheable=true) para métodos de lectura en LWC

## LWC Standards
- const/let, nunca var
- Async/await para operaciones asíncronas
- Try-catch para manejo de errores
- Accesibilidad: labels, aria-*, roles

## Integration Patterns
- Named Credentials cuando sea posible
- Retry logic en callouts
- Timeout apropiados (default: 120s)
- Logging de requests/responses

## Code Generation
- Incluir comentarios explicativos
- Manejo de errores robusto
- Considerar límites del governor
- Sugerir tests unitarios

## Performance
- Batch Apex para procesos grandes (>50k records)
- Queueable para cadenas de procesos asíncronos
- Platform Events para procesos asíncronos

## Deployment
- Validar antes de deploy a producción
- Mantener tests actualizados (>75% cobertura)
EOF

echo "✅ Archivo REGLAS_PARA_COPIAR.txt creado"
echo ""
echo "📖 Lee el archivo CONFIGURAR_CURSOR_GLOBAL.md para instrucciones detalladas"



