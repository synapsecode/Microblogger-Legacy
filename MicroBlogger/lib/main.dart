import 'dart:async';

import 'package:MicroBlogger/Composers/blogComposer.dart';
import 'package:MicroBlogger/Composers/mediacomposer.dart';
import 'package:MicroBlogger/Composers/microblogComposer.dart';
import 'package:MicroBlogger/Composers/pollComposer.dart';
import 'package:MicroBlogger/Composers/shareableComposer.dart';
import 'package:MicroBlogger/Composers/timelineComposer.dart';
import 'package:MicroBlogger/Screens/about.dart';
import 'package:MicroBlogger/Screens/bookmarks.dart';
import 'package:MicroBlogger/Screens/editprofile.dart';
import 'package:MicroBlogger/Screens/explorepage.dart';
import 'package:MicroBlogger/Screens/homepage.dart';
import 'package:MicroBlogger/Screens/newsfeedpage.dart';
import 'package:MicroBlogger/Screens/notifications.dart';
import 'package:MicroBlogger/Screens/profile.dart';
import 'package:MicroBlogger/Screens/register.dart';
import 'package:MicroBlogger/Screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Components/Global/globalcomponents.dart';
import 'Screens/login.dart';
import 'Backend/datastore.dart';
import 'package:shake/shake.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MaterialApp(
        title: 'MicroBlogger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark),
        routes: <String, WidgetBuilder>{
          //General Screens
          '/About': (BuildContext context) => new AboutPage(),
          '/NewsFeed': (BuildContext context) => new NewsFeedPage(),
          '/Login': (BuildContext context) => new LoginPage(),
          '/Register': (BuildContext context) => new RegisterPage(),
          '/Settings': (BuildContext context) => new SettingsPage(),
          '/Explore': (BuildContext context) => new ExplorePage(),

          //User screens
          '/HomePage': (BuildContext context) => new HomePage(),
          '/ProfilePage': (BuildContext context) =>
              new ProfilePage(currentUser['user']['username']),
          '/Bookmarks': (BuildContext context) => new BookmarksPage(),
          '/EditProfile': (BuildContext context) => new EditProfilePage(),
          '/Notifications': (BuildContext context) => new NotificationsPage(),

          //Composers
          '/MicroBlogComposer': (BuildContext context) => new MicroBlogComposer(
                isEditing: false,
                preExistingState: {'content': '', 'isFact': false},
              ),
          '/ShareableComposer': (BuildContext context) => new ShareableComposer(
                isEditing: false,
                preExistingState: {'content': '', 'link': '', 'name': ''},
              ),
          '/BlogComposer': (BuildContext context) => new BlogComposer(
                isEditing: false,
                preExistingState: {'content': "", 'blogName': "", 'cover': ""},
              ),
          '/PollComposer': (BuildContext context) => new PollComposer(),
          '/TimelineComposer': (BuildContext context) => new TimelineComposer(
                isEditing: false,
                preExistingState: {
                  'timelineTitle': "",
                  'events': [],
                  'cover': ""
                },
              ),
          '/MediaComposer': (BuildContext context) => new MediaComposer(
                isEditing: false,
                preExistingState: {'content': "", 'images': []},
              ),
        },
        home: MyApp()));
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String user_id = "";
  Widget payload = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: AssetImage('assets/env.png')),
        SizedBox(
          height: 10.0,
        ),
        CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
          backgroundColor: Color.fromARGB(200, 220, 20, 60),
        )
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    loadUser();
    ShakeDetector detector = ShakeDetector.autoStart(
        shakeThresholdGravity: 4.5,
        onPhoneShake: () {
          print("Shook");
          // Do stuff on phone shake
          Timer.run(() {
            showDialog(
                builder: (context) {
                  return BugReporterDialog();
                },
                context: context);
          });
        });
  }

  void loadUser() async {
    String x = await loadSavedUsername();
    setState(() {
      if (x == "") {
        payload = LoginPage();
      }
      user_id = x;
    });
    print("\nMAINSCREEN: $user_id");
    setState(() {
      if (user_id.isNotEmpty) payload = HomePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return payload;
  }
}
