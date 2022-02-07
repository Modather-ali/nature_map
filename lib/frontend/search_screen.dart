import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';

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
    List _searchMatches = _allLandscapesNames
        .where((element) => element.contains(query))
        .toList();
    return ListView.builder(
      itemCount: _searchMatches.length,
      itemBuilder: (context, i) {
        return ListTile(
          onTap: () {},
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
