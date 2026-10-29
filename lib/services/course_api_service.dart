
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';
import 'course_data_source.dart';

class CourseApiService implements CourseDataSource {
  final String baseUrl;

  CourseApiService(this.baseUrl);

  @override
  Future<List<Course>> getCourses() async {
    final uri = Uri.parse(baseUrl);

    debugPrint('GET URL: $uri');

    final response = await http.get(uri);

    debugPrint('GET STATUS: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data course: '
        'HTTP ${response.statusCode}. '
        'Respons: ${response.body}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    return data.map((item) {
      final post = item as Map<String, dynamic>;

      return Course(
        id: post['id'] as int?,
        code: 'POST-${post['userId']}',
        title: post['title'] as String? ?? '',
        credits: 0,
        status: 'planned',
      );
    }).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final uri = Uri.parse(baseUrl);

    debugPrint('POST URL: $uri');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    debugPrint('POST STATUS: ${response.statusCode}');
    debugPrint('POST RESPONSE: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Gagal menambahkan course: '
      'HTTP ${response.statusCode}. '
      'Respons: ${response.body}',
    );
  }

  @override
  Future<Course> updateCourse(int id, Course course) async {
    final uri = Uri.parse('$baseUrl/$id');

    debugPrint('PUT URL: $uri');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    debugPrint('PUT STATUS: ${response.statusCode}');
    debugPrint('PUT RESPONSE: ${response.body}');

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Gagal memperbarui course: '
      'HTTP ${response.statusCode}. '
      'Respons: ${response.body}',
    );
  }

  @override
  Future<void> deleteCourse(int id) async {
    final uri = Uri.parse('$baseUrl/$id');

    debugPrint('DELETE URL: $uri');

    final response = await http.delete(uri);

    debugPrint('DELETE STATUS: ${response.statusCode}');
    debugPrint('DELETE RESPONSE: ${response.body}');

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal menghapus course: '
        'HTTP ${response.statusCode}. '
        'Respons: ${response.body}',
      );
    }
  }
}
