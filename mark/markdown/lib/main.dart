import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'swift_flutter Learning Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black87,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardColor: Colors.white,
        dividerColor: Colors.black12,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.white70,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardColor: Colors.black,
        dividerColor: Colors.white12,
      ),
      themeMode: ThemeMode.system,
      home: const LearningHomePage(),
    );
  }
}

class LearningHomePage extends StatefulWidget {
  const LearningHomePage({super.key});

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  final List<Chapter> chapters = [
    Chapter(
      title: 'Introduction',
      file: '00_introduction.md',
      icon: Icons.info_outline,
    ),
    Chapter(
      title: 'Getting Started',
      file: '01_getting_started.md',
      icon: Icons.play_arrow,
    ),
    Chapter(
      title: 'Core Concepts',
      file: '02_basic_concepts.md',
      icon: Icons.lightbulb_outline,
    ),
    Chapter(
      title: 'Reactive State',
      file: '03_reactive_state.md',
      icon: Icons.autorenew,
    ),
    Chapter(
      title: 'Computed Values',
      file: '04_computed_values.md',
      icon: Icons.calculate,
    ),
    Chapter(
      title: 'Controllers',
      file: '05_controllers.md',
      icon: Icons.settings,
    ),
    Chapter(
      title: 'Async State',
      file: '06_async_state.md',
      icon: Icons.cloud_download,
    ),
    Chapter(
      title: 'Form Validation',
      file: '07_form_validation.md',
      icon: Icons.verified,
    ),
    Chapter(
      title: 'Extensions',
      file: '08_extensions.md',
      icon: Icons.extension,
    ),
    Chapter(
      title: 'Advanced Patterns',
      file: '09_advanced_patterns.md',
      icon: Icons.architecture,
    ),
    Chapter(
      title: 'Best Practices',
      file: '10_best_practices.md',
      icon: Icons.star,
    ),
  ];

  int selectedChapterIndex = 0;
  String? markdownContent;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChapter(0);
  }

  Future<void> _loadChapter(int index) async {
    setState(() {
      isLoading = true;
      selectedChapterIndex = index;
    });

    try {
      final chapter = chapters[index];
      final content = await rootBundle.loadString(
        'assets/markdown/${chapter.file}',
      );
      setState(() {
        markdownContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        markdownContent = 'Error loading chapter: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isMobile) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        appBar: AppBar(
          title: const Text(
            'swift_flutter Learning',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showChapterDrawer(context),
            ),
          ],
        ),
        body: _buildContent(isDark),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: Row(
        children: [
          _buildSidebar(isDark),
          Container(
            width: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 320,
      color: isDark ? Colors.black : Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school,
                    color: isDark ? Colors.black : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'swift_flutter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Learning Guide',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chapters List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isSelected = index == selectedChapterIndex;
                
                return InkWell(
                  onTap: () => _loadChapter(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          chapter.icon,
                          size: 20,
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Progress Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${selectedChapterIndex + 1}/${chapters.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (selectedChapterIndex + 1) / chapters.length,
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.white : Colors.black,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.white : Colors.black,
        ),
      );
    }

    if (markdownContent == null) {
      return Center(
        child: Text(
          'No content loaded',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Navigation Bar
        if (selectedChapterIndex > 0 || selectedChapterIndex < chapters.length - 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedChapterIndex > 0)
                  _buildNavButton(
                    context,
                    isDark,
                    icon: Icons.arrow_back_ios,
                    label: chapters[selectedChapterIndex - 1].title,
                    onPressed: () => _loadChapter(selectedChapterIndex - 1),
                    isLeft: true,
                  )
                else
                  const SizedBox(width: 100),
                if (selectedChapterIndex < chapters.length - 1)
                  _buildNavButton(
                    context,
                    isDark,
                    icon: Icons.arrow_forward_ios,
                    label: chapters[selectedChapterIndex + 1].title,
                    onPressed: () => _loadChapter(selectedChapterIndex + 1),
                    isLeft: false,
                  )
                else
                  const SizedBox(width: 100),
              ],
            ),
          ),
        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: SingleChildScrollView(
              child: Markdown(
                data: markdownContent!,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -1,
                    height: 1.2,
                  ),
                  h1Padding: const EdgeInsets.only(bottom: 16, top: 8),
                  h2: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                    height: 1.3,
                  ),
                  h2Padding: const EdgeInsets.only(bottom: 12, top: 32),
                  h3: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -0.3,
                    height: 1.4,
                  ),
                  h3Padding: const EdgeInsets.only(bottom: 10, top: 24),
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
                    letterSpacing: 0.1,
                  ),
                  pPadding: const EdgeInsets.only(bottom: 16),
                  code: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  codeblockPadding: const EdgeInsets.all(16),
                  blockquote: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    border: Border(
                      left: BorderSide(
                        color: isDark ? Colors.white : Colors.black,
                        width: 4,
                      ),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.all(16),
                  listBullet: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  em: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
                  ),
                  a: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    decoration: TextDecoration.underline,
                    decorationColor: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                  ),
                ),
                selectable: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isLeft
              ? [
                  Icon(
                    icon,
                    size: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ]
              : [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ],
        ),
      ),
    );
  }

  void _showChapterDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.black : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text(
                  'Chapters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final isSelected = index == selectedChapterIndex;
                  
                  return InkWell(
                    onTap: () {
                      _loadChapter(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            chapter.icon,
                            size: 20,
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chapter {
  final String title;
  final String file;
  final IconData icon;

  Chapter({
    required this.title,
    required this.file,
    required this.icon,
  });
}
