class User {
  late final String? id;
  late final String? firstName;
  late final String? lastName;
  late final String? email;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email']
    );
  }
}