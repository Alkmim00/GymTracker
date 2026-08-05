import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'add_exercise_screen.dart';
import '../models/exercise.dart';
import 'exercise_setup_screen.dart';
import 'edit_exercise_screen.dart';


class WorkoutScreen extends StatefulWidget {

  final Workout workout;

  final Function(Workout) onWorkoutUpdated;


  const WorkoutScreen({

    super.key,

    required this.workout,

    required this.onWorkoutUpdated,

  });


  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();

}


class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          widget.workout.name,

          style: const TextStyle(

            fontWeight: FontWeight.bold,

          ),

        ),

      ),



      body: Padding(

        padding: const EdgeInsets.all(16),


        child: ListView.builder(

          itemCount: widget.workout.muscleGroups.length,


          itemBuilder: (context, index) {


            var muscle = widget.workout.muscleGroups[index];


            return Container(

              margin: const EdgeInsets.only(bottom: 20),


              padding: const EdgeInsets.all(18),


              decoration: BoxDecoration(

                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(18),

              ),



              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,


                children: [


                  Text(

                    muscle.name.toUpperCase(),

                    style: const TextStyle(

                      fontSize: 22,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 10),

for (var exercise in muscle.exercises)

ListTile(

  onTap: () async {

    final updated = await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) => EditExerciseScreen(

          exercise: exercise,

        ),

      ),

    );


    if (updated == true) {

      setState(() {});
      widget.onWorkoutUpdated(widget.workout);

    }

  },


  title: Text(

    exercise.name,

    style: const TextStyle(

      fontSize: 18,

      fontWeight: FontWeight.bold,

    ),

  ),


  subtitle: Text(

    "${exercise.weight} lbs\n"
    "${exercise.reps.join(" • ")} reps",

    style: const TextStyle(

      color: Colors.grey,

    ),

  ),


  trailing: IconButton(

    icon: const Icon(

      Icons.delete,

      color: Colors.red,

    ),

    onPressed: () async {

  bool confirm = await showDialog<bool>(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
          "Delete Exercise?",
        ),


        content: Text(

          "Are you sure you want to delete \"${exercise.name}\"?",

        ),


        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context, false);

            },

            child: const Text(
              "CANCEL",
            ),

          ),


          TextButton(

            onPressed: () {

              Navigator.pop(context, true);

            },

            child: const Text(

              "DELETE",

              style: TextStyle(

                color: Colors.red,

              ),

            ),

          ),

        ],

      );

    },

  ) ?? false;



  if (confirm) {

    setState(() {

      muscle.exercises.remove(exercise);

    });


    widget.onWorkoutUpdated(widget.workout);

  }

},

  ),

),



                  const SizedBox(height: 15),



                  ElevatedButton(

  onPressed: () async {

    final selectedExercise = await Navigator.push<String>(

      context,

      MaterialPageRoute(

        builder: (context) => AddExerciseScreen(
          muscleGroup: muscle.name,
        ),

      ),

    );

  if (selectedExercise != null) {

  final Exercise? newExercise = await Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) => ExerciseSetupScreen(

  exerciseName: selectedExercise,

  muscleGroup: muscle.name,

),

    ),

  );


  if (newExercise != null) {

    bool alreadyExists = muscle.exercises.any(

      (exercise) => exercise.name == newExercise.name,

    );


    if (!alreadyExists) {

  setState(() {

    muscle.exercises.add(newExercise);

  });
  widget.onWorkoutUpdated(widget.workout);


}

  }

}

  },

  child: const Text(
    "+ ADD EXERCISE",
  ),

),

                ],

              ),

            );


          },

        ),

      ),

    );

  }

}