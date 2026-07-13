import 'package:tekushare/domain/entities/contact.dart';

abstract interface class ContactRepository {
  Stream<List<Contact>> watchContacts();
  Future<void> saveContact(Contact contact);
  Future<void> deleteContact(String id);
}
