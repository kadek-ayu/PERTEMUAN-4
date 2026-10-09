import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/course.dart';
import '../widgets/student_header.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;
  final Map<String, dynamic> studentData;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    final student =
        studentData['student'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudentHeader(student: student),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Kode Course: ${course.code}'),
                    const SizedBox(height: 8),
                    Text('Jumlah SKS: ${course.credits}'),
                    const SizedBox(height: 8),
                    Text('Status: ${course.status}'),
                    const Divider(height: 32),
                    const Text(
                      'Identitas Mahasiswa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Nama: $studentName'),
                    Text('NIM: $studentId'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

