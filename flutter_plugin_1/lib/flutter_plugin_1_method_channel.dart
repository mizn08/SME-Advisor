import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_plugin_1_platform_interface.dart';

/// An implementation of [FlutterPlugin_1Platform] that uses method channels.
class MethodChannelFlutterPlugin_1 extends FlutterPlugin_1Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_plugin_1');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
