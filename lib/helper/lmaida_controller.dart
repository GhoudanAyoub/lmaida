import 'package:get/get.dart';
import 'package:lmaida/Resto/resto_page.dart';
import 'package:lmaida/models/categorie_model.dart';
import 'package:lmaida/service/remote_service.dart';

class LmaidaController extends GetxController {
  var isLoading = true.obs;
  var restList = [].obs;
  var categoriesList = [].obs;
  var filtersList = [].obs;
  var locationList = [].obs;
  var userData = dynamic.obs;
  var multiItem = [].obs;

  @override
  void onInit() {
    fetchCategories();
    fetchFilters();
    fetchLocations();
    //fetchRestaurants();
    super.onInit();
  }

  /*void fetchRestaurants() async {
    try {
      isLoading(true);
      List<RestoModel> videos = await RemoteService.fetRest(id);
      if (videos != null) {
        restList.value = videos;
      }
    } finally {
      isLoading(false);
    }
  }*/
  void fetchCategories() async {
    try {
      isLoading(true);
      List<CategorieModel> cat = await RemoteService.fetchCat();
      if (cat != null) {
        categoriesList.value = cat;
      }
    } finally {
      isLoading(false);
    }
  }

  void fetchFilters() async {
    try {
      isLoading(true);
      var filters = await RemoteService.fetchCat();
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
      isLoading(true);
      List<dynamic> location = await RemoteService.fetLocation();
      if (location != null) {
        locationList.value = location;
      }
    } finally {
      isLoading(false);
    }
  }
}
