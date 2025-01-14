import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:platform/platform.dart';

part 'constants.dart';

typedef MessageHandler(SmsMessage message);
typedef SmsSendStatusListener(SendStatus status);

@pragma('vm:entry-point')
void _flutterSmsSetupBackgroundChannel(
    {MethodChannel backgroundChannel =
    const MethodChannel(_BACKGROUND_CHANNEL)}) async {
  WidgetsFlutterBinding.ensureInitialized();

  backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == HANDLE_BACKGROUND_MESSAGE) {
      final CallbackHandle handle =
      CallbackHandle.fromRawHandle(call.arguments['handle']);
      final Function handlerFunction =
      PluginUtilities.getCallbackFromHandle(handle)!;
      try {
        await handlerFunction(SmsMessage.fromMap(
            call.arguments['message'], INCOMING_SMS_COLUMNS));
      } catch (e) {
        print('Unable to handle incoming background message.');
        print(e);
      }
      return Future<void>.value();
    }
  });

  backgroundChannel.invokeMethod<void>(BACKGROUND_SERVICE_INITIALIZED);
}

class Telephony {
  final MethodChannel _foregroundChannel;
  final Platform _platform;

  late MessageHandler _onNewMessage;
  late SmsSendStatusListener _statusListener;

  static Telephony get instance => _instance;
  static Telephony get backgroundInstance => _backgroundInstance;

  @visibleForTesting
  Telephony.private(MethodChannel methodChannel, Platform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform;

  Telephony._newInstance(MethodChannel methodChannel, LocalPlatform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform {
    _foregroundChannel.setMethodCallHandler(handler);
  }

  static final Telephony _instance = Telephony._newInstance(
      const MethodChannel(_FOREGROUND_CHANNEL), const LocalPlatform());
  static final Telephony _backgroundInstance = Telephony._newInstance(
      const MethodChannel(_FOREGROUND_CHANNEL), const LocalPlatform());

  Future<dynamic> handler(MethodCall call) async {
    switch (call.method) {
      case ON_MESSAGE:
        final message = call.arguments["message"];
        return _onNewMessage(SmsMessage.fromMap(message, INCOMING_SMS_COLUMNS));
      case SMS_SENT:
        return _statusListener(SendStatus.SENT);
      case SMS_DELIVERED:
        return _statusListener(SendStatus.DELIVERED);
    }
  }

  Future<void> sendSms({
    required String to,
    required String message,
    SmsSendStatusListener? statusListener,
    bool isMultipart = false,
    int subscriptionId = -1,
  }) async {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    bool listenStatus = false;
    if (statusListener != null) {
      _statusListener = statusListener;
      listenStatus = true;
    }
    final Map<String, dynamic> args = {
      "address": to,
      "message_body": message,
      "listen_status": listenStatus,
      "sub_id": subscriptionId
    };
    final String method = isMultipart ? SEND_MULTIPART_SMS : SEND_SMS;
    await _foregroundChannel.invokeMethod(method, args);
  }

  Future<void> sendSmsByDefaultApp({
    required String to,
    required String message,
  }) async {
    final Map<String, dynamic> args = {
      "address": to,
      "message_body": message,
    };
    await _foregroundChannel.invokeMethod(SEND_SMS_INTENT, args);
  }

  Future<bool?> get requestSmsPermissions =>
      _foregroundChannel.invokeMethod<bool>(REQUEST_SMS_PERMISSION);

  Future<bool?> get requestPhonePermissions =>
      _foregroundChannel.invokeMethod<bool>(REQUEST_PHONE_PERMISSION);

  Future<bool?> get requestPhoneAndSmsPermissions =>
      _foregroundChannel.invokeMethod<bool>(REQUEST_PHONE_AND_SMS_PERMISSION);
}

class SmsMessage {
  int? id;
  String? address;
  String? body;
  int? date;
  int? dateSent;
  bool? read;
  bool? seen;
  String? subject;
  int? subscriptionId;
  int? threadId;
  SmsType? type;
  SmsStatus? status;
  String? serviceCenterAddress;

  @visibleForTesting
  SmsMessage.fromMap(Map rawMessage, List<SmsColumn> columns) {
    final message = Map.castFrom<dynamic, dynamic, String, dynamic>(rawMessage);
    for (var column in columns) {
      final value = message[column._columnName];
      switch (column._columnName) {
        case _SmsProjections.ID:
          this.id = int.tryParse(value);
          break;
        case _SmsProjections.ADDRESS:
          this.address = value;
          break;
        case _SmsProjections.BODY:
          this.body = value;
          break;
        case _SmsProjections.DATE:
          this.date = int.tryParse(value);
          break;
        case _SmsProjections.READ:
          this.read = int.tryParse(value) == 0 ? false : true;
          break;
        case _SmsProjections.STATUS:
          switch (int.tryParse(value)) {
            case 0:
              this.status = SmsStatus.STATUS_COMPLETE;
              break;
            case 32:
              this.status = SmsStatus.STATUS_PENDING;
              break;
            case 64:
              this.status = SmsStatus.STATUS_FAILED;
              break;
          }
          break;
      }
    }
  }
}
