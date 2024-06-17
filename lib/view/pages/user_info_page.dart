import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:trainerproject/controllers/providers/user_info_provider.dart';
import 'package:trainerproject/models/user_info.dart';
import 'package:trainerproject/view/pages/home_page.dart';

class UserInfoAppEntry extends StatefulWidget {
  @override
  _UserInfoAppEntryState createState() => _UserInfoAppEntryState();
}

class _UserInfoAppEntryState extends State<UserInfoAppEntry> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  int _age = 0;
  double _weight = 0.0;
  double _height = 0.0;
  ExperienceLevel _experienceLevel = ExperienceLevel.Beginner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserInfo();
    });
  }

  Future<void> _checkUserInfo() async {
    UserInfoProvider userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();
    if (userInfoProvider.userInfo == null) {
      _showUserInfoDialog();
    }
  }

  void _showUserInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your information'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'First Name'),
                    onSaved: (value) => _firstName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _age = int.parse(value!),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _weight = double.parse(value!),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _height = double.parse(value!),
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
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  UserInfo userInfo = UserInfo(
                    firstName: _firstName,
                    age: _age,
                    weight: _weight,
                    height: _height,
                    experienceLevel: _experienceLevel,
                  );
                  Provider.of<UserInfoProvider>(context, listen: false)
                      .saveUserInfo(userInfo);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('User Information'),
    //   ),
    //   body: Center(
    //     child: Consumer<UserInfoProvider>(
    //       builder: (context, userInfoProvider, child) {
    //         if (userInfoProvider.userInfo == null) {
    //           return CircularProgressIndicator();
    //         } else {
    //           UserInfo userInfo = userInfoProvider.userInfo!;
    //           return Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               Text('First Name: ${userInfo.firstName}'),
    //               Text('Age: ${userInfo.age}'),
    //               Text('Weight: ${userInfo.weight}'),
    //               Text('Height: ${userInfo.height}'),
    //               Text(
    //                   'Experience Level: ${userInfo.experienceLevel.toString().split('.').last}'),
    //             ],
    //           );
    //         }
    //       },
    //     ),
    //   ),
    // );
    return HomePage();
  }
}
