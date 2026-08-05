import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/muscle_group.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CreateWorkoutScreen extends StatefulWidget {

  const CreateWorkoutScreen({super.key});


  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();

}



class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {


  final TextEditingController workoutController =
      TextEditingController();


List<String> defaultMuscleGroups = [

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


List<String> muscleGroups = [];


  List<MuscleGroup> selectedMuscles = [];

  @override
void initState() {

  super.initState();

  loadMuscleGroups();

}


void loadMuscleGroups() {

  var box = Hive.box('customMuscleGroups');

  setState(() {

    muscleGroups = [

      ...defaultMuscleGroups,

      ...box.values
          .cast<MuscleGroup>()
          .where((muscle) => !muscle.isDeleted)
          .map((muscle) => muscle.name),

    ];

  });

}

bool isCustomMuscleGroup(String name) {

  var box = Hive.box('customMuscleGroups');

  return box.values.any(
    (muscle) => muscle.name == name,
  );

}

void deleteCustomMuscleGroup(String name) {

  showDialog(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
          "Delete Muscle Group?",
        ),


        content: Text(
          "Are you sure you want to delete $name? "
          "Existing workouts will not be affected.",
        ),


        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);

            },

            child: const Text(
              "CANCEL",
            ),

          ),


          TextButton(

            onPressed: () async {

              var box =
                  Hive.box('customMuscleGroups');


              var muscle = box.values.firstWhere(

                (item) => item.name == name,

              );


              muscle.isDeleted = true;

              await muscle.save();


             setState(() {

  muscleGroups.remove(name);

  selectedMuscles.removeWhere(
    (muscle) => muscle.name == name,
  );

});


              Navigator.pop(context);

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

  );

}

void createCustomMuscleGroup() {

  TextEditingController controller =
      TextEditingController();


  showDialog(

    context: context,

    builder: (context) {

      return AlertDialog(

        backgroundColor: const Color(0xFF1E1E1E),

        title: const Text(
          "Create Muscle Group",
        ),


        content: TextField(

          controller: controller,

          decoration: const InputDecoration(
            labelText: "Muscle Group Name",
          ),

        ),


        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);

            },

            child: const Text(
              "CANCEL",
            ),

          ),


          TextButton(

            onPressed: () async {

              if(controller.text.trim().isEmpty) {
                return;
              }


              String newMuscle =
                  controller.text.trim();


              var box =
                  Hive.box('customMuscleGroups');


              await box.add(

                MuscleGroup(

                  name: newMuscle,

                  exercises: [],

                ),

              );


              setState(() {

                muscleGroups.add(newMuscle);

              });


              Navigator.pop(context);

            },

            child: const Text(
              "CREATE",
              style: TextStyle(
                color: Colors.green,
              ),
            ),

          ),

        ],

      );

    },

  );

}



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

  child: ListView(

    children: [

      ...muscleGroups.map((muscle) {

        return CheckboxListTile(

  title: Text(muscle),


  value: selectedMuscles.any(
    (item) => item.name == muscle,
  ),


  activeColor: Colors.green,


  secondary: isCustomMuscleGroup(muscle)

      ? IconButton(

          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),


          onPressed: () {

            deleteCustomMuscleGroup(muscle);

          },

        )

      : null,


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

      }),


      ListTile(

        leading: const Icon(
          Icons.add,
          color: Colors.green,
        ),

        title: const Text(
          "Create Custom Muscle Group",
          style: TextStyle(
            color: Colors.green,
          ),
        ),


        onTap: createCustomMuscleGroup,

      ),

    ],

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