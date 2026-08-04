import 'package:flutter/material.dart';
import '../models/exercise.dart';


class ExerciseSetupScreen extends StatefulWidget {

  final String exerciseName;


  const ExerciseSetupScreen({

    super.key,

    required this.exerciseName,

  });


  @override
  State<ExerciseSetupScreen> createState() =>
      _ExerciseSetupScreenState();

}


class _ExerciseSetupScreenState
    extends State<ExerciseSetupScreen> {


  final weightController = TextEditingController();

  final set1Controller = TextEditingController();

  final set2Controller = TextEditingController();

  final set3Controller = TextEditingController();



  void saveExercise() {

    Exercise exercise = Exercise(

      name: widget.exerciseName,

      weight: double.tryParse(
        weightController.text,
      ) ?? 0,

      reps: [

        int.tryParse(set1Controller.text) ?? 0,

        int.tryParse(set2Controller.text) ?? 0,

        int.tryParse(set3Controller.text) ?? 0,

      ],

    );


    Navigator.pop(

      context,

      exercise,

    );

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(widget.exerciseName),

      ),


      body: Padding(

        padding: const EdgeInsets.all(16),


        child: Column(

          children: [


            TextField(

              controller: weightController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Weight (lbs)",

              ),

            ),


            TextField(

              controller: set1Controller,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Set 1 Reps",

              ),

            ),


            TextField(

              controller: set2Controller,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Set 2 Reps",

              ),

            ),


            TextField(

              controller: set3Controller,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Set 3 Reps",

              ),

            ),


            const SizedBox(height: 20),


            ElevatedButton(

              onPressed: saveExercise,

              child: const Text(

                "SAVE EXERCISE",

              ),

            ),

          ],

        ),

      ),

    );

  }

}