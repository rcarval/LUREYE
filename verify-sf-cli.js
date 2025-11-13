#!/usr/bin/env node

/**
 * Script para verificar instalación del Salesforce CLI
 */

const { execSync } = require('child_process');

console.log('🔍 Verificando instalación del Salesforce CLI...\n');

// Verificar sf CLI
try {
    const sfVersion = execSync('sf --version', { encoding: 'utf-8' });
    console.log('✅ Salesforce CLI (sf) instalado:');
    console.log('   ' + sfVersion.trim());
} catch (error) {
    console.log('❌ Salesforce CLI (sf) NO encontrado\n');
    console.log('📦 Para instalar, ejecuta:');
    console.log('   npm install -g @salesforce/cli\n');
    console.log('📚 O visita: https://developer.salesforce.com/tools/salesforcecli\n');
    process.exit(1);
}

// Verificar plugins instalados
console.log('\n🔌 Plugins instalados:');
try {
    const plugins = execSync('sf plugins --core', { encoding: 'utf-8' });
    console.log(plugins);
} catch (error) {
    console.log('⚠️  No se pudieron listar los plugins');
}

// Verificar Code Analyzer (para apex:scan)
console.log('\n🔍 Verificando Salesforce Code Analyzer...');
try {
    execSync('sf scanner --version', { encoding: 'utf-8', stdio: 'ignore' });
    console.log('✅ Code Analyzer instalado');
} catch (error) {
    console.log('⚠️  Code Analyzer NO instalado (opcional para apex:scan)');
    console.log('   Para instalar: sf plugins install @salesforce/sfdx-scanner\n');
}

// Verificar orgs conectadas
console.log('\n🌐 Orgs conectadas:');
try {
    const orgs = execSync('sf org list --json', { encoding: 'utf-8' });
    const orgData = JSON.parse(orgs);
    
    if (orgData.result.nonScratchOrgs.length === 0 && orgData.result.scratchOrgs.length === 0) {
        console.log('⚠️  No hay orgs conectadas');
        console.log('   Para conectar: sf org login web\n');
    } else {
        console.log('✅ Orgs encontradas:');
        orgData.result.nonScratchOrgs.forEach(org => {
            const defaultMarker = org.isDefaultUsername ? '(default)' : '';
            console.log(`   - ${org.alias || org.username} ${defaultMarker}`);
        });
        orgData.result.scratchOrgs.forEach(org => {
            const defaultMarker = org.isDefaultUsername ? '(default)' : '';
            console.log(`   - ${org.alias || org.username} ${defaultMarker} [scratch]`);
        });
    }
} catch (error) {
    console.log('⚠️  No se pudieron listar las orgs');
}

console.log('\n✅ Verificación completa!\n');
console.log('📋 Próximos pasos:');
console.log('   1. Si falta el CLI: npm install -g @salesforce/cli');
console.log('   2. Si no hay orgs: sf org login web');
console.log('   3. Ejecuta: npm run apex:test (requiere org conectada)');
console.log('   4. Ejecuta: npm run apex:scan (requiere Code Analyzer)\n');



