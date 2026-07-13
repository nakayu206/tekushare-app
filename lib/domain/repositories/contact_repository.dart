import 'package:tekushare/domain/entities/contact.dart';

abstract interface class ContactRepository {
  Stream<Contact?> watchContact();
  Future<void> saveContact(Contact contact);
  Future<void> deleteContact();
}
