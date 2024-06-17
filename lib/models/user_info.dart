enum ExperienceLevel { Beginner, Intermediate, Advanced }

class UserInfo {
  String firstName;
  int age;
  double weight;
  double height;
  ExperienceLevel experienceLevel;

  UserInfo({
    required this.firstName,
    required this.age,
    required this.weight,
    required this.height,
    required this.experienceLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'age': age,
      'weight': weight,
      'height': height,
      'experienceLevel':
          experienceLevel.toString().split('.').last, // Save as string
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      firstName: map['firstName'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['experienceLevel'],
      ),
    );
  }
}
