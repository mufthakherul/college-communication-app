#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const Jimp = require('jimp');
const pngToIco = require('png-to-ico');

const webIconsDir = path.join(__dirname, '..', 'apps', 'web', 'public', 'icons');
const srcIcon = path.join(webIconsDir, 'icon-192.png');

async function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

async function generate() {
  await ensureDir(webIconsDir);

  if (!fs.existsSync(srcIcon)) {
    console.error('Source icon not found:', srcIcon);
    process.exit(1);
  }

  const image = await Jimp.read(srcIcon);

  // icon-32.png
  await image.clone().resize(32, 32).writeAsync(path.join(webIconsDir, 'icon-32.png'));

  // icon-512.png (upscale)
  await image.clone().resize(512, 512).writeAsync(path.join(webIconsDir, 'icon-512.png'));

  // social-banner.png - 1200x630 typical OG size; center the icon on a colored background
  const bannerW = 1200, bannerH = 630;
  const banner = new Jimp(bannerW, bannerH, '#0D47A1');
  const iconLarge = await image.clone().resize(440, 440);
  const x = Math.floor((bannerW - iconLarge.bitmap.width) / 2);
  const y = Math.floor((bannerH - iconLarge.bitmap.height) / 2) - 40;
  banner.composite(iconLarge, x, y);
  // add title text (simple) - Jimp fonts are limited, skip text for now
  await banner.writeAsync(path.join(webIconsDir, 'social-banner.png'));

  // favicon.ico - generate from 32 and 192 sized pngs
  const p32 = path.join(webIconsDir, 'icon-32.png');
  const p192 = path.join(webIconsDir, 'icon-192.png');
  const p512 = path.join(webIconsDir, 'icon-512.png');

  try {
    const icoBuffer = await pngToIco([p32, p192, p512]);
    fs.writeFileSync(path.join(__dirname, '..', 'apps', 'web', 'public', 'favicon.ico'), icoBuffer);
    console.log('favicon.ico generated');
  } catch (err) {
    console.warn('png-to-ico failed (optional):', err.message);
  }

  console.log('Generated icons in', webIconsDir);
}

generate().catch(err => { console.error(err); process.exit(1); });
