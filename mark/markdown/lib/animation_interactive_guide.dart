import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Interactive Animation Guide - No markdown, pure Dart with live examples
/// Users can see, edit, and test animations in real-time
class AnimationInteractiveGuide extends StatefulWidget {
  final bool isDark;
  
  const AnimationInteractiveGuide({
    super.key,
    required this.isDark,
  });

  @override
  State<AnimationInteractiveGuide> createState() => _AnimationInteractiveGuideState();
}

class _AnimationInteractiveGuideState extends State<AnimationInteractiveGuide> {
  int selectedDemo = 0;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'SwiftUI-like Declarative Animations',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zero boilerplate - No controllers, no ticker providers, no mixins!',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 32),
            
            // Demo Selector
            _buildDemoSelector(),
            const SizedBox(height: 24),
            
            // Selected Demo
            _buildSelectedDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSelector() {
    final demos = [
      'Fade In',
      'Scale',
      'Rotate',
      'Slide',
      'Bounce',
      'Pulse',
      'Combined',
      'Repeat',
      'Interactive',
      'Custom Code',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: demos.asMap().entries.map((entry) {
        final index = entry.key;
        final title = entry.value;
        final isSelected = index == selectedDemo;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => selectedDemo = index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007ACC)
                    : (widget.isDark ? const Color(0xFF2D2D30) : const Color(0xFFF3F3F3)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF007ACC)
                      : (widget.isDark ? const Color(0xFF3C3C3C) : const Color(0xFFDDDDDD)),
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (widget.isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedDemo() {
    switch (selectedDemo) {
      case 0:
        return _FadeInDemo(isDark: widget.isDark);
      case 1:
        return _ScaleDemo(isDark: widget.isDark);
      case 2:
        return _RotateDemo(isDark: widget.isDark);
      case 3:
        return _SlideDemo(isDark: widget.isDark);
      case 4:
        return _BounceDemo(isDark: widget.isDark);
      case 5:
        return _PulseDemo(isDark: widget.isDark);
      case 6:
        return _CombinedDemo(isDark: widget.isDark);
      case 7:
        return _RepeatDemo(isDark: widget.isDark);
      case 8:
        return _InteractiveDemo(isDark: widget.isDark);
      case 9:
        return _CustomCodeDemo(isDark: widget.isDark);
      default:
        return _FadeInDemo(isDark: widget.isDark);
    }
  }
}

// Individual Demo Widgets

class _FadeInDemo extends StatelessWidget {
  final bool isDark;
  const _FadeInDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Fade In Animation',
      description: 'Widget fades in from transparent to opaque',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.blue,
)
  .animate()
  .fadeIn()
  .duration(1.s)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      )
          .animate()
          .fadeIn()
          .duration(1.s),
    );
  }
}

class _ScaleDemo extends StatelessWidget {
  final bool isDark;
  const _ScaleDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Scale Animation',
      description: 'Widget scales from 1.0 to target value',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.green,
)
  .animate()
  .scale(1.5)
  .duration(1.s)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.green,
      )
          .animate()
          .scale(1.5)
          .duration(1.s),
    );
  }
}

class _RotateDemo extends StatelessWidget {
  final bool isDark;
  const _RotateDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Rotate Animation',
      description: 'Widget rotates by specified degrees',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.orange,
)
  .animate()
  .rotate(360)
  .duration(1.s)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.orange,
      )
          .animate()
          .rotate(360)
          .duration(1.s),
    );
  }
}

class _SlideDemo extends StatelessWidget {
  final bool isDark;
  const _SlideDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Slide In Animation',
      description: 'Widget slides in from bottom',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.purple,
)
  .animate()
  .slideInBottom()
  .fadeIn()
  .duration(1.s)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.purple,
      )
          .animate()
          .slideInBottom()
          .fadeIn()
          .duration(1.s),
    );
  }
}

class _BounceDemo extends StatelessWidget {
  final bool isDark;
  const _BounceDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Bounce Animation',
      description: 'Widget bounces with elastic effect',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.red,
)
  .animate()
  .bounce()
  .scale(1.3)
  .duration(800.ms)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.red,
      )
          .animate()
          .bounce()
          .scale(1.3)
          .duration(800.ms),
    );
  }
}

