import 'package:hive/hive.dart';
import 'muscle_group.dart';


part 'workout.g.dart';


@HiveType(typeId: 2)
class Workout {

  @HiveField(0)
  String name;


  @HiveField(1)
  List<MuscleGroup> muscleGroups;


  Workout({

    required this.name,

    required this.muscleGroups,

  });

}