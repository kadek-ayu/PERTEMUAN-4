
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/home_page.dart';
import 'screens/courses_page.dart';
import 'screens/favorites_page.dart';
import 'screens/profile_page.dart';

const String supabaseUrl =
    'https://qscxrkgqvysjaliyupcf.supabase.co';

const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzY3hya2dxdnlzamFsaXl1cGNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMyODIxODcsImV4cCI6MjEwODg1ODE4N30.jHPZ6stosJ15tG-ff2BMuJSEql-EIk16SMMDzrRkmK8';

// =====================================================
// DOKUMENTASI PENGUJIAN STAGE 17
// =====================================================

// KASUS A – HTTP 404 ERROR
// Kode sebelumnya saat melakukan pengujian:
//
// final CourseDataSource dataSource = CourseApiService(
//   'https://jsonplaceholder.typicode.com/invalid-endpoint',
// );
//
// Penyebab:
// Endpoint yang digunakan tidak ditemukan (HTTP 404).
//
// Perbaikan:
// Mengembalikan sumber data ke CourseSupabaseService().


// KASUS C – JSON MAPPING ERROR
// Kode sebelumnya saat melakukan pengujian:
//
// final CourseDataSource dataSource = CourseApiService(
//   'https://jsonplaceholder.typicode.com/posts',
// );
//
// Catatan:
// Kesalahan pemetaan JSON dilakukan pada
// course_api_service.dart menggunakan key title_wrong.
//
// Perbaikan:
// Mengembalikan sumber data ke CourseSupabaseService().


// =====================================================
// KODE MAIN.DART NORMAL (SUDAH DIPERBAIKI)
// =====================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  runApp(
    ChangeNotifierProvider<CourseProvider>(
      create: (_) => CourseProvider(repository)..loadCourses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
        scaffoldBackgroundColor: Colors.pink.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 3,
        ),
      ),
      home: const ResponsiveShell(),
    );
  }
}

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int currentIndex = 0;

  final Map<String, dynamic> studentData = {
    'student': {
      'name': studentName,
      'nim': studentId,
    },
  };

  Widget buildCurrentPage() {
    if (currentIndex == 0) {
      return HomePage(data: studentData);
    }

    if (currentIndex == 1) {
      return CoursesPage(data: studentData);
    }

    if (currentIndex == 2) {
      return FavoritesPage(data: studentData);
    }

    return ProfilePage(data: studentData);
  }

  NavigationBar buildNavigationBar() {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.school),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  NavigationRail buildNavigationRail() {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite),
          label: Text('Favorites'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final page = buildCurrentPage();

          if (constraints.maxWidth < 840) {
            return page;
          }

          return Row(
            children: [
              buildNavigationRail(),
              const VerticalDivider(width: 1),
              Expanded(child: page),
            ],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 840) {
            return buildNavigationBar();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
