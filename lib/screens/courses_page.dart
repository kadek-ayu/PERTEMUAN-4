
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_form_page.dart';

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
      return ErrorView(
        message: 'Terjadi error: ${provider.error}',
        onRetry: provider.loadCourses,
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
                  IconButton(
                    tooltip: 'Tambah Course',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CourseFormPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.pink,
                      size: 30,
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

            if (provider.courses.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Data course belum tersedia'),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
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
