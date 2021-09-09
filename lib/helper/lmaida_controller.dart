import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lmaida/Resto/resto_page.dart';
import 'package:lmaida/service/remote_service.dart';

class LmaidaController extends GetxController {
  var isLoading = true.obs;
  var isLoadingLocation = true.obs;
  var isLoadingCategories = true.obs;
  var restList;
  var categoriesList = [].obs;
  var filtersList = [].obs;
  var locationList = [].obs;
  var userData = dynamic.obs;
  var address;
  var locationID = dynamic.obs;
  List<MultiSelectDialogItem<int>> multiItem = [];
  List<MultiSelectDialogItem<int>> locMultiItem = [];

  @override
  void onInit() {
    fetchCategories();
    fetchFilters();
    fetchLocations();
    //fetchRestaurants();
    super.onInit();
  }

  void fetchCategories() async {
    try {
      isLoadingCategories(true);
      var cats = await RemoteService.fetchCat();
      if (cats != null) {
        for (var cat in cats) categoriesList.add(cat);
      }
    } finally {
      isLoadingCategories(false);
    }
  }

  void fetchFilters() async {
    try {
      isLoading(true);
      var filters = await RemoteService.fetFilters();
      if (filters != null) {
        for (var filter in filters) {
          multiItem.add(MultiSelectDialogItem(filter["id"], filter["name"]));
        }
      }
    } finally {
      isLoading(false);
    }
  }

  void fetchLocations() async {
    try {
      isLoadingLocation(true);
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var loc = await RemoteService.fetLocation();

      await Geocoder.local
          .findAddressesFromCoordinates(
              new Coordinates(position.latitude, position.longitude))
          .then((value) async {
        address = value;
        if (loc != null) {
          for (var location in loc) {
            locMultiItem
                .add(MultiSelectDialogItem(location["id"], location["name"]));

            if (value.first.addressLine.contains(location["name"])) {
              restList = await RemoteService.fetRest(location["id"]);
              print('8855 $restList');
            }
          }
        }
      });
    } finally {
      isLoadingLocation(false);
    }
  }
}
