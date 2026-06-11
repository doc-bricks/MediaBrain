import { useEffect, useState } from 'react'

import {
  detectPwaInstallPlatform,
  getPwaInstallHint,
  isStandalonePwa,
} from '../platform/pwa'

type NavigatorWithStandalone = Navigator & { standalone?: boolean }

export function PwaInstallHint() {
  const [hint, setHint] = useState<string | null>(null)

  useEffect(() => {
    if (typeof window === 'undefined' || typeof navigator === 'undefined') {
      return
    }

    const mediaQuery = window.matchMedia('(display-mode: standalone)')

    const updateHint = () => {
      const platform = detectPwaInstallPlatform(navigator.userAgent)
      const standalone = isStandalonePwa({
        matchMediaMatches: mediaQuery.matches,
        navigatorStandalone: Boolean(
          (navigator as NavigatorWithStandalone).standalone,
        ),
      })
      setHint(getPwaInstallHint(platform, standalone))
    }

    updateHint()

    const handleMediaChange = () => updateHint()
    const handleInstalled = () => updateHint()

    if (typeof mediaQuery.addEventListener === 'function') {
      mediaQuery.addEventListener('change', handleMediaChange)
    } else {
      mediaQuery.addListener(handleMediaChange)
    }
    window.addEventListener('appinstalled', handleInstalled)

    return () => {
      if (typeof mediaQuery.removeEventListener === 'function') {
        mediaQuery.removeEventListener('change', handleMediaChange)
      } else {
        mediaQuery.removeListener(handleMediaChange)
      }
      window.removeEventListener('appinstalled', handleInstalled)
    }
  }, [])

  if (!hint) {
    return null
  }

  return (
    <div className="mx-4 mt-4 rounded-xl border border-blue-200 bg-blue-50 px-4 py-3 text-sm text-blue-900 shadow-sm">
      <div className="font-semibold">Mobile Nutzung</div>
      <p className="mt-1">{hint}</p>
    </div>
  )
}
