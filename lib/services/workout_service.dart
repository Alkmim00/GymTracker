import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../models/workout.dart';

class WorkoutService {
  static CollectionReference<Map<String, dynamic>>? _collection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts');
  }

  /// Firestore-first, Hive-fallback — same pattern as UserService.loadProfile().
  static Future<List<Workout>> loadWorkouts() async {
    final box = Hive.box('workouts');
    final collection = _collection();

    if (collection == null) {
      return _loadCached(box);
    }

    try {
      final snapshot = await collection.get();

      final workouts = snapshot.docs.map((doc) {
        final workout = Workout.fromMap(doc.data());
        workout.id = doc.id;
        return workout;
      }).toList();

      await box.put('myWorkouts', workouts);

      return workouts;
    } catch (e) {
      // Offline or Firestore error — fall back to last cached copy.
      return _loadCached(box);
    }
  }

  static List<Workout> _loadCached(Box box) {
    final cached = box.get('myWorkouts');
    return cached != null ? List<Workout>.from(cached) : <Workout>[];
  }

  /// Writes the current in-memory list to the Hive cache. Call this
  /// after any add/update/delete so the offline cache stays in sync.
  static Future<void> cacheWorkouts(List<Workout> workouts) async {
    final box = Hive.box('workouts');
    await box.put('myWorkouts', workouts);
  }

  /// Adds a new workout to Firestore and sets its generated id on
  /// the passed-in object. Does NOT touch the Hive cache — call
  /// cacheWorkouts() after updating your in-memory list.
  static Future<void> addWorkout(Workout workout) async {
    final collection = _collection();

    if (collection == null) return;

    final docRef = await collection.add(workout.toMap());
    workout.id = docRef.id;
  }

  /// Updates an existing workout in Firestore. Requires workout.id
  /// to already be set.
  static Future<void> updateWorkout(Workout workout) async {
    final collection = _collection();

    if (collection == null || workout.id == null) return;

    await collection.doc(workout.id).set(
          workout.toMap(),
          SetOptions(merge: true),
        );
  }

  static Future<void> deleteWorkout(Workout workout) async {
    final collection = _collection();

    if (collection == null || workout.id == null) return;

    await collection.doc(workout.id).delete();
  }
}