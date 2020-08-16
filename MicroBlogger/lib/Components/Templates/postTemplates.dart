import 'dart:ui';

import 'package:MicroBlogger/Backend/server.dart';
import 'package:MicroBlogger/Screens/profile.dart';
import 'package:MicroBlogger/Views/blog_viewer.dart';
import 'package:MicroBlogger/Views/shareableWebViewer.dart';
import 'package:MicroBlogger/Views/timeline_viewer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'basetemplate.dart';
import '../../Backend/datastore.dart';

class MicroBlogPost extends StatelessWidget {
  final postObject;
  final isInViewMode;
  final bool isHosted;
  const MicroBlogPost(
      {Key key,
      this.postObject,
      this.isHosted = false,
      this.isInViewMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: postObject,
        isHosted: isHosted,
        isInViewMode: isInViewMode,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${postObject['content']}"),
        ]));
  }
}

class CarouselPost extends StatefulWidget {
  final postObject;
  final isInViewMode;
  final bool isHosted;
  const CarouselPost(
      {Key key,
      this.postObject,
      this.isHosted = false,
      this.isInViewMode = false})
      : super(key: key);

  @override
  _CarouselPostState createState() => _CarouselPostState();
}

class _CarouselPostState extends State<CarouselPost> {
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: widget.postObject,
        isHosted: widget.isHosted,
        isInViewMode: widget.isInViewMode,
        widgetComponent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.postObject['content']),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(color: Colors.white30, width: 0.1)),
              child: CarouselSlider(
                aspectRatio: 1 / 1,
                initialPage: 0,
                //enlargeCenterPage: true,
                viewportFraction: 1.1,
                height: 300,
                reverse: false,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index) {
                  setState(() {
                    _current = index;
                  });
                },
                items: widget.postObject['images'].map<Widget>((imgUrl) {
                  return Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white30, width: 1.0)),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(widget.postObject['images'], (index, url) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index ? Colors.red : Colors.white24),
                );
              }),
            )
          ],
        ));
  }
}

class LevelOneComment extends StatelessWidget {
  final commentObject;
  const LevelOneComment({Key key, this.commentObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: commentObject,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${commentObject['content']}"),
        ]));
  }
}

class PollPost extends StatefulWidget {
  final postObject;
  const PollPost({Key key, this.postObject}) : super(key: key);

  @override
  _PollPostState createState() => _PollPostState();
}

class _PollPostState extends State<PollPost> {
  int votedFor;
  @override
  void initState() {
    super.initState();
    votedFor = widget.postObject['votedFor'];
  }

  @override
  Widget build(BuildContext context) {
    int c = -1;
    return BasicTemplate(
        postObject: widget.postObject,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${widget.postObject['content']}"),
          SizedBox(
            height: 10.0,
          ),
          Column(
            children: [...widget.postObject['options']].map((x) {
              c += 1;
              return Row(children: <Widget>[
                Expanded(
                    child: RaisedButton(
                  color: (votedFor == c) ? Colors.green : Colors.black,
                  onPressed: () {
                    print("Clicked on option (${x['name']}) in Poll");
                    if (votedFor == -1) {
                      submitVote(widget.postObject['id'],
                          widget.postObject['options'].indexOf(x).toString());
                      setState(() {
                        votedFor = widget.postObject['options'].indexOf(x);
                        x['count']++;
                      });
                      widget.postObject['votedFor'] = votedFor;
                    } else
                      Fluttertoast.showToast(
                          msg: "Already Voted",
                          backgroundColor: Color.fromARGB(200, 220, 20, 60));
                  },
                  child: (votedFor != -1)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${x['name']}"),
                            Text(
                              " (${x['count']})",
                              style: TextStyle(color: Colors.white30),
                            )
                          ],
                        )
                      : Text("${x['name']}"),
                ))
              ]);
            }).toList(),
          ),
        ]));
  }
}

class ShareablePost extends StatelessWidget {
  final postObject;
  final bool isHosted;
  const ShareablePost({Key key, this.postObject, this.isHosted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        isHosted: isHosted,
        postObject: postObject,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${postObject['content']}"),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton.icon(
                  color: Color.fromARGB(200, 220, 20, 60),
                  onPressed: () {
                    print("Visiting ${postObject['link']}");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShareableWebView(
                                  link: postObject['link'],
                                )));
                  },
                  icon: Icon(Icons.link),
                  label: Text("Visit ${postObject['name']}"))
            ],
          )
        ]));
  }
}

