import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/start_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.ibmPlexMono(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      bodyTextStyle: GoogleFonts.ibmPlexMono(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Welcome to Nature Map",
          body: "",
          image: _buildImage('assets/images/desert.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          reverse: true,
          title: "",
          body:
              "With Nature Map app, watch the from your phone window, and explore the greatest Landscapes on Earth",
          image: Container(
            alignment: Alignment.bottomCenter,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5D93C1),
                  Color(0xFFB0D3EF),
                  Color(0xFFB0D3EF),
                  Color(0xFFD8EBFA),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset('assets/images/image1.jpg'),
                Text(
                  "  Discover and explore ",
                  style: appTheme()
                      .textTheme
                      .headline3!
                      .copyWith(fontSize: 20, backgroundColor: Colors.white),
                ),
              ],
            ),
          ),
          decoration: pageDecoration.copyWith(
            pageColor: Colors.transparent,
            fullScreen: true,
            titlePadding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 1.0),
            imagePadding: EdgeInsets.zero,
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.bottomCenter,
          ),
        ),
        PageViewModel(
          title: "Share and enjoy",
          body:
              "Enjoy sharing your Knowledge about the landscapes you have visited, and are to visit, with Nature Map community",
          image: Image.asset('assets/images/mountain.jpg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Start now, the adventure is waiting for you",
          body: "",
          image: _buildFullscreenImage(),
          decoration: pageDecoration.copyWith(
            contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            fullScreen: true,
            bodyFlex: 2,
            imageFlex: 3,
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color: Colors.black87.withOpacity(0.6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/images/civilization.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(
    String assetName,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        image: DecorationImage(
          image: AssetImage(assetName),
        ),
      ),
      // child: Image.asset(
      //   assetName,
      //   fit: BoxFit.cover,
      // ),
    );
  }
}
