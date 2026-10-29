
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/course.dart';


const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

Future<List<Course>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final List<dynamic> jsonList =
        jsonDecode(response.body) as List<dynamic>;

    return jsonList.map((json) {
      final post = json as Map<String, dynamic>;

      return Course(
        id: post['id'] as int?,
        code: 'POST-${post['userId']}',
        title: post['title'] as String? ?? '',
        credits: 0,
        status: 'planned',
      );
    }).toList();
  }

  throw Exception('HTTP ${response.statusCode}');
}

Future<void> testFetchCourses() async {
  try {
    final courses = await fetchCourses();

    debugPrint('Jumlah data diterima: ${courses.length}');

    for (final course in courses.take(3)) {
      debugPrint(
        'Code: ${course.code}, '
        'Title: ${course.title}, '
        'Status: ${course.status}',
      );
    }
  } catch (e) {
    debugPrint('Gagal mengambil data: $e');
  }
}
void testCourseJson() {
  const course = Course(
    id: 1,
    code: 'MOB01',
    title: 'Git & GitHub',
    credits: 2,
    status: 'done',
  );

  final json = course.toJson();
  final restoredCourse = Course.fromJson(json);

  debugPrint('Hasil toJson: $json');
  debugPrint('Hasil fromJson: ${restoredCourse.code}');
  debugPrint('Status course: ${restoredCourse.status}');
}
