class UserModel {
  String username;
  String email;
  String contact;
  String photoUrl;
  String id;
  String password;

  UserModel({this.username, this.email, this.id, this.photoUrl, this.contact});

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    id = json['id'];
    contact = json['contact'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['photoUrl'] = this.photoUrl;
    data['id'] = this.id;
    data['contact'] = this.contact;
    data['password'] = this.password;

    return data;
  }
}
