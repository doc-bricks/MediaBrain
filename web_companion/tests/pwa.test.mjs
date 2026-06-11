import { readFileSync, existsSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { describe, expect, it } from 'vitest'

const __dir = dirname(fileURLToPath(import.meta.url))
const root = join(__dir, '..')

describe('PWA vite.config icons', () => {
  const cfg = readFileSync(join(root, 'vite.config.ts'), 'utf-8')

  it('vite.config defines icon-192.png', () => expect(cfg).toContain('icon-192.png'))
  it('vite.config defines icon-512.png', () => expect(cfg).toContain('icon-512.png'))
  it('vite.config defines icon-maskable-192.png', () =>
    expect(cfg).toContain('icon-maskable-192.png'))
  it('vite.config defines icon-maskable-512.png', () =>
    expect(cfg).toContain('icon-maskable-512.png'))
  it('vite.config has maskable purpose', () =>
    expect(cfg).toContain("purpose: 'maskable'"))
})

describe('PWA index.html integration', () => {
  const html = readFileSync(join(root, 'index.html'), 'utf-8')

  it('index.html has lang="de"', () => expect(html).toContain('lang="de"'))
  it('index.html has theme-color meta', () => expect(html).toContain('theme-color'))
  it('index.html enables viewport-fit=cover', () =>
    expect(html).toContain('viewport-fit=cover'))
  it('index.html has apple-touch-icon', () =>
    expect(html).toContain('apple-touch-icon'))
  it('index.html has apple-mobile-web-app-title', () =>
    expect(html).toContain('apple-mobile-web-app-title'))
  it('index.html has apple-mobile-web-app-status-bar-style', () =>
    expect(html).toContain('apple-mobile-web-app-status-bar-style'))
})

describe('PWA icon files', () => {
  const pub = join(root, 'public')

  it('icon-192.png exists in public/', () =>
    expect(existsSync(join(pub, 'icon-192.png'))).toBe(true))
  it('icon-512.png exists in public/', () =>
    expect(existsSync(join(pub, 'icon-512.png'))).toBe(true))
  it('apple-touch-icon.png exists in public/', () =>
    expect(existsSync(join(pub, 'apple-touch-icon.png'))).toBe(true))
  it('icon-maskable-192.png exists in public/', () =>
    expect(existsSync(join(pub, 'icon-maskable-192.png'))).toBe(true))
  it('icon-maskable-512.png exists in public/', () =>
    expect(existsSync(join(pub, 'icon-maskable-512.png'))).toBe(true))
})

describe('PWA safe-area layout', () => {
  const css = readFileSync(join(root, 'src', 'index.css'), 'utf-8')
  const app = readFileSync(join(root, 'src', 'App.tsx'), 'utf-8')

  it('index.css defines safe-area variables', () =>
    expect(css).toContain('--safe-area-top'))
  it('index.css keeps 44px touch targets', () =>
    expect(css).toContain('min-height: 44px'))
  it('App shell uses app-shell class', () =>
    expect(app).toContain('app-shell'))
  it('bottom nav uses app-bottom-nav class', () =>
    expect(app).toContain('app-bottom-nav'))
})
