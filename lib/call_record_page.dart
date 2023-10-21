import 'package:call_recorder_app/call_record_service.dart';
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
  bool isRecording = false;
  PhoneState phoneStateStatus = PhoneState.nothing();

  @override
  void initState() {
    super.initState();
    initAll();
  }

  void initAll() async {
    if (!await requestCallPermissions() || !await requestRecordPermissions()) {
      setState(() {
        statusText = "No permission granted";
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
      if (status.status == PhoneStateStatus.CALL_ENDED) {
        CallRecordService.getInstance().stopRecord().then((value) {
          setState(() {
            isRecording = false;
          });
        });
      }
    });
  }

  String getPhoneStateText() {
    return '${phoneStateStatus.number} ${phoneStateStatus.status.name}';
  }

  Future<bool> requestCallPermissions() async {
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

  Future<bool> requestRecordPermissions() async {
    var statusAudio = await Permission.audio.request();
    var statusMicrophone = await Permission.microphone.request();
    return switch (statusAudio) {
          PermissionStatus.denied ||
          PermissionStatus.restricted ||
          PermissionStatus.limited ||
          PermissionStatus.permanentlyDenied =>
            false,
          PermissionStatus.provisional || PermissionStatus.granted => true
        } &&
        switch (statusMicrophone) {
          PermissionStatus.denied ||
          PermissionStatus.restricted ||
          PermissionStatus.limited ||
          PermissionStatus.permanentlyDenied =>
            false,
          PermissionStatus.provisional || PermissionStatus.granted => true
        };
    ;
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
              ? isRecording
                  ? TextButton(
                      onPressed: () async {
                        await CallRecordService.getInstance().stopRecord();
                        setState(() {
                          isRecording = false;
                        });
                      },
                      child: const Text("Stop Recording"))
                  : TextButton(
                      onPressed: () async {
                        if (phoneStateStatus.number == null) {
                          return;
                        }
                        setState(() {
                          isRecording = true;
                        });
                        await CallRecordService.getInstance()
                            .startRecord(phoneStateStatus.number ?? "");
                      },
                      child: const Text("Start Record"))
              : const Text("Waiting for a call")
        ],
      ),
    );
  }
}
