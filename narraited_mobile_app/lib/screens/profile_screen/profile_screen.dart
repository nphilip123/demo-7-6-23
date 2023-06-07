import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapters.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';
import 'package:provider/provider.dart';

import '../../provider/userAuthSection/user_auth_controller.dart';
// import '../../utilities/icons/profile_screen_icons_icons.dart';
import '../../utilities/shared_preference/sharedpreference.dart';
import '../sign_in_section/signin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ignore: prefer_typing_uninitialized_variables
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserAuthContoller>(context, listen: false).setUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            // ignore: sized_box_for_whitespace
            Consumer<UserAuthContoller>(
                // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
                builder: (context, UserAuthContoller, child) {
              // ignore: sized_box_for_whitespace
              return Container(
                height: MediaQuery.of(context).size.height * 0.40,
                width: MediaQuery.of(context).size.width,
                // ignore: prefer_const_constructors
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    CircleAvatar(
                      maxRadius: 70,
                      child: SvgPicture.asset(
                        'assets/images/profile_picture_default.svg',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // ignore: prefer_const_constructors
                      Text(UserAuthContoller.userName,
                        style: Styles.ProfileScreen_Style_1,
                      ),
                      Text(UserAuthContoller.userEmail),
                  ],
                ),
              );
            }),
            // Row(
            //   children: [
            //     Icon(
            //       ProfileScreenIcons.voice,
            //       color: Colors.blue[800],
            //       size: 30,
            //     ),
            //     const SizedBox(
            //       width: 20,
            //     ),
            //     const Text(
            //       "Voice Selection",
            //       style: Styles.ProfileScreen_Style_2,
            //     )
            //   ],
            // ),
            const Divider(),
            Expanded(
                child: ListView(
              children: [
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.brush_outlined,
                //       color: Color(0xff5F5F5F),
                //       size: 30,
                //     ),
                //     const SizedBox(
                //       width: 20,
                //     ),
                //     TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           "Appearance",
                //           style: Styles.ProfileScreen_Style_2,
                //         ))
                //   ],
                // ),
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.notifications_none,
                //       color: Color(0xff5F5F5F),
                //       size: 30,
                //     ),
                //     const SizedBox(
                //       width: 20,
                //     ),
                //     TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           "Notification",
                //           style: Styles.ProfileScreen_Style_2,
                //         ))
                //   ],
                // ),
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.shield_outlined,
                //       color: Color(0xff5F5F5F),
                //       size: 30,
                //     ),
                //     const SizedBox(
                //       width: 20,
                //     ),
                //     TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           "Privacy",
                //           style: Styles.ProfileScreen_Style_2,
                //         ))
                //   ],
                // ),
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.help,
                //       color: Color(0xff5F5F5F),
                //       size: 30,
                //     ),
                //     const SizedBox(
                //       width: 12,
                //     ),
                //     TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           "Help",
                //           style: Styles.ProfileScreen_Style_2,
                //         ))
                //   ],
                // ),
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.settings,
                //       color: Color(0xff5F5F5F),
                //       size: 30,
                //     ),
                //     const SizedBox(
                //       width: 20,
                //     ),
                //     TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           "Settings",
                //           style: Styles.ProfileScreen_Style_2,
                //         ))
                //   ],
                // ),
                Row(
                  children: [
                    const Icon(
                      Icons.logout_outlined,
                      color: Color(0xff5F5F5F),
                      size: 30,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                        onPressed: () async {
                          await UserAuthContoller.logout();
                          // ignore: use_build_context_synchronously
                          Provider.of<ChaptersList>(context, listen: false)
                              .reset();
                          if (await SharedPreferenceUtil.getUserKey() ==
                              "null") {
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignIn(),
                                ));
                          }
                        },
                        child: const Text(
                          "Logout",
                          style: Styles.ProfileScreen_Style_2,
                        ))
                  ],
                ),
              ],
            )),
            const Text("Version 0.1.4"),
          ],
        ),
      ),
    );
  }
}
