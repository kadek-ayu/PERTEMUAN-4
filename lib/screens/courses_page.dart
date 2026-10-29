
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

  Future<void> _confirmDelete(
    BuildContext context,
    CourseProvider provider,
    int id,
    String code,
    String title,
  ) async {
    // Tampilkan dialog konfirmasi terlebih dahulu.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Course?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '"$title" ($code)?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Jangan lanjut jika pengguna membatalkan atau widget sudah tidak aktif.
    if (!context.mounted || confirmed != true) return;

    try {
      await provider.deleteCourse(id);

      // Periksa mounted setelah operasi asynchronous sebelum SnackBar.
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "$title" berhasil dihapus.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus course: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CourseCard(
                            course: course,
                            studentData: data,
                          ),
                        ),

                        // Tombol Edit.
                        Positioned(
                          top: 4,
                          right: 44,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              tooltip: 'Edit ${course.code}',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.pink,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CourseFormPage(
                                      course: course,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Tombol Delete.
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              tooltip: 'Hapus ${course.code}',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: provider.isDeleting ||
                                      provider.isSaving
                                  ? null
                                  : () {
                                      final id = course.id;

                                      if (id == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Course tidak memiliki ID.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      _confirmDelete(
                                        context,
                                        provider,
                                        id,
                                        course.code,
                                        course.title,
                                      );
                                    },
                            ),
                          ),
                        ),
                      ],
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
