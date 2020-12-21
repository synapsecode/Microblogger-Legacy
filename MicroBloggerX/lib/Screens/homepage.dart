import 'dart:async';
import 'package:MicroBlogger/Backend/server.dart';
import 'package:MicroBlogger/Components/Templates/followsuggestions.dart';
import 'package:MicroBlogger/Components/Templates/nativeVideoPlayer.dart';
import 'package:MicroBlogger/Components/Templates/youtubePlayer.dart';
import 'package:MicroBlogger/bloc/theme_change_bloc.dart';
import 'package:MicroBlogger/bloc/theme_change_event.dart';
import 'package:MicroBlogger/bloc/theme_change_state.dart';
import 'package:MicroBlogger/globalcache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Backend/datastore.dart';
import '../Components/Global/globalcomponents.dart';
import 'dart:developer';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import '../Components/Templates/postTemplates.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkConnection(context);
    return Scaffold(
      // backgroundColor: Colors.black87,
      appBar: AppBar(
        // backgroundColor: Colors.black,
        title: Text("Feed"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Fluttertoast.showToast(
                msg: "Logging Out",
                backgroundColor: Color.fromARGB(200, 220, 20, 60),
              );
              logoutSavedUser();
              Navigator.of(context).pushReplacementNamed('/Login');
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/HomePage');
            },
          ),
          BlocBuilder<ThemeChangeBloc, ThemeChangeState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.only(top: 0),
                child: Switch(
                    value: state.themeState.isLightMode,
                    onChanged: (value) {
                      BlocProvider.of<ThemeChangeBloc>(context)
                          .add(OnThemeChangedEvent(value));
                      Phoenix.rebirth(context);
                    }),
              );
            },
          )
          // IconButton(
          //   icon: Icon(Icons.send),
          //   onPressed: () => Fluttertoast.showToast(
          //     msg: "Feature Coming Soon!",
          //     backgroundColor: Color.fromARGB(200, 220, 20, 60),
          //   ),
          // ),
        ],
      ),
      body: Feed(
        currentUser: (currentUser['username']),
      ),
      drawer: MainAppDrawer(),
      floatingActionButton: FloatingCircleButton(),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}

class Feed extends StatefulWidget {
  final currentUser;
  Feed({Key key, this.currentUser}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  Future feedData;
  @override
  void initState() {
    super.initState();
    feedData = getFeed();
  }

  Widget feedBuilder(String postType, postData) {
    Widget output;
    switch (postType) {
      case "microblog":
        output = MicroBlogPost(postObject: postData);
        break;
      case "blog":
        output = BlogPost(postData);
        break;
      case "carousel":
        output = CarouselPost(postObject: postData);
        break;
      case "shareable":
        output = ShareablePost(postObject: postData);
        break;
      case "timeline":
        output = Timeline(postData);
        break;
      case "poll":
        output = PollPost(postObject: postData);
        break;
      case "ResharedWithComment":
        output = ReshareWithComment(
          postObject: postData,
        );
        break;
      case "SimpleReshare":
        output = SimpleReshare(
          postObject: postData,
        );
        break;
      case "FollowSuggestions":
        output = UserFollowSuggestions();
        break;
      case "YoutubeElement":
        output = YoutubeElement(postData);
        break;
      case "Video":
        output = VideoCarouselPost(
          postObject: postData,
        );
        break;
      default:
        break;
    }
    return output;
  }

  bool first = true;

  @override
  Widget build(BuildContext context) {
    FutureBuilder fbdr = FutureBuilder(
      future: feedData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return feedBuilder(
                  snapshot.data[index]['type'], snapshot.data[index]);
            },
          );
        } else {
          return CirclularLoader();
        }
      },
    );

    CachedFutureBuilder cbdr = CachedFutureBuilder(
      future: feedData,
      cacheStore: GlobalFeedCache,
      onCacheUsed: (cache) {
        print("Using Cache");
        return ListView.builder(
          shrinkWrap: true,
          itemCount: GlobalFeedCache.length,
          itemBuilder: (context, index) {
            return feedBuilder(
              GlobalFeedCache[index]['type'],
              GlobalFeedCache[index],
            );
          },
        );
      },
      onUpdate: (AsyncSnapshot snapshot) {
        GlobalFeedCache = [...snapshot.data];
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return feedBuilder(
              snapshot.data[index]['type'],
              snapshot.data[index],
            );
          },
        );
      },
    );

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: cbdr,
      ),
    );
  }
}