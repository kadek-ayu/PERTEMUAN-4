
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map(
          (e) => Course.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Pengguna belum login.');
    }

    final payload = course.toJson()
      ..remove('id');

    // Mengisi owner_id dengan ID pengguna yang sedang login.
    payload['owner_id'] = userId;

    final row = await supabase
        .from('courses')
        .insert(payload)
        .select()
        .single();

    return Course.fromJson(row);
  }

  @override
  Future<Course> updateCourse(int id, Course course) async {
    final payload = course.toJson()
      ..remove('id');

    final row = await supabase
        .from('courses')
        .update(payload)
        .eq('id', id)
        .select()
        .maybeSingle();

    if (row == null) {
      throw Exception(
        'Akses ditolak. Kamu tidak memiliki izin '
        'untuk memperbarui course ini.',
      );
    }

    return Course.fromJson(row);
  }

  @override
  Future<void> deleteCourse(int id) async {
    final deletedRows = await supabase
        .from('courses')
        .delete()
        .eq('id', id)
        .select('id');

    if (deletedRows.isEmpty) {
      throw Exception(
        'Akses ditolak. Kamu tidak memiliki izin '
        'untuk menghapus course ini.',
      );
    }
  }
}
