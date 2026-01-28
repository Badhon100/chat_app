import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chat_app/app_start_screen.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/providers/bloc_providers.dart';
import 'package:chat_app/features/auth/presentation/pages/auth_screen.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:chat_app/features/auth/presentation/pages/register_screen.dart';
import 'package:chat_app/features/chat/presentation/pages/conversation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pwyakjgatlsmwwjippig.supabase.co',
    anonKey: 'sb_publishable_kb-8uceag-_ymLXLpXH-7A_TNr036-B',
  );
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Realtime Chat',
        theme: ThemeData(primarySwatch: Colors.blue),

        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/conversations': (_) => const ConversationPage(),
        },

        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conversationId: args['conversationId'],
                  otherUserEmail: args['otherUserEmail'] ?? 'Unknown',
                ),
              );
            }
          }
          return null;
        },

        home: const AppStartScreen(),
      ),
    );
  }
}
