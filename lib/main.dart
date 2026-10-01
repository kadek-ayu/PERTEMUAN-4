import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Kadek Ayu Aulia';
const String studentId = '2415051041';

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '$studentId - $studentName',
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
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          final student =
              data['student'] as Map<String, dynamic>;
          final courses = data['courses'] as List<dynamic>;

          final completed = courses
              .where(
                (course) => course['status'] == 'done',
              )
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil mahasiswa
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage('assets/profile.jpeg'),
                            ),
                            Positioned(
                              top: -10,
                              right: -5,
                              child: Icon(
                                Icons.local_florist,
                                color: Colors.pink,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                              const SizedBox(height: 5),
                              const Text(
                                'Mahasiswa',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Kasus A - RenderFlex Overflow
                Row(
                  children: [
                    const Icon(Icons.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$studentId - $studentName - Ini adalah teks yang sangat panjang untuk menguji layout',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Identitas
                Center(
                  child: Text(
                    '$studentId - $studentName',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // Ringkasan
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

                const SizedBox(height: 20),

                // Daftar course
                const Text(
                  'Daftar Course',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ...courses.map((course) {
                  final item =
                      course as Map<String, dynamic>;

                  final status =
                      item['status'] as String;

                  IconData icon;

                  if (status == 'done') {
                    icon = Icons.check_circle;
                  } else if (status == 'active') {
                    icon = Icons.play_circle;
                  } else {
                    icon = Icons.schedule;
                  }

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.pink.shade100,
                        child: Icon(
                          icon,
                          color: Colors.pink.shade700,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${item['code']} • ${item['credits']} SKS',
                      ),
                      trailing: Text(
                        status == 'done'
                            ? 'Selesai'
                            : status == 'active'
                                ? 'Aktif'
                                : 'Rencana',
                        style: TextStyle(
                          color: Colors.pink.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}