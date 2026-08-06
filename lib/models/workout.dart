import 'package:hive/hive.dart';
import 'muscle_group.dart';

part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<MuscleGroup> muscleGroups;

  // Firestore document ID. Deliberately NOT a @HiveField — adding a
  // new HiveField index would require regenerating workout.g.dart
  // via build_runner. It's only used to identify the doc in
  // Firestore for updates/deletes; Hive just ignores it.
  String? id;

  Workout({
    required this.name,
    required this.muscleGroups,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroups': muscleGroups.map((group) => group.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      name: map['name'] ?? '',
      muscleGroups: (map['muscleGroups'] as List? ?? [])
          .map((g) => MuscleGroup.fromMap(Map<String, dynamic>.from(g)))
          .toList(),
    );
  }
}