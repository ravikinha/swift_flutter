import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Comprehensive example demonstrating SwiftUI-like declarative animations
/// 
/// Zero boilerplate - no controllers, no ticker providers needed!
class AnimateExample extends StatelessWidget {
  const AnimateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SwiftUI-like Declarative Animations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zero boilerplate - no controllers, no ticker providers!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            '1. Basic Animations',
            [
              _buildAnimationCard(
                'Fade In',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                )
                    .animate().fadeIn().duration(5.ms),
              ),
              _buildAnimationCard(
                'Scale',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.green,
                ).animate().scale(1.5),
              ),
              _buildAnimationCard(
                'Rotate',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.orange,
                ).animate().rotate(360),
              ),
            ],
          ),
          
          _buildSection(
            '2. Slide Animations',
            [
              _buildAnimationCard(
                'Slide In Top',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.purple,
                  child: const Center(child: Text('Top', style: TextStyle(color: Colors.white))),
                ).animate().slideInTop(),
              ),
              _buildAnimationCard(
                'Slide In Bottom',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.teal,
                  child: const Center(child: Text('Bottom', style: TextStyle(color: Colors.white))),
                ).animate().slideInBottom(),
              ),
              _buildAnimationCard(
                'Slide X',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ).animate().slideX(50),
              ),
              _buildAnimationCard(
                'Slide Y',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                ).animate().slideY(50),
              ),
            ],
          ),
          
          _buildSection(
            '3. Combined Animations',
            [
              _buildAnimationCard(
                'Fade In + Scale',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.indigo,
                ).animate().fadeInScale(1.3),
              ),
              _buildAnimationCard(
                'Multiple Transforms',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.amber,
                )
                    .animate()
                    .fadeIn()
                    .scale(1.2)
                    .rotate(180),
              ),
            ],
          ),
          
          _buildSection(
            '4. Special Effects',
            [
              _buildAnimationCard(
                'Bounce',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.deepOrange,
                ).animate().bounce().scale(1),
              ),
              _buildAnimationCard(
                'Pulse',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.cyan,
                ).animate().pulse().scale(1.2),
              ),
            ],
          ),
          
          _buildSection(
            '5. Repeat Animations',
            [
              _buildAnimationCard(
                'Repeat Forever',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.lime,
                )
                    .animate()
                    .scale(1.3)
                    .repeat(reverse: true),
              ),
              _buildAnimationCard(
                'Repeat Count',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.brown,
                )
                    .animate()
                    .rotate(360)
                    .repeatCount(3),
              ),
            ],
          ),
          
          _buildSection(
            '6. Custom Configuration',
            [
              _buildAnimationCard(
                'Custom Duration (String)',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.deepPurple,
                )
                    .animate()
                    .scale(1.5)
                    .duration('.5s'), // Shorthand: .5s
              ),
              _buildAnimationCard(
                'Custom Duration (Number)',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.indigo,
                )
                    .animate()
                    .scale(1.5)
                    .duration(2.s), // Shorthand: 2.s
              ),
              _buildAnimationCard(
                'Custom Curve',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.blueGrey,
                )
                    .animate()
                    .fadeIn()
                    .curve(Curves.bounceOut),
              ),
              _buildAnimationCard(
                'With Delay (String)',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.lightGreen,
                )
                    .animate()
                    .fadeIn()
                    .delay('.5s'), // Shorthand: .5s
              ),
              _buildAnimationCard(
                'With Delay (Number)',
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.teal,
                )
                    .animate()
                    .fadeIn()
                    .delay(500.ms), // Shorthand: 500.ms
              ),
            ],
          ),
          
          _buildSection(
            '7. Complex Examples',
            [
              _buildAnimationCard(
                'Full Chain',
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Complex',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn()
                    .scale(1.2)
                    .slideInBottom()
                    .rotate(180)
                    .duration(const Duration(milliseconds: 1500))
                    .curve(Curves.easeInOut),
              ),
              _buildAnimationCard(
                'Bouncing Box',
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
                    .animate()
                    .bounce()
                    .scale(1.3)
                    .repeat(reverse: true)
                    .duration(const Duration(milliseconds: 800)),
              ),
            ],
          ),
          
          _buildSection(
            '8. Real World Examples',
            [
              _buildInteractiveExample(
                'Tap to Animate',
                const _InteractiveAnimationDemo(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children,
        ),
      ],
    );
  }

  Widget _buildAnimationCard(String title, Widget animatedWidget) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: animatedWidget),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInteractiveExample(String title, Widget example) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              example,
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive demo showing animations triggered by user interaction
class _InteractiveAnimationDemo extends StatefulWidget {
  const _InteractiveAnimationDemo();

  @override
  State<_InteractiveAnimationDemo> createState() => _InteractiveAnimationDemoState();
}

class _InteractiveAnimationDemoState extends State<_InteractiveAnimationDemo> {
  bool _isExpanded = false;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
              .animate()
              .scale(_isExpanded ? 1.5 : 1.0)
              .rotate(_isExpanded ? 180 : 0)
              .duration(const Duration(milliseconds: 300))
              .curve(Curves.easeInOut),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap the box to toggle animation',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

