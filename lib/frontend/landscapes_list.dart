import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

class LandscapesList extends StatefulWidget {
  final String landscapeName;
  final Color color;
  const LandscapesList(
      {Key? key, this.color = Colors.blue, required this.landscapeName})
      : super(key: key);

  @override
  _LandscapesListState createState() => _LandscapesListState();
}

class _LandscapesListState extends State<LandscapesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.clear_all))
        ],
        title: const TextField(
          maxLines: 1,
        ),
      ),
      body: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return _landscapeCard();
          }),
    );
  }

  Widget _landscapeCard() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 16,
        child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: Row(
              children: [
                // Consumer<ProviderMethods>(
                //     builder: (context, proiderValue, child) {
                //   return IconButton(
                //       onPressed: () {
                //     //    print(proiderValue.isRegister);
                //       },
                //       icon: const Icon(Icons.clear_all));
                // }),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset("assets/images/sea.jpg"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MapScreen()));
                            },
                            child: const Text("View the site")),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "landscape name",
                        style: appTheme().textTheme.headline3,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Contery / Area",
                        style: appTheme().textTheme.headline3,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Wrap(
                        children: const [
                          Card(
                            elevation: 18,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Text("Sea"),
                            ),
                            color: Colors.blue,
                          ),
                          Card(
                            elevation: 18,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Text("Mountains"),
                            ),
                            color: Colors.brown,
                          ),
                          Card(
                            elevation: 18,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Text("Deserts"),
                            ),
                            color: Colors.yellow,
                          ),
                          Card(
                            elevation: 18,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Text("Volcano"),
                            ),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
