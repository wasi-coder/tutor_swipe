import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import '../../models/user_model.dart';

typedef OnSwipeCallback = void Function(String teacherId, String direction);

class SwipeCardStack extends StatefulWidget {
  final List<AppUser> teachers;
  final OnSwipeCallback onSwipe;

  const SwipeCardStack({Key? key, required this.teachers, required this.onSwipe}) : super(key: key);

  @override
  State<SwipeCardStack> createState() => _SwipeCardStackState();
}

class _SwipeCardStackState extends State<SwipeCardStack> {
  late SwipableStackController controller;

  @override
  void initState() {
    super.initState();
    controller = SwipableStackController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.teachers.isEmpty) {
      return const Center(child: Text('No teachers found.'));
    }
    return SizedBox(
      height: 560,
      child: SwipableStack(
        controller: controller,
        onSwipeCompleted: (index, direction) {
          final teacher = widget.teachers[index];
          final dir = (direction == SwipeDirection.right) ? 'right' : 'left';
          widget.onSwipe(teacher.id, dir);
        },
        builder: (context, properties) {
          final teacher = widget.teachers[properties.index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: teacher.photoUrl != null
                        ? Image.network(teacher.photoUrl!, fit: BoxFit.cover, height: 320, width: double.infinity)
                        : Container(height: 320, color: Colors.grey[200], child: const Icon(Icons.person, size: 80)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${teacher.subjects.isNotEmpty ? teacher.subjects.first : ''} • ৳${teacher.rate ?? '—'}/hr',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text(teacher.bio ?? '', maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => controller.next(swipeDirection: SwipeDirection.left),
                              icon: const Icon(Icons.close),
                              label: const Text('Skip'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => controller.next(swipeDirection: SwipeDirection.right),
                              icon: const Icon(Icons.favorite),
                              label: const Text('Like'),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: widget.teachers.length,
      ),
    );
  }
}