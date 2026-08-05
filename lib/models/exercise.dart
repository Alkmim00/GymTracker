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

}