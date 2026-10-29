
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String apiUrl =
    'https://jsonplaceholder.typicode.com/posts';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  throw Exception('HTTP ${response.statusCode}');
}

Future<void> testFetchCourses() async {
  try {
    final courses = await fetchCourses();
    debugPrint('Jumlah data diterima: ${courses.length}');
  } catch (e) {
    debugPrint('Gagal mengambil data: $e');
  }
}
