import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/router.dart';
import '../providers/auth_state_provider.dart';

/// FCM + local notification service.
/// High-priority data messages drive the alarm flow.
/// Tone family A selected for incoming orders.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;

  /// Holds the tap intent payload during cold-start
  String? _initialOrderUuid;

  static const _orderChannelId = 'pr_orders';
  static const _orderChannelName = 'New orders';

  Future<void> initialize({required ProviderContainer container}) async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      criticalAlert: Platform.isIOS,
    );

    // Keep alarm volume above media stream (MOB-RST-04)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications channel (Android O+)
    const androidChannel = AndroidNotificationChannel(
      _orderChannelId,
      _orderChannelName,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFF59E0B),
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handlePayload(details.payload, container);
      },
    );

    // FCM foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleFcmMessage(message, container, isForeground: true);
    });

    // FCM background tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleFcmMessage(message, container, isForeground: false);
    });

    // Cold start
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _initialOrderUuid = initial.data['order_uuid'] as String?;
    }
  }

  void _handleFcmMessage(
    RemoteMessage message,
    ProviderContainer container, {
    required bool isForeground,
  }) {
    final orderUuid = message.data['order_uuid'] as String?;
    if (orderUuid == null) return;

    if (isForeground) {
      // Show local notification to bring alarm overlay
      _showLocalAlarmNotification(orderUuid);
    }
  }

  Future<void> _showLocalAlarmNotification(String orderUuid) async {
    await _localNotifications.show(
      orderUuid.hashCode,
      'New Order!',
      'Tap to accept',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _orderChannelId,
          _orderChannelName,
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
          ledColor: const Color(0xFFF59E0B),
          ledOnMs: 1000,
          ledOffMs: 500,
          ticker: 'New order incoming',
        ),
      ),
      payload: orderUuid,
    );
  }

  void _handlePayload(String? payload, ProviderContainer container) {
    if (payload == null) return;
    // Navigate to alarm overlay
    // The router will handle this via deep-link navigation
    debugPrint('[FCM] Navigating to alarm/$payload');
  }

  Future<String?> getToken() => _messaging.getToken();

  String? consumeInitialOrderUuid() {
    final uuid = _initialOrderUuid;
    _initialOrderUuid = null;
    return uuid;
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService.instance,
);
