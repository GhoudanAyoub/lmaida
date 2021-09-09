import 'dart:convert';

class CategorieModel {
  int id;
  String name;
  String picture;
  int parent_id;
  String created_at;
  String updated_at;
  bool value;

  CategorieModel(
      {this.id,
      this.name,
      this.picture,
      this.parent_id,
      this.created_at,
      this.updated_at});

  CategorieModel.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    name = json['name'];
    picture = json['picture'];
    parent_id = json['parent_id'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}

List<CategorieModel> userModelFromJson(String str) => List<CategorieModel>.from(
    json.decode(str).map((x) => CategorieModel.fromJson(x)));
