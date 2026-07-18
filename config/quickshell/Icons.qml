pragma Singleton
import Quickshell
import QtQuick

// Shared app-icon resolution. Callers pass candidate identifiers (window class,
// desktop-entry id, app/icon name) and get back a themed icon path for an Image
// `source`; a miss yields "" (or the caller's fallback).
Singleton {
    id: root

    // Hits are memoized (resolution touches disk, callers re-resolve often).
    // Misses are NOT cached — desktop entries scan in async, so an early miss
    // may become a hit moments later.
    property var cache: new Map()

    // First themed path matching any candidate, else `fallback` as an icon name,
    // else "". `candidates` is a value or array; each is tried verbatim, then
    // normalized (lower-cased, spaces → dashes), then via a desktop-entry heuristic.
    function resolve(candidates, fallback): string {
        const list = Array.isArray(candidates) ? candidates : [candidates];
        const key = list.map(c => String(c ?? "")).join("\x1f")
                  + "\x1f\x1f" + String(fallback ?? "");
        const hit = cache.get(key);
        if (hit !== undefined)
            return hit;
        const path = lookup(list, fallback);
        if (path)
            cache.set(key, path);
        return path;
    }

    function lookup(list, fallback): string {
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
