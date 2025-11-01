import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../ui/widgets/swipe_card.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final _fs = FirestoreService();
  List<AppUser> teachers = [];

  @override
  void initState() {
    super.initState();
    _fs.streamTeachers().listen((list) {
      setState(() => teachers = list);
    });
  }

  void _onSwipe(String teacherId, String direction) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (direction == 'right') {
      _fs.setSwipe({
        'fromId': auth.userId ?? '',
        'toId': teacherId,
        'direction': 'right',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      _fs.setSwipe({
        'fromId': auth.userId ?? '',
        'toId': teacherId,
        'direction': 'left',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TutorSwipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
          )
        ],
      ),
      body: Center(
        child: SwipeCardStack(
          teachers: teachers,
          onSwipe: _onSwipe,
        ),
      ),
    );
  }
}