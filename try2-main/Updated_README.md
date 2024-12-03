
# RFID-Based Home Security System with Multi-Factor Authentication

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Usage](#usage)
- [Code Structure](#code-structure)
- [Additional Directories and Files](#additional-directories-and-files)
- [API and Database Usage](#api-and-database-usage)
- [Contributing](#contributing)
- [License](#license)
- [FAQ](#faq)

---

## Overview

This application implements an RFID-based home security system with multi-factor authentication. It incorporates RFID access control with an additional fingerprint sensor and a mobile app interface for enhanced security.

## Features
- RFID-based authentication for physical access.
- Multi-factor authentication with fingerprint sensors.
- Temporary passkey generation.
- Entry logs for authorized and unauthorized access attempts.
- Firebase backend integration for storing user and access data.
- Simple and intuitive mobile app interface.

---

## Technologies Used
- **Programming Language:** Dart (Flutter Framework)
- **Database:** Firebase Firestore
- **Cloud Services:** Firebase Authentication and Firestore
- **Mobile Framework:** Flutter
- **Others:** SharedPreferences for local storage

---

## Installation

### Prerequisites
- Install Flutter SDK ([Flutter installation guide](https://flutter.dev/docs/get-started/install)).
- Set up a Firebase project and configure the application with `google-services.json`.

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo-link.git
   ```
2. Navigate to the project directory:
   ```bash
   cd rfid-home-security
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application on an emulator or a physical device:
   ```bash
   flutter run
   ```

---

## Usage

### Generating Temporary Passkeys
- Access the "Generate Temp Passkey" feature on the home screen.
- Enter a 4-digit passcode, which will be saved to the database and used for temporary access.

### Viewing Logs
- Navigate to "View Logs" to see entry records. Logs include details of authorized and unauthorized access attempts with timestamps.

### Login and Signup
- New users can register via the signup screen, while existing users can log in using their credentials.

---

## Code Structure
```
rfid-home-security/
├── assets/                 # Contains app assets like images and icons
├── lib/
│   ├── main.dart           # Entry point of the application
│   ├── firebase_options.dart # Firebase configuration
│   ├── login.dart          # Login screen
│   ├── signup.dart         # Signup screen
│   ├── home.dart           # Main dashboard
│   ├── logs.dart           # Logs view
│   ├── temppasskey.dart    # Temporary passkey management
│   └── test.dart           # Example/test code
├── pubspec.yaml            # Dependencies and project configuration
└── README.md               # Project documentation
```

---

## Additional Directories and Files

- **`android/`**: Contains Android-specific configurations and files required to run the Flutter application on Android devices.
- **`build/`**: Auto-generated directory where the app build files are stored during the compilation process.
- **`dataconnect/` and `dataconnect-generated/`**: May be related to generated data classes or connections used for backend or service integrations.
- **`ios/`**: Contains iOS-specific configurations and files required to run the Flutter application on iOS devices.
- **`linux/`**: Linux-specific configuration for running the application on Linux platforms.
- **`macos/`**: MacOS-specific configuration for running the application on macOS platforms.
- **`test/`**: Contains test files for the Flutter application, used to implement and run unit or integration tests.
- **`web/`**: Configuration and files for running the application on the web.
- **`windows/`**: Contains Windows-specific configurations for running the application on Windows platforms.
- **`analysis_options.yaml`**: Defines code analysis rules for the project, ensuring consistent coding standards.

---

## API and Database Usage

### Firebase Firestore
- **User Data Collection**:
  - Stores user details such as email, password hash, and unique identifiers.
- **Access Logs Collection**:
  - Logs each access attempt with fields:
    - `succAuth`: Boolean indicating success or failure.
    - `timestamp`: Timestamp of the access attempt.

### SharedPreferences
- Stores session-related data locally for user authentication and app state management.

---

## Contributing

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature description"
   ```
4. Push to your branch:
   ```bash
   git push origin feature-name
   ```
5. Submit a pull request.

---

## License
This project is licensed under the MIT License. See `LICENSE` for details.

---

## FAQ

**Q:** How do I reset my password?  
**A:** Password reset functionality can be implemented using Firebase Authentication's password reset feature.

**Q:** How is data secured?  
**A:** Data is securely stored in Firebase Firestore and encrypted during transmission with SSL.

**Q:** Can I use this system for commercial purposes?  
**A:** Yes, provided you adhere to the terms of the MIT License.

---
