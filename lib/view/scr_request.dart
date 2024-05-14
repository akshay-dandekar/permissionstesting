import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWidgetInfo {
  final String title;
  final String description;
  final List<Permission> perm;
  bool? isGranted;

  PermissionWidgetInfo(this.title, this.description, this.perm);

  Future<bool> request() async {
    for (Permission p in perm) {
      await p.request();
    }
    return await checkIsGranted();
  }

  Future<bool> checkIsGranted() async {
    bool _isGranted = true;

    for (Permission p in perm) {
      _isGranted &= await p.isGranted;
    }

    isGranted = _isGranted;

    return _isGranted;
  }
}

class RequestPermissionScreen extends StatefulWidget {
  const RequestPermissionScreen({super.key});

  @override
  State<RequestPermissionScreen> createState() =>
      _RequestPermissionScreenState();
}

class _RequestPermissionScreenState extends State<RequestPermissionScreen> {
  static final List<PermissionWidgetInfo> _permInfos = [
    PermissionWidgetInfo(
        "Location",
        "This is required for GeoFence feature of the app",
        [Permission.location, Permission.locationAlways]),
    PermissionWidgetInfo(
        "SMS",
        "This is required for sending updates to caregiver(s) in case of emergency and otherwise",
        [Permission.sms]),
    PermissionWidgetInfo(
        "CALL",
        "This is required for calling a caregiver in case of emergency",
        [Permission.phone]),
    PermissionWidgetInfo(
        "CAMERA",
        "This is required for scanning QR code while onboarding",
        [Permission.camera]),
    PermissionWidgetInfo(
        "BLUETOOTH",
        "This is required for connecting to Amicane and full operation of the stick",
        [
          Permission.bluetooth,
          Permission.bluetoothConnect,
          Permission.bluetoothScan
        ]),
  ];

  bool _checkIfAllGranted() {
    bool allGranted = true;

    for (PermissionWidgetInfo p in _permInfos) {
      allGranted &= p.isGranted == null ? false : p.isGranted!;
    }

    print("All granted $allGranted");

    return allGranted;
  }

  List<Widget> _getPermissionWidgets(BuildContext context) {
    List<Widget> permWidgets = [];

    for (PermissionWidgetInfo p in _permInfos) {
      permWidgets.add(Row(children: [
        SizedBox(
          width: 280,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title,
                textAlign: TextAlign.left,
              ),
              Text(p.description,
                  textAlign: TextAlign.left, overflow: TextOverflow.clip),
            ],
          ),
        ),
        FilledButton(
            onPressed: p.isGranted == null
                ? null
                : (p.isGranted!
                    ? null
                    : () async {
                        print("Requesting permission for $p.perm");
                        await p.request();
                        await p.checkIsGranted();
                        setState(() {});
                      }),
            child: p.isGranted == null
                ? const CircularProgressIndicator()
                : p.isGranted!
                    ? const Text("Granted")
                    : const Text("Grant")),
      ]));
    }
    return permWidgets;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (PermissionWidgetInfo p in _permInfos) {
      Future.delayed(const Duration(seconds: 1), () async {
        print("Checking permissions for $p");
        await p.checkIsGranted();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "All permissions are${_checkIfAllGranted() ? "" : " not"} granted",
          style: TextStyle(
              fontSize: 15,
              color: _checkIfAllGranted() ? Colors.green : Colors.redAccent),
        ),
        Column(
          children: _getPermissionWidgets(context),
        ),
        FilledButton(
            onPressed: _checkIfAllGranted()
                ? () {
                    print("Sign In pressed");
                  }
                : null,
            child: const Text("Sign In"))
      ],
    );
  }
}
