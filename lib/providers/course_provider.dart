
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];

  bool isLoading = false;
  bool isSaving = false;

  String? error;

  // Error saat memuat ulang daftar setelah POST.
  // Dipisahkan agar tidak dianggap sebagai kegagalan POST.
  String? refreshError;

  final Set<String> favorites = {};

  bool isFavorite(String code) {
    return favorites.contains(code);
  }

  void toggleFavorite(String code) {
    if (favorites.contains(code)) {
      favorites.remove(code);
    } else {
      favorites.add(code);
    }

    notifyListeners();
  }

  List<Course> get favoriteCourses {
    return courses
        .where((course) => favorites.contains(course.code))
        .toList();
  }

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    refreshError = null;

    notifyListeners();

    try {
      final loadedCourses = await repository.getCourses();
      courses = loadedCourses;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Course> createCourse(Course course) async {
    if (isSaving) {
      throw Exception('Penyimpanan course sedang berlangsung.');
    }

    isSaving = true;
    error = null;
    refreshError = null;

    notifyListeners();

    try {
      // 1. Kirim course baru menggunakan HTTP POST.
      final createdCourse = await repository.createCourse(course);

      // 2. Setelah POST berhasil, coba muat ulang daftar menggunakan GET.
      // Jika GET gagal, jangan menganggap POST ikut gagal.
      try {
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;
      } catch (e) {
        refreshError = e.toString();
      }

      // 3. Kembalikan hasil POST kepada halaman form.
      return createdCourse;
    } catch (e) {
      // Bagian ini menangani kegagalan saat POST.
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
