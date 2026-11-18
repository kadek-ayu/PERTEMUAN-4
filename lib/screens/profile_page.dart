
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/student_header.dart';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ProfilePage({
    super.key,
    required this.data,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _commentController = TextEditingController();

  final ProfileService _profileService = ProfileService();
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();

    _nameController.text = studentName;
    _nimController.text = studentId;

    _profileFuture = _profileService.getMyProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _commentController.dispose();

    super.dispose();
  }

  void _submitFeedback() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback berhasil dikirim'),
      ),
    );

    _commentController.clear();
  }

  Widget _buildAccountProfile() {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal mengambil profil: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Data profil belum ditemukan.'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${profile.name}'),
                const SizedBox(height: 8),
                Text('Email: ${profile.email}'),
                const SizedBox(height: 8),
                Text('Role: ${profile.role.toUpperCase()}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.data['student'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudentHeader(student: student),

          const SizedBox(height: 16),

          const Text(
            'Profil Akun Pengguna',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          _buildAccountProfile(),

          const SizedBox(height: 24),

          const Text(
            'Profil Mahasiswa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text('Nama: $studentName'),
          Text('NIM: $studentId'),

          const SizedBox(height: 24),

          const Text(
            'Formulir Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _nimController,
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIM wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Komentar',
                    hintText: 'Minimal 5 karakter',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Komentar minimal 5 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    child: const Text('Kirim Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
