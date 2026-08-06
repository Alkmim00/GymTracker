import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/workout.dart';
import '../models/muscle_group.dart';
import '../services/exercise_service.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late TextEditingController workoutController;

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
  late List<MuscleGroup> selectedMuscles;

  @override
  void initState() {
    super.initState();

    workoutController = TextEditingController(
      text: widget.workout.name,
    );

    selectedMuscles = List.from(widget.workout.muscleGroups);

    syncAndLoadMuscleGroups();
  }

  Future<void> syncAndLoadMuscleGroups() async {
    await ExerciseService.syncCustomMuscleGroups();
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

  void createCustomMuscleGroup() {
    TextEditingController controller = TextEditingController();

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
                if (controller.text.trim().isEmpty) {
                  return;
                }

                String newMuscle = controller.text.trim();

                var box = Hive.box('customMuscleGroups');

                final newGroup = MuscleGroup(
                  name: newMuscle,
                  exercises: [],
                );

                await box.add(newGroup);
                await ExerciseService.addCustomMuscleGroup(newGroup);

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
                var box = Hive.box('customMuscleGroups');

                var muscle = box.values.firstWhere(
                  (item) => item.name == name,
                );

                muscle.isDeleted = true;
                await muscle.save();
                await ExerciseService.updateCustomMuscleGroup(muscle);

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

  bool isCustomMuscleGroup(String name) {
    var box = Hive.box('customMuscleGroups');

    return box.values.any(
      (muscle) => muscle.name == name,
    );
  }

  void saveWorkout() {
    widget.workout.name = workoutController.text;
    widget.workout.muscleGroups = selectedMuscles;

    Navigator.pop(
      context,
      widget.workout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Workout",
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
                          if (value == true) {
                            selectedMuscles.add(
                              MuscleGroup(
                                name: muscle,
                                exercises: [],
                              ),
                            );
                          } else {
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
                ),
                onPressed: saveWorkout,
                child: const Text(
                  "SAVE CHANGES",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}