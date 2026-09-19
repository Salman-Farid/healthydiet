import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/food_tips.dart';

/// Daily food-tip notifications (FitBook 2026).
///
/// - Unique tip + **matching** photo per day
/// - Title is plain text (no emoji prefix)
/// - Small/large icon = **app icon** (keep launcher logo)
/// - Expanded banner = food photo (letterboxed / fit, not cropped)
class FoodNotificationService {
  FoodNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _inited = false;
  static bool _pluginMissing = false;
  static bool get pluginMissing => _pluginMissing;

  static const int _baseId = 909000;
  static const int _daysAhead = 14;

  static const String _channelId = 'food_tips_daily';
  static const String _channelName = 'Daily food tips';
  static const String _channelDesc = 'Everyday 9:00 food tips with a photo';

  static const String _prefAsked = 'food_notif_permission_asked';
  static const String _prefEnabled = 'food_notif_9am_enabled';

  static int _testCursor = 0;

  static Future<void> bootOnLaunch() async {
    try {
      await init();
      if (_pluginMissing) {
        debugPrint(
            'Food tips: native plugin missing — flutter clean && flutter run');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool(_prefAsked) ?? false;
      if (!alreadyAsked) {
        await _requestPermissionOnce();
        await prefs.setBool(_prefAsked, true);
      }

      final allowed = await _notificationsAllowed();
      if (allowed) {
        await scheduleDaily(hour: 9, minute: 0);
        await prefs.setBool(_prefEnabled, true);
        debugPrint('Food tips: scheduled ${_daysAhead} unique 9:00 AM tips');
      } else {
        debugPrint('Food tips: notifications blocked in system settings');
      }
    } catch (e) {
      debugPrint('bootOnLaunch: $e');
    }
  }

  static Future<void> init() async {
    if (_inited) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
        } catch (_) {
          tz.setLocalLocation(tz.UTC);
        }
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      try {
        await androidImpl?.createNotificationChannel(_androidChannel());
      } catch (_) {}

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _inited = true;
    } catch (e) {
      _pluginMissing = e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found');
      debugPrint('FoodNotificationService init: $e');
    }
  }

  static Future<void> _requestPermissionOnce() async {
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        try {
          await androidImpl.requestNotificationsPermission();
        } catch (_) {}
        try {
          await androidImpl.createNotificationChannel(_androidChannel());
        } catch (_) {}
      }
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('requestPermissionOnce: $e');
    }
  }

  static Future<bool> _notificationsAllowed() async {
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final enabled = await androidImpl.areNotificationsEnabled();
        return enabled != false;
      }
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final perms = await iosImpl.checkPermissions();
        return perms?.isEnabled ?? true;
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  /// App icon on the notification; food photo only in the expanded picture.
  static NotificationDetails _details({
    String? foodPicturePath,
    required String title,
    required String body,
  }) {
    final android = foodPicturePath != null
        ? AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            // Keep app logo as the notification icon.
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(foodPicturePath),
              contentTitle: title,
              summaryText: body,
              // Do not put food photo in largeIcon — that caused mismatch UI.
              hideExpandedLargeIcon: true,
            ),
          )
        : const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios);
  }

  static AndroidNotificationChannel _androidChannel() {
    return const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
  }

  /// Unique cache key per URL (old code used first 40 chars → all milk.png).
  static String _cacheKeyFor(String url) {
    final file = url.split('/').last.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final hash = url.hashCode.toRadixString(16);
    return '${file}_$hash'.substring(0, (file.length + 10).clamp(8, 80));
  }

  /// Download + letterbox on white square → photo is FIT (not cropped).
  static Future<String?> _downloadImage(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final key = _cacheKeyFor(url);
      final fitted = File('${dir.path}/food_tip_fit_$key.png');
      if (await fitted.exists() && await fitted.length() > 200) {
        return fitted.path;
      }

      final resp =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final bytes = resp.bodyBytes;
      if (bytes.isEmpty) return null;

      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        final raw = File('${dir.path}/food_tip_raw_$key.jpg');
        await raw.writeAsBytes(bytes, flush: true);
        return raw.path;
      }

      const side = 512;
      final canvas = img.Image(width: side, height: side);
      img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

      final scaleW = side / decoded.width;
      final scaleH = side / decoded.height;
      final scale = scaleW < scaleH ? scaleW : scaleH;
      final w = (decoded.width * scale).round().clamp(1, side);
      final h = (decoded.height * scale).round().clamp(1, side);
      final resized = img.copyResize(decoded, width: w, height: h);
      final x = ((side - w) / 2).round();
      final y = ((side - h) / 2).round();
      img.compositeImage(canvas, resized, dstX: x, dstY: y);

      final png = img.encodePng(canvas);
      await fitted.writeAsBytes(png, flush: true);
      return fitted.path;
    } catch (e) {
      debugPrint('food notif image: $e');
      return null;
    }
  }

  /// Title has **no emoji** — body explains the food; banner photo must match.
  static Future<void> _showTip(FoodTip tip, {int id = 909099}) async {
    final path = await _downloadImage(tip.imageUrl);
    final title = tip.title; // e.g. "Have some walnuts"
    final body = tip.body; // e.g. "Eat some walnuts about 30g/day…"
    await _plugin.show(
      id,
      title,
      body,
      _details(foodPicturePath: path, title: title, body: body),
    );
    debugPrint('Notif $id → $title | image=$path | url=${tip.imageUrl}');
  }

  /// One **unique** tip + photo per day at [hour]:[minute] for the next 14 days.
  static Future<void> scheduleDaily({int hour = 9, int minute = 0}) async {
    await init();
    if (!_inited || _pluginMissing) return;

    // Clear old schedule first (stale milk-only payloads).
    await cancel();

    final now = tz.TZDateTime.now(tz.local);
    final prefs = await SharedPreferences.getInstance();

    for (var d = 0; d < _daysAhead; d++) {
      final fire = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + d,
        hour,
        minute,
      );
      if (!fire.isAfter(now)) continue;

      final day = DateTime(fire.year, fire.month, fire.day);
      final tip = FoodTips.tipForDate(day);
      final id = _baseId + d;
      // Image is fetched **from this tip's URL only**.
      final path = await _downloadImage(tip.imageUrl);
      final title = tip.title;
      final body = tip.body;

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          fire,
          _details(foodPicturePath: path, title: title, body: body),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'food_tip_d${d}_${tip.imageUrl}',
        );
      } catch (e) {
        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            fire,
            _details(foodPicturePath: null, title: title, body: body),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'food_tip_d${d}_${tip.imageUrl}',
          );
        } catch (e2) {
          debugPrint('scheduleDaily d=$d failed: $e / $e2');
          _pluginMissing = e.toString().contains('MissingPluginException') ||
              e.toString().contains('No implementation found');
        }
      }
      debugPrint('Sched +$d $fire | $title | $path');
    }

    await prefs.setBool(_prefEnabled, true);
  }

  /// Test button — cycles foods; each tip gets its **own** matching photo.
  static Future<bool> showTestTip() async {
    try {
      await init();
      if (_pluginMissing) return false;
      await _requestPermissionOnce();
      final tip = FoodTips.tipAt(_testCursor++);
      await _showTip(tip, id: 909099);
      return true;
    } catch (e) {
      debugPrint('showTestTip: $e');
      _pluginMissing = e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found');
      return false;
    }
  }

  static Future<void> cancel() async {
    for (var d = 0; d < 30; d++) {
      try {
        await _plugin.cancel(_baseId + d);
      } catch (_) {}
    }
  }

  static Future<bool> isScheduled() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.isNotEmpty;
  }
}
