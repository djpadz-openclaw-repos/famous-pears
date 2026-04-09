# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Apple Developer credentials
- Anything environment-specific

## Apple Developer

- **Team ID**: N2XUW3D6G2
- **Bundle ID Prefix**: net.padz.famous-peers

Use this team ID in all xcodegen `project.yml` files:
```yaml
settings:
  DEVELOPMENT_TEAM: "N2XUW3D6G2"
```

Use this bundle ID prefix:
```yaml
options:
  bundleIdPrefix: net.padz.famous-peers
```

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
