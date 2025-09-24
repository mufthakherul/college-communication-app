#!/usr/bin/env node

/**
 * Backend Seeding Script
 * 
 * This script provides a convenient way to run the Firebase seeding script
 * from the backend directory. It acts as a wrapper for the actual seeding
 * script located in the functions directory.
 */

const path = require('path');
const { spawn } = require('child_process');

const functionsDir = path.resolve(__dirname, '../../functions');
const seedScript = path.join(functionsDir, 'scripts', 'seed.js');

console.log('🔗 Running Firebase seeding script...');
console.log(`📁 Functions directory: ${functionsDir}`);
console.log(`📄 Seed script: ${seedScript}`);
console.log('');

// Change to functions directory and run the seed script
process.chdir(functionsDir);

const nodeProcess = spawn('node', ['scripts/seed.js'], {
  stdio: 'inherit',
  cwd: functionsDir
});

nodeProcess.on('error', (error) => {
  console.error('❌ Error running seed script:', error);
  process.exit(1);
});

nodeProcess.on('close', (code) => {
  if (code === 0) {
    console.log('✅ Seeding script completed successfully');
  } else {
    console.error(`❌ Seeding script exited with code ${code}`);
  }
  process.exit(code);
});