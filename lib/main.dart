import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/workout.dart';
import 'screens/create_workout_screen.dart';
import 'screens/workout_screen.dart';

import 'models/exercise.dart';
import 'models/muscle_group.dart';
import 'screens/edit_workout_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

import 'services/user_service.dart';
import 'services/workout_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(MuscleGroupAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  await Hive.openBox('profile');
  await Hive.openBox('muscleGroups');
  await Hive.openBox('workouts');
  await Hive.openBox('customMuscleGroups');
  await Hive.openBox('customExercises');

  runApp(const AuthGate());
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const GymTrackerApp();
        }

        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
        );
      },
    );
  }
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
  String name = "";
  double weight = 0.0;
  List<Workout> workouts = <Workout>[];
  bool isProfileLoading = true;
  bool isWorkoutsLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadWorkouts();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await UserService.loadProfile();

      setState(() {
        name = profile['name'];
        weight = profile['weight'];
        isProfileLoading = false;
      });
    } catch (e) {
      final cached = UserService.getCachedProfile();

      setState(() {
        name = cached['name'];
        weight = cached['weight'];
        isProfileLoading = false;
      });
    }
  }

  Future<void> loadWorkouts() async {
    final loaded = await WorkoutService.loadWorkouts();

    setState(() {
      workouts = loaded;
      isWorkoutsLoading = false;
    });
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

  void editProfile() {
    TextEditingController nameController = TextEditingController(text: name);

    TextEditingController weightController =
        TextEditingController(text: weight.toString());

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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                  if (nameController.text.isEmpty) {
                    name = "Your Name";
                  } else {
                    name = nameController.text;
                  }

                  weight = double.tryParse(weightController.text) ?? 0.0;
                });

                await UserService.saveProfile(
                  name: name,
                  weight: weight,
                );

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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
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
              child: isProfileLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      ),
                    )
                  : Column(
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
                            "ACCOUNT SETTINGS",
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
                      builder: (context) => const CreateWorkoutScreen(),
                    ),
                  );

                  if (newWorkout != null) {
                    await WorkoutService.addWorkout(newWorkout);

                    setState(() {
                      workouts.add(newWorkout);
                    });

                    await WorkoutService.cacheWorkouts(workouts);
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
              child: isWorkoutsLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    )
                  : workouts.isEmpty
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
                                      onWorkoutUpdated: (updatedWorkout) async {
                                        updatedWorkout.id = workout.id;

                                        await WorkoutService.updateWorkout(
                                          updatedWorkout,
                                        );

                                        setState(() {
                                          int index =
                                              workouts.indexOf(workout);
                                          workouts[index] = updatedWorkout;
                                        });

                                        await WorkoutService.cacheWorkouts(
                                          workouts,
                                        );
                                      },
                                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          workout.name,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.green,
                                              ),
                                              onPressed: () async {
                                                final updatedWorkout =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditWorkoutScreen(
                                                      workout: workout,
                                                    ),
                                                  ),
                                                );

                                                if (updatedWorkout != null) {
                                                  updatedWorkout.id =
                                                      workout.id;

                                                  await WorkoutService
                                                      .updateWorkout(
                                                    updatedWorkout,
                                                  );

                                                  setState(() {
                                                    int index = workouts
                                                        .indexOf(workout);
                                                    workouts[index] =
                                                        updatedWorkout;
                                                  });

                                                  await WorkoutService
                                                      .cacheWorkouts(
                                                    workouts,
                                                  );
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                bool confirm =
                                                    await confirmDelete(
                                                  context,
                                                  workout.name,
                                                );

                                                if (confirm) {
                                                  await WorkoutService
                                                      .deleteWorkout(workout);

                                                  setState(() {
                                                    workouts.remove(workout);
                                                  });

                                                  await WorkoutService
                                                      .cacheWorkouts(
                                                    workouts,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
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