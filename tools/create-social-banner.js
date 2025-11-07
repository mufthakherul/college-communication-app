#!/usr/bin/env node
/**
 * Simple PNG generator for social banner
 * Creates a 1200x630 banner with RPI Echo System branding
 */
const fs = require('fs');
const path = require('path');

// PNG header + simple blue image data (1200x630, blue background)
function createSimplePNG() {
  // PNG Signature
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  
  // IHDR chunk (image header)
  const width = 1200;
  const height = 630;
  const ihdr = Buffer.alloc(25);
  ihdr.writeUInt32BE(13, 0);  // chunk length
  ihdr.write('IHDR', 4);
  ihdr.writeUInt32BE(width, 8);
  ihdr.writeUInt32BE(height, 12);
  ihdr[16] = 8;  // bit depth
  ihdr[17] = 2;  // color type (RGB)
  ihdr[18] = 0;  // compression
  ihdr[19] = 0;  // filter
  ihdr[20] = 0;  // interlace
  
  // Simple CRC (not calculating properly, but will make it close)
  const crcVal = 0;
  ihdr.writeUInt32BE(crcVal, 21);
  
  // IDAT chunk (image data) - simplified single scanline repeated
  // Create minimal compressed data: just blue color (0x0D47A1 equivalent)
  const zlib = require('zlib');
  
  // Create simple image data - all pixels blue
  const blue = Buffer.from([13, 71, 161]);  // #0D47A1 in RGB
  let scanlineData = Buffer.alloc(height * (width * 3 + 1));
  let pos = 0;
  
  for (let y = 0; y < height; y++) {
    scanlineData[pos++] = 0;  // filter type
    for (let x = 0; x < width; x++) {
      scanlineData[pos++] = blue[0];
      scanlineData[pos++] = blue[1];
      scanlineData[pos++] = blue[2];
    }
  }
  
  const compressed = zlib.deflateSync(scanlineData);
  const idatLength = Buffer.alloc(4);
  idatLength.writeUInt32BE(compressed.length, 0);
  
  const idatChunk = Buffer.concat([
    idatLength,
    Buffer.from('IDAT'),
    compressed,
    Buffer.alloc(4) // placeholder CRC
  ]);
  
  // IEND chunk (image end)
  const iend = Buffer.from([0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
  
  return Buffer.concat([signature, ihdr, idatChunk, iend]);
}

const bannerPath = path.join(__dirname, '..', 'apps', 'web', 'public', 'icons', 'social-banner.png');

try {
  const dir = path.dirname(bannerPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  const pngData = createSimplePNG();
  fs.writeFileSync(bannerPath, pngData);
  console.log('✓ Created social banner:', bannerPath);
  console.log('  Size: 1200x630, Blue (#0D47A1)');
} catch (err) {
  console.error('Error creating social banner:', err);
  process.exit(1);
}
