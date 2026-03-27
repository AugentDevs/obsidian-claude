# Contributing to augent-obsidian

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/augent-obsidian.git
   cd augent-obsidian
   ```
3. Ensure you have the prerequisites:
   - macOS with Xcode Command Line Tools (`xcode-select --install`)
   - [Obsidian](https://obsidian.md) with at least one vault
   - Homebrew (`brew install duti`)

## Development

### Building from source

The setup script compiles two Swift binaries. To build manually:

```bash
# Compile Open in Obsidian (replace with your vault path)
sed 's|VAULT_PATH_HERE|/path/to/your/vault|g' src/OpenInObsidian.swift > /tmp/OpenInObsidian.swift
swiftc -O -o /tmp/open-in-obsidian /tmp/OpenInObsidian.swift -framework Cocoa

# Compile File Watcher
sed 's|VAULT_PATH_HERE|/path/to/your/vault|g' src/ObsidianFileWatcher.swift > /tmp/ObsidianFileWatcher.swift
swiftc -O -o /tmp/obsidian-file-watcher /tmp/ObsidianFileWatcher.swift -framework Cocoa
```

### Running tests

```bash
bash test.sh
```

Tests verify app installation, file handlers, LaunchAgent, process auto-restart, and live file edits.

### Code style

- Shell scripts: follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html). CI runs `shellcheck` on all `.sh` files.
- Swift: standard Swift conventions. Keep it simple and auditable.

### Project structure

```
src/
├── OpenInObsidian.swift       # Default file handler for .txt and .md
├── ObsidianFileWatcher.swift  # Background hard-link repair service
├── open-in-obsidian.plist     # App bundle Info.plist
├── file-watcher.plist         # App bundle Info.plist
└── hooks/                     # Legacy v1.x hooks (deprecated)
setup.sh                       # One-command installer
uninstall.sh                   # Clean removal
test.sh                        # Post-install verification
```

## Submitting Changes

1. Create a branch from `main`
2. Make your changes
3. Run `bash test.sh` locally
4. Run `shellcheck setup.sh uninstall.sh test.sh`
5. Push and open a pull request

### Pull requests

- Keep PRs focused, one fix or feature per PR
- Ensure CI passes before requesting review
- Test on your own Mac with a real Obsidian vault

## Reporting Bugs

Use the [bug report template](https://github.com/AugentDevs/augent-obsidian/issues/new?template=bug_report.md).

## Security

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities.
