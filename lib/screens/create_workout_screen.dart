import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/muscle_group.dart';


class CreateWorkoutScreen extends StatefulWidget {

  const CreateWorkoutScreen({super.key});


  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();

}



class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {


  final TextEditingController workoutController =
      TextEditingController();


  List<String> muscleGroups = [

    "Chest",
    "Back",
    "Shoulders",
    "Biceps",
    "Triceps",
    "Quads",
    "Hamstrings",
    "Calves",
    "Abs",
    "Forearms",

  ];


  List<MuscleGroup> selectedMuscles = [];



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Create Workout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),


      body: Padding(

        padding: const EdgeInsets.all(16),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [


            TextField(

              controller: workoutController,

              decoration: InputDecoration(

                labelText: "Workout Name",

                filled: true,

                fillColor: const Color(0xFF1E1E1E),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(15),

                ),

              ),

            ),



            const SizedBox(height: 25),



            const Text(

              "Select Muscle Groups",

              style: TextStyle(

                fontSize: 20,

                fontWeight: FontWeight.bold,

              ),

            ),



            const SizedBox(height: 10),



            Expanded(

              child: ListView.builder(

                itemCount: muscleGroups.length,


                itemBuilder: (context, index) {


                  String muscle = muscleGroups[index];


                  return CheckboxListTile(

                    title: Text(muscle),


                    value: selectedMuscles.any(
                      (item) => item.name == muscle,
                    ),


                    activeColor: Colors.green,


                    onChanged: (value) {


                      setState(() {


                        if(value == true) {

  selectedMuscles.add(

    MuscleGroup(

      name: muscle,

      exercises: [],

    ),

  );

}

else {

  selectedMuscles.removeWhere(

    (item) => item.name == muscle,

  );

}


                      });


                    },

                  );


                },

              ),

            ),



            SizedBox(

              width: double.infinity,


              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.green,

                  foregroundColor: Colors.black,

                  padding: const EdgeInsets.all(18),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(15),

                  ),

                ),



                onPressed: () {


                  if(workoutController.text.isEmpty ||
                      selectedMuscles.isEmpty) {


                    return;

                  }



                  Workout workout = Workout(

                    name: workoutController.text,

                    muscleGroups: selectedMuscles,

                  );



                  Navigator.pop(

                    context,

                    workout,

                  );


                },


                child: const Text(

                  "CREATE WORKOUT",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.bold,

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}