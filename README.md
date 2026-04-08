# Famous Pears

A multiplayer iOS/tvOS game where players guess famous duos based on one member's name.

## Architecture

- **FamousPearsCore**: Shared Swift Package with game logic, card database, and validation
- **FamousPearsIOS**: iOS app for players (iPhone/iPad)
- **FamousPearsTVOS**: tvOS app for Apple TV (game host)

## Build Order

1. Shared framework + card database
2. iOS-to-iOS multiplayer (GameKit)
3. tvOS + controller support

## Project Structure

```
famous-pears/
├── FamousPearsCore/          # Shared Swift Package
│   ├── Sources/
│   │   └── FamousPearsCore/
│   │       ├── Models/
│   │       ├── GameLogic/
│   │       ├── Validation/
│   │       └── Resources/
│   └── Package.swift
├── FamousPearsIOS/           # iOS app
├── FamousPearsTVOS/          # tvOS app
└── README.md
```
