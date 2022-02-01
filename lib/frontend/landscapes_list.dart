import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
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
  List<QueryDocumentSnapshot<Object?>> _landscapesDataList = [];

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();

  _getLandscapesDate() async {
    _landscapesDataList = await _firebaseDatabase.getLandscapesData(
        landTag: widget.landscapeName);
    setState(() {});
  }

  @override
  void initState() {
    _getLandscapesDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        actions: [
          IconButton(
              onPressed: () {
                _getLandscapesDate();
                debugPrint(_landscapesDataList[0].id.toString());
              },
              icon: const Icon(Icons.clear_all))
        ],
        title: const TextField(
          maxLines: 1,
        ),
      ),
      body: ListView.builder(
        itemCount: _landscapesDataList.length,
        itemBuilder: (context, index) {
          return _landscapeCard(
            index: index,
            landQueryDocumentSnapshot: _landscapesDataList[index],
          );
        },
      ),
    );
  }

  Widget _landscapeCard({
    required int index,
    required QueryDocumentSnapshot<Object?> landQueryDocumentSnapshot,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 16,
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.network(
                          landQueryDocumentSnapshot["land_images"][0]),
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
          ),
        ),
      ),
    );
  }
}
