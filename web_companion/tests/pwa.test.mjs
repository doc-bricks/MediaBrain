import { test, describe } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, existsSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dir = dirname(fileURLToPath(import.meta.url))
const root = join(__dir, '..')

describe('PWA vite.config icons', () => {
  const cfg = readFileSync(join(root, 'vite.config.ts'), 'utf-8')

  test('vite.config defines icon-192.png', () => assert.ok(cfg.includes('icon-192.png')))
  test('vite.config defines icon-512.png', () => assert.ok(cfg.includes('icon-512.png')))
  test('vite.config defines icon-maskable-192.png', () => assert.ok(cfg.includes('icon-maskable-192.png')))
  test('vite.config defines icon-maskable-512.png', () => assert.ok(cfg.includes('icon-maskable-512.png')))
  test('vite.config has maskable purpose', () => assert.ok(cfg.includes("purpose: 'maskable'")))
})

describe('PWA index.html integration', () => {
  const html = readFileSync(join(root, 'index.html'), 'utf-8')

  test('index.html has lang="de"', () => assert.ok(html.includes('lang="de"')))
  test('index.html has theme-color meta', () => assert.ok(html.includes('theme-color')))
  test('index.html has apple-touch-icon', () => assert.ok(html.includes('apple-touch-icon')))
})

describe('PWA icon files', () => {
  const pub = join(root, 'public')

  test('icon-192.png exists in public/', () => assert.ok(existsSync(join(pub, 'icon-192.png'))))
  test('icon-512.png exists in public/', () => assert.ok(existsSync(join(pub, 'icon-512.png'))))
  test('apple-touch-icon.png exists in public/', () => assert.ok(existsSync(join(pub, 'apple-touch-icon.png'))))
  test('icon-maskable-192.png exists in public/', () => assert.ok(existsSync(join(pub, 'icon-maskable-192.png'))))
  test('icon-maskable-512.png exists in public/', () => assert.ok(existsSync(join(pub, 'icon-maskable-512.png'))))
})
