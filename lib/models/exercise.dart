import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double weight;

  @HiveField(2)
  List<int> reps;

  @HiveField(3)
  bool isDeleted;

  @HiveField(4)
  String muscleGroup;

  Exercise({
    required this.name,
    required this.weight,
    required this.reps,
    required this.muscleGroup,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'reps': reps,
      'isDeleted': isDeleted,
      'muscleGroup': muscleGroup,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      reps: List<int>.from(map['reps'] ?? <int>[]),
      muscleGroup: map['muscleGroup'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}