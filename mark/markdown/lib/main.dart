import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatefulWidget {
  const LearningApp({super.key});

  @override
  State<LearningApp> createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'swift_flutter Learning Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2196F3),
          secondary: Color(0xFF1976D2),
          surface: Colors.white,
          background: Color(0xFFF5F5F5),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFF29B6F6),
          surface: Color(0xFF2B2B2B),
          background: Color(0xFF1E1E1E),
        ),
      ),
      themeMode: _themeMode,
      home: LearningHomePage(onThemeToggle: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class LearningHomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  
  const LearningHomePage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  final List<Chapter> chapters = [
    Chapter(title: 'Introduction', file: '00_introduction.md', icon: Icons.info_outline),
    Chapter(title: 'Getting Started', file: '01_getting_started.md', icon: Icons.play_arrow),
    Chapter(title: 'Core Concepts', file: '02_basic_concepts.md', icon: Icons.lightbulb_outline),
    Chapter(title: 'Reactive State', file: '03_reactive_state.md', icon: Icons.autorenew),
    Chapter(title: 'Computed Values', file: '04_computed_values.md', icon: Icons.calculate),
    Chapter(title: 'Controllers', file: '05_controllers.md', icon: Icons.settings),
    Chapter(title: 'Async State', file: '06_async_state.md', icon: Icons.cloud_download),
    Chapter(title: 'Form Validation', file: '07_form_validation.md', icon: Icons.verified),
    Chapter(title: 'Extensions', file: '08_extensions.md', icon: Icons.extension),
    Chapter(title: 'Advanced Patterns', file: '09_advanced_patterns.md', icon: Icons.architecture),
    Chapter(title: 'Best Practices', file: '10_best_practices.md', icon: Icons.star),
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
    if (index == selectedChapterIndex && markdownContent != null) return;
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      selectedChapterIndex = index;
    });

    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    try {
      final chapter = chapters[index];
      final content = await rootBundle.loadString('assets/markdown/${chapter.file}');
      
      if (mounted) {
        setState(() {
          markdownContent = content;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          markdownContent = 'Error loading chapter: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isMobile) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(isDark),
        body: _buildContent(isDark),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          _buildSidebar(isDark),
          Container(width: 1, color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0)),
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF2B2B2B) : Colors.white,
      elevation: 0,
      title: Text(
        'swift_flutter Learning',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            widget.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: widget.onThemeToggle,
        ),
        IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () => _showChapterDrawer(context),
        ),
      ],
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 300,
      color: isDark ? const Color(0xFF2B2B2B) : Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'swift_flutter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Learning Guide',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              ],
            ),
          ),
          // Chapters
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isSelected = index == selectedChapterIndex;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _loadChapter(index),
                    child: Container(
                      key: ValueKey('chapter_$index'),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF0D47A1).withOpacity(0.3) : const Color(0xFFE3F2FD))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(color: isDark ? const Color(0xFF2196F3) : const Color(0xFF2196F3), width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2196F3)
                                  : (isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            chapter.icon,
                            size: 18,
                            color: isSelected
                                ? const Color(0xFF2196F3)
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Text(
                      '${selectedChapterIndex + 1}/${chapters.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (selectedChapterIndex + 1) / chapters.length,
                    backgroundColor: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
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
        child: CircularProgressIndicator(color: const Color(0xFF2196F3)),
      );
    }

    if (markdownContent == null) {
      return Center(
        child: Text(
          'No content loaded',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
      );
    }

    return Column(
      children: [
        // Navigation
        if (selectedChapterIndex > 0 || selectedChapterIndex < chapters.length - 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B2B2B) : Colors.white,
              border: Border(
                bottom: BorderSide(color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedChapterIndex > 0)
                  _buildNavButton(isDark, Icons.arrow_back, chapters[selectedChapterIndex - 1].title, () => _loadChapter(selectedChapterIndex - 1), true)
                else
                  const SizedBox(width: 100),
                if (selectedChapterIndex < chapters.length - 1)
                  _buildNavButton(isDark, Icons.arrow_forward, chapters[selectedChapterIndex + 1].title, () => _loadChapter(selectedChapterIndex + 1), false)
                else
                  const SizedBox(width: 100),
              ],
            ),
          ),
        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Markdown(
              data: markdownContent!,
              styleSheet: MarkdownStyleSheet(
                h1: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.3,
                ),
                h1Padding: const EdgeInsets.only(bottom: 16, top: 8),
                h2: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
                h2Padding: const EdgeInsets.only(bottom: 12, top: 24),
                h3: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
                h3Padding: const EdgeInsets.only(bottom: 10, top: 20),
                p: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                ),
                pPadding: const EdgeInsets.only(bottom: 12),
                code: TextStyle(
                  fontSize: 13,
                  fontFamily: 'JetBrains Mono, Consolas, monospace',
                  backgroundColor: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5),
                  color: isDark ? const Color(0xFFCC7832) : const Color(0xFFD32F2F),
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0),
                  ),
                ),
                codeblockPadding: const EdgeInsets.all(16),
                blockquote: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF616161),
                ),
                blockquoteDecoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5),
                  border: Border(
                    left: BorderSide(color: const Color(0xFF2196F3), width: 3),
                  ),
                ),
                blockquotePadding: const EdgeInsets.all(12),
                listBullet: TextStyle(color: const Color(0xFF2196F3)),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                ),
                a: const TextStyle(
                  color: Color(0xFF2196F3),
                  decoration: TextDecoration.underline,
                ),
              ),
              selectable: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(bool isDark, IconData icon, String label, VoidCallback onPressed, bool isLeft) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    Icon(icon, size: 16, color: const Color(0xFF2196F3)),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ]
                : [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, size: 16, color: const Color(0xFF2196F3)),
                  ],
          ),
        ),
      ),
    );
  }

  void _showChapterDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2B2B2B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text(
                  'Chapters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
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
                  
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _loadChapter(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        key: ValueKey('drawer_chapter_$index'),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF0D47A1).withOpacity(0.3) : const Color(0xFFE3F2FD))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2196F3) : (isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              chapter.icon,
                              size: 20,
                              color: isSelected ? const Color(0xFF2196F3) : (isDark ? Colors.white60 : Colors.black54),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                chapter.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Chapter({required this.title, required this.file, required this.icon});
}
