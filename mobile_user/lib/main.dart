import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_user/app/core/api/auth_api.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/notif'),
    ),
  );
  print('Firebase initialized successfully');
  final messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("================================");
    print("TITLE: ${message.notification?.title}");
    print("BODY: ${message.notification?.body}");
    print("================================");

    await localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'impactin_channel',
          'ImpactIn Notifications',
          icon: '@drawable/notif',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  });

  final settings = await FirebaseMessaging.instance.requestPermission();

  print("AUTH STATUS: ${settings.authorizationStatus}");

  await messaging.requestPermission();

  final token = await messaging.getToken();

  print('FCM TOKEN: $token');

  FirebaseMessaging.instance.onTokenRefresh.listen(
    (newToken) async {
      print("================================");
      print("FCM TOKEN REFRESHED");
      print("NEW TOKEN: $newToken");
      print("================================");

      try {
        await AuthApi.saveFcmToken(newToken);

        print("FCM TOKEN UPDATED IN BACKEND");
      } catch (e) {
        print("FAILED TO UPDATE FCM TOKEN: $e");
      }
    },
  );

  await GetStorage.init();

  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      print("================================");
      print("NOTIFICATION TAPPED");
      print("TITLE: ${message.notification?.title}");
      print("BODY: ${message.notification?.body}");
      print("================================");
    },
  );

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    print("================================");
    print("APP OPENED FROM NOTIFICATION");
    print("TITLE: ${initialMessage.notification?.title}");
    print("BODY: ${initialMessage.notification?.body}");
    print("================================");
  }

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
