# Birdle

Birdle is a simple five-letter word guessing game built with Flutter. Players enter guesses, and each letter is scored as a hit, partial match, or miss against the hidden word.

## Features

- Five-letter word guessing gameplay
- Color-coded tile feedback for each guess
- Basic game state and guess validation in Dart
- Cross-platform Flutter project structure

## Getting Started

1. Install the Flutter SDK if it is not already available.
2. Fetch dependencies:

	```bash
	flutter pub get
	```

3. Run the app:

	```bash
	flutter run
	```

## Project Layout

- [lib/main.dart](lib/main.dart) contains the app entry point and UI.
- [lib/game.dart](lib/game.dart) contains the core word-matching logic and game state.

## Notes

- The current word list is intentionally small and is defined in [lib/game.dart](lib/game.dart).
- The project is configured as a Flutter application and can be run on any platform supported by your local Flutter setup.
