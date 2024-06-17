import 'package:flutter/material.dart';
import 'package:trainerproject/controllers/preferences/exercise_preferences.dart';
import 'package:trainerproject/models/exercise.dart';

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];
  final ExercisePreferences _exercisePreferences = ExercisePreferences();

  List<Exercise> get exercises => _exercises;

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
    _exercisePreferences.saveExercisesToStorage(_exercises);
    notifyListeners();
  }

  void removeExercise(Exercise exerciseToRemove) {
    _exercises.removeWhere((exercise) =>
        exercise.title == exerciseToRemove.title &&
        exercise.dateTime == exerciseToRemove.dateTime);
    _exercisePreferences.saveExercisesToStorage(_exercises);
    notifyListeners();
  }

  void saveModifiedExercise(Exercise modifiedExercise) {
    final index = _exercises.indexWhere((exercise) =>
        exercise.title == modifiedExercise.title &&
        exercise.dateTime == modifiedExercise.dateTime);
    if (index != -1) {
      _exercises[index] = modifiedExercise;
      _exercisePreferences.saveExercisesToStorage(_exercises);
      notifyListeners();
    }
  }

  void loadExercisesFromStorage() async {
    _exercises = await _exercisePreferences.loadExercisesFromStorage();
    notifyListeners();
  }

  void clearExercises() {
    _exercisePreferences.clearExercises();
    _exercises.clear();
    notifyListeners();
  }
}
