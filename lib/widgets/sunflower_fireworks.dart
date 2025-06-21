import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/user_provider.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';

class SunflowerFireworks extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const SunflowerFireworks({super.key, this.onComplete});

  @override
  State<SunflowerFireworks> createState() => _SunflowerFireworksState();
}

class _SunflowerFireworksState extends State<SunflowerFireworks>
    with TickerProviderStateMixin {
  late AnimationController _sunflowerController;
  late AnimationController _fireworksController;
  late Animation<double> _sunflowerGrow;
  late Animation<double> _sunflowerRotate;
  late Animation<double> _fireworksExplosion;
  late Animation<double> _fireworksFade;

  @override
  void initState() {
    super.initState();
    
    // Sunflower animation (0-2 seconds)
    _sunflowerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Fireworks animation (2-5 seconds)
    _fireworksController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _sunflowerGrow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sunflowerController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _sunflowerRotate = Tween(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _sunflowerController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _fireworksExplosion = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fireworksController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _fireworksFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fireworksController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _sunflowerController.forward();
    await _fireworksController.forward();
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.8),
      child: AnimatedBuilder(
        animation: Listenable.merge([_sunflowerController, _fireworksController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Celebration text
              Positioned(
                top: 100,
                child: AnimatedBuilder(
                  animation: _sunflowerGrow,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _sunflowerGrow.value,
                      child: const Text(
                        '🎉 AMAZING! 🎉\nYou both completed it!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Sunflower
              Transform.scale(
                scale: _sunflowerGrow.value,
                child: Transform.rotate(
                  angle: _sunflowerRotate.value * math.pi,
                  child: CustomPaint(
                    size: const Size(150, 150),
                    painter: SunflowerPainter(),
                  ),
                ),
              ),
              
              // Fireworks particles
              if (_fireworksController.isAnimating)
                ...List.generate(30, (index) {
                  final angle = (index * 12.0) * math.pi / 180;
                  final distance = _fireworksExplosion.value * 200;
                  final x = math.cos(angle) * distance;
                  final y = math.sin(angle) * distance;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + x - 5,
                    top: MediaQuery.of(context).size.height / 2 + y - 5,
                    child: Opacity(
                      opacity: _fireworksFade.value,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getFireworkColor(index),
                          boxShadow: [
                            BoxShadow(
                              color: _getFireworkColor(index),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Color _getFireworkColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _sunflowerController.dispose();
    _fireworksController.dispose();
    super.dispose();
  }
}

class SunflowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw stem
    final stemPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(center.dx, center.dy + 30),
      Offset(center.dx, size.height),
      stemPaint,
    );
    
    // Draw leaves
    final leafPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;
    
    final leafPath1 = Path();
    leafPath1.moveTo(center.dx - 5, center.dy + 40);
    leafPath1.quadraticBezierTo(center.dx - 25, center.dy + 35, center.dx - 20, center.dy + 55);
    leafPath1.quadraticBezierTo(center.dx - 10, center.dy + 50, center.dx - 5, center.dy + 40);
    canvas.drawPath(leafPath1, leafPaint);
    
    final leafPath2 = Path();
    leafPath2.moveTo(center.dx + 5, center.dy + 50);
    leafPath2.quadraticBezierTo(center.dx + 25, center.dy + 45, center.dx + 20, center.dy + 65);
    leafPath2.quadraticBezierTo(center.dx + 10, center.dy + 60, center.dx + 5, center.dy + 50);
    canvas.drawPath(leafPath2, leafPaint);
    
    // Draw petals
    final petalPaint = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * math.pi / 180;
      final petalCenter = Offset(
        center.dx + math.cos(angle) * 25,
        center.dy + math.sin(angle) * 25,
      );
      
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle + math.pi / 2);
      
      final petalPath = Path();
      petalPath.addOval(const Rect.fromLTWH(-8, -15, 16, 30));
      canvas.drawPath(petalPath, petalPaint);
      
      canvas.restore();
    }
    
    // Draw center
    final centerPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 20, centerPaint);
    
    // Draw seeds pattern
    final seedPaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 3; j++) {
        final angle = (i * 45.0) * math.pi / 180;
        final distance = 5.0 + j * 5.0;
        final seedPos = Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        );
        canvas.drawCircle(seedPos, 1.5, seedPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, child) {
        if (habitProvider.habits.isEmpty) {
          return const Center(
            child: Text('No habits yet. Add some habits to get started!'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await habitProvider.loadHabits();
          },
          child: ListView.builder(
            itemCount: habitProvider.habits.length,
            itemBuilder: (context, index) {
              final habit = habitProvider.habits[index];
              return HabitCard(
                habit: habit,
                currentUser: userProvider.currentUser!,
              );
            },
          ),
        );
      },
    );
  }
}

class HabitCard extends StatefulWidget {
  final Habit habit;
  final User currentUser;

  const HabitCard({
    super.key,
    required this.habit,
    required this.currentUser,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _checkCompletion();
  }

  Future<void> _checkCompletion() async {
    final isCompleted = await context
        .read<HabitProvider>()
        .isHabitCompletedToday(widget.habit.id!, widget.currentUser.id!);
    setState(() {
      _isCompletedToday = isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(widget.habit.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.habit.description),
            const SizedBox(height: 4),
            Text(
              widget.habit.isShared ? 'Shared Habit' : 'Personal Habit',
              style: TextStyle(
                fontSize: 12,
                color: widget.habit.isShared ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: _isCompletedToday ? null : _completeHabit,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isCompletedToday ? Colors.green : Colors.grey[300],
            ),
            child: Icon(
              _isCompletedToday ? Icons.check : Icons.touch_app,
              color: _isCompletedToday ? Colors.white : Colors.grey[600],
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeHabit() async {
    await context
        .read<HabitProvider>()
        .completeHabit(widget.habit.id!, widget.currentUser.id!);
    await _checkCompletion();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.habit.title} completed!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
