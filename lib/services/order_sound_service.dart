
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OrderSoundService {
  OrderSoundService._();

  static final OrderSoundService instance =
      OrderSoundService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'new_orders_foreground_v1';

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      channelId,
      'New Matching Orders',
      description: 'Sound alerts for new matching service orders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(channel);
    await android?.requestNotificationsPermission();
  }

  Future<void> showNewOrder({
    required String orderId,
    required String profession,
    required String problemType,
  }) async {
    await _notifications.show(
      id: orderId.hashCode,
      title: 'New $profession Order',
      body: problemType.isEmpty
          ? 'A new booking matches your services.'
          : 'New request: $problemType',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'New Matching Orders',
          channelDescription:
              'Sound alerts for new matching service orders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: orderId,
    );
  }
}
