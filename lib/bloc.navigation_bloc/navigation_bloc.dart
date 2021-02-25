import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lmaida/Home/Components/Body.dart';
import 'package:lmaida/Home/Components/maps.dart';
import 'package:lmaida/Resto/resto_page.dart';
import 'package:lmaida/book/book.dart';
import 'package:lmaida/profile/profile_page.dart';

enum NavigationEvents {
  HomePageClickedEvent,
  MyAccountClickedEvent,
  MyOrdersClickedEvent,
  MapClickedEvent,
  RestaurantPageEvent,
  RestaurantPageEventWithParam,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc(NavigationStates initialState) : super(initialState);

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomePageClickedEvent:
        yield Body();
        break;
      case NavigationEvents.MapClickedEvent:
        yield Maps();
        break;
      case NavigationEvents.RestaurantPageEvent:
        yield RestaurantPage();
        break;
      case NavigationEvents.RestaurantPageEventWithParam:
        yield RestaurantPage(
          offers: true,
        );
        break;
      case NavigationEvents.MyAccountClickedEvent:
        yield ProfilePage();
        break;
      case NavigationEvents.MyOrdersClickedEvent:
        yield Book();
        break;
    }
  }
}
