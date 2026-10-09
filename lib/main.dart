
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'course_state.dart';
import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';

const String studentName = 'Kadek Ayu Aulia';
const String studentId = '2415051041';

int columnsFor(double width) {
  if (width < 600) return 1;
  if (width < 840) return 2;
  return 3;
}

// TAHAP 6 - PROVIDER
// TAHAP 7 - watch(), read(), dan Consumer
// TAHAP 8 - MODEL COURSE
// TAHAP 9 - COURSE SERVICE
// TAHAP 10 - REPOSITORY PATTERN
void main() {
  runApp(
    ChangeNotifierProvider<CourseState>(
      create: (_) {
        final state = CourseState(
          CourseRepository(CourseService()),
        );

        state.loadCourses();

        return state;
      },
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
  State<ResponsiveShell> createState() =>
      _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  late Future<Map<String, dynamic>> studentFuture;

  final CourseService courseService = CourseService();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Memuat data mahasiswa melalui service.
    studentFuture = courseService.loadData();
  }

  Widget buildCurrentPage(Map<String, dynamic> data) {
    if (currentIndex == 0) {
      return HomePage(data: data);
    }

    if (currentIndex == 1) {
      return CoursesPage(data: data);
    }

    return ProfilePage(data: data);
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi error:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak tersedia'),
            );
          }

          final data = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final page = buildCurrentPage(data);

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

class StudentHeader extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentHeader({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                'assets/profile.jpeg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    student['nim'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.pink.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic> data;

  const HomePage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final student =
        data['student'] as Map<String, dynamic>;

    // Data course diambil dari Provider,
    // yang memuat data melalui Repository.
    final courseState = context.watch<CourseState>();
    final courses = courseState.courses;

    final completed = courses
        .where((course) => course.status == 'done')
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudentHeader(student: student),
          const SizedBox(height: 20),
          const Text(
            'Progress Belajar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.pink.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Colors.pink.shade700,
                        size: 32,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${courses.length}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Total Course'),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.pink.shade700,
                        size: 32,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$completed',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Selesai'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoursesPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const CoursesPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Daftar course berasal dari Provider.
    final courseState = context.watch<CourseState>();
    final courses = courseState.courses;

    if (courseState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      );
    }

    if (courseState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Gagal memuat course:\n'
            '${courseState.errorMessage}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jumlah Favorite: '
                    '${courseState.favorites.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isCompact
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: CourseCard(
                            course: courses[index],
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnsFor(
                          constraints.maxWidth,
                        ),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(
                          course: courses[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;

    if (course.status == 'done') {
      statusIcon = Icons.check_circle;
    } else if (course.status == 'active') {
      statusIcon = Icons.play_circle;
    } else {
      statusIcon = Icons.schedule;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                course: course,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.pink.shade100,
                    child: Icon(
                      statusIcon,
                      color: Colors.pink.shade700,
                    ),
                  ),
                  Consumer<CourseState>(
                    builder: (context, state, child) {
                      final isFavorite =
                          state.favorites.contains(course.code);

                      return IconButton(
                        onPressed: () {
                          context
                              .read<CourseState>()
                              .toggleFavorite(course.code);
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.pink
                              : Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${course.code} • ${course.credits} SKS',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                course.status == 'done'
                    ? 'Selesai'
                    : course.status == 'active'
                        ? 'Aktif'
                        : 'Rencana',
                style: TextStyle(
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Code: ${course.code}'),
            const SizedBox(height: 8),
            Text('Credits: ${course.credits} SKS'),
            const SizedBox(height: 8),
            Text('Status: ${course.status}'),
            const SizedBox(height: 20),
            Text('Nama: $studentName'),
            const SizedBox(height: 8),
            Text('NIM: $studentId'),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ProfilePage({
    super.key,
    required this.data,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final student =
        widget.data['student'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudentHeader(student: student),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$studentId - $studentName - '
                  'teks sangat panjang untuk menguji '
                  'RenderFlex overflow',
                ),
              ),
            ],
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: studentName,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: studentId,
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Komentar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 5) {
                      return 'Komentar minimal 5 karakter';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Feedback berhasil dikirim',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Kirim Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}