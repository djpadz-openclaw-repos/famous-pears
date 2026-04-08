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
cd FamousPearsIOS
xcodegen generate
```

This creates `FamousPearsIOS.xcodeproj` in the `FamousPearsIOS` directory.

### Generate tvOS Project

```bash
cd FamousPearsTVOS
xcodegen generate
```

This creates `FamousPearsTVOS.xcodeproj` in the `FamousPearsTVOS` directory.

### Generate Both Projects

```bash
./scripts/generate-projects.sh
```

Or manually:

```bash
cd FamousPearsIOS && xcodegen generate && cd ..
cd FamousPearsTVOS && xcodegen generate && cd ..
```

## Building

### Build iOS

```bash
cd FamousPearsIOS
xcodebuild -scheme FamousPearsIOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Build tvOS

```bash
cd FamousPearsTVOS
xcodebuild -scheme FamousPearsTVOS -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Opening in Xcode

After generating, open the projects in Xcode:

```bash
open FamousPearsIOS/FamousPearsIOS.xcodeproj
open FamousPearsTVOS/FamousPearsTVOS.xcodeproj
```

## Configuration

Each `project.yml` file defines:
- **name**: Project name
- **options**: Global settings (bundle ID prefix, deployment targets, formatting)
- **packages**: Swift Package dependencies (FamousPearsCore)
- **targets**: Build targets with sources, dependencies, settings, and schemes

## Customization

To customize the generated projects, edit the respective `project.yml` files:

- `FamousPearsIOS/project.yml` - iOS app configuration
- `FamousPearsTVOS/project.yml` - tvOS app configuration

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

1. Ensure you're in the correct directory (FamousPearsIOS or FamousPearsTVOS)
2. Check that `project.yml` is valid YAML
3. Verify FamousPearsCore package path is correct
4. Run `xcodegen generate --verbose` for detailed output

## CI/CD

For automated builds, add xcodegen generation to your CI pipeline:

```bash
xcodegen generate
xcodebuild -scheme FamousPearsIOS -destination 'platform=iOS Simulator,name=iPhone 15' build
```
