
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

import '../screens/course_detail_page.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final Map<String, dynamic> studentData;

  const CourseCard({
    super.key,
    required this.course,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final isFavorite = provider.favorites.contains(course.code);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                course: course,
                studentData: studentData,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                course.status.toLowerCase() == 'selesai'
                    ? Icons.check_circle
                    : Icons.menu_book,
                color: course.status.toLowerCase() == 'selesai'
                    ? Colors.green
                    : Colors.pink,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(course.code),
                    Text('${course.credits} SKS · ${course.status}'),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambahkan ke favorit',
                onPressed: () {
                  provider.toggleFavorite(course.code);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.pink : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}