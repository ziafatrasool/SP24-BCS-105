import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/form_screen.dart';
import 'screens/records_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace with your real Supabase credentials
  await Supabase.initialize(
    url: 'https://bdushmkohzykitjwqlqn.supabase.co',
    anonKey: 'sb_publishable_edylllyh8MYVm6zC1xRJyw_5_JyEMVI',
  );

  runApp(const SubmissionApp());
}

class SubmissionApp extends StatelessWidget {
  const SubmissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Submission Form',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: ThemeMode.dark, // Default to dark mode as requested
      initialRoute: '/',
      routes: {
        '/': (context) => const FormScreen(),
        '/records': (context) => const RecordsScreen(),
      },
    );
  }
}