class _PulseDemo extends StatelessWidget {
  final bool isDark;
  const _PulseDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Pulse Animation',
      description: 'Widget pulses with smooth easing',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.cyan,
)
  .animate()
  .pulse()
  .scale(1.2)
  .duration(1.s)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.cyan,
      )
          .animate()
          .pulse()
          .scale(1.2)
          .duration(1.s),
    );
  }
}

class _CombinedDemo extends StatelessWidget {
  final bool isDark;
  const _CombinedDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Combined Animations',
      description: 'Multiple animations chained together',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.indigo,
)
  .animate()
  .fadeIn()
  .scale(1.2)
  .rotate(180)
  .duration(1.5.s)
  .curve(Curves.easeInOut)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.indigo,
      )
          .animate()
          .fadeIn()
          .scale(1.2)
          .rotate(180)
          .duration(1.5.s)
          .curve(Curves.easeInOut),
    );
  }
}

class _RepeatDemo extends StatelessWidget {
  final bool isDark;
  const _RepeatDemo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: isDark,
      title: 'Repeating Animation',
      description: 'Animation repeats infinitely with reverse',
      code: '''Container(
  width: 100,
  height: 100,
  color: Colors.teal,
)
  .animate()
  .scale(1.3)
  .repeat(reverse: true)
  .duration(800.ms)''',
      child: Container(
        width: 100,
        height: 100,
        color: Colors.teal,
      )
          .animate()
          .scale(1.3)
          .repeat(reverse: true)
          .duration(800.ms),
    );
  }
}

class _InteractiveDemo extends StatefulWidget {
  final bool isDark;
  const _InteractiveDemo({required this.isDark});

  @override
  State<_InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<_InteractiveDemo> {
  bool _isExpanded = false;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      isDark: widget.isDark,
      title: 'Interactive Animation',
      description: 'Tap the box to toggle animation state',
      code: '''GestureDetector(
  onTap: () {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  },
  child: Container(...)
    .animate()
    .scale(_isExpanded ? 1.5 : 1.0)
    .rotate(_isExpanded ? 180 : 0)
    .duration(300.ms)''',
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            _tapCount++;
          });
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Tap! ($_tapCount)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
            .animate()
            .scale(_isExpanded ? 1.5 : 1.0)
            .rotate(_isExpanded ? 180 : 0)
            .duration(300.ms)
            .curve(Curves.easeInOut),
      ),
    );
  }
}

class _CustomCodeDemo extends StatefulWidget {
  final bool isDark;
  const _CustomCodeDemo({required this.isDark});

  @override
  State<_CustomCodeDemo> createState() => _CustomCodeDemoState();
}

class _CustomCodeDemoState extends State<_CustomCodeDemo> {
  // Animation properties
  double _width = 100;
  double _height = 100;
  Color _color = Colors.purple;
  double _scale = 1.2;
  double _rotate = 0;
  double _opacity = 1.0;
  bool _fadeIn = true;
  bool _slideInBottom = false;
  bool _bounce = false;
  bool _pulse = false;
  double _duration = 1.0;
  bool _repeat = false;
  bool _reverse = false;
  
