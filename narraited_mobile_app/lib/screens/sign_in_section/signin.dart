import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/userAuthSection/user_auth_controller.dart';
import '../../utilities/shared_preference/sharedpreference.dart';
import '../../utilities/styles.dart';
import '../home_layout/homelayout.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<SignIn> {
  bool signInStatus = true;

  Future launchEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }
    final Uri url = Uri(
      scheme: 'mailto',
      path: 'hello@narraited.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Request for narraited app access',
        'body': 'Hello,\n\nI would like to request access to NarrAIted.\n\nThanks'
      }),
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Error on email link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Visibility(
          visible: signInStatus,
          replacement: LoadingAnimationWidget.staggeredDotsWave(
            color: const Color(0xff1C75B6),
            size: 35,
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.90,
              maxHeight: MediaQuery.of(context).size.height * 0.30,
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/narraited_signup.svg',
                ),
                const SizedBox(
                  height: 50.0,
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      signInStatus = false;
                    });
                    final status = await UserAuthContoller.signin();
                    if (status == "success" &&
                        await SharedPreferenceUtil.getUserKey() != "null") {
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Homelayout(),
                          ));
                    } else {
                      setState(() {
                        signInStatus = true;
                      });
                      String? message = status;
                      if (message == "UNAUTHORISED") {
                        message = "Your account is yet to be activated.";
                      }
                      setState(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          // ignore: prefer_const_constructors
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message!,style: Styles.NotificationStyle,),
                                if (status == "UNAUTHORISED")
                                  InkWell(
                                    child: RichText(text: const TextSpan(
                                      children: [
                                        TextSpan(text: "Contact ",style: Styles.NotificationStyle),
                                        TextSpan(text: "hello@narraited.com",style: Styles.NotificationLinkStyle),
                                      ]
                                    ),),
                                    onTap: () {
                                      launchEmail();
                                    },
                                  )
                              ],
                            ),
                            action: SnackBarAction(
                              textColor: Colors.white,
                              label: 'Close',
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                            backgroundColor: status == "UNAUTHORISED"
                                ? Colors.blue
                                : Colors.red,
                          ),
                        );
                      });
                    }
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/google_signin.svg',
                            height: 25,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text("Sign in with Google",
                              style: Styles.SignInStyle),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    ));
  }
}
