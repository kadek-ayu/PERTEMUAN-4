
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

  // Error saat memuat ulang daftar setelah POST atau PUT.
  // Dipisahkan agar tidak dianggap sebagai kegagalan penyimpanan.
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

      // 2. Coba muat ulang daftar menggunakan GET.
      // Kegagalan GET tidak berarti POST gagal.
      try {
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;
      } catch (e) {
        refreshError = e.toString();
      }

      // 3. Kembalikan hasil POST ke halaman form.
      return createdCourse;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<Course> updateCourse(int id, Course course) async {
    if (isSaving) {
      throw Exception('Penyimpanan course sedang berlangsung.');
    }

    isSaving = true;
    error = null;
    refreshError = null;

    notifyListeners();

    try {
      // 1. Kirim perubahan menggunakan HTTP PUT.
      final updatedCourse = await repository.updateCourse(id, course);

      // 2. Coba muat ulang daftar menggunakan GET.
      // Jika GET gagal, hasil PUT tetap dikembalikan.
      try {
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;
      } catch (e) {
        refreshError = e.toString();
      }

      // 3. Kembalikan hasil PUT ke halaman form.
      return updatedCourse;
    } catch (e) {
      // Menangani kegagalan permintaan PUT.
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
