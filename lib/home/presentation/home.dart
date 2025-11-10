import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/configs/assets.dart';
import 'package:simple_bible/configs/extensions.dart';
import 'package:simple_bible/favorites/presentation/favorites_screen.dart';
import 'package:simple_bible/history/presentation/history_screen.dart';
import 'package:simple_bible/notes/presentation/note_List.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // leadingWidth: 30.w,
        centerTitle: false,
        title: Padding(
          // height: 5.h,
          padding: EdgeInsets.only(left: 1.5.w, top: 1.h),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.end,
            // textBaseline: TextBaseline.ideographic,
            children: [
              Lottie.asset(
                DateTime.now().greeting().$2,
                // LottieAssets.night,
                fit: BoxFit.contain,
                height: kToolbarHeight,
              ),
              SizedBox(
                width: 1.w,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      DateTime.now().greeting().$1,
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                    ),
                  ),
                  // Spacer(),
                  Flexible(
                      flex: 3,
                      child: Text(
                        'Welcome!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1),
                      )),
                ],
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Icon(Icons.search),
          ),
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(Icons.settings_outlined),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        // shrinkWrap: true,
        children: [
          Container(
            height: 28.h,
            padding: EdgeInsets.only(
              top: 2.h,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // clipBehavior: Clip.hardEdge,
                child: ColoredBox(
                  color: theme.primaryColor,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Verse of the Day',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 10)),
                                  Text('Sat, 07 Sep 2019',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12))
                                ],
                              ),
                              Text('John 1:01 [KJV]',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12))
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'In the beginning was the word, and the word was with God, and the word was God.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 15)),
                              // Text('John 1:1 [KJV]',
                              //     style: TextStyle(
                              //         fontWeight: FontWeight.w500,
                              //         fontSize: 10))
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: theme.primaryColorLight)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 15,
                              ),
                              Icon(
                                Icons.share,
                                size: 15,
                              ),
                              Icon(
                                Icons.more_horiz_rounded,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: .5.h,
                horizontal: 2.w,
              ),
              height: 10.h,
              decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColorLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reflections Today',
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13)),
                      Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: theme.primaryColorLight),
                              // color: theme.primaryColorLight,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.arrow_outward_sharp,
                            color: theme.primaryColorLight,
                            size: 15,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Flexible(
                    child: Text(
                      'God\'s plan for us is filled with hope.\nReflect on HIS assurances and provisions.',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScriptureScreen(),
                        )),
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.reader,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Bible Reader',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
 GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(),
                        )),                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.history,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteList(),
                        )),
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.notes,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Notes',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoritesScreen(),
                        )),
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.favourite,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Favourites',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Explore',
                  // textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              SizedBox(
                height: 1.h,
              ),
              SizedBox(
                height: 10.h,
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 1.h,
                      crossAxisCount: 2,
                      mainAxisExtent: 40.w),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorDark,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Love',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Anger',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Fear',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorDark,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Desperation',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorDark,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Hope',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Family',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: theme.primaryColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resume Reading: Genesis 1:02',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                ),
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: theme.primaryColorLight,
                        // border:
                        //     Border.all(color: theme.primaryColorLight),
                        // color: theme.primaryColorLight,
                        shape: BoxShape.circle),
                    child: Icon(
                      Icons.arrow_forward,
                      color: theme.scaffoldBackgroundColor,
                      size: 15,
                    ))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: .5.h,
                horizontal: 2.w,
              ),
              height: 15.h,
              decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColorLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favourite Verses',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 13)),
                  SizedBox(
                    height: 1.h,
                  ),
                  Flexible(
                    child: Text(
                      'Job 1:20 - "God\'s plan for us is filled with hope. Reflect on HIS assurances and provisions."',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  // color: theme.primaryColorLight,
                                  border: Border.all(
                                      color: theme.primaryColorLight),
                                  // color: theme.primaryColorLight,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.arrow_back,
                                color: theme.primaryColorLight,
                                size: 15,
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  // color: theme.primaryColorLight,
                                  border: Border.all(
                                      color: theme.primaryColorLight),
                                  // color: theme.primaryColorLight,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.arrow_forward,
                                color: theme.primaryColorLight,
                                size: 15,
                              ))
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }
}
