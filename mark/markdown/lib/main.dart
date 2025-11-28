import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:swift_flutter/swift_flutter.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = swift(ThemeMode.light);

    return Swift(
      builder: (context) => MaterialApp(
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
        themeMode: themeMode.value,
        home: LearningHomePage(themeMode: themeMode),
      ),
    );
  }
}

class LearningHomePage extends StatelessWidget {
  final SwiftValue<ThemeMode> themeMode;
  
  const LearningHomePage({
    super.key,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final selectedChapterIndex = swift(0);
    final markdownContent = swift<String?>(null);
    final isLoading = swift(false);

    final chapters = [
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

    // Load initial chapter
    Future.microtask(() => _loadChapter(0, chapters, selectedChapterIndex, markdownContent, isLoading));

    return Swift(
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 900;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        if (isMobile) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(isDark, themeMode, context, chapters, selectedChapterIndex, markdownContent, isLoading),
            body: _buildContent(isDark, isLoading, markdownContent, selectedChapterIndex, chapters),
          );
        }

    return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Row(
            children: [
              _buildSidebar(isDark, themeMode, chapters, selectedChapterIndex, markdownContent, isLoading),
              Container(width: 1, color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFDDDDDD)),
              Expanded(child: _buildContent(isDark, isLoading, markdownContent, selectedChapterIndex, chapters)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadChapter(
    int index,
    List<Chapter> chapters,
    SwiftValue<int> selectedChapterIndex,
    SwiftValue<String?> markdownContent,
    SwiftValue<bool> isLoading,
  ) async {
    if (index == selectedChapterIndex.value && markdownContent.value != null) return;
    
    isLoading.value = true;
    selectedChapterIndex.value = index;

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final chapter = chapters[index];
      final content = await rootBundle.loadString('assets/markdown/${chapter.file}');
      markdownContent.value = content;
    } catch (e) {
      markdownContent.value = 'Error loading chapter: $e';
    } finally {
      isLoading.value = false;
    }
  }

  PreferredSizeWidget _buildAppBar(
    bool isDark,
    SwiftValue<ThemeMode> themeMode,
    BuildContext context,
    List<Chapter> chapters,
    SwiftValue<int> selectedChapterIndex,
    SwiftValue<String?> markdownContent,
    SwiftValue<bool> isLoading,
  ) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF252526) : const Color(0xFF007ACC),
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/swift_flutter_logo.png',
            height: 24,
            errorBuilder: (_, __, ___) => Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.school, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'swift_flutter Learning',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeMode.value == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
          tooltip: 'Toggle theme',
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 22),
          onPressed: () => _showChapterDrawer(context, isDark, chapters, selectedChapterIndex, markdownContent, isLoading),
          tooltip: 'Chapters',
        ),
      ],
    );
  }

  Widget _buildSidebar(
    bool isDark,
    SwiftValue<ThemeMode> themeMode,
    List<Chapter> chapters,
    SwiftValue<int> selectedChapterIndex,
    SwiftValue<String?> markdownContent,
    SwiftValue<bool> isLoading,
  ) {
    return Container(
      width: 270,
      color: isDark ? const Color(0xFF252526) : const Color(0xFFF3F3F3),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF007ACC) : const Color(0xFF007ACC),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/swift_flutter_logo.png',
                  height: 28,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'swift_flutter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Learning Guide',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    themeMode.value == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
                  tooltip: 'Toggle theme',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
                final isSelected = index == selectedChapterIndex.value;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _loadChapter(index, chapters, selectedChapterIndex, markdownContent, isLoading),
                    hoverColor: isDark ? const Color(0xFF2A2D2E) : const Color(0xFFE8E8E8),
                    child: Container(
                      key: ValueKey('chapter_$index'),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF37373D) : Colors.white)
                            : Colors.transparent,
                        border: isSelected
                            ? const Border(left: BorderSide(color: Color(0xFF007ACC), width: 3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            chapter.icon,
                            size: 18,
                            color: isSelected
                                ? const Color(0xFF007ACC)
                                : (isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF1E1E1E))
                                    : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242)),
                                letterSpacing: -0.1,
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE8E8E8),
              border: Border(
                top: BorderSide(color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFDDDDDD)),
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF858585) : const Color(0xFF616161),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007ACC),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${selectedChapterIndex.value + 1}/${chapters.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (selectedChapterIndex.value + 1) / chapters.length,
                    backgroundColor: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFD0D0D0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007ACC)),
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

  Widget _buildContent(
    bool isDark,
    SwiftValue<bool> isLoading,
    SwiftValue<String?> markdownContent,
    SwiftValue<int> selectedChapterIndex,
    List<Chapter> chapters,
  ) {
    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF007ACC), strokeWidth: 3),
      );
    }

    if (markdownContent.value == null) {
      return Center(
        child: Text(
          'No content loaded',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF858585) : const Color(0xFF616161),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Watermark
        Positioned.fill(
          child: Center(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/swift_flutter_logo.png',
                width: 500,
                height: 500,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ),
        // Content
        Column(
          children: [
            // Navigation Bar
            if (selectedChapterIndex.value > 0 || selectedChapterIndex.value < chapters.length - 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252526) : const Color(0xFFF8F8F8),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFDDDDDD),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (selectedChapterIndex.value > 0)
                      _buildNavButton(
                        isDark,
                        Icons.arrow_back_ios_new,
                        chapters[selectedChapterIndex.value - 1].title,
                        () => _loadChapter(selectedChapterIndex.value - 1, chapters, selectedChapterIndex, markdownContent, isLoading),
                        true,
                      )
                    else
                      const SizedBox(width: 100),
                    Text(
                      chapters[selectedChapterIndex.value].title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                      ),
                    ),
                    if (selectedChapterIndex.value < chapters.length - 1)
                      _buildNavButton(
                        isDark,
                        Icons.arrow_forward_ios,
                        chapters[selectedChapterIndex.value + 1].title,
                        () => _loadChapter(selectedChapterIndex.value + 1, chapters, selectedChapterIndex, markdownContent, isLoading),
                        false,
                      )
                    else
                      const SizedBox(width: 100),
                  ],
                ),
              ),
            // Markdown Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: Markdown(
                  data: markdownContent.value!,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                    h1Padding: const EdgeInsets.only(bottom: 20, top: 8),
                    h2: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF2D2D30),
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                    h2Padding: const EdgeInsets.only(bottom: 14, top: 24),
                    h3: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF3C3C3C),
                      height: 1.4,
                      letterSpacing: -0.2,
                    ),
                    h3Padding: const EdgeInsets.only(bottom: 12, top: 18),
                    p: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                      letterSpacing: 0.1,
                    ),
                    pPadding: const EdgeInsets.only(bottom: 14),
                    code: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Consolas, Monaco, Courier New, monospace',
                      backgroundColor: isDark ? const Color(0xFF2D2D30) : const Color(0xFFE8E8E8),
                      color: isDark ? const Color(0xFFD7BA7D) : const Color(0xFFA31515),
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF007ACC) : const Color(0xFF007ACC),
                        width: 2,
                      ),
                    ),
                    codeblockPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    blockquote: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF858585) : const Color(0xFF616161),
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252526) : const Color(0xFFF3F3F3),
                      border: const Border(
                        left: BorderSide(color: Color(0xFF007ACC), width: 4),
                      ),
                    ),
                    blockquotePadding: const EdgeInsets.all(14),
                    listBullet: const TextStyle(
                      color: Color(0xFF007ACC),
                      fontWeight: FontWeight.bold,
                    ),
                    strong: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                    ),
                    em: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                    ),
                    a: const TextStyle(
                      color: Color(0xFF007ACC),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selectable: true,
                ),
              ),
            ),
            // Bottom Navigation
            if (selectedChapterIndex.value > 0 || selectedChapterIndex.value < chapters.length - 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252526) : const Color(0xFFF8F8F8),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF2D2D30) : const Color(0xFFDDDDDD),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (selectedChapterIndex.value > 0)
                      _buildNavButton(
                        isDark,
                        Icons.arrow_back_ios_new,
                        chapters[selectedChapterIndex.value - 1].title,
                        () => _loadChapter(selectedChapterIndex.value - 1, chapters, selectedChapterIndex, markdownContent, isLoading),
                        true,
                      )
                    else
                      const SizedBox(width: 100),
                    if (selectedChapterIndex.value < chapters.length - 1)
                      _buildNavButton(
                        isDark,
                        Icons.arrow_forward_ios,
                        chapters[selectedChapterIndex.value + 1].title,
                        () => _loadChapter(selectedChapterIndex.value + 1, chapters, selectedChapterIndex, markdownContent, isLoading),
                        false,
                      )
                    else
                      const SizedBox(width: 100),
                  ],
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
        hoverColor: isDark ? const Color(0xFF2A2D2E) : const Color(0xFFE8E8E8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFDDDDDD),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    Icon(icon, size: 13, color: const Color(0xFF007ACC)),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                      ),
                    ),
                  ]
                : [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(icon, size: 13, color: const Color(0xFF007ACC)),
                  ],
          ),
        ),
      ),
    );
  }

  void _showChapterDrawer(
    BuildContext context,
    bool isDark,
    List<Chapter> chapters,
    SwiftValue<int> selectedChapterIndex,
    SwiftValue<String?> markdownContent,
    SwiftValue<bool> isLoading,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF252526) : Colors.white,
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
                    color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
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
                  final isSelected = index == selectedChapterIndex.value;
                  
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _loadChapter(index, chapters, selectedChapterIndex, markdownContent, isLoading);
                        Navigator.pop(context);
                      },
                      child: Container(
                        key: ValueKey('drawer_chapter_$index'),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF37373D) : const Color(0xFFF3F3F3))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected
                              ? Border.all(color: const Color(0xFF007ACC), width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              chapter.icon,
                              size: 22,
                              color: isSelected
                                  ? const Color(0xFF007ACC)
                                  : (isDark ? const Color(0xFF858585) : const Color(0xFF616161)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                chapter.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected
                                      ? (isDark ? Colors.white : const Color(0xFF1E1E1E))
                                      : (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242)),
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
