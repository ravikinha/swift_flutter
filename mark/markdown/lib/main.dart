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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('swift_flutter Learning'),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showChapterDrawer(context),
            ),
          ],
        ),
        body: _buildContent(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'swift_flutter\nLearning Guide',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isSelected = index == selectedChapterIndex;
                
                return ListTile(
                  leading: Icon(
                    chapter.icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    '${index + 1}. ${chapter.title}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () => _loadChapter(index),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                Text(
                  'Progress: ${selectedChapterIndex + 1}/${chapters.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (selectedChapterIndex + 1) / chapters.length,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (markdownContent == null) {
      return const Center(child: Text('No content loaded'));
    }

    return Column(
      children: [
        if (selectedChapterIndex > 0 || selectedChapterIndex < chapters.length - 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedChapterIndex > 0)
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text('Previous: ${chapters[selectedChapterIndex - 1].title}'),
                    onPressed: () => _loadChapter(selectedChapterIndex - 1),
                  )
                else
                  const SizedBox(),
                if (selectedChapterIndex < chapters.length - 1)
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('Next: ${chapters[selectedChapterIndex + 1].title}'),
                    onPressed: () => _loadChapter(selectedChapterIndex + 1),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerRight,
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),
          ),
        Expanded(
          child: Markdown(
            data: markdownContent!,
            styleSheet: MarkdownStyleSheet(
              h1: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              h2: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              h3: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              code: TextStyle(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                fontFamily: 'monospace',
              ),
              codeblockDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            selectable: true,
          ),
        ),
      ],
    );
  }

  void _showChapterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
            Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final isSelected = index == selectedChapterIndex;
                  
                  return ListTile(
                    leading: Icon(chapter.icon),
                    title: Text('${index + 1}. ${chapter.title}'),
                    selected: isSelected,
                    onTap: () {
                      _loadChapter(index);
                      Navigator.pop(context);
                    },
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
