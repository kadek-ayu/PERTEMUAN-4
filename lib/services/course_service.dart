
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/course.dart';

class CourseService {
  // Membaca dan mengubah JSON asset menjadi Map.
  // TAHAP 15 - KASUS C
  // Simulasi kegagalan pemuatan data.
  Future<Map<String, dynamic>> _loadJsonData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Memuat seluruh data yang diperlukan aplikasi.
  // Data courses diubah menjadi List<Course>.
  Future<Map<String, dynamic>> loadData() async {
    final data = await _loadJsonData();

    final list = data['courses'] as List<dynamic>;

    final courses = list
        .map(
          (item) => Course.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    return {
      'student': data['student'],
      'courses': courses,
    };
  }

  // TAHAP 9 - Service mengembalikan List<Course>.
  Future<List<Course>> loadCourses() async {
    final data = await _loadJsonData();

    final list = data['courses'] as List<dynamic>;

    return list
        .map(
          (item) => Course.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}