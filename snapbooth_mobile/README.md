# SnapBooth Mobile

SnapBooth is a modern photobooth application built with Flutter. It allows users to capture moments in a classic photostrip format, with customizable templates and easy sharing options.

## Features

- **Tutorial & Template Selection**: A user-friendly onboarding experience and multiple photostrip layouts (3-strip, 4-strip).
- **Automated Capture Session**: Real-time camera preview with a countdown timer and automatic photo capturing.
- **Customizable Camera Settings**: Delay timer, mirror mode, and camera source switching.
- **Photostrip Generation**: High-quality photostrips generated using Canvas processing.
- **Save & Share**: Quickly download your photostrip to the gallery or share it with friends.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Camera**: `camera` package
- **Image Processing**: `dart:ui` (Canvas)
- **Permissions**: `permission_handler`
- **Sharing**: `share_plus`

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/snapbooth-mobile.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## Project Structure

- `lib/models/`: Data models for templates.
- `lib/providers/`: State management using Provider.
- `lib/screens/`: UI screens (Home, Photobooth, Result).
- `lib/services/`: Core logic for image generation.
