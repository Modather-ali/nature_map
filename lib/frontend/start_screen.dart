import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/landscapes_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:nature_map/frontend/search_screen.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  var connectivityResult;

  List<QueryDocumentSnapshot<Object?>> _landscapesDataList = [];
  final List _allLandscapesNames = [];

  _checkConnectivity() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {});
    debugPrint("connectivityResult: $connectivityResult");
  }

  _getLandscapesDate() async {
    if (connectivityResult != ConnectionState.none) {
      _landscapesDataList = await FirebaseDatabase().getLandscapesData(
          landTag: [
            "Mountain",
            "Sea",
            "Desert",
            "Volcano",
            "Forest",
            "Civilization"
          ]);
      for (var landscape in _landscapesDataList) {
        _allLandscapesNames.add(landscape["land_name"]);
      }
    }
  }

  @override
  void initState() {
    _checkConnectivity();
    _getLandscapesDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          body: _startScreenUI(_scaffoldKey)),
    );
  }

  Widget _startScreenUI(_scaffoldKey) {
    if (connectivityResult == ConnectivityResult.none) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No internet connection!"),
          Image.asset("assets/images/offline.jpg"),
          const SizedBox(
            height: 15,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _checkConnectivity();
                _getLandscapesDate();
                setState(() {});
              },
              child: const Text("Reload this Page"),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            height: MediaQuery.of(context).size.height / 3.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1b3a4b),
                    Color(0xFF0b525b),
                    Color(0xFF006466),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.mirror),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(120),
              ),
            ),
          ),
          ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 4.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _landscapeButton(
                      context: context,
                      imagePath: "assets/images/mountain.jpg",
                      landscapeName: ["Mountain"],
                      color: const Color(0xFF7f4f24)),
                  _landscapeButton(
                    context: context,
                    imagePath: "assets/images/sea.jpg",
                    landscapeName: ["Sea"],
                    color: const Color(0xFF014f86),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _landscapeButton(
                      context: context,
                      imagePath: "assets/images/desert.jpg",
                      landscapeName: ["Desert"],
                      color: const Color(0xFFffba08)),
                  _landscapeButton(
                    context: context,
                    imagePath: "assets/images/volcano.jpg",
                    landscapeName: ["Volcano"],
                    color: const Color(0xFFae2012),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _landscapeButton(
                    context: context,
                    imagePath: "assets/images/forest.jpg",
                    landscapeName: ["Forest"],
                    color: const Color(0xFF2d6a4f),
                  ),
                  _landscapeButton(
                    context: context,
                    imagePath: "assets/images/civilization.jpg",
                    landscapeName: ["Civilization"],
                    color: const Color(0xFF7b2cbf),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                color: Colors.white,
                onPressed: () {
                  ZoomDrawer.of(context)?.open();
                },
                icon: const Icon(Icons.menu),
              ),
              Text(
                "Nature Map",
                style: appTheme().textTheme.headline1,
              ),
              Consumer<DifferentLandsapesValus>(
                builder: (context, providerValue, child) {
                  providerValue.allLandscapesNames = _allLandscapesNames;
                  return IconButton(
                    color: Colors.white,
                    onPressed: () {
                      print("Searching...");
                      showSearch(
                          context: context,
                          delegate: SearchScreen(_allLandscapesNames));
                    },
                    icon: const Icon(Icons.search),
                  );
                },
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _landscapeButton(
      {required BuildContext context,
      required String imagePath,
      required List<String> landscapeName,
      required Color color}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LandscapesList(
                  landscapeName: landscapeName,
                  color: color,
                )));
      },
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.height / 4
            : MediaQuery.of(context).size.height / 7,
        width: MediaQuery.of(context).size.width / 2.2,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(
                65,
              ),
              topLeft: Radius.circular(65),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 5,
                offset: Offset(1, -0.5),
              )
            ],
            image: DecorationImage(
                image: AssetImage(imagePath), fit: BoxFit.fill)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(
                    65,
                  ),
                  topLeft: Radius.circular(65),
                ),
              ),
            ),
            Text(
              landscapeName[0],
              style: appTheme().textTheme.headline2,
            ),
          ],
        ),
      ),
    );
  }
}
