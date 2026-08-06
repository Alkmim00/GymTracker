import 'package:hive/hive.dart';
import 'exercise.dart';

part 'muscle_group.g.dart';

@HiveType(typeId: 1)
class MuscleGroup extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Exercise> exercises;

  @HiveField(2)
  bool isDeleted;

  MuscleGroup({
    required this.name,
    required this.exercises,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'isDeleted': isDeleted,
    };
  }

  factory MuscleGroup.fromMap(Map<String, dynamic> map) {
    return MuscleGroup(
      name: map['name'] ?? '',
      exercises: (map['exercises'] as List? ?? [])
          .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}