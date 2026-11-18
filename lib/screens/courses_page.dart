
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/profile_service.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_form_page.dart';

class CoursesPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const CoursesPage({
    super.key,
    required this.data,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

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

    if (!context.mounted || confirmed != true) return;

    try {
      await provider.deleteCourse(id);

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

  void _openAddCourse() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CourseFormPage(),
      ),
    );
  }

  void _openEditCourse(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseFormPage(
          course: course,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        final userRole = profileSnapshot.data?.role
                .toLowerCase()
                .trim() ??
            '';

        final canManageCourses =
            userRole == 'owner' || userRole == 'admin';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identitas mahasiswa
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIM: $studentId',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '♡',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Judul daftar course
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

                  // Tombol tambah hanya untuk owner dan admin
                  if (canManageCourses)
                    IconButton(
                      tooltip: 'Tambah Course',
                      onPressed: provider.isSaving ||
                              provider.isDeleting
                          ? null
                          : _openAddCourse,
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

            // Status data course
            if (provider.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.pink,
                  ),
                ),
              )
            else if (provider.error != null)
              Expanded(
                child: ErrorView(
                  message: 'Terjadi error: ${provider.error}',
                  onRetry: provider.loadCourses,
                ),
              )
            else if (provider.courses.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Data course belum tersedia'),
                ),
              )
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        columnsFor(constraints.maxWidth);

                    return GridView.builder(
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
                                studentData: widget.data,
                              ),
                            ),

                            // Tombol edit dan hapus
                            // hanya untuk owner dan admin
                            if (canManageCourses) ...[
                              Positioned(
                                top: 4,
                                right: 44,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: IconButton(
                                    tooltip: 'Edit ${course.code}',
                                    visualDensity:
                                        VisualDensity.compact,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.pink,
                                      size: 20,
                                    ),
                                    onPressed: provider.isSaving ||
                                            provider.isDeleting
                                        ? null
                                        : () {
                                            _openEditCourse(course);
                                          },
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 4,
                                right: 4,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: IconButton(
                                    tooltip: 'Hapus ${course.code}',
                                    visualDensity:
                                        VisualDensity.compact,
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
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Course tidak memiliki ID.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.red,
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
                          ],
                        );
                      },
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
