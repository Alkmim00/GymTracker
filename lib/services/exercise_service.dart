import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../models/exercise.dart';
import '../models/muscle_group.dart';

class ExerciseService {
  static CollectionReference<Map<String, dynamic>>?
      _muscleGroupsCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('customMuscleGroups');
  }

  static CollectionReference<Map<String, dynamic>>? _exercisesCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('customExercises');
  }

  // ---- Custom muscle groups ----

  /// Pulls custom muscle groups from Firestore into the local Hive
  /// box, matching by name (see note on doc IDs above). Call this
  /// once when a screen that lists muscle groups loads, BEFORE
  /// reading the Hive box, so the box is up to date first.
  static Future<void> syncCustomMuscleGroups() async {
    final box = Hive.box('customMuscleGroups');
    final collection = _muscleGroupsCollection();

    if (collection == null) return;

    try {
      final snapshot = await collection.get();

      for (final doc in snapshot.docs) {
        final remote = MuscleGroup.fromMap(doc.data());

        MuscleGroup? existing;
        for (final local in box.values.cast<MuscleGroup>()) {
          if (local.name == remote.name) {
            existing = local;
            break;
          }
        }

        if (existing == null) {
          await box.add(remote);
        } else {
          existing.isDeleted = remote.isDeleted;
          await existing.save();
        }
      }
    } catch (e) {
      // Offline or Firestore error — leave the local cache as-is.
    }
  }

  static Future<void> addCustomMuscleGroup(MuscleGroup muscleGroup) async {
    final collection = _muscleGroupsCollection();
    if (collection == null) return;

    await collection.doc(muscleGroup.name).set(muscleGroup.toMap());
  }

  static Future<void> updateCustomMuscleGroup(MuscleGroup muscleGroup) async {
    final collection = _muscleGroupsCollection();
    if (collection == null) return;

    await collection
        .doc(muscleGroup.name)
        .set(muscleGroup.toMap(), SetOptions(merge: true));
  }

  // ---- Custom exercises ----

  /// Same pattern as syncCustomMuscleGroups(), but matches on
  /// name + muscleGroup together, since exercise names are only
  /// unique within a muscle group, not globally.
  static Future<void> syncCustomExercises() async {
    final box = Hive.box('customExercises');
    final collection = _exercisesCollection();

    if (collection == null) return;

    try {
      final snapshot = await collection.get();

      for (final doc in snapshot.docs) {
        final remote = Exercise.fromMap(doc.data());

        Exercise? existing;
        for (final local in box.values.cast<Exercise>()) {
          if (local.name == remote.name &&
              local.muscleGroup == remote.muscleGroup) {
            existing = local;
            break;
          }
        }

        if (existing == null) {
          await box.add(remote);
        } else {
          existing.isDeleted = remote.isDeleted;
          await existing.save();
        }
      }
    } catch (e) {
      // Offline or Firestore error — leave the local cache as-is.
    }
  }

  static String _exerciseDocId(String muscleGroup, String name) {
    return '${muscleGroup}_$name';
  }

  static Future<void> addCustomExercise(Exercise exercise) async {
    final collection = _exercisesCollection();
    if (collection == null) return;

    await collection
        .doc(_exerciseDocId(exercise.muscleGroup, exercise.name))
        .set(exercise.toMap());
  }

  static Future<void> updateCustomExercise(Exercise exercise) async {
    final collection = _exercisesCollection();
    if (collection == null) return;

    await collection
        .doc(_exerciseDocId(exercise.muscleGroup, exercise.name))
        .set(exercise.toMap(), SetOptions(merge: true));
  }
}