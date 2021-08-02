import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lmaida/Home/Components/maps.dart';

import '../bloc.navigation_bloc/navigation_bloc.dart';
import 'sidebar.dart';

class SideBarLayout extends StatefulWidget {
  @override
  _SideBarLayoutState createState() => _SideBarLayoutState();
}

class _SideBarLayoutState extends State<SideBarLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new WillPopScope(
          onWillPop: () async => false,
          child: BlocProvider<NavigationBloc>(
            create: (context) => NavigationBloc(Maps()),
            child: Stack(
              children: <Widget>[
                BlocBuilder<NavigationBloc, NavigationStates>(
                  builder: (context, navigationState) {
                    return navigationState as Widget;
                  },
                ),
                SideBar(),
              ],
            ),
          )),
    );
  }
}
