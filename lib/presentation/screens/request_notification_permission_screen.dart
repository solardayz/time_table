import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class RequestNotificationPermissionScreen extends StatefulWidget {
  @override
  _RequestNotificationPermissionScreenState createState() =>
      _RequestNotificationPermissionScreenState();
}

class _RequestNotificationPermissionScreenState extends State<RequestNotificationPermissionScreen> {
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    setState(() {
      _isPermissionGranted = isAllowed;
    });
  }

  void _requestPermission() async {
    bool result = await AwesomeNotifications().requestPermissionToSendNotifications();
    setState(() {
      _isPermissionGranted = result;
    });
    if (result) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pastelGradient = LinearGradient(
      colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: pastelGradient),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_active, size: 48, color: Colors.pinkAccent),
                  const SizedBox(height: 16),
                  Text(
                    _isPermissionGranted
                        ? "알림 권한이 이미 허용되어 있어요!"
                        : "시간표 알림을 받으시려면\n알림 권한을 허용해주세요 💌",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  if (!_isPermissionGranted)
                    ElevatedButton(
                      onPressed: _requestPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text("알림 권한 요청", style: TextStyle(fontSize: 16)),
                    ),
                  if (_isPermissionGranted)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("돌아가기", style: TextStyle(color: Colors.pink)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
