import 'dart:io';

import 'package:flutter_sms/flutter_sms.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:url_launcher/url_launcher.dart';

abstract interface class SmsService {
  Future<void> sendInactivityAlert({
    required List<Contact> contacts,
    required String senderName,
  });
}

class SmsServiceImpl implements SmsService {
  const SmsServiceImpl();

  static const _messageTemplate = '【てくしぇあ】{name}さんから10分以上連絡がありません。確認してください。';

  @override
  Future<void> sendInactivityAlert({
    required List<Contact> contacts,
    required String senderName,
  }) async {
    if (contacts.isEmpty) return;
    final message = _messageTemplate.replaceFirst('{name}', senderName);
    final numbers = contacts.map((c) => c.phone).toList();

    if (Platform.isAndroid) {
      await _sendAndroid(numbers, message);
    } else {
      await _openIosSms(numbers, message);
    }
  }

  /// Android: flutter_sms で直接送信
  Future<void> _sendAndroid(List<String> numbers, String message) async {
    for (final number in numbers) {
      await sendSMS(message: message, recipients: [number], sendDirect: true);
    }
  }

  /// iOS: SMSアプリを開き宛先・本文をセット
  Future<void> _openIosSms(List<String> numbers, String message) async {
    final recipients = numbers.join(',');
    final uri = Uri(
      scheme: 'sms',
      path: recipients,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
