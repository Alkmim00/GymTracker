import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/workout.dart';
import 'screens/create_workout_screen.dart';
import 'screens/workout_screen.dart';

import 'models/exercise.dart';
import 'models/muscle_group.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();


  Hive.registerAdapter(ExerciseAdapter());

  Hive.registerAdapter(MuscleGroupAdapter());

  Hive.registerAdapter(WorkoutAdapter());




  await Hive.openBox('profile');

  await Hive.openBox('workouts');


  runApp(const GymTrackerApp());

}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101010),
        primaryColor: Colors.green,
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.greenAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

@override
void initState() {

  super.initState();

  loadProfile();

  loadWorkouts();

}
void saveWorkouts() {

  var box = Hive.box('workouts');


  box.put(

    'myWorkouts',

    workouts,

  );

}

Future<bool> confirmDelete(BuildContext context, String name) async {

  final result = await showDialog<bool>(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
          "Delete Workout?",
        ),


        content: Text(
          "Are you sure you want to delete \"$name\"?",
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

  );


  return result ?? false;

}

  String name = "";
  String weight = "";
  List<Workout> workouts = <Workout>[];

  void loadProfile() {
    
  var box = Hive.box('profile');

  setState(() {
    name = box.get('name', defaultValue: 'Diego');
    weight = box.get('weight', defaultValue: '170');
  });
}
void loadWorkouts() {

  var box = Hive.box('workouts');


  var saved = box.get('myWorkouts');


  if (saved != null) {

    setState(() {

      workouts = List<Workout>.from(saved);

    });

  }

}
  void editProfile() {

    TextEditingController nameController =
        TextEditingController(text: name);

    TextEditingController weightController =
        TextEditingController(text: weight);


    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          backgroundColor: const Color(0xFF1E1E1E),

          title: const Text(
            "Edit Profile",
          ),


          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(

                controller: nameController,

                decoration: const InputDecoration(
                  labelText: "Name",
                ),
              ),


              TextField(

                controller: weightController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Weight (lbs)",
                ),
              ),

            ],
          ),



          actions: [

            TextButton(

              onPressed: () async {

                setState(() {
                  name = nameController.text;
                  weight = weightController.text;
                });

                var box = Hive.box('profile');

                await box.put('name', name);
                await box.put('weight', weight);

                Navigator.pop(context);
              },

              child: const Text(
                "SAVE",
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
          "Gym Tracker",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),


      body: Padding(

        padding: const EdgeInsets.all(16),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),


              decoration: BoxDecoration(

                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(20),

              ),


              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,


                children: [

                  Text(

                    name,

                    style: const TextStyle(

                      fontSize: 28,

                      fontWeight: FontWeight.bold,

                    ),

                  ),


                  const SizedBox(height: 10),


                  Text(

                    "Weight: $weight lbs",

                    style: const TextStyle(

                      color: Colors.grey,

                      fontSize: 16,

                    ),

                  ),



                  const SizedBox(height: 20),



                  ElevatedButton(

                    onPressed: editProfile,

                    child: const Text(
                      "EDIT PROFILE",
                    ),

                  ),

                ],

              ),

            ),



            const SizedBox(height: 25),



            SizedBox(

              width: double.infinity,


              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  padding: const EdgeInsets.all(18),

                  backgroundColor: Colors.green,

                  foregroundColor: Colors.black,

                ),


                onPressed: () async {

  final Workout? newWorkout = await Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) =>
          const CreateWorkoutScreen(),

    ),

  );


 if (newWorkout != null) {

    setState(() {

      workouts.add(newWorkout);

    });


    saveWorkouts();

  }

},


                child: const Text(

                  "+ CREATE WORKOUT",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.bold,

                  ),

                ),

              ),

                        ),


            const SizedBox(height: 30),


            const Text(

              "MY WORKOUTS",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),


            const SizedBox(height: 15),


            Expanded(

  child: workouts.isEmpty

      ? const Text(
          "No workouts created yet",

          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),

        )

      : ListView.builder(

          itemCount: workouts.length,

          itemBuilder: (context, index) {

            Workout workout = workouts[index];

            return InkWell(

  onTap: () {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) => WorkoutScreen(

  workout: workout,

  onWorkoutUpdated: (updatedWorkout) {

    setState(() {

      int index = workouts.indexOf(workout);

      workouts[index] = updatedWorkout;

    });


    saveWorkouts();

  },

)

      ),

    );

  },

  child: Container(

              margin: const EdgeInsets.only(bottom: 12),

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(18),

              ),

              child: Column(

  crossAxisAlignment: CrossAxisAlignment.start,

  children: [

    Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        Text(

          workout.name,

          style: const TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

          ),

        ),


        IconButton(

          icon: const Icon(

            Icons.delete,

            color: Colors.red,

          ),

          onPressed: () async {

  bool confirm = await confirmDelete(

    context,

    workout.name,

  );


  if (confirm) {

    setState(() {

      workouts.remove(workout);

    });


    saveWorkouts();

  }

},

        ),

      ],

    ),


    const SizedBox(height: 8),


    Text(

      workout.muscleGroups

        .map((muscle) => muscle.name)

        .join(" • "),


      style: const TextStyle(

        color: Colors.grey,

      ),

    ),

  ],

),
  ),

            );

          },

        ),

),
          ],

        ),

      ),

    );

  }
}