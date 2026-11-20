
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'constants.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'services/profile_service.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/auth_page.dart';
import 'screens/home_page.dart';
import 'screens/courses_page.dart';
import 'screens/favorites_page.dart';
import 'screens/profile_page.dart';

// Global key untuk menampilkan SnackBar dari listener FCM.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Background handler harus berupa fungsi top-level,
// yaitu berada di luar class.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('================================');
  debugPrint('[BACKGROUND] NOTIFIKASI DITERIMA');
  debugPrint('Judul: ${message.notification?.title}');
  debugPrint('Isi: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  debugPrint('================================');
}

const String supabaseUrl =
    'https://qscxrkgqvysjaliyupcf.supabase.co';

const String supabaseAnonKey =
    'sb_publishable_aB6BsNU3QhvOkVqq2rMTew_9TpElf8A';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Daftarkan background handler setelah Firebase diinisialisasi.
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // Inisialisasi Supabase.
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  final messaging = FirebaseMessaging.instance;

  // Meminta izin notifikasi.
  final permission = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint(
    'Status permission notification: ${permission.authorizationStatus}',
  );

  // Dengarkan hasil registrasi sebelum register().
  messaging.onRegistered.listen(
    (String installationId) {
      debugPrint('================================');
      debugPrint('FIREBASE INSTALLATION ID:');
      debugPrint(installationId);
      debugPrint('================================');
    },
    onError: (error) {
      debugPrint('Gagal mendapatkan Installation ID: $error');
    },
  );

  // Registrasikan perangkat ke Firebase.
  try {
    await messaging.register();
    debugPrint('Registrasi perangkat FCM berhasil.');
  } catch (e) {
    debugPrint('Gagal melakukan registrasi FCM: $e');
  }

  // FOREGROUND: aplikasi sedang terbuka.
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      debugPrint('================================');
      debugPrint('[FOREGROUND] NOTIFIKASI DITERIMA');
      debugPrint('Judul: ${message.notification?.title}');
      debugPrint('Isi: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('================================');

      // Tampilkan pesan di dalam aplikasi.
      final title =
          message.notification?.title ?? 'Notifikasi';

      final body =
          message.notification?.body ?? '';

      messengerKey.currentState
          ?.hideCurrentSnackBar();

      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            body.isEmpty ? title : '$title\n$body',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    },
  );

  final CourseDataSource dataSource =
      CourseSupabaseService();

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
      scaffoldMessengerKey: messengerKey,
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
      home: const AuthGate(
        child: ResponsiveShell(),
      ),
    );
  }
}

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() =>
      _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int currentIndex = 0;

  late Future<UserProfile?> _profileFuture;

  final Map<String, dynamic> studentData = {
    'student': {
      'name': studentName,
      'nim': studentId,
    },
  };

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  List<_NavItem> _getNavigationItems(String role) {
    final items = <_NavItem>[
      _NavItem(
        key: 'home',
        label: 'Home',
        icon: Icons.home,
      ),
      _NavItem(
        key: 'courses',
        label: 'Courses',
        icon: Icons.school,
      ),
    ];

    if (role == 'seeker') {
      items.add(
        _NavItem(
          key: 'favorites',
          label: 'Favorites',
          icon: Icons.favorite,
        ),
      );
    }

    if (role == 'admin') {
      items.add(
        _NavItem(
          key: 'admin',
          label: 'Manajemen Pengguna',
          icon: Icons.manage_accounts,
        ),
      );
    }

    items.add(
      _NavItem(
        key: 'profile',
        label: 'Profile',
        icon: Icons.person,
      ),
    );

    return items;
  }

  Widget _buildCurrentPage(String key) {
    switch (key) {
      case 'home':
        return HomePage(data: studentData);

      case 'courses':
        return CoursesPage(data: studentData);

      case 'favorites':
        return FavoritesPage(data: studentData);

      case 'admin':
        return const AdminManagementPage();

      case 'profile':
        return ProfilePage(data: studentData);

      default:
        return HomePage(data: studentData);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
          ),
        );
      }
    }
  }

  Widget _buildNavigationBar(List<_NavItem> items) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildNavigationRail(List<_NavItem> items) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  Widget _buildRoleLayout(
    BuildContext context,
    UserProfile profile,
  ) {
    final role = profile.role.toLowerCase().trim();

    if (!['seeker', 'owner', 'admin'].contains(role)) {
      return const Center(
        child: Text('Role akun tidak dikenali.'),
      );
    }

    final items = _getNavigationItems(role);

    if (currentIndex >= items.length) {
      currentIndex = 0;
    }

    final page =
        _buildCurrentPage(items[currentIndex].key);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Column(
            children: [
              Expanded(child: page),
              _buildNavigationBar(items),
            ],
          );
        }

        return Row(
          children: [
            _buildNavigationRail(items),
            const VerticalDivider(width: 1),
            Expanded(child: page),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal mengambil profil pengguna.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _profileFuture =
                              ProfileService().getMyProfile();
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(
              child: Text(
                'Profil pengguna tidak ditemukan di Supabase.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return _buildRoleLayout(context, profile);
        },
      ),
    );
  }
}

class _NavItem {
  final String key;
  final String label;
  final IconData icon;

  const _NavItem({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class AdminManagementPage extends StatelessWidget {
  const AdminManagementPage({super.key});

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('id, email, name, role')
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Gagal memuat pengguna.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Text('Belum ada data pengguna.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Manajemen Pengguna',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Total pengguna: ${users.length}'),
            const SizedBox(height: 16),
            ...users.map((user) {
              final name = user['name'] ?? 'Tanpa nama';
              final email = user['email'] ?? '-';
              final role = user['role'] ?? '-';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(name.toString()),
                  subtitle: Text(
                    '$email\nRole: $role',
                  ),
                  isThreeLine: true,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
