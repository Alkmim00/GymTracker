import 'package:hive/hive.dart';

part 'exercise.g.dart';


@HiveType(typeId: 0)
class Exercise {

  @HiveField(0)
  String name;


  @HiveField(1)
  double weight;


  @HiveField(2)
  List<int> reps;


  Exercise({

    required this.name,

    required this.weight,

    required this.reps,

  });

}