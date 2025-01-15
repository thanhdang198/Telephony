part of 'telephony.dart';

const _FOREGROUND_CHANNEL = 'plugins.shounakmulay.com/foreground_sms_channel';
const _BACKGROUND_CHANNEL = 'plugins.shounakmulay.com/background_sms_channel';

const HANDLE_BACKGROUND_MESSAGE = "handleBackgroundMessage";
const BACKGROUND_SERVICE_INITIALIZED = "backgroundServiceInitialized";
const SEND_SMS = "sendSms";
const SEND_MULTIPART_SMS = "sendMultipartSms";
const SEND_SMS_INTENT = "sendSmsIntent";
const REQUEST_SMS_PERMISSION = "requestSmsPermissions";
const REQUEST_PHONE_PERMISSION = "requestPhonePermissions";
const REQUEST_PHONE_AND_SMS_PERMISSION = "requestPhoneAndSmsPermissions";

const ON_MESSAGE = "onMessage";
const SMS_SENT = "smsSent";
const SMS_DELIVERED = "smsDelivered";

///
/// Possible parameters that can be fetched during a SMS query operation.
class _SmsProjections {
  static const String ID = "_id";
  static const String ADDRESS = "address";
  static const String BODY = "body";
  static const String DATE = "date";
  static const String READ = "read";
  static const String STATUS = "status";
}

/// Represents all the possible parameters for a SMS
class SmsColumn {
  final String _columnName;

  const SmsColumn._(this._columnName);

  static const ID = SmsColumn._(_SmsProjections.ID);
  static const ADDRESS = SmsColumn._(_SmsProjections.ADDRESS);
  static const BODY = SmsColumn._(_SmsProjections.BODY);
  static const DATE = SmsColumn._(_SmsProjections.DATE);
  static const READ = SmsColumn._(_SmsProjections.READ);
  static const STATUS = SmsColumn._(_SmsProjections.STATUS);
}

const DEFAULT_SMS_COLUMNS = [
  SmsColumn.ID,
  SmsColumn.ADDRESS,
  SmsColumn.BODY,
  SmsColumn.DATE
];

const INCOMING_SMS_COLUMNS = [
  SmsColumn._(_SmsProjections.ADDRESS),
  SmsColumn._(_SmsProjections.BODY),
  SmsColumn._(_SmsProjections.DATE),
  SmsColumn.STATUS
];

/// Represents types of SMS.
enum SmsType {
  MESSAGE_TYPE_ALL,
  MESSAGE_TYPE_INBOX,
  MESSAGE_TYPE_SENT,
  MESSAGE_TYPE_DRAFT,
  MESSAGE_TYPE_OUTBOX,
  MESSAGE_TYPE_FAILED,
  MESSAGE_TYPE_QUEUED
}

/// Represents states of SMS.
enum SmsStatus { STATUS_COMPLETE, STATUS_FAILED, STATUS_NONE, STATUS_PENDING }

/// Represents the status of a SMS message sent from the device.
enum SendStatus { SENT, DELIVERED }
