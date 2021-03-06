class BookModel {
  int id;
  int iduser;
  int iditem;
  String dates;
  int person;
  String offer;
  String statut;
  Map restoModel;
  Map user;
  String created_at;
  String updated_at;
  BookModel(
      {this.id,
      this.iduser,
      this.iditem,
      this.dates,
      this.person,
      this.offer,
      this.statut,
      this.restoModel,
      this.created_at,
      this.updated_at,
      this.user});

  BookModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    iduser = json['iduser'];
    iditem = json['iditem'];
    dates = json['dates'];
    person = json['person'];
    offer = json['offer'];
    statut = json['statut'];
    restoModel = json['item'];
    user = json['user'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}
