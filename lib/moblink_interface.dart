import 'dart:async';
import 'package:flutter/services.dart';
import 'package:moblink/moblink_defines.dart';

class Moblink {
  static Moblink? _instance;
  MethodChannel? _channel;
  EventChannel? _iosEventChannel;
  EventChannel? _androidEventChannel;
  Function(MLSDKScene scene)? moblinkCallBack;
  Function(Object error)? moblinkError;

  static Moblink sharedInstance() {
    if (_instance == null) {
      _instance = Moblink();
      _instance!._channel = MethodChannel('com.mob.moblink');
      _instance!._iosEventChannel = EventChannel("MOBLINK_TO_FLUTTER");
      _instance!._androidEventChannel = EventChannel("JAVA_TO_FLUTTER");
    }
    return _instance!;
  }

  void _onEvent(dynamic event) {
    if (moblinkCallBack == null) return;

    MLSDKScene scenes = MLSDKScene(
      event["path"] ?? "",
      event["params"],
    );
    scenes.mobid = event["mobid"];
    scenes.rawURL = event["rawURL"];
    scenes.className = event["className"];
    moblinkCallBack!(scenes);
  }

  Future<dynamic>? _onError(Object error) {
    print("QQQ _onError");
    print(error);
  }

  static Future<dynamic> getPrivacyPolicy(
      String type, Function(dynamic data, dynamic error)? result) {
    Map args = {"type": type};
    Future? callback = Moblink.sharedInstance()
        ._channel
        ?.invokeMethod(MobLinkMethods.getPrivacyPolicy.name!, args);
    callback?.then((dynamic response) {
      print(response);
      if (result != null) {
        result(response["data"], response["error"]);
      }
    });
    return callback!;
  }

  static Future<dynamic> uploadPrivacyPermissionStatus(
      int status, Function(bool success)? result) {
    Map args = {"status": status};
    Future? callback = Moblink.sharedInstance()._channel?.invokeMethod(
        MobLinkMethods.uploadPrivacyPermissionStatus.name!, args);
    callback?.then((dynamic response) {
      print(response);
      if (result != null) {
        result(response["success"]);
      }
    });
    return callback!;
  }

  static Future<dynamic> getMobId(MLSDKScene scene,
      Function(String mobid, String domain, MLSDKError error)? result) {
    Map args = {"path": scene.path, "params": scene.params};
    Future? callback = Moblink.sharedInstance()
        ._channel
        ?.invokeMethod(MobLinkMethods.getMobId.name!, args);

    callback?.then((dynamic response) {
      if (result != null) {
        result(response["mobid"], response["domain"],
            MLSDKError(rawData: response["error"]));
      }
    });
    return callback!;
  }

  static Future<dynamic> restoreScene(
      Function(MLSDKScene scene) callback) async {
    Moblink.sharedInstance()._iosEventChannel?.receiveBroadcastStream().listen(
        Moblink.sharedInstance()._onEvent,
        onError: Moblink.sharedInstance()._onError);
    Moblink.sharedInstance().moblinkCallBack = callback;
    Moblink.sharedInstance()
        ._channel
        ?.invokeMethod(MobLinkMethods.restoreScene.name!);
  }

  static Future<dynamic> restoreScene_Android(
      Function(MLSDKScene scene) callback) async {

    Moblink.sharedInstance()
        ._androidEventChannel
        ?.receiveBroadcastStream()
        .listen(Moblink.sharedInstance()._onEvent,
            onError: Moblink.sharedInstance()._onError);
    Moblink.sharedInstance().moblinkCallBack = callback;
    Moblink.sharedInstance()
        ._channel
        ?.invokeMethod(MobLinkMethods.restoreScene.name!);
  }
}

class MLSDKScene {
  String path;
  Map params;

  String? mobid;
  String? className;
  String? rawURL;

  // create scene
  MLSDKScene(this.path, this.params);
}
