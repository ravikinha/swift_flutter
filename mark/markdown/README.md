# swift_flutter Learning Guide

An interactive web application for learning swift_flutter - a reactive state management library for Flutter.

## Overview

This is a comprehensive, step-by-step learning guide that takes you from zero to hero with swift_flutter. The guide is presented as an interactive web application where you can navigate through different chapters and learn at your own pace.

## Features

- 📚 **11 Comprehensive Chapters** - From introduction to best practices
- 🎨 **Beautiful UI** - Modern, responsive design with dark mode support
- 📱 **Mobile Friendly** - Works on desktop, tablet, and mobile devices
- 🔍 **Searchable Content** - All content is selectable and searchable
- 📖 **Markdown Based** - Easy to update and maintain
- 🎯 **Progressive Learning** - Structured learning path with clear progression

## Chapters

1. **Introduction** - Why choose swift_flutter?
2. **Getting Started** - Installation and setup
3. **Core Concepts** - Understanding the fundamentals
4. **Reactive State** - Working with SwiftValue
5. **Computed Values** - Derived state management
6. **Controllers** - The controller pattern
7. **Async State** - Handling asynchronous operations
8. **Form Validation** - Building forms with validation
9. **Extensions** - Using Swift-like extensions
10. **Advanced Patterns** - Complex scenarios
11. **Best Practices** - Production-ready code

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Navigate to the project directory:
```bash
cd mark/markdown
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the web app:
```bash
flutter run -d chrome
```

Or build for web:
```bash
flutter build web
```

## Project Structure

```
markdown/
├── lib/
│   └── main.dart          # Main application
├── assets/
│   └── markdown/          # Learning guide markdown files
│       ├── 00_introduction.md
│       ├── 01_getting_started.md
│       ├── ...
│       └── 10_best_practices.md
├── pubspec.yaml          # Dependencies and assets
└── README.md            # This file
```

## Features in Detail

### Navigation

- **Sidebar Navigation** (Desktop) - Easy access to all chapters
- **Bottom Sheet** (Mobile) - Chapter selection on mobile devices
- **Previous/Next Buttons** - Navigate between chapters
- **Progress Indicator** - Track your learning progress

### Content Display

- **Markdown Rendering** - Beautiful rendering of markdown content
- **Code Highlighting** - Syntax highlighting for code blocks
- **Selectable Text** - Copy code and text easily
- **Responsive Layout** - Adapts to different screen sizes

### Theme

- **Light/Dark Mode** - Automatic theme switching based on system preference
- **Material Design 3** - Modern Material Design components

## Customization

### Adding New Chapters

1. Create a new markdown file in `assets/markdown/`
2. Add the chapter to the `chapters` list in `lib/main.dart`:

```dart
Chapter(
  title: 'Your Chapter Title',
  file: 'your_file.md',
  icon: Icons.your_icon,
),
```

### Updating Content

Simply edit the markdown files in `assets/markdown/` and the changes will be reflected when you reload the app.

## Building for Production

### Web Build

```bash
flutter build web
```

The output will be in `build/web/`. You can deploy this to any static hosting service like:
- GitHub Pages
- Firebase Hosting
- Netlify
- Vercel

### Custom Domain

After building, you can deploy to your custom domain. The app is a single-page application and works with client-side routing.

## Technologies Used

- **Flutter** - UI framework
- **flutter_markdown** - Markdown rendering
- **Material Design 3** - UI components

## Contributing

To contribute to the learning guide:

1. Edit the markdown files in `assets/markdown/`
2. Test your changes locally
3. Submit a pull request

## License

This learning guide is part of the swift_flutter project and follows the same license.

## Support

For issues or questions about swift_flutter, visit:
- [GitHub Repository](https://github.com/ravikinha/swift_flutter)
- [Pub.dev Package](https://pub.dev/packages/swift_flutter)

---

**Happy Learning!** 🚀
