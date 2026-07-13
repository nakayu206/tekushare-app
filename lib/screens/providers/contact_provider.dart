import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

final contactProvider = StreamProvider<Contact?>((ref) {
  return ref.watch(contactRepositoryProvider).watchContact();
});

class ContactNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save(Contact contact) async {
    await ref.read(contactRepositoryProvider).saveContact(contact);
  }

  Future<void> delete() async {
    await ref.read(contactRepositoryProvider).deleteContact();
  }
}

final contactNotifierProvider =
    AsyncNotifierProvider<ContactNotifier, void>(ContactNotifier.new);
