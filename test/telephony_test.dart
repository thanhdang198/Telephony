import "package:another_telephony/telephony.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import 'package:mockito/annotations.dart';
import "package:mockito/mockito.dart";
import "package:platform/platform.dart";

import 'telephony_test.mocks.dart';

@GenerateMocks([MethodChannel])
main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockMethodChannel methodChannel = MockMethodChannel();
  late Telephony telephony;

  setUp(() {
    methodChannel = MockMethodChannel();
    telephony = Telephony.private(
        methodChannel, FakePlatform(operatingSystem: "android"));
  });

  tearDown(() {
    verifyNoMoreInteractions(methodChannel);
  });


    group("should send", () {
      test("sms", () async {
        final String address = "0000000000";
        final String body = "Test message";
        when(methodChannel.invokeMethod(SEND_SMS, {
          "address": address,
          "message_body": body,
          "listen_status": false,
          "sub_id": -1, // Include the missing argument
        })).thenAnswer((realInvocation) => Future<void>.value());

        await telephony.sendSms(to: address, message: body);

        verify(methodChannel.invokeMethod(SEND_SMS, {
          "address": address,
          "message_body": body,
          "listen_status": false,
          "sub_id": -1, // Verify the missing argument
        })).called(1);
      });

      test("multipart message", () async {
        final args = {
          "address": "123456",
          "message_body": "some long message",
          "listen_status": false,
          "sub_id": -1, // Include the missing argument
        };
        when(methodChannel.invokeMethod(SEND_MULTIPART_SMS, args))
            .thenAnswer((realInvocation) => Future<void>.value());

        await telephony.sendSms(
            to: "123456", message: "some long message", isMultipart: true);

        verifyNever(methodChannel.invokeMethod(SEND_SMS, args));

        verify(methodChannel.invokeMethod(SEND_MULTIPART_SMS, args)).called(1);
      });


      test("sms by default app", () async {
        final String address = "123456";
        final String body = "message";
        when(methodChannel.invokeMethod(
                SEND_SMS_INTENT, {"address": address, "message_body": body}))
            .thenAnswer((realInvocation) => Future<void>.value());
        telephony.sendSmsByDefaultApp(to: address, message: body);

        verify(methodChannel.invokeMethod(
                SEND_SMS_INTENT, {"address": address, "message_body": body}))
            .called(1);
      });
    });



















}
