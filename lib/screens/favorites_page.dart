import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class FavoritesPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const FavoritesPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteCourses = provider.favoriteCourses;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pink),
      );
    }

    if (favoriteCourses.isEmpty) {
      return const Center(
        child: Text('Belum ada course favorit'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: favoriteCourses.length,
      itemBuilder: (context, index) {
        return CourseCard(
          course: favoriteCourses[index],
          studentData: data,
        );
      },
    );
  }
}

