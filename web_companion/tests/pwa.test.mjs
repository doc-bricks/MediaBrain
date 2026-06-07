import { describe, it, expect } from 'vitest'
import { readFileSync, existsSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))
const distDir = join(__dir, '..', 'dist')

describe('PWA dist/ checks', () => {
  it('dist/ directory exists (build required before tests)', () => {
    expect(existsSync(distDir)).toBe(true)
  })

  it('manifest.webmanifest exists in dist/', () => {
    expect(existsSync(join(distDir, 'manifest.webmanifest'))).toBe(true)
  })

  it('manifest.webmanifest has required fields', () => {
    const manifest = JSON.parse(readFileSync(join(distDir, 'manifest.webmanifest'), 'utf-8'))
    expect(manifest.name).toBeTruthy()
    expect(manifest.short_name).toBeTruthy()
    expect(manifest.start_url).toBeTruthy()
    expect(manifest.display).toBeTruthy()
    expect(manifest.id).toBeTruthy()
  })

  it('manifest has at least 2 icons including 192x192 and 512x512', () => {
    const manifest = JSON.parse(readFileSync(join(distDir, 'manifest.webmanifest'), 'utf-8'))
    expect(Array.isArray(manifest.icons)).toBe(true)
    expect(manifest.icons.length).toBeGreaterThanOrEqual(2)
    expect(manifest.icons.some((i) => i.sizes?.includes('192x192'))).toBe(true)
    expect(manifest.icons.some((i) => i.sizes?.includes('512x512'))).toBe(true)
  })

  it('all declared icon files exist in dist/', () => {
    const manifest = JSON.parse(readFileSync(join(distDir, 'manifest.webmanifest'), 'utf-8'))
    for (const icon of manifest.icons) {
      const iconPath = join(distDir, icon.src.replace(/^\//, ''))
      expect(existsSync(iconPath), `Icon fehlt in dist/: ${icon.src}`).toBe(true)
    }
  })

  it('sw.js exists in dist/', () => {
    expect(existsSync(join(distDir, 'sw.js'))).toBe(true)
  })

  it('index.html references manifest', () => {
    const html = readFileSync(join(distDir, 'index.html'), 'utf-8')
    expect(html).toContain('manifest')
  })
})
