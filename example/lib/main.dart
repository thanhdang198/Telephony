import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'dart:async';

@pragma('vm:entry-point')
onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  List<SubscriptionInfo> _subscriptions = [];
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);

      // Get dual SIM subscriptions
      try {
        final subscriptions = await telephony.getSubscriptionList();
        setState(() {
          _subscriptions = subscriptions;
        });
      } catch (e) {
        debugPrint('Error getting subscriptions: $e');
      }
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Telephony Plugin Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SMS Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest SMS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_message.isEmpty ? "No messages yet" : _message),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dual SIM Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SIM Cards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_subscriptions.isEmpty)
                      const Text('No SIM cards detected')
                    else
                      ..._subscriptions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sub = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index > 0) const Divider(),
                            Text(
                              'SIM ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Slot: ${sub.simSlotIndex}'),
                            Text('Carrier: ${sub.carrierName ?? "Unknown"}'),
                            Text('Name: ${sub.displayName ?? "Unknown"}'),
                            Text('Number: ${sub.phoneNumber ?? "Not available"}'),
                            Text('ID: ${sub.subscriptionId}'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await telephony.sendSms(
                                    to: "1234567890",
                                    message: "Test from ${sub.displayName}",
                                    subscriptionId: sub.subscriptionId!,
                                    statusListener: onSendStatus,
                                  );
                                } catch (e) {
                                  debugPrint('Error sending SMS: $e');
                                }
                              },
                              child: Text('Send SMS from SIM ${index + 1}'),
                            ),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Other Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Other Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await telephony.openDialer("123413453");
                      },
                      child: const Text('Open Dialer'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final subscriptions =
                              await telephony.getSubscriptionList();
                          setState(() {
                            _subscriptions = subscriptions;
                          });
                        } catch (e) {
                          debugPrint('Error refreshing subscriptions: $e');
                        }
                      },
                      child: const Text('Refresh SIM List'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
