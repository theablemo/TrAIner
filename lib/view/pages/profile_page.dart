import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/controllers/providers/chat_provider.dart';
import 'package:trainerproject/controllers/providers/exercise_provider.dart';
import 'package:trainerproject/controllers/providers/user_info_provider.dart';
import 'package:trainerproject/models/user_info.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ExperienceLevel _experienceLevel = ExperienceLevel.Beginner;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  // Example data for the summary section
  int totalSquats = 0;
  int correctSquats = 0;
  int wrongSquats = 0;

  @override
  void initState() {
    // Add user info to text fields
    UserInfoProvider userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    ExerciseProvider exerciseProvider =
        Provider.of<ExerciseProvider>(context, listen: false);
    final userInfo = userInfoProvider.userInfo;
    if (userInfo == null) {
      return;
    }
    firstNameController.text = userInfo.firstName;
    ageController.text = userInfo.age.toString();
    weightController.text = userInfo.weight.toString();
    heightController.text = userInfo.height.toString();
    apiKeyController.text = chatProvider.apiKey;
    _experienceLevel = userInfo.experienceLevel;

    // initialize exercises overivew
    final exercises = exerciseProvider.exercises;
    for (var exercise in exercises) {
      totalSquats += exercise.totalReps;
      correctSquats += exercise.correctReps;
      wrongSquats += exercise.wrongReps;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double correctPercentage =
        totalSquats > 0 ? correctSquats / totalSquats : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            UserInfo userInfo = UserInfo(
              firstName: firstNameController.text,
              age: ageController.text.isNotEmpty
                  ? int.parse(ageController.text)
                  : 0,
              weight: weightController.text.isNotEmpty
                  ? double.parse(weightController.text)
                  : 0.0,
              height: heightController.text.isNotEmpty
                  ? double.parse(heightController.text)
                  : 0.0,
              experienceLevel: _experienceLevel,
            );
            Provider.of<UserInfoProvider>(context, listen: false)
                .saveUserInfo(userInfo);
            Provider.of<ChatProvider>(context, listen: false)
                .setApiKey(apiKeyController.text);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Privacy Information'),
                    content: Text(
                        'None of your personal information will be disclosed to anyone. This app does not require an internet connection to operate.'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
              keyboardType: TextInputType.name,
              // onEditingComplete: (value) => print("submittet"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              // onSaved: (value) => _age = int.parse(value!),
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
              // onSaved: (value) => _weight = double.parse(value!),
            ),
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
              // onSaved: (value) => _height = double.parse(value!),
            ),
            DropdownButtonFormField<ExperienceLevel>(
              value: _experienceLevel,
              items: ExperienceLevel.values.map((ExperienceLevel level) {
                return DropdownMenuItem<ExperienceLevel>(
                  value: level,
                  child: Text(level.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _experienceLevel = value!;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(labelText: 'Gemini API Key'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              // onSaved: (value) => _height = double.parse(value!),
            ),
            SizedBox(height: 20),
            Text(
              'Exercise Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Total Squats: $totalSquats',
                        style: TextStyle(fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Correct',
                                style: TextStyle(color: Colors.green)),
                            Text('$correctSquats',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Wrong', style: TextStyle(color: Colors.red)),
                            Text('$wrongSquats',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 13.0,
                      animation: true,
                      percent: correctPercentage,
                      center: Text(
                        "${(correctPercentage * 100).toStringAsFixed(1)}% Correct",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
