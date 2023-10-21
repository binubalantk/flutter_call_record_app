import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';

class CallRecordPage extends StatefulWidget {
  const CallRecordPage({super.key});

  @override
  State<CallRecordPage> createState() => _CallRecordPageState();
}

class _CallRecordPageState extends State<CallRecordPage> {
  String statusText = "Initializing";
  bool hasPermission = false;
  PhoneState phoneStateStatus = PhoneState.nothing();

  @override
  void initState() {
    super.initState();
    initAll();
  }

  void initAll() async {
    if (!await requestPermissions()) {
      setState(() {
        statusText = "No permission found";
      });
    }

    setState(() {
      hasPermission = true;
      statusText = "Permission granted";
    });

    PhoneState.stream.listen((status) {
      setState(() {
        phoneStateStatus = status;
        statusText = getPhoneStateText();
      });
    });
  }

  String getPhoneStateText() {
    return '${phoneStateStatus.number} ${phoneStateStatus.status.name}';
  }

  Future<bool> requestPermissions() async {
    var status = await Permission.phone.request();
    return switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited ||
      PermissionStatus.permanentlyDenied =>
        false,
      PermissionStatus.provisional || PermissionStatus.granted => true
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(statusText),
          SizedBox(height: 20),
          hasPermission &&
                  phoneStateStatus.status != PhoneStateStatus.NOTHING &&
                  phoneStateStatus.status != PhoneStateStatus.CALL_ENDED
              ? TextButton(
                  onPressed: () {
                    // TODO: Record the call here
                  },
                  child: const Text("Record"))
              : const Text("Waiting for a call")
        ],
      ),
    );
  }
}
