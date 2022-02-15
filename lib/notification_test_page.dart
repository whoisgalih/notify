import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:notify/finish_page.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({Key? key}) : super(key: key);

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onSelectNotification: _onSelectNotification,
    );
  }

  void _sendNotification(int id, String title, String body) {
    const androidPlatfromChannelSpesifics = AndroidNotificationDetails(
      'notification_channel_id',
      'notification_added',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      playSound: true,
    );
    const platfromChannelSpesifics =
        NotificationDetails(android: androidPlatfromChannelSpesifics);
    flutterLocalNotificationsPlugin!.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      platfromChannelSpesifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _onSelectNotification(String? payload) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const FinishPage()));
    _gpnr();
  }

  List<PendingNotificationRequest>? _pendingNotification;

  void _gpnr() async {
    List<PendingNotificationRequest>? pendingNotification =
        await flutterLocalNotificationsPlugin?.pendingNotificationRequests();

    if (pendingNotification != null) {
      setState(() {
        _pendingNotification = pendingNotification;
      });
    }
  }

  List<Widget> _createWidgetFromGPNR(
      List<PendingNotificationRequest>? pendingNotification) {
    if (pendingNotification != null) {
      final x = pendingNotification
          .map((e) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${e.id}'),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,
                      ),
                      onPressed: () {
                        flutterLocalNotificationsPlugin?.cancel(e.id);
                        _gpnr();
                        setState(() {
                          _timer.cancel();
                          _start = 10;
                          _isTimerRunning = false;
                        });
                      },
                      child: const Text('Cancel')),
                ],
              ))
          .toList();
      return x;
    } else {
      return [const SizedBox()];
    }
  }

  int _id = 0;

  late Timer _timer;
  int _start = 10;
  bool _isTimerRunning = false;
  bool _isNotificationSent = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    try {
      if (_timer.isActive) {
        _timer.cancel();
      }
    } catch (e) {}
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isTimerRunning = false;
            _gpnr();
            _isNotificationSent = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  late Timer _refreshTimer;

  void refresherTimer() {
    try {
      if (_refreshTimer.isActive) {
        _refreshTimer.cancel();
      }
    } catch (e) {}
    ;

    _refreshTimer = Timer(const Duration(seconds: 15), () {
      _gpnr();
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/Push notifications-rafiki (1).svg',
                  height: 300),
              const Text(
                'Notification check',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text('Check whether you can receive notification',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  )),
              const SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _isTimerRunning
                      ? 'You should receive notification in $_start'
                      : (_isNotificationSent
                          ? 'Notification should have been sent. Please click the notification or send new notification'
                          : 'You haven\'t sent notification yet'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              SizedBox(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                      ),
                      onPressed: () {
                        _sendNotification(_id, 'Notification Test Succes',
                            'Click here to end the application setup');
                        setState(() {
                          _id += 1;
                          _start = 10;
                          _isTimerRunning = true;
                        });
                        refresherTimer();
                        startTimer();
                        _gpnr();
                      },
                      child: const Text('Send Notification',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          )))),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(
                    left: 28, right: 28, bottom: 12, top: 24),
                child: (_pendingNotification != null) &&
                        (_pendingNotification!.isNotEmpty)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notification id',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              flutterLocalNotificationsPlugin?.cancelAll();
                              _gpnr();
                              setState(() {
                                _timer.cancel();
                                _start = 10;
                                _isTimerRunning = false;
                              });
                            },
                            child: const Text('Cancel All',
                                style: TextStyle(color: Colors.redAccent)),
                          )
                        ],
                      )
                    : const SizedBox(),
              ),
              (_pendingNotification != null) &&
                      (_pendingNotification!.isNotEmpty)
                  ? Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              children:
                                  _createWidgetFromGPNR(_pendingNotification),
                            ),
                          )),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
