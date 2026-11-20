
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  /// Meminta izin notifikasi dan mengembalikan statusnya:
  /// authorized | provisional | denied | notDetermined
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final status = settings.authorizationStatus;

    debugPrint(
      'Notification permission: ${status.name}',
    );

    return status;
  }
}
