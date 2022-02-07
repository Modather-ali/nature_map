import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';

class SearchScreen extends SearchDelegate {
  final List _allLandscapesNames;
  SearchScreen(this._allLandscapesNames);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    QueryDocumentSnapshot<Object?>? _landscapeData;
    List _searchMatches = _allLandscapesNames
        .where((element) => element.contains(query))
        .toList();
    return ListView.builder(
      itemCount: _searchMatches.length,
      itemBuilder: (context, i) {
        return ListTile(
          onTap: () async {
            query = _searchMatches[i];
            _landscapeData = (await FirebaseDatabase().getLandscapesDataByName(
              landscapeName: "${_searchMatches[i]}",
            ))!;
            if (_landscapeData == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(message: "Error happened!", color: Colors.red));
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MapScreen(landscapeData: _landscapeData!),
                ),
              );
            }
          },
          title: Text(
            "${_searchMatches[i]}",
            style:
                appTheme().textTheme.headline4!.copyWith(color: Colors.black),
          ),
          trailing: const Icon(Icons.search),
        );
      },
    );
  }
}
