class LocationModel {
  int id;
  String name;
  int parent_id;
  String created_at;
  String updated_at;

  LocationModel(
      {this.id, this.name, this.parent_id, this.created_at, this.updated_at});

  LocationModel.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parent_id = json['parent_id'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}
