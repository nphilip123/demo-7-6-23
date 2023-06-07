import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:narraited_mobile_app/screens/home_layout/homelayout.dart';
import 'package:narraited_mobile_app/screens/sign_in_section/signin.dart';
import 'package:narraited_mobile_app/utilities/shared_preference/sharedpreference.dart';

class SplashSection extends StatefulWidget {
  const SplashSection({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashSectionState createState() => _SplashSectionState();
}

class _SplashSectionState extends State<SplashSection> {
  @override
  void initState() {
    super.initState();
    navigatetohome();
  }

  Future<void> navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    // ignore: use_build_context_synchronously
    String name = await SharedPreferenceUtil.getUserKey();
    if (name != "null") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Homelayout(),
          ));
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignIn(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      // ignore: prefer_const_constructors
      body:Container(
          decoration: const BoxDecoration(
            color: Color(0xff252a2d)
          ),
          child: Center(
        child: SvgPicture.asset('assets/images/narraited_splash.svg'),
      ),
          ), 
    );
  }
}
