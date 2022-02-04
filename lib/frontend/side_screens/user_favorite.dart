import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:like_button/like_button.dart';

class UserFavorite extends StatefulWidget {
  const UserFavorite({Key? key}) : super(key: key);

  @override
  _UserFavoriteState createState() => _UserFavoriteState();
}

class _UserFavoriteState extends State<UserFavorite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favorite"),
      ),
    );
  }
}
