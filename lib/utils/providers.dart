import 'package:lmaida/Home/Components/map_model.dart';
import 'package:lmaida/Home/Components/multiple_nutifier.dart';
import 'package:lmaida/profile/Componant/edit_profile__model_view.dart';
import 'package:lmaida/profile/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => MyModel()),
  ChangeNotifierProvider(create: (_) => MultipleNotifier([])),
  ChangeNotifierProvider(create: (_) => MultipleCityNotifier([])),
  ChangeNotifierProvider(create: (_) => MultipleSpectsNotifier([])),
];
