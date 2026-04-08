# Generating Xcode Projects with xcodegen

This project uses [xcodegen](https://github.com/yonaskolb/XcodeGen) to generate `.xcodeproj` files from `project.yml` configuration files.

## Installation

Install xcodegen via Homebrew:

```bash
brew install xcodegen
```

Or via CocoaPods:

```bash
sudo gem install cocoapods
pod repo update
```

## Generating Projects

### Generate iOS Project

```bash
cd FamousPeersIOS
xcodegen generate
```

This creates `FamousPeersIOS.xcodeproj` in the `FamousPeersIOS` directory.

### Generate tvOS Project

```bash
cd FamousPeersTVOS
xcodegen generate
```

This creates `FamousPeersTVOS.xcodeproj` in the `FamousPeersTVOS` directory.

### Generate Both Projects

```bash
./scripts/generate-projects.sh
```

Or manually:

```bash
cd FamousPeersIOS && xcodegen generate && cd ..
cd FamousPeersTVOS && xcodegen generate && cd ..
```

## Building

### Build iOS

```bash
cd FamousPeersIOS
xcodebuild -scheme FamousPeersIOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Build tvOS

```bash
cd FamousPeersTVOS
xcodebuild -scheme FamousPeersTVOS -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Opening in Xcode

After generating, open the projects in Xcode:

```bash
open FamousPeersIOS/FamousPeersIOS.xcodeproj
open FamousPeersTVOS/FamousPeersTVOS.xcodeproj
```

## Configuration

Each `project.yml` file defines:
- **name**: Project name
- **options**: Global settings (bundle ID prefix, deployment targets, formatting)
- **packages**: Swift Package dependencies (FamousPeersCore)
- **targets**: Build targets with sources, dependencies, settings, and schemes

## Customization

To customize the generated projects, edit the respective `project.yml` files:

- `FamousPeersIOS/project.yml` - iOS app configuration
- `FamousPeersTVOS/project.yml` - tvOS app configuration

After editing, regenerate the projects:

```bash
xcodegen generate
```

## Notes

- The `DEVELOPMENT_TEAM` is left empty. Set it to your Apple Team ID if you plan to build for device or submit to App Store.
- `CODE_SIGN_STYLE` is set to `Automatic`. Change to `Manual` if you prefer manual code signing.
- Deployment targets are set to iOS 16.0 and tvOS 16.0. Adjust in `project.yml` if needed.

## Troubleshooting

If xcodegen fails:

1. Ensure you're in the correct directory (FamousPeersIOS or FamousPeersTVOS)
2. Check that `project.yml` is valid YAML
3. Verify FamousPeersCore package path is correct
4. Run `xcodegen generate --verbose` for detailed output

## CI/CD

For automated builds, add xcodegen generation to your CI pipeline:

```bash
xcodegen generate
xcodebuild -scheme FamousPeersIOS -destination 'platform=iOS Simulator,name=iPhone 15' build
```
