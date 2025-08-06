# DailyFlow

An AI-powered productivity app designed to help users organize their lives by integrating work schedules, personal tasks, life goals, and health optimization.

## Features

### Core Features (Free Tier)
- **Task Management**: Create, organize, and track tasks with priorities and categories
- **Habit Tracking**: Build and maintain habits with streak tracking and progress visualization
- **AI Insights**: Smart recommendations and insights based on your productivity patterns
- **Modern UI**: Clean, intuitive design with dark/light theme support
- **Local Storage**: All data stored locally on your device for privacy

### Premium Features (Coming Soon)
- **AI Habit Coaching**: Personalized habit formation guidance
- **Advanced Analytics**: Detailed insights and progress reports
- **Sleep Optimization**: AI-powered sleep recommendations
- **Custom Themes**: Full theme customization
- **Third-party Integrations**: Calendar, fitness tracker, and health platform sync

## Architecture

### Tech Stack
- **Framework**: Flutter 3.x
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **UI**: Material Design 3 with custom theming
- **Fonts**: Google Fonts (Inter)

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart            # Task model with AI prioritization
│   └── habit.dart           # Habit model with streak tracking
├── providers/               # State management
│   ├── theme_provider.dart  # Theme switching
│   ├── task_provider.dart   # Task management
│   └── habit_provider.dart  # Habit management
├── screens/                 # UI screens
│   ├── home_screen.dart     # Dashboard with AI insights
│   ├── tasks_screen.dart    # Task management
│   ├── habits_screen.dart   # Habit tracking
│   ├── goals_screen.dart    # Goal tracking (placeholder)
│   └── settings_screen.dart # App settings and premium features
├── widgets/                 # Reusable UI components
│   ├── stats_card.dart      # Statistics display
│   ├── task_list_item.dart  # Task list item
│   ├── habit_list_item.dart # Habit list item
│   └── ai_insight_card.dart # AI-powered insights
└── utils/                   # Utilities
    └── theme.dart           # App theming system
```

## Getting Started

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd DailyFlow
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

For Android:
```bash
flutter build apk --release
```

For iOS:
```bash
flutter build ios --release
```

For Web:
```bash
flutter build web --release
```

## Features in Detail

### Task Management
- Create tasks with titles, descriptions, and due dates
- Set priorities (Low, Medium, High) with color coding
- Categorize tasks (Work, Personal, Health, Learning, Other)
- AI-powered task prioritization
- Filter tasks by status, priority, and date

### Habit Tracking
- Create habits with custom frequencies (daily, weekly, custom days)
- Track completion streaks and longest streaks
- Visual progress indicators for multi-count habits
- Category-based organization (Health, Productivity, Learning, etc.)
- Motivation messages and AI insights

### AI Insights
- Smart recommendations based on your patterns
- Progress tracking and completion rates
- Personalized motivation messages
- Task and habit prioritization

### Theme System
- Light and dark mode support
- System theme detection
- Modern Material Design 3 implementation
- Custom color schemes and gradients

## Roadmap

### Phase 1 (Current) ✅
- [x] Core task management
- [x] Basic habit tracking
- [x] AI insights and recommendations
- [x] Modern UI with theme support
- [x] Local data storage

### Phase 2 (Next)
- [ ] Goal tracking and progress visualization
- [ ] Advanced AI features
- [ ] Third-party integrations
- [ ] Premium subscription system

### Phase 3 (Future)
- [ ] Sleep optimization features
- [ ] Advanced analytics dashboard
- [ ] Team collaboration features
- [ ] Community features

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@dailyflow.app or create an issue in this repository.

---

**DailyFlow** - Organize your life, one day at a time. 🚀
