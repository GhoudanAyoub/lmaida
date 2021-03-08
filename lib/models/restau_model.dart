import 'package:lmaida/models/user.dart';

import 'categorie_model.dart';

class RestoModel {
  int id;
  String name;
  String description;
  String opening_hours_from;
  String opening_hours_to;
  String address_lon;
  String address_lat;
  String address;
  String telephone;
  String trip_advisor_id;
  String status;
  List categories;
  String pictures;
  int location_id;
  int user_id;
  String created_at;
  String updated_at;
  List<CategorieModel> list;
  List filters;
  List itemphotos;
  Map<String, dynamic> locationModel;
  double rating;
  List special_offer;
  Users user;
  List menus;
  List reviews;

  RestoModel(
      {this.id,
      this.name,
      this.description,
      this.opening_hours_from,
      this.opening_hours_to,
      this.address_lon,
      this.address_lat,
      this.address,
      this.telephone,
      this.trip_advisor_id,
      this.status,
      this.categories,
      this.pictures,
      this.location_id,
      this.user_id,
      this.created_at,
      this.updated_at,
      this.special_offer,
      this.user,
      this.list,
      this.filters,
      this.itemphotos,
      this.locationModel,
      this.menus,
      this.reviews});

  RestoModel.fromJson(Map<dynamic, dynamic> json) {
    id = json["id"];
    name = json['name'];
    description = json['description'];
    opening_hours_from = json['opening_hours_from'];
    opening_hours_to = json['opening_hours_to'];
    address_lon = json['address_lon'];
    address_lat = json['address_lat'];
    address = json['address'];
    telephone = json['telephone'];
    trip_advisor_id = json['trip_advisor_id'];
    status = json['status'];
    categories = json['category'];
    pictures = json['pictures'];
    location_id = json['location_id'];
    user_id = json['user_id'];
    list = json['list'];
    filters = json['filter'];
    special_offer = json['special_offer'];
    itemphotos = json['itemphotos'];
    locationModel = json['location'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    menus = json['menus'];
    reviews = json['reviews'];
  }
}
