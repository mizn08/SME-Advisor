import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_1/flutter_plugin_1.dart';
import 'package:flutter_plugin_1/flutter_plugin_1_platform_interface.dart';
import 'package:flutter_plugin_1/flutter_plugin_1_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPlugin_1Platform
    with MockPlatformInterfaceMixin
    implements FlutterPlugin_1Platform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterPlugin_1Platform initialPlatform = FlutterPlugin_1Platform.instance;

  test('$MethodChannelFlutterPlugin_1 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPlugin_1>());
  });

  test('getPlatformVersion', () async {
    FlutterPlugin_1 flutterPlugin_1Plugin = FlutterPlugin_1();
    MockFlutterPlugin_1Platform fakePlatform = MockFlutterPlugin_1Platform();
    FlutterPlugin_1Platform.instance = fakePlatform;

    expect(await flutterPlugin_1Plugin.getPlatformVersion(), '42');
  });
}
