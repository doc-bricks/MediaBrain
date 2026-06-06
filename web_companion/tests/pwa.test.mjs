import { readFileSync, existsSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import assert from 'node:assert/strict'

const __dir = dirname(fileURLToPath(import.meta.url))
const distDir = join(__dir, '..', 'dist')

// Read manifest
const manifestPath = join(distDir, 'manifest.webmanifest')
assert.ok(existsSync(manifestPath), 'manifest.webmanifest fehlt in dist/')
const manifest = JSON.parse(readFileSync(manifestPath, 'utf-8'))

// Required manifest fields
assert.ok(manifest.name, 'manifest.name fehlt')
assert.ok(manifest.short_name, 'manifest.short_name fehlt')
assert.ok(manifest.start_url, 'manifest.start_url fehlt')
assert.ok(manifest.display, 'manifest.display fehlt')
assert.ok(manifest.id, 'manifest.id fehlt')

// Icons not empty
assert.ok(Array.isArray(manifest.icons), 'manifest.icons ist kein Array')
assert.ok(manifest.icons.length >= 2, `manifest.icons hat ${manifest.icons.length} Einträge, mindestens 2 erwartet`)

// At least one 192x192 and one 512x512 icon
const has192 = manifest.icons.some(i => i.sizes?.includes('192x192'))
const has512 = manifest.icons.some(i => i.sizes?.includes('512x512'))
assert.ok(has192, 'Kein 192x192 Icon in manifest.icons')
assert.ok(has512, 'Kein 512x512 Icon in manifest.icons')

// Each icon file actually exists in dist/
for (const icon of manifest.icons) {
  const iconPath = join(distDir, icon.src.replace(/^\//, ''))
  assert.ok(existsSync(iconPath), `Icon-Datei fehlt in dist/: ${icon.src}`)
}

// sw.js exists
assert.ok(existsSync(join(distDir, 'sw.js')), 'sw.js fehlt in dist/')

// index.html has pwa meta
const html = readFileSync(join(distDir, 'index.html'), 'utf-8')
assert.ok(html.includes('manifest'), 'index.html verlinkt kein Manifest')

console.log('PWA-Tests: alle OK')
