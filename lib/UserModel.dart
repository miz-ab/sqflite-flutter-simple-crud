class UserModel {
  int id;
  String firstName, lastName, phoneNo, email, image;

  UserModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.phoneNo,
      this.email,
      this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstName,
      'lastName': lastName,
      'phoneNo': phoneNo,
      'email': email,
      'image': image
    };
  }
}
