import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/exercise_library.dart';
import '../models/exercise.dart';


class AddExerciseScreen extends StatefulWidget {

  final String muscleGroup;


  const AddExerciseScreen({

    super.key,

    required this.muscleGroup,

  });


  @override
  State<AddExerciseScreen> createState() =>
      _AddExerciseScreenState();

}



class _AddExerciseScreenState
    extends State<AddExerciseScreen> {


  List<String> customExercises = [];


  @override
  void initState() {

    super.initState();

    loadCustomExercises();

  }



  void loadCustomExercises() {

    var box = Hive.box('customExercises');


    setState(() {

      customExercises = box.values

          .cast<Exercise>()

          .where(
            (exercise) =>
                exercise.muscleGroup == widget.muscleGroup &&
                !exercise.isDeleted,
          )

          .map(
            (exercise) => exercise.name,
          )

          .toList();

    });

  }




  void createCustomExercise() {

    TextEditingController controller =
        TextEditingController();



    showDialog(

      context: context,

      builder: (context) {


        return AlertDialog(

          backgroundColor:
              const Color(0xFF1E1E1E),


          title: const Text(
            "Create Exercise",
          ),


          content: TextField(

            controller: controller,

            decoration: const InputDecoration(

              labelText:
                  "Exercise Name",

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


                var box =
                    Hive.box('customExercises');



                await box.add(

                  Exercise(

                    name:
                        controller.text.trim(),


                    weight: 0,


                    reps: [
                      0,
                      0,
                      0,
                    ],


                    muscleGroup:
                        widget.muscleGroup,

                  ),

                );


                loadCustomExercises();


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

  void deleteCustomExercise(String name) {

  showDialog(

    context: context,

    builder: (context) {

      return AlertDialog(

        backgroundColor: const Color(0xFF1E1E1E),

        title: const Text(
          "Delete Exercise?",
        ),


        content: Text(
          "Are you sure you want to delete \"$name\"?\n\n"
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
                  Hive.box('customExercises');


              var exercise =
                  box.values.firstWhere(

                    (item) =>
                        item.name == name,

                  );



              exercise.isDeleted = true;


              await exercise.save();



              loadCustomExercises();


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




  @override
  Widget build(BuildContext context) {


    final defaultExercises =
        exerciseLibrary[widget.muscleGroup] ?? [];


    final allExercises = [

      ...defaultExercises,

      ...customExercises,

    ];



    return Scaffold(

      appBar: AppBar(

        title: Text(
          "Add Exercise - ${widget.muscleGroup}",
        ),

      ),



      body: ListView(

        children: [


          ...allExercises.map(

  (exercise) {


    bool isCustom =
        customExercises.contains(exercise);



    return ListTile(

      title: Text(exercise),


      trailing: isCustom

          ? IconButton(

              icon: const Icon(

                Icons.delete,

                color: Colors.red,

              ),


              onPressed: () {

                deleteCustomExercise(exercise);

              },

            )

          : null,



      onTap: () {

        Navigator.pop(

          context,

          exercise,

        );

      },

    );

  },

),



          ListTile(

            leading: const Icon(

              Icons.add,

              color: Colors.green,

            ),


            title: const Text(

              "Create Custom Exercise",

              style: TextStyle(

                color: Colors.green,

              ),

            ),


            onTap: createCustomExercise,

          ),


        ],

      ),

    );

  }

}