# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/).

---

## [2.1.0] - 2026-03-27

### Fixed

- Path injection vulnerability in setup.sh when vault path contains special characters
- Silent failures in Swift link/symlink operations now log errors via NSLog
- LaunchAgent logs moved from world-readable `/tmp/` to `~/Library/Logs/`

### Added

- GitHub Actions CI: shellcheck linting, Swift compilation check, plist validation
- `.gitignore` for build artifacts and macOS metadata
- `CHANGELOG.md`
- `CONTRIBUTING.md`

---

## [2.0.0] - 2026-03-24

### Added

- Complete rewrite: two native macOS apps compiled from source
- **Open in Obsidian**: default handler for `.txt` and `.md` files, hard-links external files into vault
- **Obsidian File Watcher**: background service that detects broken hard links and re-creates them
- LaunchAgent for auto-start and auto-restart
- One-liner install via `curl -fsSL https://augent.app/obsidian.sh | bash`
- Vault auto-detection (scans ~/Desktop, ~/Documents, ~/)
- Cross-volume symlink fallback when hard links aren't possible
- Full uninstall script
- Test suite (test.sh)
- Security policy (SECURITY.md)

### Removed

- Legacy v1.x hook-based approach (pre-edit/post-edit shell hooks)
- Dependency on Claude Code hooks system

---

## [1.0.0] - 2026-02-15

### Added

- Initial release: shell hooks for Claude Code that sync Obsidian vault edits
- Pre-edit hook: opens file in Obsidian before Claude edits it
- Post-edit hook: refreshes Obsidian after Claude writes changes
