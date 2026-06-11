export type PwaInstallPlatform = 'android' | 'ios' | 'desktop'

export function detectPwaInstallPlatform(userAgent: string): PwaInstallPlatform {
  const ua = userAgent.toLowerCase()
  if (ua.includes('android')) {
    return 'android'
  }
  if (
    ua.includes('iphone') ||
    ua.includes('ipad') ||
    ua.includes('ipod') ||
    (ua.includes('macintosh') && ua.includes('mobile'))
  ) {
    return 'ios'
  }
  return 'desktop'
}

export function isStandalonePwa(params: {
  matchMediaMatches?: boolean
  navigatorStandalone?: boolean
}): boolean {
  return Boolean(params.matchMediaMatches || params.navigatorStandalone)
}

export function getPwaInstallHint(
  platform: PwaInstallPlatform,
  standalone: boolean,
): string | null {
  if (standalone) {
    return null
  }
  if (platform === 'android') {
    return 'Für schnellen Zugriff im Browser-Menü „App installieren“ wählen. Der importierte Bibliotheksstand bleibt danach auch offline verfügbar.'
  }
  if (platform === 'ios') {
    return 'Für den Home-Bildschirm in Safari auf „Teilen“ und danach auf „Zum Home-Bildschirm“ tippen. So bleibt der lokale Import als PWA schnell erreichbar.'
  }
  return null
}
