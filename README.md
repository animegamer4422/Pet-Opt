# PetOpt

PetOpt is a modern Flutter application dedicated to pet adoption and building a community for pet lovers. It provides a platform to browse pets looking for a new home, share updates, and connect with other pet enthusiasts.

## Features

- **Pet Adoption:** Browse profiles of pets that need a home and initiate adoption requests.
- **Community Feed:** View and share posts, photos, and updates about pets.
- **User Profiles:** Manage your profile, view your posts, and track your adoption requests.
- **Authentication:** Secure login and user onboarding.

## Getting Started

This project is built with [Flutter](https://flutter.dev).

### Prerequisites

- Flutter SDK (>=3.10.8)
- Dart SDK
- Android Studio / Xcode for emulators and building.

### Running the App

1. Clone the repository and navigate to the project root.
2. Get the dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on your connected device or emulator:
   ```bash
   flutter run
   ```

## Project Structure

The app's source code is located in the `lib` directory, organized by features:
- `lib/features/auth/` - Authentication flow.
- `lib/features/feed/` - Social community feed.
- `lib/features/onboarding/` - User setup and onboarding.
- `lib/features/pet/` - Pet details and adoption flows.
- `lib/features/post/` - Creating and viewing posts.
- `lib/features/profile/` - User profile management.
- `lib/features/shell/` - Main application shell and navigation.

## Resources

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
