
import 'package:flutter/foundation.dart';

// TAHAP 5: CHANGE NOTIFIER DAN NOTIFY LISTENERS
// Class untuk mengelola state favorite course.
class CourseState extends ChangeNotifier {
  // Menyimpan ID course yang ditandai sebagai favorite.
  final Set<String> favorites = {};

  // Menambah atau menghapus course dari daftar favorite.
  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    // Memberi tahu widget listener bahwa state berubah.
    notifyListeners();
  }
}