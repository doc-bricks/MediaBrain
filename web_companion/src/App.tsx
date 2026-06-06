import {
  HashRouter,
  Navigate,
  NavLink,
  Outlet,
  Route,
  Routes,
} from 'react-router-dom'

import { ImportScreen } from './screens/ImportScreen'
import { LibraryScreen } from './screens/LibraryScreen'
import { ItemDetailScreen } from './screens/ItemDetailScreen'
import { PlaylistsScreen } from './screens/PlaylistsScreen'
import { SettingsScreen } from './screens/SettingsScreen'

export default function App() {
  return (
    <HashRouter>
      <Routes>
        <Route element={<AppShell />}>
          <Route index element={<Navigate to="/library" replace />} />
          <Route path="/library" element={<LibraryScreen />} />
          <Route path="/library/:id" element={<ItemDetailScreen />} />
          <Route path="/playlists" element={<PlaylistsScreen />} />
          <Route path="/import" element={<ImportScreen />} />
          <Route path="/einstellungen" element={<SettingsScreen />} />
          <Route path="*" element={<Navigate to="/library" replace />} />
        </Route>
      </Routes>
    </HashRouter>
  )
}

function AppShell() {
  return (
    <div className="flex flex-col min-h-screen bg-gray-50 text-gray-900">
      <main className="flex-1 pb-16">
        <Outlet />
      </main>
      <BottomNav />
    </div>
  )
}

function BottomNav() {
  const tabs = [
    { to: '/library', label: 'Bibliothek', icon: '📚' },
    { to: '/playlists', label: 'Playlists', icon: '🎶' },
    { to: '/import', label: 'Import', icon: '⬇️' },
    { to: '/einstellungen', label: 'Mehr', icon: '⚙️' },
  ]
  return (
    <nav className="fixed bottom-0 inset-x-0 bg-white border-t border-gray-200 flex">
      {tabs.map((t) => (
        <NavLink
          key={t.to}
          to={t.to}
          className={({ isActive }) =>
            'flex-1 flex flex-col items-center justify-center py-2 text-xs ' +
            (isActive ? 'text-blue-600 font-semibold' : 'text-gray-500')
          }
        >
          <span className="text-lg">{t.icon}</span>
          {t.label}
        </NavLink>
      ))}
    </nav>
  )
}
