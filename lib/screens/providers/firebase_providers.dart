import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/data/repositories/account_link_repository_impl.dart';
import 'package:tekushare/data/repositories/firestore_contact_repository_impl.dart';
import 'package:tekushare/data/repositories/firestore_photo_repository_impl.dart';
import 'package:tekushare/data/repositories/firestore_spot_repository_impl.dart';
import 'package:tekushare/data/services/firebase_auth_service_impl.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// Firebase 実装を ProviderScope.overrides に渡すためのリスト。
/// main_*.dart の ProviderScope(overrides: firebaseProviderOverrides()) で使用する。
List<Override> firebaseProviderOverrides() => [
      authServiceProvider.overrideWithValue(
        FirebaseAuthServiceImpl(
          fb_auth.FirebaseAuth.instance,
          FirebaseFirestore.instance,
        ),
      ),
      spotRepositoryProvider.overrideWith((ref) {
        final uid = ref.watch(authStateProvider).value?.uid ?? '';
        return FirestoreSpotRepositoryImpl(FirebaseFirestore.instance, uid);
      }),
      photoRepositoryProvider.overrideWith((ref) {
        final uid = ref.watch(authStateProvider).value?.uid ?? '';
        return FirestorePhotoRepositoryImpl(
          FirebaseFirestore.instance,
          FirebaseStorage.instance,
          uid,
        );
      }),
      contactRepositoryProvider.overrideWith((ref) {
        final uid = ref.watch(authStateProvider).value?.uid ?? '';
        return FirestoreContactRepositoryImpl(FirebaseFirestore.instance, uid);
      }),
      accountLinkRepositoryProvider.overrideWith((_) {
        return AccountLinkRepositoryImpl(
          FirebaseFirestore.instance,
          fb_auth.FirebaseAuth.instance,
        );
      }),
    ];
