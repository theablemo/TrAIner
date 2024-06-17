import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainerproject/models/exercise.dart';

class ExercisePreferences {
  static const String exercisesKey = 'exercises';

  Future<void> saveExercisesToStorage(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        exercisesKey, jsonEncode(exercises.map((e) => e.toJson()).toList()));
  }

  Future<List<Exercise>> loadExercisesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getString(exercisesKey);
    if (exercisesJson == null) return [];
    final List<dynamic> decodedJson = jsonDecode(exercisesJson);
    return decodedJson.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<void> clearExercises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(exercisesKey);
  }
}
