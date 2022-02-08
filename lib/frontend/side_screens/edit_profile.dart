import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/support_screens/image_view.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/enums.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _textEditingController = TextEditingController();
  var _userData;

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();

  _getUserData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      _userData = await _firebaseDatabase.getUserData(
          userEmail: FirebaseAuth.instance.currentUser!.email.toString());
      _textEditingController.text = _userData["user_name"];
      setState(() {});
    }
  }

  @override
  void initState() {
    _getUserData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _userData == null
            ? const Center(
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                    colors: kDefaultRainbowColors,
                    strokeWidth: 4.0,
                  ),
                ),
              )
            : _editScreenUI());
  }

  Widget _editScreenUI() {
    return ListView(
      padding: const EdgeInsets.only(top: 50, right: 15, left: 15),
      children: [
        CircleAvatar(
          backgroundColor: Colors.black,
          radius: 80,
          child: Hero(
            tag: "profile avatar",
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageView(
                          imageType: ImageType.networkImage,
                          imagePath: _userData["profile_image_link"].toString(),
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(
                      _userData["profile_image_link"].toString(),
                    ),
                    radius: 78,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    iconSize: 35,
                    //color: const Color(0xFF52b788),

                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height / 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Change your profile photo:",
                                  style: appTheme().textTheme.headline4,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _choiceImageButton(
                                        source: "From Gallery",
                                        imageSource: ImageSource.gallery,
                                        iconData: Icons.add_a_photo_outlined),
                                    _choiceImageButton(
                                        source: "From Camera",
                                        imageSource: ImageSource.camera,
                                        iconData: Icons.image_outlined),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add_a_photo),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(),
        ),
        const SizedBox(
          height: 10,
        ),
        CheckboxListTile(
            selectedTileColor: Colors.green,
            title: Text(
              FirebaseAuth.instance.currentUser!.email.toString(),
              style: appTheme().textTheme.headline3,
            ),
            value: _userData['show_email'],
            onChanged: (isChanged) {})
      ],
    );
  }

  Widget _choiceImageButton(
      {required String source,
      required ImageSource imageSource,
      required IconData iconData}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () async {
            try {
              final XFile? _selectedImage = await ImagePicker().pickImage(
                source: imageSource,
                imageQuality: 1,
              );
              if (_selectedImage != null) {
                Navigator.pop(context);
              }
            } catch (e) {
              debugPrint("error in choice image: $e");
            }
          },
          child: Icon(iconData),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          source,
          style: appTheme().textTheme.headline3!.copyWith(fontSize: 14),
        )
      ],
    );
  }
}
