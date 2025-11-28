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
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007ACC),
          secondary: Color(0xFF0098FF),
          surface: Color(0xFFF3F3F3),
          background: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF007ACC),
          secondary: Color(0xFF0098FF),
          surface: Color(0xFF252526),
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
          Container(width: 1, color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE5E5E5)),
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF252526) : const Color(0xFF007ACC),
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/images/swift_flutter_logo.png', height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 24)),
          const SizedBox(width: 12),
          const Text(
            'swift_flutter Learning',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(widget.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: Colors.white),
          onPressed: widget.onThemeToggle,
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showChapterDrawer(context),
        ),
      ],
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 280,
      color: isDark ? const Color(0xFF252526) : const Color(0xFFF3F3F3),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D30) : const Color(0xFF007ACC),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/swift_flutter_logo.png',
                  height: 32,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('swift_flutter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('Learning Guide', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              ],
            ),
          ),
          // Chapters
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF37373D) : Colors.white)
                            : Colors.transparent,
                        border: isSelected
                            ? Border(left: BorderSide(color: const Color(0xFF007ACC), width: 2))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF007ACC) : Colors.transparent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : (isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            chapter.icon,
                            size: 16,
                            color: isSelected ? const Color(0xFF007ACC) : (isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF1E1E1E))
                                    : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE5E5E5))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                    ),
                    Text(
                      '${selectedChapterIndex + 1}/${chapters.length}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF007ACC)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (selectedChapterIndex + 1) / chapters.length,
                    backgroundColor: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007ACC)),
                    minHeight: 3,
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFF007ACC)));
    }

    if (markdownContent == null) {
      return Center(
        child: Text('No content loaded', style: TextStyle(color: isDark ? const Color(0xFF858585) : const Color(0xFF616161))),
      );
    }

    return Stack(
      children: [
        // Watermark
        Positioned.fill(
          child: Center(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/swift_flutter_logo.png',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ),
        // Content
        Column(
          children: [
            // Navigation
            if (selectedChapterIndex > 0 || selectedChapterIndex < chapters.length - 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252526) : const Color(0xFFF3F3F3),
                  border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE5E5E5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (selectedChapterIndex > 0)
                      _buildNavButton(isDark, Icons.arrow_back_ios, chapters[selectedChapterIndex - 1].title, () => _loadChapter(selectedChapterIndex - 1), true)
                    else
                      const SizedBox(width: 80),
                    if (selectedChapterIndex < chapters.length - 1)
                      _buildNavButton(isDark, Icons.arrow_forward_ios, chapters[selectedChapterIndex + 1].title, () => _loadChapter(selectedChapterIndex + 1), false)
                    else
                      const SizedBox(width: 80),
                  ],
                ),
              ),
            // Markdown Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Markdown(
                  data: markdownContent!,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E1E), height: 1.3),
                    h1Padding: const EdgeInsets.only(bottom: 16, top: 8),
                    h2: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E1E), height: 1.4),
                    h2Padding: const EdgeInsets.only(bottom: 12, top: 20),
                    h3: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E1E1E), height: 1.4),
                    h3Padding: const EdgeInsets.only(bottom: 10, top: 16),
                    p: TextStyle(fontSize: 14, height: 1.6, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C)),
                    pPadding: const EdgeInsets.only(bottom: 12),
                    code: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Consolas, Monaco, Courier New, monospace',
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                      color: isDark ? const Color(0xFFCE9178) : const Color(0xFFA31515),
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE5E5E5)),
                    ),
                    codeblockPadding: const EdgeInsets.all(14),
                    blockquote: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                    blockquoteDecoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252526) : const Color(0xFFF3F3F3),
                      border: const Border(left: BorderSide(color: Color(0xFF007ACC), width: 3)),
                    ),
                    blockquotePadding: const EdgeInsets.all(12),
                    listBullet: const TextStyle(color: Color(0xFF007ACC)),
                    strong: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E1E)),
                    em: TextStyle(fontStyle: FontStyle.italic, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C)),
                    a: const TextStyle(color: Color(0xFF007ACC), decoration: TextDecoration.underline),
                  ),
                  selectable: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(bool isDark, IconData icon, String label, VoidCallback onPressed, bool isLeft) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    Icon(icon, size: 14, color: const Color(0xFF007ACC)),
                    const SizedBox(width: 6),
                    Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C))),
                  ]
                : [
                    Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C))),
                    const SizedBox(width: 6),
                    Icon(icon, size: 14, color: const Color(0xFF007ACC)),
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
      backgroundColor: isDark ? const Color(0xFF252526) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chapters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E1E))),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? (isDark ? const Color(0xFF37373D) : const Color(0xFFF3F3F3)) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: isSelected ? Border(left: BorderSide(color: const Color(0xFF007ACC), width: 2)) : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF007ACC) : (isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE5E5E5)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : (isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(chapter.icon, size: 18, color: isSelected ? const Color(0xFF007ACC) : (isDark ? const Color(0xFF858585) : const Color(0xFF616161))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                chapter.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                  color: isSelected ? (isDark ? Colors.white : const Color(0xFF1E1E1E)) : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C)),
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

