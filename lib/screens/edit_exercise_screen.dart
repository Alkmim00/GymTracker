import 'package:flutter/material.dart';
import '../models/exercise.dart';


class EditExerciseScreen extends StatefulWidget {

  final Exercise exercise;


  const EditExerciseScreen({

    super.key,

    required this.exercise,

  });


  @override
  State<EditExerciseScreen> createState() =>
      _EditExerciseScreenState();

}


class _EditExerciseScreenState
    extends State<EditExerciseScreen> {


  late TextEditingController weightController;

  late TextEditingController set1Controller;

  late TextEditingController set2Controller;

  late TextEditingController set3Controller;



  @override
  void initState() {

    super.initState();


    weightController = TextEditingController(

      text: widget.exercise.weight.toString(),

    );


    set1Controller = TextEditingController(

      text: widget.exercise.reps[0].toString(),

    );


    set2Controller = TextEditingController(

      text: widget.exercise.reps[1].toString(),

    );


    set3Controller = TextEditingController(

      text: widget.exercise.reps[2].toString(),

    );

  }



  void saveChanges() {


    widget.exercise.weight =

        double.tryParse(weightController.text) ?? 0;


    widget.exercise.reps = [

      int.tryParse(set1Controller.text) ?? 0,

      int.tryParse(set2Controller.text) ?? 0,

      int.tryParse(set3Controller.text) ?? 0,

    ];


    Navigator.pop(context, true);

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(widget.exercise.name),

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

              onPressed: saveChanges,

              child: const Text(

                "SAVE CHANGES",

              ),

            ),

          ],

        ),

      ),

    );

  }

}