import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({Key? key}) : super(key: key);

  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Image.asset(
              "assets/images/forest.jpg",
              fit: BoxFit.contain,
            ),
            title: Text(
              _packageInfo.appName,
              style: appTheme()
                  .textTheme
                  .headline3, //!.copyWith(color: Colors.black),
            ),
            subtitle: Text(
              "V " + _packageInfo.version,
              style: appTheme().textTheme.headline4,
            ),
          ),
          const Divider(),
          // ListTile(
          //   onTap: () {},
          //   leading: const Icon(
          //     Icons.star,
          //     color: Colors.orange,
          //     size: 30,
          //   ),
          //   title: Text(
          //     "Rate us ",
          //     style: appTheme().textTheme.headline4,
          //   ),
          //   trailing: const Icon(
          //     Icons.arrow_forward_ios_rounded,
          //     color: Colors.black,
          //     size: 20,
          //   ),
          // )
        ],
      ),
    );
  }
}
