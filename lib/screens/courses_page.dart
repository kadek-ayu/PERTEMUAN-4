
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class CoursesPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const CoursesPage({
    super.key,
    required this.data,
  });

  int columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Terjadi error: ${provider.error}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: provider.loadCourses,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Course',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.favorite,
                    color: Colors.pink,
                  ),
                  const SizedBox(width: 4),
                  Text('${provider.favorites.length}'),
                ],
              ),
            ),
            Expanded(
              child: provider.courses.isEmpty
                  ? const Center(
                      child: Text('Belum ada course'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 150,
                      ),
                      itemCount: provider.courses.length,
                      itemBuilder: (context, index) {
                        final course = provider.courses[index];

                        return CourseCard(
                          course: course,
                          studentData: data,
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