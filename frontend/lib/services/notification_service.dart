import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// ---------------------------------------------------------------------------
/// NotificationService : Gère les rappels locaux (ex : rappel après 2 heures
/// pour inviter l'utilisateur à faire son quiz et maintenir sa série).
/// ---------------------------------------------------------------------------
class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  static const int reminderNotificationId = 1001;
  static const String _prefEnabledKey = 'notification_reminder_enabled';
  static const String _prefHoursKey = 'notification_reminder_hours';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _enabled = true;
  int _delayHours = 2; // Par défaut : rappel après 2 heures

  bool get isEnabled => _enabled;
  int get delayHours => _delayHours;

  /// Initialisation du service au démarrage de l'application
  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefEnabledKey) ?? true;
      _delayHours = prefs.getInt(_prefHoursKey) ?? 2;

      // Initialisation de la base de données de fuseaux horaires
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings: initSettings);

      // Demande de permission sur Android 13+ (API 33+)
      if (!kIsWeb && Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _initialized = true;
      notifyListeners();

      // Si le rappel est activé, planifier le rappel par défaut
      if (_enabled) {
        await scheduleReminder(hours: _delayHours);
      }
    } catch (e) {
      debugPrint('NotificationService init error (safe fallback): $e');
    }
  }

  /// Active ou désactive les rappels
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnabledKey, value);

      if (value) {
        await scheduleReminder(hours: _delayHours);
      } else {
        await cancelReminder();
      }
    } catch (_) {}
  }

  /// Modifie l'intervalle d'heures du rappel (ex: 2 heures)
  Future<void> setDelayHours(int hours) async {
    if (hours < 1) hours = 1;
    _delayHours = hours;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefHoursKey, hours);

      if (_enabled) {
        await scheduleReminder(hours: _delayHours);
      }
    } catch (_) {}
  }

  /// Planifie une notification de rappel après [hours] heures (par défaut 2 heures)
  Future<void> scheduleReminder({
    int? hours,
    String? title,
    String? body,
  }) async {
    if (!_enabled) return;
    final int delay = hours ?? _delayHours;

    try {
      // Annule l'ancien rappel s'il y en avait un
      await _plugin.cancel(id: reminderNotificationId);

      final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(hours: delay));

      const androidDetails = AndroidNotificationDetails(
        'quiz_reminders',
        'Rappels Quiz',
        channelDescription: 'Rappels réguliers pour vous entraîner et maintenir votre série.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notifTitle = title ?? 'C\'est l\'heure de votre Quiz ! 🌙';
      final notifBody = body ??
          'Prenez 2 minutes pour tester vos connaissances et conserver votre série de jours.';

      await _plugin.zonedSchedule(
        id: reminderNotificationId,
        title: notifTitle,
        body: notifBody,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      debugPrint('Rappel quiz planifié pour dans $delay heure(s) à $scheduledDate');
    } catch (e) {
      debugPrint('Erreur lors de la planification du rappel : $e');
    }
  }

  /// Annule le rappel planifié
  Future<void> cancelReminder() async {
    try {
      await _plugin.cancel(id: reminderNotificationId);
    } catch (_) {}
  }

  /// Affiche immédiatement une notification de test
  Future<void> showTestNotification({
    String? title,
    String? body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'quiz_reminders',
        'Rappels Quiz',
        channelDescription: 'Rappels réguliers pour continuer le quiz.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id: 999,
        title: title ?? 'Rappel Quiz Islamique 🌙',
        body: body ?? 'Votre rappel fonctionne parfaitement ! Prêt pour le quiz ?',
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Erreur affichage notification test : $e');
    }
  }
}
