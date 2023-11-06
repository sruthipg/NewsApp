import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

Future<String> getFilePathMp4() async {
  final DateTime now = DateTime.now();
  final String formattedDateTime =
      "${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}";
  final filePath = 'audio_$formattedDateTime.mp4';
  return filePath; // You can change the file extension to match the audio format you're using.
}

Future<String?> getFileName(String path) async {
  Uri uri = Uri.parse(path);
  List<String> segments = uri.pathSegments;

  if (segments.isNotEmpty) {
    // Return the last path segment
    return segments.last;
  }

  // Handle the case where there are no path segments
  return null;
}

Future<int> getTotalResults(int total) async {
  final prefs = await SharedPreferences.getInstance();
  int allNews = (prefs.getInt(AppConstants.totalNewsRetrieved)?.toInt()) ?? 0;
  allNews = total + allNews;
  return allNews;
}

Future<bool> checkPermission()async{
  bool isPermissionGranted =false;
  if (!kIsWeb) {
    var status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }else{
      isPermissionGranted = true;
    }
  }
  return isPermissionGranted;
}
Future<bool> checkUrlExists(String path) async {
  var file = File(path);
  var isFileExists = await file.exists();
  if (isFileExists) {
    return true;
  } else {
    return false;
  }
}