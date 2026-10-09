
import 'package:flutter/foundation.dart';

import 'models/course.dart';
import 'repositories/course_repository.dart';

// TAHAP 5 - CHANGE NOTIFIER
// TAHAP 10 - REPOSITORY PATTERN
class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState(this.repository);

  final Set<String> favorites = {};

  List<Course> courses = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCourses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    notifyListeners();
  }
}