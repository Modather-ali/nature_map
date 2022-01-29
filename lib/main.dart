import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/side_screens/user_profile.dart';
import 'package:nature_map/frontend/start_screen.dart';
import 'package:nature_map/methods/backend/auth_methods/google_sign_in.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => LandscapeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: appTheme(),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  //final _drawerController = ZoomDrawerController();

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {}

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      //  controller: _drawerController,
      menuScreen: const MenuScreen(),
      mainScreen: const StartScreen(),
      borderRadius: 24.0,
      showShadow: true,
      angle: 0.0,
      backgroundColor: Colors.grey,
      slideWidth: MediaQuery.of(context).size.width * 0.6,
      mainScreenTapClose: true,
      disableGesture: true,
      mainScreenScale: 0.05,
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);
  _getProfileImage() {
    if (FirebaseAuth.instance.currentUser != null) {
      return NetworkImage(
          FirebaseAuth.instance.currentUser!.photoURL.toString());
    } else {
      return const AssetImage("assets/images/profile_avatar.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF52b788),
        body: ListView(
          padding: const EdgeInsets.only(top: 15, left: 20),
          children: [
            // _profileAvatar(context),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 50,
                  child: GestureDetector(
                    onTap: () {
                      //  context.read<ProviderMethods>().showState();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserProfile()));
                    },
                    child: Hero(
                      tag: "profile avatar",
                      child: CircleAvatar(
                        foregroundImage: _getProfileImage(),
                        radius: 47.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserProfile()));
              },
              leading: const Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              title: Text(
                "Profile",
                style: appTheme().textTheme.headline2,
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.landscape_outlined,
                color: Colors.white,
              ),
              title: Text(
                "Activity",
                style: appTheme().textTheme.headline2,
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.favorite_border_outlined,
                color: Colors.white,
              ),
              title: Text(
                "Favorite",
                style: appTheme().textTheme.headline2,
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              title: Text(
                "About",
                style: appTheme().textTheme.headline2,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // side: BorderSide(),
                      primary: Color(0xFF1b3a4b),
                    ),
                    onPressed: () {
                      logOut();
                    },
                    child: const Text("Log out")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //  Consumer<ProviderMethods>(builder: (context, proiderValue, child) {
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              textStyle: appTheme().textTheme.headline2!.copyWith(fontSize: 14),
              primary: Colors.blueGrey),
          onPressed: () {},
          child: const Text("Log In"),
        ),
        //  }),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              textStyle: appTheme().textTheme.headline2!.copyWith(fontSize: 14),
              primary: Colors.deepPurpleAccent),
          onPressed: () {},
          child: const Text("New account"),
        ),
      ],
    );
  }
}


// AIzaSyDEbonPdi7tbY5xB3uRVAA7SMPMHyvQDcg