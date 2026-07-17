pragma Singleton
import Quickshell
import QtQuick

// Shared application-icon resolution for the bar. Callers pass one or more
// candidate identifiers — a window class, a desktop-entry id, an app or
// icon name — and get back a themed icon path usable directly as an Image
// `source`. Every lookup uses check=true so a miss yields "" (or the caller's
// fallback) instead of a broken image.
Singleton {
    id: root

    // The first themed icon path matching any candidate, else `fallback`
    // resolved as an icon name, else "". `candidates` may be a single value or
    // an array; empty/undefined entries are skipped. Each candidate is tried
    // verbatim, then normalized (lower-cased, spaces → dashes), then via a
    // desktop-entry heuristic on its name.
    function resolve(candidates, fallback): string {
        const list = Array.isArray(candidates) ? candidates : [candidates];
        for (const cand of list) {
            if (!cand) continue;
            const name = String(cand);

            let path = Quickshell.iconPath(name, true);
            if (path) return path;

            const normalized = name.toLowerCase().replace(/ /g, "-");
            if (normalized !== name) {
                path = Quickshell.iconPath(normalized, true);
                if (path) return path;
            }

            const entry = DesktopEntries.heuristicLookup(name);
            if (entry && entry.icon) {
                path = Quickshell.iconPath(entry.icon, true);
                if (path) return path;
            }
        }
        return fallback ? Quickshell.iconPath(fallback, true) : "";
    }
}
