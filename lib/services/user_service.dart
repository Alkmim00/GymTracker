import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class UserService {
  static Future<Map<String, dynamic>> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final box = Hive.box('profile');

    if (user == null) {
      await box.put('name', 'Your Name');
      await box.put('weight', 0.0);

      return {
        'name': 'Your Name',
        'weight': 0.0,
      };
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        final name = data['name'] ?? 'Your Name';
        final weight = (data['weight'] ?? 0).toDouble();

        await box.put('name', name);
        await box.put('weight', weight);

        return {
          'name': name,
          'weight': weight,
        };
      }

      // Firestore responded but has no doc for this uid — this is a
      // brand-new account or a guest session, NOT an offline error.
      // Don't fall back to the Hive cache here: it's shared per
      // device, not per account, and may still hold whoever was
      // last signed in. Reset it to defaults.
      await box.put('name', 'Your Name');
      await box.put('weight', 0.0);

      return {
        'name': 'Your Name',
        'weight': 0.0,
      };
    } catch (e) {
      // Firestore genuinely unreachable (e.g. offline). Here it IS
      // reasonable to trust the cache, since this device was almost
      // certainly last used by this same signed-in account.
      return {
        'name': box.get('name', defaultValue: 'Your Name'),
        'weight': box.get('weight', defaultValue: 0.0),
      };
    }
  }

  static Future<void> saveProfile({
    required String name,
    required double weight,
  }) async {
    final box = Hive.box('profile');

    await box.put('name', name);
    await box.put('weight', weight);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'weight': weight,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Synchronous read from the local Hive cache only — no Firestore call.
  /// Safe to use in any screen reached after app startup, since
  /// HomeScreen's initState() already calls loadProfile() once per
  /// session and warms this cache.
  static Map<String, dynamic> getCachedProfile() {
    final box = Hive.box('profile');

    return {
      'name': box.get('name', defaultValue: 'Your Name'),
      'weight': (box.get('weight', defaultValue: 0.0) as num).toDouble(),
    };
  }
}