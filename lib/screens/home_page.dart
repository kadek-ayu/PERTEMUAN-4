import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/student_header.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> data;

  const HomePage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final courses = courseProvider.courses;

    final completedCourses = courses
        .where((course) => course.status.toLowerCase() == 'done')
        .length;

    final student = data['student'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudentHeader(student: student),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Belajar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              size: 32,
                              color: Colors.pink,
                            ),
                            const SizedBox(height: 8),
                            const Text('Total Course'),
                            const SizedBox(height: 4),
                            Text(
                              '${courses.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 32,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            const Text('Selesai'),
                            const SizedBox(height: 4),
                            Text(
                              '$completedCourses',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

