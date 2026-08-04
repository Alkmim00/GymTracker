import 'package:hive/hive.dart';
import 'exercise.dart';

part 'muscle_group.g.dart';


@HiveType(typeId: 1)
class MuscleGroup {

  @HiveField(0)
  String name;


  @HiveField(1)
  List<Exercise> exercises;


  MuscleGroup({

    required this.name,

    required this.exercises,

  });

}