  String _durationUnit = 's'; // 'ms', 's', 'm'

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Animation Builder',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? Colors.white : const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adjust properties below and see the animation update in real-time',
          style: TextStyle(
            fontSize: 14,
            color: widget.isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF252526) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF007ACC),
                    width: 1.5,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Size', [
                        _buildSlider('Width', _width, 50, 300, (v) => setState(() => _width = v)),
                        _buildSlider('Height', _height, 50, 300, (v) => setState(() => _height = v)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Color', [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.red,
                            Colors.teal,
                            Colors.indigo,
                            Colors.pink,
                          ].map((color) => _buildColorButton(color)).toList(),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Transform', [
                        _buildSlider('Scale', _scale, 0.5, 2.0, (v) => setState(() => _scale = v)),
                        _buildSlider('Rotate (degrees)', _rotate, 0, 360, (v) => setState(() => _rotate = v)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Effects', [
                        _buildCheckbox('Fade In', _fadeIn, (v) => setState(() => _fadeIn = v)),
                        _buildCheckbox('Slide In Bottom', _slideInBottom, (v) => setState(() => _slideInBottom = v)),
                        _buildCheckbox('Bounce', _bounce, (v) => setState(() => _bounce = v)),
                        _buildCheckbox('Pulse', _pulse, (v) => setState(() => _pulse = v)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Duration', [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSlider('Duration', _duration, 0.1, 5.0, (v) => setState(() => _duration = v)),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: _durationUnit,
                              items: ['ms', 's', 'm'].map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              )).toList(),
                              onChanged: (v) => setState(() => _durationUnit = v!),
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Repeat', [
                        _buildCheckbox('Repeat', _repeat, (v) => setState(() => _repeat = v)),
                        if (_repeat)
                          _buildCheckbox('Reverse', _reverse, (v) => setState(() => _reverse = v)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Preview and Code
            Column(
              children: [
                // Preview
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF007ACC),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: _buildPreviewWidget(),
                  ),
                ),
                const SizedBox(height: 16),
                // Generated Code
                Container(
                  width: 300,
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF007ACC),
                      width: 1.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _generateCode(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFD7BA7D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewWidget() {
    Widget widget = Container(
      width: _width,
      height: _height,
      color: _color,
    );

    var builder = widget.animate();

    if (_fadeIn) {
      builder = builder.fadeIn();
    }
    if (_scale != 1.0) {
      builder = builder.scale(_scale);
    }
    if (_rotate != 0) {
      builder = builder.rotate(_rotate);
    }
    if (_slideInBottom) {
      builder = builder.slideInBottom();
    }
    if (_bounce) {
      builder = builder.bounce();
    }
    if (_pulse) {
      builder = builder.pulse();
    }

    // Duration
    Duration duration;
    switch (_durationUnit) {
      case 'ms':
        duration = Duration(milliseconds: _duration.round());
        builder = builder.duration(_duration.round().ms);
        break;
      case 'm':
        duration = Duration(minutes: _duration.round());
        builder = builder.duration(_duration.round().m);
        break;
      default:
        duration = Duration(milliseconds: (_duration * 1000).round());
        builder = builder.duration(_duration.s);
    }

    if (_repeat) {
      builder = builder.repeat(reverse: _reverse);
    }

    return builder;
  }

  String _generateCode() {
    final buffer = StringBuffer();
    buffer.writeln('Container(');
    buffer.writeln('  width: $_width,');
    buffer.writeln('  height: $_height,');
    buffer.writeln('  color: ${_colorToCode(_color)},');
    buffer.writeln(')');
    buffer.writeln('  .animate()');
    
    if (_fadeIn) {
      buffer.writeln('  .fadeIn()');
    }
    if (_scale != 1.0) {
      buffer.writeln('  .scale($_scale)');
    }
    if (_rotate != 0) {
      buffer.writeln('  .rotate($_rotate)');
    }
    if (_slideInBottom) {
      buffer.writeln('  .slideInBottom()');
    }
    if (_bounce) {
      buffer.writeln('  .bounce()');
    }
    if (_pulse) {
      buffer.writeln('  .pulse()');
    }
    
    // Duration
    switch (_durationUnit) {
      case 'ms':
        buffer.writeln('  .duration(${_duration.round()}.ms)');
        break;
      case 'm':
        buffer.writeln('  .duration(${_duration.round()}.m)');
        break;
      default:
        buffer.writeln('  .duration($_duration.s)');
    }
    
    if (_repeat) {
      buffer.writeln('  .repeat(reverse: $_reverse)');
    }
    
    return buffer.toString();
  }

  String _colorToCode(Color color) {
    if (color == Colors.blue) return 'Colors.blue';
    if (color == Colors.green) return 'Colors.green';
    if (color == Colors.orange) return 'Colors.orange';
    if (color == Colors.purple) return 'Colors.purple';
    if (color == Colors.red) return 'Colors.red';
    if (color == Colors.teal) return 'Colors.teal';
    if (color == Colors.indigo) return 'Colors.indigo';
    if (color == Colors.pink) return 'Colors.pink';
    return 'Colors.purple';
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white : const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF007ACC),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: const Color(0xFF007ACC),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: widget.isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
        ),
      ),
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      activeColor: const Color(0xFF007ACC),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _color == color;
    return GestureDetector(
      onTap: () => setState(() => _color = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

// Reusable Demo Card
class _DemoCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String description;
  final String code;
  final Widget child;

  const _DemoCard({
    required this.isDark,
    required this.title,
    required this.description,
    required this.code,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252526) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF007ACC),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: child),
              ),
              const SizedBox(width: 24),
              // Code
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFFD7BA7D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