class SimpleReshare extends StatelessWidget {
  final postObject;
  SimpleReshare({Key key, this.postObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Reshared By ",
                style: TextStyle(color: Colors.white30),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                postObject['author']['username'],
                              )));
                },
                child: Text(
                  "@${postObject['author']['username']}",
                  style: TextStyle(color: Colors.pink),
                ),
              )
            ],
          ),
          if (postObject['child']['type'] == "microblog") ...[
            MicroBlogPost(
              postObject: postObject['child'],
            )
          ] else if (postObject['child']['type'] == "shareable") ...[
            ShareablePost(
              postObject: postObject['child'],
            )
          ] else if (postObject['child']['type'] == "blog") ...[
            BlogPost(
              postObject['child'],
            )
          ] else if (postObject['child']['type'] == "timeline") ...[
            Timeline(
              postObject['child'],
            )
          ] else if (postObject['child']['type'] == "carousel") ...[
            CarouselPost(
              postObject: postObject['child'],
            )
          ],
        ],
      ),
    );
  }
}

class BlogPost extends StatelessWidget {
  final postObject;
  final isHosted;
  BlogPost(this.postObject, {this.isHosted = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BlogViewer(postObject: postObject))),
      child: Padding(
          padding: (isHosted)
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border.all(
              width: 1.0,
              color: Colors.white38,
            )),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                    constraints: new BoxConstraints.expand(
                      height: 250.0,
                    ),
                    padding: new EdgeInsets.only(left: 16.0, bottom: 8.0),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: NetworkImage("${postObject['background']}"),
                          fit: BoxFit.cover),
                    ),
                    child: new Stack(
                      children: <Widget>[
                        new Positioned(
                            left: 0.0,
                            top: 20.0,
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 24.0,
                                  backgroundImage: NetworkImage(
                                      "${postObject['author']['icon']}"),
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${postObject['author']['name']}",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    Text("@${postObject['author']['username']}")
                                  ],
                                )
                              ],
                            )),
                        new Positioned(
                          left: 0.0,
                          bottom: 20.0,
                          child: Container(
                            width: 300.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Writeup",
                                    style: new TextStyle(
                                      fontSize: 40.0,
                                    )),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text("${postObject['blog_name']}",
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))),
          )),
    );
  }
}

class Timeline extends StatelessWidget {
  final isHosted;
  final postObject;
  Timeline(this.postObject, {this.isHosted = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TimelineViewer(postObject: postObject))),
        child: Padding(
          padding: (isHosted)
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border.all(
              width: 1.0,
              color: Colors.white38,
            )),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                    constraints: new BoxConstraints.expand(
                      height: 250.0,
                    ),
                    padding: new EdgeInsets.only(left: 16.0, bottom: 8.0),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: NetworkImage("${postObject['background']}"),
                          fit: BoxFit.cover),
                    ),
                    child: new Stack(
                      children: <Widget>[
                        new Positioned(
                            left: 0.0,
                            top: 20.0,
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 24.0,
                                  backgroundImage: NetworkImage(
                                      "${postObject['author']['icon']}"),
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${postObject['author']['name']}",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    Text("@${postObject['author']['username']}")
                                  ],
                                )
                              ],
                            )),
                        new Positioned(
                          left: 0.0,
                          bottom: 20.0,
                          child: Container(
                            width: 300.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Timeline",
                                    style: new TextStyle(
                                      fontSize: 40.0,
                                    )),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text("${postObject['timeline_name']}",
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))),
          ),
        ));
  }
}

class ReshareWithComment extends StatelessWidget {
  final postObject;
  final isInViewMode;
  ReshareWithComment({this.postObject, this.isInViewMode = false});

  @override
  Widget build(BuildContext context) {
    Widget hostChild = Container();

    if (postObject['child']['type'] == "blog") {
      hostChild = BlogPost(
        postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "timeline") {
      hostChild = Timeline(
        postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "microblog") {
      hostChild = MicroBlogPost(
        postObject: postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "shareable") {
      hostChild = ShareablePost(
        postObject: postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "carousel") {
      hostChild = CarouselPost(
        postObject: postObject['child'],
      );
    }
    return BasicTemplate(
        postObject: postObject,
        isInViewMode: isInViewMode,
        widgetComponent: hostChild);
  }
}
