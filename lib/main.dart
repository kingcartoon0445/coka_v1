import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coka/api/user.dart';
import 'package:coka/screen/overlay_widget.dart';
import 'package:coka/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'constants.dart';
import 'firebase_options.dart';
import 'list_route.dart';
import 'noti.dart';

bool isLogin = false;
bool isRegister = false;
bool isNullOrg = false;
int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'coka_notification', // id
    'coka_notification', // title
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound("notify"));

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

const String navigationActionId = 'id_3';
String? selectedNotificationPayload;
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CustomerOverlayWidget(),
  ));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("========== Background Notify ==========");

  print(message.data);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FlutterOverlayWindow.shareData(message.data);
  // FlutterOverlayWindow.showOverlay(
  //   height: 600,
  //   enableDrag: true,
  //   positionGravity: PositionGravity.auto,
  // );

  _showNotification(message.data);
}

Future<void> _showNotification(message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('coka_notification', 'coka_notification',
          channelDescription: 'Check',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound("notify"));
  NotificationDetails notificationDetails = const NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      ));
  await flutterLocalNotificationsPlugin.show(
      id++, message['title'], message['body'], notificationDetails,
      payload: jsonEncode(message));
}

Future sendToken() async {
  try {
    // 检查 Firebase 是否已初始化
    if (Firebase.apps.isEmpty) {
      print("Firebase chưa được khởi tạo, bỏ qua việc lấy FCM token");
      return;
    }

    // 检查通知权限状态（仅在 iOS 上需要）
    if (Platform.isIOS) {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        print("Thông báo chưa được cấp quyền, bỏ qua việc lấy FCM token");
        return;
      }
    }

    // 获取 FCM token，添加错误处理
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null && fcmToken.isNotEmpty) {
      print("FCM Token: $fcmToken");
      UserApi().updateFcmToken({
        "deviceId": await getDeviceId(),
        "version": await getVersion(),
        "fcmToken": fcmToken,
        "status": 1
      });
    } else {
      print("Không thể lấy FCM token: token rỗng");
    }
  } catch (e) {
    // 捕获并记录错误，但不中断应用运行
    print("Lỗi khi lấy FCM token: $e");
    // 在某些平台（如 iOS 模拟器）上，FCM 可能不可用
    // 这是正常的，不应该中断应用
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  _configureLocalTimeZone();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // prefs.setString('accessToken',
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNkZmEzM2FhLWQ3ODMtNGU5MC1hMzY0LTU3ZjkzYzFjZTQzNiIsInByb2ZpbGVJZCI6IjllMGZkNTc3LWM1ZWUtNDkxMC1hMWY5LTQ2ZDA4ZDk2NzVkMiIsImVtYWlsIjoicGh1b25nbGRAYXp2aWRpLnZuIiwianRpIjoiMTNiMmRmM2EtMDAzYy00ODQ4LWI2MGItOGZhZDVkYzMwZWJjIiwiZXhwIjoxNzAwOTk4NTQzLCJpc3MiOiJodHRwczovL2FwaS5jb2thLmFpIiwiYXVkIjoiaHR0cHM6Ly9hcGkuY29rYS5haSJ9.PI3ucj7Cw75cxe85-PeRkJDgPZG0ZghWRlpbXHtbnSQ");
  // prefs.setString('refreshToken',
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNkZmEzM2FhLWQ3ODMtNGU5MC1hMzY0LTU3ZjkzYzFjZTQzNiIsInByb2ZpbGVJZCI6IjllMGZkNTc3LWM1ZWUtNDkxMC1hMWY5LTQ2ZDA4ZDk2NzVkMiIsImVtYWlsIjoicGh1b25nbGRAYXp2aWRpLnZuIiwianRpIjoiMTNiMmRmM2EtMDAzYy00ODQ4LWI2MGItOGZhZDVkYzMwZWJjIiwiZXhwIjoxNzAwOTk4NTQzLCJpc3MiOiJodHRwczovL2FwaS5jb2thLmFpIiwiYXVkIjoiaHR0cHM6Ly9hcGkuY29rYS5haSJ9.PI3ucj7Cw75cxe85-PeRkJDgPZG0ZghWRlpbXHtbnSQ");

  try {
    if (prefs.getString('accessToken') != null) {
      print(prefs.getString('accessToken'));
      isLogin = true;
      // var response = await UserApi().getProfile();
      // if (isSuccessStatus(response['code'])) {
      //   prefs.setString('uid', response['content']['id']);
      //   prefs.setString('userData', jsonEncode(response['content']));
      //   if (response['content']["fullName"] == response['content']["email"] ||
      //       response['content']["fullName"] == response['content']["phone"]) {
      //     isRegister = true;
      //   }
      //   final organList = await fetchOrganList();
      //   if (organList.length == 0) {
      //     isNullOrg = true;
      //   } else {
      //     if ((await getOData()) == null) {
      //       prefs.setString('oId', organList[0]['id']);
      //       prefs.setString('oData', jsonEncode(organList[0]));
      //     }
      //   }
      // }
    }
  } catch (e) {
    prefs.clear();
    isLogin = false;
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await FirebaseAnalytics.instance.logBeginCheckout();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // /// check if overlay permission is granted
    // final bool status = await FlutterOverlayWindow.isPermissionGranted();
    //
    // /// request overlay permission
    // /// it will open the overlay settings page and return `true` once the permission granted.
    // if (!status) {
    //   await FlutterOverlayWindow.requestPermission();
    // }
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.subscribeToTopic('allDevice');
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    Noti.initialize(flutterLocalNotificationsPlugin);
    // 使用 unawaited 或 try-catch 来避免未处理的异常
    // sendToken 内部已经有错误处理，所以可以安全地异步调用
    sendToken().catchError((error) {
      print("Lỗi khi gửi FCM token: $error");
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print(e);
  }
  runApp(const MyApp());
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isInForeground = true;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: !isLogin
            ? '/login'
            : isRegister
                ? "/register"
                : isNullOrg
                    ? "/createPOrg"
                    : '/main',
        getPages: listRoute,
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        title: 'Coka',
        theme: theme(context),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('en'),
        ],
      ),
    );
  }
}
