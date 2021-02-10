class Users {
  String name;
  String email;
  bool email_verified_at;
  String phone_number;
  String item_ids;
  String created_at;
  String updated_at;
  int id;

  Users(
      {this.name,
      this.email,
      this.email_verified_at,
      this.phone_number,
      this.item_ids,
      this.created_at,
      this.updated_at,
      this.id});

  Users.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    email_verified_at = json['email_verified_at'];
    phone_number = json['phone_number'];
    item_ids = json['item_ids'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}
