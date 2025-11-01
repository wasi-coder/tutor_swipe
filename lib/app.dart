import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/swipe_provider.dart';
import 'services/firestore_service.dart';
import 'ui/screens/home_screen.dart';

class TutorSwipeApp extends StatelessWidget {
  const TutorSwipeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _fs = FirestoreService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SwipeProvider>(
          create: (_) => SwipeProvider(_fs, ''),
          update: (_, auth, swipe) => SwipeProvider(_fs, auth.userId ?? ''),
        ),
      ],
      child: MaterialApp(
        title: 'TutorSwipe',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}