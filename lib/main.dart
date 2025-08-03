import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one_ai/app.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePermission();
  runApp(const MyApp());
}

Future<void> initializePermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.audio,
    Permission.photos,
    if (Platform.isAndroid) Permission.manageExternalStorage,
  ].request();

  statuses.forEach((permission, status) {
    if (!status.isGranted) {
      debugPrint('Permission not granted: $permission');
    }
  });
}

