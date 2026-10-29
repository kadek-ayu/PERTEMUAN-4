
import '../models/course.dart';
import '../services/course_data_source.dart';

class CourseRepository {
  final CourseDataSource dataSource;

  CourseRepository(this.dataSource);

  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return dataSource.createCourse(course);
  }

  Future<Course> updateCourse(int id, Course course) {
    return dataSource.updateCourse(id, course);
  }

  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}
