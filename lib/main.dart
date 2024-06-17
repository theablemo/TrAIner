import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/constants.dart';
import 'package:trainerproject/controllers/providers/camera_provider.dart';
import 'package:trainerproject/controllers/providers/exercise_provider.dart';
import 'package:trainerproject/controllers/providers/pose_provider.dart';
import 'package:trainerproject/controllers/providers/user_info_provider.dart';
import 'package:trainerproject/view/pages/user_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PoseProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => PoseCheck(),
        // ),
        ChangeNotifierProvider(
          create: (_) => CameraProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserInfoProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'TrAIner',
        theme: ThemeData(
          primaryColor: primaryColor,
          hintColor: accentColor,
          scaffoldBackgroundColor: backgroundColor,
          cardColor: errorColor,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: textColor),
            bodyMedium: TextStyle(color: textColor),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
          ),
          buttonTheme: const ButtonThemeData(
            buttonColor: accentColor,
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        home: UserInfoAppEntry(),
      ),
    );
  }
}
