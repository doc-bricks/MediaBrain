import { describe, expect, it } from 'vitest'

import {
  detectPwaInstallPlatform,
  getPwaInstallHint,
  isStandalonePwa,
} from './pwa'

describe('detectPwaInstallPlatform', () => {
  it('recognizes Android user agents', () => {
    expect(
      detectPwaInstallPlatform(
        'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 Chrome/124.0 Mobile Safari/537.36',
      ),
    ).toBe('android')
  })

  it('recognizes iPhone and iPad user agents', () => {
    expect(
      detectPwaInstallPlatform(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1',
      ),
    ).toBe('ios')
    expect(
      detectPwaInstallPlatform(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1',
      ),
    ).toBe('ios')
  })

  it('falls back to desktop for other user agents', () => {
    expect(
      detectPwaInstallPlatform(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0 Safari/537.36',
      ),
    ).toBe('desktop')
  })
})

describe('isStandalonePwa', () => {
  it('returns true if either standalone signal is active', () => {
    expect(isStandalonePwa({ matchMediaMatches: true })).toBe(true)
    expect(isStandalonePwa({ navigatorStandalone: true })).toBe(true)
  })

  it('returns false without standalone signals', () => {
    expect(isStandalonePwa({})).toBe(false)
  })
})

describe('getPwaInstallHint', () => {
  it('returns platform-specific guidance until the app is installed', () => {
    expect(getPwaInstallHint('android', false)).toContain('App installieren')
    expect(getPwaInstallHint('ios', false)).toContain(
      'Zum Home-Bildschirm',
    )
    expect(getPwaInstallHint('desktop', false)).toBeNull()
  })

  it('hides the hint for standalone installs', () => {
    expect(getPwaInstallHint('android', true)).toBeNull()
    expect(getPwaInstallHint('ios', true)).toBeNull()
  })
})
