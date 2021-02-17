class Users {
  String name;
  String email;
  bool email_verified_at;
  String phone_number;
  String item_ids;
  String photoUrl;
  String created_at;
  String updated_at;
  String id;

  Users(
      {this.name,
      this.email,
      this.email_verified_at,
      this.phone_number,
      this.item_ids,
      this.created_at,
      this.updated_at,
      this.photoUrl,
      this.id});

  Users.fromJson(Map<dynamic, dynamic> json) {
    name = json['username'];
    email = json['email'];
    email_verified_at = json['email_verified_at'];
    phone_number = json['phone_number'];
    item_ids = json['item_ids'];
    created_at = json['created_at'];
    photoUrl = json['photoUrl'];
    updated_at = json['updated_at'];
    id = json['id'];
  }
}
