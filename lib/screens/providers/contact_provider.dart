import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

final contactProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(contactRepositoryProvider).watchContacts();
});

class ContactNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> save(Contact contact) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(contactRepositoryProvider).saveContact(contact),
    );
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(contactRepositoryProvider).deleteContact(id),
    );
  }
}

final contactNotifierProvider =
    AsyncNotifierProvider<ContactNotifier, void>(ContactNotifier.new);
