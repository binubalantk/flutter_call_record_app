import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class CallRecordService {
  static final CallRecordService _instance = CallRecordService();
  static final DateFormat defaultDateFormat = DateFormat("yyyyMMddHHmmss");

  AudioRecorder recorder = AudioRecorder();

  static CallRecordService getInstance() {
    return _instance;
  }

  String getTimeStamp() {
    return defaultDateFormat.format(DateTime.now());
  }

  Future<String> createFilePath(String phoneNumber) async {
    final Directory? baseDir = await getDownloadsDirectory();
    if (baseDir == null) {
      throw Exception("Can't get the the record path base dir");
    }
    String timestamp = getTimeStamp();
    return '${baseDir.path}/call_${phoneNumber}_$timestamp.mp3';
  }

  Future startRecord(String phoneNumber) async {
    recorder = AudioRecorder();
    String filePath = await createFilePath(phoneNumber);
    // Start recording to file
    await recorder.start(const RecordConfig(), path: filePath);
  }

  Future stopRecord() async {
    if (await recorder.isRecording()) {
      await recorder.stop();
    }
  }
}
