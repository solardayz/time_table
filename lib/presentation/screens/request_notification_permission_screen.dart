import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class RequestNotificationPermissionScreen extends StatefulWidget {
  @override
  _RequestNotificationPermissionScreenState createState() => _RequestNotificationPermissionScreenState();
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
      // 권한이 허용되면 화면을 닫거나 다음 작업으로 진행
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알림 권한 요청"),
      ),
      body: Center(
        child: _isPermissionGranted
            ? Text("알림 권한이 이미 허용되었습니다.", style: TextStyle(fontSize: 18))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("앱에서 알림을 보내기 위해 알림 권한이 필요합니다.", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermission,
              child: Text("알림 권한 요청", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
