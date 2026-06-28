#!/usr/bin/env node
/**
 * QR Code Generator for Smart English Everyday APK
 * Usage: node scripts/generate-qr.js [APK_URL]
 */

const QRCode = require('qrcode');
const path = require('path');
const fs = require('fs');

const APK_URL = process.argv[2] || process.env.APK_URL || 'https://github.com/Iskanderqasem/Smart-English-Everyday/releases/latest/download/app-release.apk';

const outputDir = path.join(__dirname, '..', 'docs', 'qr-codes');
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

async function generateQR() {
  console.log(`\n🔗 Generating QR Code for:\n   ${APK_URL}\n`);

  // PNG
  const pngPath = path.join(outputDir, 'install-qr.png');
  await QRCode.toFile(pngPath, APK_URL, { errorCorrectionLevel: 'H', width: 400, margin: 2, color: { dark: '#1a237e', light: '#ffffff' } });
  console.log(`✅ PNG saved: ${pngPath}`);

  // SVG
  const svgPath = path.join(outputDir, 'install-qr.svg');
  const svgString = await QRCode.toString(APK_URL, { type: 'svg', width: 400, errorCorrectionLevel: 'H' });
  fs.writeFileSync(svgPath, svgString);
  console.log(`✅ SVG saved: ${svgPath}`);

  // Terminal QR
  console.log('\n📱 Scan this QR code to install the app:\n');
  try {
    const qrTerminal = require('qrcode-terminal');
    qrTerminal.generate(APK_URL, { small: true });
  } catch {
    console.log('(Install qrcode-terminal for terminal QR: npm i -g qrcode-terminal)');
  }

  // Update README QR section
  console.log(`\n📋 Markdown for README:\n`);
  console.log(`![Install QR Code](docs/qr-codes/install-qr.png)\n`);
  console.log(`**Direct Link:** ${APK_URL}\n`);
}

generateQR().catch(console.error);
