import 'package:flutter/material.dart';
import '../data/exercise_library.dart';

class AddExerciseScreen extends StatelessWidget {
  final String muscleGroup;

  const AddExerciseScreen({
    super.key,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = exerciseLibrary[muscleGroup] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Exercise - $muscleGroup"),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(exercises[index]),
            onTap: () {
              Navigator.pop(context, exercises[index]);
            },
          );
        },
      ),
    );
  }
}