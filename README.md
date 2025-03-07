# QR Code Attendance System

A Flutter application for managing student attendance using QR codes, built with Supabase backend.

## Features

### Student Features
- Scan QR codes to mark attendance
- View attendance history by course
- Filter attendance by session type
- View course-wise attendance statistics
- Quick access dashboard

### Teacher Features
- Create and manage sessions
- Generate QR codes for attendance
- View real-time attendance
- Manage course schedules
- View student attendance reports

### Admin Features (Desktop Only)
- Manage departments and courses
- Handle user accounts
- Process absence justifications
- Generate reports

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.0)
- Dart SDK (^3.0.0)
- Supabase Account
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Setup Instructions

1. Clone the repository:
```bash
git clone https://your-repository-url.git
cd qr_code_attendnce_2
```

2. Create a .env file in the project root:
```bash
cp .env.example .env
```

3. Set up your Supabase project:
   - Create a new project at https://supabase.com
   - Copy your project URL and anon key
   - Update the .env file with your credentials:
```
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
```

4. Initialize the database:
   - Go to your Supabase project's SQL editor
   - Copy the contents of db/db.sql
   - Run the SQL script to create tables and relationships

5. Install dependencies:
```bash
flutter pub get
```

6. Run the app:
```bash
flutter run
```

## Development

### Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # Configuration
│   ├── models/             # Data models
│   ├── providers/          # State management
│   ├── services/           # Services
│   ├── theme/             # App theme
│   └── widgets/           # Shared widgets
│
├── feature-student/        # Student features
│   ├── layouts/           # Student layouts
│   ├── models/            # Student-specific models
│   ├── providers/         # Student state management
│   ├── screens/           # Student screens
│   └── widgets/          # Student-specific widgets
│
└── feature-teacher/       # Teacher features
    ├── layouts/          # Teacher layouts
    ├── models/           # Teacher-specific models
    ├── providers/        # Teacher state management
    ├── screens/          # Teacher screens
    └── widgets/         # Teacher-specific widgets
```

### Key Files

- `lib/main.dart`: App initialization and routing
- `lib/core/config/`: Configuration files
- `lib/core/providers/`: Core state management
- `lib/feature-*/screens/`: Feature-specific screens

### Running in Development Mode

1. Enable development features:
```bash
# In .env file
ENVIRONMENT=development
```

2. Run with development configuration:
```bash
flutter run --debug
```

3. Use the dev signup feature to create test accounts

### Testing

Run tests with:
```bash
flutter test
```

## Deployment

1. Update the .env file with production credentials
2. Build the release version:

For Android:
```bash
flutter build apk --release
```

For iOS:
```bash
flutter build ios --release
```

## Contributing

1. Create a new branch
2. Implement your changes
3. Write or update tests
4. Create a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- Flutter Team
- Supabase Team
- Contributors
