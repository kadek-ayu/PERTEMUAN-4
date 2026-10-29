
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];

  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;

  String? error;
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
    if (isSaving || isDeleting) {
      throw Exception('Operasi course sedang berlangsung.');
    }

    isSaving = true;
    error = null;
    refreshError = null;

    notifyListeners();

    try {
      final createdCourse = await repository.createCourse(course);

      try {
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;
      } catch (e) {
        refreshError = e.toString();
      }

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
    if (isSaving || isDeleting) {
      throw Exception('Operasi course sedang berlangsung.');
    }

    isSaving = true;
    error = null;
    refreshError = null;

    notifyListeners();

    try {
      final updatedCourse =
          await repository.updateCourse(id, course);

      try {
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;
      } catch (e) {
        refreshError = e.toString();
      }

      return updatedCourse;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(int id) async {
    if (isSaving || isDeleting) {
      throw Exception('Operasi course sedang berlangsung.');
    }

    final courseIndex = courses.indexWhere(
      (course) => course.id == id,
    );

    if (courseIndex == -1) {
      throw Exception('Course tidak ditemukan.');
    }

    final course = courses[courseIndex];

    isDeleting = true;
    error = null;
    refreshError = null;

    notifyListeners();

    try {
      // 1. Kirim permintaan DELETE ke API.
      await repository.deleteCourse(id);

      // 2. Hapus course dari daftar lokal.
      courses.removeWhere((item) => item.id == id);

      // 3. Hapus juga favorite berdasarkan kode course.
      favorites.remove(course.code);

      // 4. Coba sinkronkan ulang daftar dari API.
      // Kegagalan GET tidak membatalkan DELETE yang berhasil.
      try {
        final loadedCourses = await repository.getCourses();
        courses = loadedCourses;

        // Bersihkan favorite yang tidak lagi ada di daftar.
        final validCodes = courses
            .map((item) => item.code)
            .toSet();

        favorites.removeWhere(
          (code) => !validCodes.contains(code),
        );
      } catch (e) {
        refreshError = e.toString();
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
