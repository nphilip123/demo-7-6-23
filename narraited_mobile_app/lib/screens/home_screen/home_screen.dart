import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapters.dart';
import 'package:narraited_mobile_app/screens/biographyScreen/biography_screen.dart';
import 'package:narraited_mobile_app/screens/home_screen/life_event_card.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cardInsertName = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
  // var userDetail;
  // ignore: prefer_typing_uninitialized_variables
  var chapters;

  bool chapterLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChaptersList>(context, listen: false).loadChapters();
    });
  }

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: const Color(0xff252a2d),
          title: Center(
            child: SvgPicture.asset('assets/images/narraited_appbar.svg'),
          )),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            const SizedBox(
              height: 5,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xff3c83cb),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                      enableDrag: false,
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        // ignore: prefer_const_constructors
                        return BiographyScreen();
                      });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/images/HomeScreenBooks.svg',
                    ),
                    const Text(
                      "Generated Biography",
                      style: Styles.HomeScreen_Style_8,
                    )
                  ],
                ),
              ),
            ),
            // ignore: prefer_const_literals_to_create_immutables
            Row(
              children: [
                // ignore: prefer_const_constructors
                Expanded(
                    flex: 5,
                    child: const Text("Biography Life Events",
                        style: Styles.HomeScreen_Style_2)),
                const Spacer(),
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                      color: Color(0xff3c83cb),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(30.0)),
                                color: Colors.white),
                            padding: MediaQuery.of(context).viewInsets,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Name',
                                        style: Styles.HomeScreen_Style_4,
                                      ),
                                      TextFormField(
                                        controller: cardInsertName,
                                        decoration: const InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Color(0xffC9C9C9)),
                                            ),
                                            border: InputBorder.none,
                                            focusedBorder:
                                                OutlineInputBorder()),
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(60, 0, 60, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff1C75B6),
                                            elevation: 0.0),
                                        child: const Text('Add Chapter',
                                            style: Styles.HomeScreen_Style_7),
                                        onPressed: () async {
                                          final response = await ChaptersList
                                              .addUserChapters(
                                                  cardInsertName.text);
                                          if (response != "Error" &&
                                              cardInsertName.text.isNotEmpty &&
                                              response['Category'] != null) {
                                            // ignore: use_build_context_synchronously
                                            Provider.of<ChaptersList>(context,
                                                    listen: false)
                                                .insertnewChapter(
                                                    0,
                                                    cardInsertName.text,
                                                    response['Category']);
                                            cardInsertName.clear();
                                          }
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0.0),
                                        child: const Text(
                                          'Cancel',
                                          style: Styles.HomeScreen_Style_6,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            Flexible(
                flex: 20,
                child: Consumer<ChaptersList>(
                    // ignore: non_constant_identifier_names, avoid_types_as_parameter_names
                    builder: (context, ChaptersList, child) {
                  final generatedChapterCards = List.generate(
                    ChaptersList.chapterList.length,
                    (index) => LifeEventCard(
                      key: Key('$index'),
                      cardTitle: ChaptersList.chapterList[index].chapterName!,
                      categoryId: ChaptersList.chapterList[index].categoryId!,
                      status: ChaptersList.chapterList[index].status!,
                      index: index,
                      cardColor: ChaptersList.chapterList[index].chapterColor!,
                    ),
                  );
                  return Visibility(
                    visible: ChaptersList.chapterLoadStatus,
                    replacement: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: const Color(0xff1C75B6),
                        size: 25,
                      ),
                    ),
                    child: ReorderableBuilder(
                      scrollController: _scrollController,
                      onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
                        for (final orderUpdateEntity in orderUpdateEntities) {
                          final tempChapter = ChaptersList.chapterList
                              .removeAt(orderUpdateEntity.oldIndex);
                          ChaptersList.chapterList
                              .insert(orderUpdateEntity.newIndex, tempChapter);
                        }
                        ChaptersList.updateReorder();
                        ChaptersList.rearrange();
                      },
                      builder: (children) {
                        return GridView(
                          key: _gridViewKey,
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          children: children,
                        );
                      },
                      children: generatedChapterCards,
                    ),
                  );
                }))
          ],
        ),
      ),
    );
  }
}
