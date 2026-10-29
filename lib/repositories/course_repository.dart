
import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  // Mengambil daftar course.
  Future<List<Course>> getCourses() {
    return service.getCourses();
  }

  // Membuat course baru.
  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }

  // Memperbarui course yang sudah ada.
  Future<Course> updateCourse(int id, Course course) {
    return service.updateCourse(id, course);
  }
}
