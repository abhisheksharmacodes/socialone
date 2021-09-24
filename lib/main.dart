//@dart=2.9
import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'Basic.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.orange,
          accentColor: Colors.white,
          textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black))),
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  //MyApp({Key key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool showImage = false;

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  static final _kAdIndex = 4;
  BannerAd _ad;
  bool _isAdLoaded = false;

  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _isAdLoaded) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    _ad.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _TypesOfPost = getDropDownMenuItems();
    BackButtonInterceptor.add(myInterceptor);
    // ads
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    )..load();

    super.initState();
  }

  var icon = 45;
  var top = 0.0; //parallaxing
  var duration = 300;
  var value;
  var text = "Social One";

  // Fading Variables
  bool socialMedia = true;
  bool news = true;
  bool newsGaming = false;
  bool newsTech = false;
  bool newsSports = false;
  bool newsFinancial = false;
  bool newsLocal = false;
  bool newsGlobal = false;
  bool music = false;
  bool games = false;
  bool about = false;
  bool feedback = false;
  bool featUrself = false;

  // App Bar
  bool refresh = false;
  bool reload = false;

  bool bg = true;

  bool _loading = false;
  bool _webvisible = false;
  bool _closeVisible = false;
  bool openedByClosed = false;
  bool sendFeedback = false;
  bool sendButtonDisabled = true;

  // Text Controllers

  WebViewController webctrl;

  // Feedback Mail

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController feedbackCtrl = TextEditingController();

  // Stepper Variables & methods ======================================================
  String uploadButton = "Upload";
  XFile image;
  TextEditingController featuredName = TextEditingController();
  TextEditingController featuredPostLink = TextEditingController();
  var postTypeSelected = "Social Media account";

  var linkType = "Link";
  List types = [
    "Social Media account",
    "Websites",
    "App/Game",
    "Browser Game",
    "Computer Software"
  ];
  List<DropdownMenuItem<String>> _TypesOfPost;
  int _currentStep = 0;

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 2 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  String featImage =
      "https://scontent.fjdh1-2.fna.fbcdn.net/v/t1.6435-9/242320384_1275201079614448_5250163352803980740_n.jpg?_nc_cat=104&ccb=1-5&_nc_sid=0debeb&_nc_ohc=_6K_KNdwua0AX-4_rKN&_nc_ht=scontent.fjdh1-2.fna&oh=61817d11839f9ac8be3a475c91eb3b1c&oe=6172FD1F";

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in types) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(value: city, child: new Text(city)));
    }
    return items;
  }

//=====================================================================================
  featureImage() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection("FeatureYourself").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        } else
          return Container(
              child: Image(
            image: NetworkImage(snapshot.data.docs[0]['image']),
          ));
      },
    );
  }

  void focusOut() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
  }

  Widget appSection(fadevar, obj, type, {size = 1}) {
    return IgnorePointer(
      ignoring: !fadevar,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: duration),
        opacity: fadevar ? 1.0 : 0.0,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 14, right: 14),
                  child: Expanded(
                    child: GridView.extent(
                      primary: false,
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 20, right: 6, left: 6),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: (140 / 200),
                      maxCrossAxisExtent: 200.0,
                      shrinkWrap: true,
                      children: <Widget>[
                        appCard(obj[0][0], () {
                          openWebView(obj[0][1]);
                        }),
                        appCard(obj[1][0], () {
                          openWebView(obj[1][1]);
                        }),
                        appCard(obj[2][0], () {
                          openWebView(obj[2][1]);
                        }),
                        appCard(obj[3][0], () {
                          openWebView(obj[3][1]);
                        }),
                        appCard(obj[4][0], () {
                          openWebView(obj[4][1]);
                        }),
                        appCard(obj[5][0], () {
                          openWebView(obj[5][1]);
                        }),
                        appCard(obj[6][0], () {
                          openWebView(obj[6][1]);
                        }),
                        appCard(obj[7][0], () {
                          openWebView(obj[7][1]);
                        }),
                        appCard(obj[8][0], () {
                          openWebView(obj[8][1]);
                        }),
                        appCard(obj[9][0], () {
                          openWebView(obj[9][1]);
                        }),
                      ],
                    ),
                  )),
              Text(
                "FEATURED",
                style: GoogleFonts.openSans(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    letterSpacing: 3),
                textAlign: TextAlign.left,
              ),
              Container(
                margin: EdgeInsets.only(left: 14, right: 14),
                child: Expanded(
                    child: GetStreamData(type, swtichCategory: switchCategory)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (webctrl.currentUrl().toString().endsWith("com") ||
        webctrl.currentUrl().toString().endsWith("com/")) {
      setState(() {
        _loading = false;
        _webvisible = false;
        _closeVisible = true;
      });
      return true;
    } else {
      webctrl.goBack();
      return true;
    }
  }

  Future<void> openWebView(url) async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          openedByClosed = false;
          _webvisible = false;
          webctrl.loadUrl(url);
          _loading = true;
          _closeVisible = true;
          refresh = true;
        });
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Row(children: <Widget>[
          //Icon widget of your choice HERE,
          Text(
            "Not connected",
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.signal_cellular_connected_no_internet_4_bar,
            color: Colors.white,
          )
        ]),
      ));
    }
  }

  switchCategory(category) {
    setState(() {
      _loading = false;
      _webvisible = false;
      _closeVisible = false;
    });
    switch (category) {
      case "social_media":
        {
          setState(() {
            socialMedia = true;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "news_gaming":
        {
          setState(() {
            socialMedia = false;
            newsGaming = true;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "news_tech":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = true;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "news_sports":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = true;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "news_financial":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = true;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "news_local":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = true;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "news_global":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = true;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "music":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = true;
            games = false;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "games":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = true;
            about = false;
            feedback = false;
            bg = true;
            featUrself = false;
          });
        }
        break;
      case "about":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = true;
            feedback = false;
            bg = false;
            featUrself = false;
          });
        }
        break;
      case "feedback":
        {
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = true;
            bg = false;
            featUrself = false;
          });
        }
        break;
      case "Feature Yourself":
        {
          featureImage();
          setState(() {
            socialMedia = false;
            newsGaming = false;
            newsTech = false;
            newsSports = false;
            newsFinancial = false;
            newsLocal = false;
            newsGlobal = false;
            music = false;
            games = false;
            about = false;
            feedback = false;
            bg = false;
            featUrself = true;
          });
        }
    }
  }

  void launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  Widget build(BuildContext context) {
    var w = (MediaQuery.of(context).size.width);
    var h = (MediaQuery.of(context).size.height);
    return Scaffold(
      drawer: Drawer(
          child: ListView(children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text("Social One",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          accountEmail: Text("All of Social World",
              style: TextStyle(color: Colors.white, fontSize: 15)),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/edited.jpeg"),
            fit: BoxFit.cover,
          )),
        ),
        ListTile(
          leading: Icon(Icons.people),
          title: Text("Social Media"),
          onTap: () {
            switchCategory("social_media");
            Navigator.pop(context);
            focusOut();
          },
        ),
        ExpansionTile(
            leading: FaIcon(FontAwesomeIcons.newspaper),
            title: Text("News"),
            children: <Widget>[
              ListTile(
                leading: Icon(IcoFontIcons.gamePad),
                title: Text("Gaming"),
                onTap: () {
                  switchCategory("news_gaming");
                  Navigator.pop(context);
                  focusOut();
                },
              ),
              ListTile(
                leading: Icon(IcoFontIcons.microChip),
                title: Text("Tech News"),
                onTap: () {
                  switchCategory("news_tech");
                  Navigator.pop(context);
                  focusOut();
                },
              ),
              ListTile(
                leading: Icon(
                  IcoFontIcons.rupeePlus,
                  size: 20,
                ),
                title: Text("Financial"),
                onTap: () {
                  switchCategory("news_financial");
                  Navigator.pop(context);
                  focusOut();
                },
              ),
              ListTile(
                leading: Icon(
                  IcoFontIcons.footballAlt,
                  size: 20,
                ),
                title: Text("Sports"),
                onTap: () {
                  switchCategory("news_sports");
                  Navigator.pop(context);
                  focusOut();
                },
              ),
              ListTile(
                leading: Icon(IcoFontIcons.locationPin),
                title: Text("Local"),
                onTap: () {
                  switchCategory("news_local");
                  Navigator.pop(context);
                  focusOut();
                },
              ),
              ListTile(
                leading: Icon(IcoFontIcons.globe),
                title: Text("Global"),
                onTap: () {
                  switchCategory("news_global");
                  Navigator.pop(context);
                  focusOut();
                },
              ),
            ]),
        ListTile(
          leading: Icon(IcoFontIcons.music),
          title: Text("Music"),
          onTap: () {
            switchCategory("music");
            Navigator.pop(context);
            focusOut();
          },
        ),
        ListTile(
          leading: Icon(IcoFontIcons.gameController),
          title: Text("Games"),
          onTap: () {
            switchCategory("games");
            Navigator.pop(context);
            focusOut();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(IcoFontIcons.starShape, color: Colors.orange),
          title: Text(
            "Feature yourself",
            style: TextStyle(color: Colors.orange),
          ),
          onTap: () {
            switchCategory("Feature Yourself");
            Navigator.pop(context);
            focusOut();
          },
        ),
        ListTile(
          leading: Icon(IcoFontIcons.comment),
          title: Text("Feedback"),
          onTap: () {
            switchCategory("feedback");
            Navigator.pop(context);
            focusOut();
          },
        ),
        ListTile(
          leading: FaIcon(FontAwesomeIcons.infoCircle),
          title: Text("About"),
          onTap: () {
            switchCategory("about");
            Navigator.pop(context);
            focusOut();
          },
        ),
      ])),
      appBar: AppBar(
        bottomOpacity: 100,
        shadowColor: Colors.orange,
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(text, style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Positioned(
            top: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IgnorePointer(
                    ignoring: !refresh,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: duration),
                      opacity: refresh ? 1.0 : 0.0,
                      child: IconButton(
                        icon: Icon(Icons.refresh),
                        iconSize: 30,
                        onPressed: () {
                          webctrl.reload();
                          setState(() {
                            reload = true;
                          });
                        },
                      ),
                    )),
                IgnorePointer(
                  ignoring: !_closeVisible,
                  child: AnimatedOpacity(
                    opacity: _closeVisible ? 1 : 0,
                    duration: Duration(milliseconds: duration),
                    child: IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        webctrl.loadUrl(
                            "https://idkzmaw2wapnazirmsf5ma-on.drv.tw/idle.html");
                        openedByClosed = true;
                        setState(() {
                          _loading = false;
                          _webvisible = false;
                          _closeVisible = false;
                          refresh = false;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
      body: new NotificationListener(
        onNotification: (v) {
          if (v is ScrollUpdateNotification) {
            setState(() => top -= (v.scrollDelta / 2));
          }
          return true;
        },
        child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                //The background
                new Positioned(
                  top: top,
                  child: new ConstrainedBox(
                    constraints: new BoxConstraints(
                        maxHeight: (MediaQuery.of(context).size.height),
                        maxWidth: (MediaQuery.of(context).size.width)),
                    child: new Image.asset(
                      'assets/images/background.png',
                      height: (MediaQuery.of(context).size.height),
                      width: (MediaQuery.of(context).size.width),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: !bg ? 1.0 : 0.0,
                  child: Container(height: h, width: w, color: Colors.white),
                ),
                /* Social Media */ appSection(
                    socialMedia,
                    [
                      [
                        "assets/SocialMedia/facebook.jpeg",
                        "https://www.facebook.com"
                      ],
                      [
                        "assets/SocialMedia/instagram.jpeg",
                        "https://www.instagram.com"
                      ],
                      ["assets/SocialMedia/koo.jpeg", "https://www.kooapp.com"],
                      [
                        "assets/SocialMedia/twitter.jpeg",
                        "https://twitter.com"
                      ],
                      [
                        "assets/SocialMedia/youtube.jpeg",
                        "https://www.youtube.com"
                      ],
                      [
                        "assets/SocialMedia/sharechat.jpeg",
                        "https://sharechat.com"
                      ],
                      [
                        "assets/SocialMedia/reddit.jpeg",
                        "https://www.reddit.com/"
                      ],
                      [
                        "assets/SocialMedia/linkedin.jpeg",
                        "https://www.linkedin.com"
                      ],
                      [
                        "assets/SocialMedia/tumblr.jpeg",
                        "https://www.tumblr.com"
                      ],
                      [
                        "assets/SocialMedia/pintrest.jpeg",
                        "https://in.pinterest.com"
                      ],
                    ],
                    "SocialMediaFeatured"),
                /* News: Gaming */ appSection(
                    newsGaming,
                    [
                      [
                        "assets/NewsGaming/thelegions2.jpeg",
                        "https://thelegionsgames.blogspot.com/search/label/games"
                      ],
                      [
                        "assets/NewsGaming/ps.jpeg",
                        "https://blog.playstation.com/"
                      ],
                      [
                        "assets/NewsGaming/xbox.jpeg",
                        "https://news.xbox.com/en-us/"
                      ],
                      ["assets/NewsGaming/ign.jpeg", "https://in.ign.com/"],
                      [
                        "assets/NewsGaming/gi.jpeg",
                        "https://www.gameinformer.com/"
                      ],
                      [
                        "assets/NewsGaming/dualshockers.jpeg",
                        "https://www.dualshockers.com/"
                      ],
                      [
                        "assets/NewsGaming/gamerheadlines.jpeg",
                        "https://gamerheadlines.com"
                      ],
                      [
                        "assets/NewsGaming/ni.jpeg",
                        "https://www.nintendolife.com/news"
                      ],
                      [
                        "assets/NewsGaming/gamespot.jpeg",
                        "https://www.gamespot.com/news/"
                      ],
                      [
                        "assets/NewsGaming/grplus.jpeg",
                        "https://www.gamesradar.com/uk/"
                      ],
                    ],
                    "GamingNewsFeatured"),
                /* News: Tech */ appSection(
                    newsTech,
                    [
                      [
                        "assets/NewsTech/amarujala.jpeg",
                        "https://www.amarujala.com/technology"
                      ],
                      [
                        "assets/NewsTech/jagran.jpeg",
                        "https://www.jagran.com/technology-hindi.html"
                      ],
                      [
                        "assets/NewsTech/theverge.jpeg",
                        "https://www.theverge.com/tech"
                      ],
                      ["assets/NewsTech/bgr.jpeg", "https://bgr.com/tech/"],
                      [
                        "assets/NewsTech/gadgetsnow.jpeg",
                        "https://www.gadgetsnow.com/tech-news"
                      ],
                      [
                        "assets/NewsTech/cnet.jpeg",
                        "https://www.cnet.com/news/"
                      ],
                      [
                        "assets/NewsTech/axios.jpeg",
                        "https://www.axios.com/technology/"
                      ],
                      [
                        "assets/NewsTech/engadget.jpeg",
                        "https://www.engadget.com"
                      ],
                      [
                        "assets/NewsTech/gizmodo.jpeg",
                        "https://gizmodo.com/tech"
                      ],
                      [
                        "assets/NewsTech/bsn.jpeg",
                        "https://brightsideofnews.com/tech-news/"
                      ],
                    ],
                    "TechNewsFeatured"),
                /* News: Financial */ appSection(
                    newsFinancial,
                    [
                      [
                        "assets/NewsFinancial/nse.jpg",
                        "https://www.nseindia.com"
                      ],
                      [
                        "assets/NewsFinancial/bse.jpg",
                        "https://www.bseindia.com"
                      ],
                      [
                        "assets/NewsFinancial/forbes.jpg",
                        "https://www.forbes.com/?sh=3f15efbb2254"
                      ],
                      [
                        "assets/NewsFinancial/reuters.jpg",
                        "https://www.reuters.com/markets"
                      ],
                      ["assets/NewsFinancial/ft.jpg", "https://www.ft.com"],
                      [
                        "assets/NewsFinancial/moneycontrol.jpg",
                        "https://www.moneycontrol.com"
                      ],
                      [
                        "assets/NewsFinancial/investing.jpg",
                        "https://in.investing.com/?ref=www"
                      ],
                      [
                        "assets/NewsFinancial/screener.jpg",
                        "https://www.screener.in"
                      ],
                      [
                        "assets/NewsFinancial/mw.jpg",
                        "https://www.marketwatch.com"
                      ],
                      [
                        "assets/NewsFinancial/etm.jpg",
                        "https://economictimes.indiatimes.com/markets"
                      ],
                    ],
                    "FinancialNewsFeatured"),
                /* News: Sports */ appSection(
                    newsSports,
                    [
                      [
                        "assets/NewsSports/nbcsports.jpeg",
                        "https://www.nbcsports.com"
                      ],
                      [
                        "assets/NewsSports/cricbuzz.jpeg",
                        "https://www.cricbuzz.com"
                      ],
                      [
                        "assets/NewsSports/isn.jpeg",
                        "http://www.indiansportsnews.com"
                      ],
                      [
                        "assets/NewsSports/wwe.jpeg",
                        "https://www.wwe.com/shows/wwe-now"
                      ],
                      ["assets/NewsSports/f1.jpeg", "https://www.formula1.com"],
                      ["assets/NewsSports/espn.jpeg", "https://www.espn.in"],
                      [
                        "assets/NewsSports/247sports.jpeg",
                        "https://247sports.com"
                      ],
                      [
                        "assets/NewsSports/deadspin.jpeg",
                        "https://deadspin.com"
                      ],
                      [
                        "assets/NewsSports/bet365.jpeg",
                        "https://www.bet365.com/#/AS/B3/"
                      ],
                      [
                        "assets/NewsSports/sk.jpeg",
                        "https://www.sportskeeda.com"
                      ],
                    ],
                    "SportsFeatured"),
                /* News: Local */ appSection(
                    newsLocal,
                    [
                      [
                        "assets/NewsLocal/ddnews.jpeg",
                        "http://ddnews.gov.in/national"
                      ],
                      [
                        "assets/NewsLocal/ani.jpeg",
                        "https://aninews.in/category/national/general-news/"
                      ],
                      [
                        "assets/NewsLocal/ians.jpeg",
                        "https://ians.in/index.php?param=category/139/139"
                      ],
                      [
                        "assets/NewsLocal/amarujala.jpeg",
                        "https://www.amarujala.com/india-news?src=mainmenu"
                      ],
                      [
                        "assets/NewsLocal/jagran.jpeg",
                        "https://www.jagran.com/news/national-news-hindi.html"
                      ],
                      [
                        "assets/NewsLocal/zeenews.jpeg",
                        "https://zeenews.india.com/india"
                      ],
                      [
                        "assets/NewsLocal/hindustantimes.jpeg",
                        "https://www.hindustantimes.com/india-news"
                      ],
                      [
                        "assets/NewsLocal/dainikbhaskar.jpeg",
                        "https://www.bhaskar.com/national/"
                      ],
                      [
                        "assets/NewsLocal/patrika.jpeg",
                        "https://www.patrika.com/india-news/"
                      ],
                      [
                        "assets/NewsLocal/india.jpeg",
                        "https://www.india.com/news/india/"
                      ],
                    ],
                    "LocalFeatured"),
                /* News: Global */ appSection(
                    newsGlobal,
                    [
                      [
                        "assets/NewsGlobal/nyt.jpeg",
                        "https://www.nytimes.com/international/section/world"
                      ],
                      ["assets/NewsGlobal/cnn.jpeg", "https://edition.cnn.com"],
                      [
                        "assets/NewsGlobal/reuters.jpeg",
                        "https://www.reuters.com/world/"
                      ],
                      [
                        "assets/NewsGlobal/cnbc.jpeg",
                        "https://www.cnbc.com/world/"
                      ],
                      [
                        "assets/NewsGlobal/buzzfeed.jpeg",
                        "https://www.buzzfeednews.com/section/world"
                      ],
                      [
                        "assets/NewsGlobal/defenseblog.jpeg",
                        "https://defence-blog.com/"
                      ],
                      [
                        "assets/NewsGlobal/thecipherbrief.jpeg",
                        "https://www.thecipherbrief.com"
                      ],
                      [
                        "assets/NewsGlobal/euronews.jpeg",
                        "https://www.euronews.com/news/international"
                      ],
                      [
                        "assets/NewsGlobal/dw.jpeg",
                        "https://www.dw.com/en/top-stories/s-9097"
                      ],
                      [
                        "assets/NewsGlobal/south.jpeg",
                        "https://www.smh.com.au/world"
                      ],
                    ],
                    "GlobalFeatured"),
                /* Music */ appSection(
                    music,
                    [
                      [
                        "assets/Music/spotify.jpeg",
                        "https://open.spotify.com/"
                      ],
                      [
                        "assets/Music/applemusic.jpeg",
                        "https://music.apple.com/us/browse"
                      ],
                      [
                        "assets/Music/soundcloud.jpeg",
                        "https://soundcloud.com/discover"
                      ],
                      [
                        "assets/Music/jiosaavn.jpeg",
                        "https://www.jiosaavn.com/"
                      ],
                      [
                        "assets/Music/youtubemusic.jpeg",
                        "https://music.youtube.com/"
                      ],
                      ["assets/Music/hungama.jpeg", "https://www.hungama.com/"],
                      ["assets/Music/wynk.jpeg", "https://wynk.in/music"],
                      ["assets/Music/audiomack.jpeg", "https://audiomack.com/"],
                      ["assets/Music/gaana.jpeg", "https://gaana.com/"],
                      ["assets/Music/stream.jpeg", "https://streamplayer.io/"],
                    ],
                    "MusicFeatured",
                    size: 2),
                /* Games */ appSection(
                    games,
                    [
                      [
                        "assets/Games/callofwar.jpeg",
                        "https://www.callofwar.com/"
                      ],
                      [
                        "assets/Games/minigiants.jpeg",
                        "https://minigiants.io/?v=1.6.53&play-game"
                      ],
                      ["assets/Games/gartic.jpeg", "https://gartic.io"],
                      [
                        "assets/Games/catanuniverse.jpeg",
                        "https://catanuniverse.com/en/game/"
                      ],
                      [
                        "assets/Games/starblast.jpeg",
                        "https://starblast.io/#7132"
                      ],
                      ["assets/Games/krunker.jpeg", "https://krunker.io/"],
                      [
                        "assets/Games/paper.jpeg",
                        "https://paper-io.com/teams/"
                      ],
                      ["assets/Games/mope.jpeg", "https://mope.io/"],
                      [
                        "assets/Games/gobattle.jpeg",
                        "https://www.gobattle.io/ "
                      ],
                      [
                        "assets/Games/evowars.jpeg",
                        "https://evowars.io/?v=1.8.1&play-game"
                      ],
                      ["assets/Games/slitcher.jpeg", "https://slither.io/"],
                    ],
                    "GamesFeatured",
                    size: 2),
                /* Feature Yourself */ IgnorePointer(
                    ignoring: !featUrself,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: duration),
                      opacity: featUrself ? 1.0 : 0.0,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            featureImage(),
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: RichText(
                                    textAlign: TextAlign.justify,
                                    text: TextSpan(
                                        text:
                                            "Feature your Social Media accounts, Websites, Apps etc on Social One. It only cost you one time (",
                                        style: GoogleFonts.openSans(
                                          color: Colors.grey[600],
                                          letterSpacing: 1,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: "50rs",
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          TextSpan(
                                            text: ") for ",
                                          ),
                                          TextSpan(
                                              text: "life time",
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          TextSpan(
                                            text:
                                                " featuring. Just fill in some details, pay and be featured!  ",
                                          ),
                                        ]))),
                            Stepper(
                                type: StepperType.vertical,
                                physics: ScrollPhysics(),
                                currentStep: _currentStep,
                                onStepTapped: (step) => tapped(step),
                                onStepContinue: continued,
                                onStepCancel: cancel,
                                steps: [
                                  Step(
                                    title: Text("Details"),
                                    content: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: ButtonTheme(
                                            padding:
                                                EdgeInsets.only(left: 20),
                                            child: DropdownButtonFormField(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                  labelText: "Post Type",
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10))),
                                              icon: Icon(Icons
                                                  .arrow_drop_down_rounded),
                                              alignment: Alignment.topLeft,
                                              focusColor: Colors.white,
                                              value: postTypeSelected,
                                              //elevation: 5,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              iconEnabledColor: Colors.black,
                                              items: <String>[
                                                'Social Media account',
                                                'Website',
                                                'App/Game',
                                                'Browser Game',
                                                'Computer Software',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                );
                                              }).toList(),

                                              onChanged: (String value) {
                                                if (value == "App/Game")
                                                  setState(() {
                                                    linkType =
                                                        "Play Store / App Store link";
                                                  });
                                                else
                                                  setState(() {
                                                    linkType = "Link";
                                                  });
                                                setState(() {
                                                  postTypeSelected = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          controller: featuredPostLink,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4)),
                                              labelText: linkType),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Step(
                                    title: Text("Image"),
                                    isActive: _currentStep >= 0,
                                    state: _currentStep >= 1
                                        ? StepState.complete
                                        : StepState.disabled,
                                    content: Column(
                                      children: <Widget>[
                                        RichText(
                                            text: TextSpan(
                                                text:
                                                    "Abhishek Sharma will create an attractive image for your post (",
                                                style: GoogleFonts.openSans(
                                                    color: Colors.grey),
                                                children: [
                                              TextSpan(
                                                  text: "for free",
                                                  style: GoogleFonts.openSans(
                                                      color:
                                                          Colors.blueAccent,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      ") but you can also upload your desired image of resolution 700 x 1000. ",
                                                  style: GoogleFonts.openSans(
                                                      color: Colors.grey)),
                                            ])),
                                        IgnorePointer(
                                          ignoring: !showImage,
                                          child: AnimatedOpacity(
                                            opacity: showImage ? 1.0 : 0.0,
                                            duration:
                                                Duration(seconds: duration),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24)),
                                                height: 200,
                                                width: 140,
                                                child: showImage
                                                    ? Image.file(
                                                        File(image.path),
                                                      )
                                                    : Container(
                                                        height: 0,
                                                      )),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            image = await ImagePicker()
                                                .pickImage(
                                                    source:
                                                        ImageSource.gallery,
                                                    imageQuality: 50);
                                            setState(() {
                                              uploadButton =
                                                  File(image.path).toString();
                                              showImage = true;
                                            });
                                          },
                                          child: Container(
                                            child: Text(uploadButton),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ])
                          ],
                        ),
                      ),
                    )),
                /* About */ IgnorePointer(
                  ignoring: !about,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: duration),
                    opacity: about ? 1.0 : 0.0,
                    child: Container(
                      width: w,
                      height: h,
                      margin: EdgeInsets.all(14),
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            Text(
                              "Social One",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 40,
                                  color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "1.0.0",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "     Social One is a utility app to provide All of Social Media, News, Music, Popular Games in least storage possible. Social One helps you to save a lot of space. Social One always aims to provide you maximum entertainment in minimal storage, that should be our main slogan, right? ",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey.shade600),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    openWebView(
                                        "https://www.facebook.com/GeekySharma03/");
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.facebook,
                                    size: icon.toDouble(),
                                    color: Color(0xff2f55a4),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    openWebView(
                                        "https://www.instagram.com/geekysharma/");
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.instagram,
                                    size: icon.toDouble(),
                                    color: Color(0xffcd486b),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    openWebView(
                                        "https://www.youtube.com/c/geekysharmacreator");
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.youtube,
                                    size: icon.toDouble(),
                                    color: Color(0xffFF0000),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    openWebView(
                                        "https://twitter.com/geeky_sharma");
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.twitter,
                                    size: icon.toDouble(),
                                    color: Color(0xff1DA1F2),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 130,
                            ),
                            Text(
                              "All rights reserved \n ©️ 2021 Geeky Sharma \n Developed in India",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new InkWell(
                                    child: new Text(
                                      'Privacy Policy',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ),
                                    onTap: () =>
                                        openWebView('https://bit.ly/2YjT88s')),
                                Text(
                                  " • ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                new InkWell(
                                    child: new Text(
                                      'Terms & Conditions',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ),
                                    onTap: () =>
                                        openWebView('https://bit.ly/3jJhq40')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                /* Feedback */ IgnorePointer(
                    ignoring: !feedback,
                    child: AnimatedOpacity(
                      opacity: feedback ? 1.0 : 0.0,
                      duration: Duration(milliseconds: duration),
                      child: Container(
                        width: 310,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: SingleChildScrollView(
                          child: Container(
                            height: h,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Provide valuable feedback to enhance Social One. If you suggest a new feature, then your name may be considered for inclusion in the App About Section.",
                                  style: GoogleFonts.openSans(
                                      fontSize: 15,
                                      color: Colors.grey.shade600),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                TextField(
                                  onChanged: (String value) {
                                    if (nameCtrl.text.characters.length != 0 &&
                                        feedbackCtrl.text.characters.length !=
                                            0) {
                                      setState(() {
                                        sendButtonDisabled = false;
                                      });
                                    } else {
                                      setState(() {
                                        sendButtonDisabled = true;
                                      });
                                    }
                                  },
                                  controller: nameCtrl,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Name"),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  onChanged: (String value) {
                                    if (nameCtrl.text.characters.length != 0 &&
                                        feedbackCtrl.text.characters.length !=
                                            0) {
                                      setState(() {
                                        sendButtonDisabled = false;
                                      });
                                    } else {
                                      setState(() {
                                        sendButtonDisabled = true;
                                      });
                                    }
                                  },
                                  controller: feedbackCtrl,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Feedback"),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: TextButton.icon(
                                    onPressed: sendButtonDisabled
                                        ? null
                                        : () {
                                            Uri emailLaunchUri = Uri(
                                                scheme: 'mailto',
                                                path: 'geekysharma31@gmail.com',
                                                queryParameters: {
                                                  'subject': nameCtrl.text +
                                                      " gave feedback",
                                                  'body': feedbackCtrl.text
                                                      .toString()
                                                      .replaceAll("+", " ")
                                                });
                                            launchURL(
                                                emailLaunchUri.toString());
                                          },
                                    style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white12),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        backgroundColor: sendButtonDisabled
                                            ? MaterialStateProperty.all<Color>(
                                                Colors.grey.shade300)
                                            : MaterialStateProperty.all<Color>(
                                                Colors.orange)),
                                    label: Text(
                                      'SEND',
                                    ),
                                    icon: Icon(
                                      Icons.send,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                /* WebView */ IgnorePointer(
                  ignoring: !_loading,
                  child: AnimatedOpacity(
                    opacity: _loading ? 1.00 : 0.00,
                    duration: Duration(milliseconds: duration),
                    child: Stack(
                      children: [
                        Container(
                          child: Transform.scale(
                            scale: 0.2,
                            child: Image.asset("assets/images/loading.gif",
                                height: 20, width: 40),
                          ),
                          height: (MediaQuery.of(context).size.height),
                          width: (MediaQuery.of(context).size.width),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                        IgnorePointer(
                          ignoring: !_webvisible,
                          child: AnimatedOpacity(
                            opacity: _webvisible ? 1.00 : 0.00,
                            duration: Duration(milliseconds: duration),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: WebView(
                                  javascriptMode: JavascriptMode.unrestricted,
                                  onWebViewCreated:
                                      (WebViewController webViewController) {
                                    webctrl = webViewController;
                                  },
                                  onPageStarted: (url) {
                                    if (!openedByClosed) {
                                      setState(() {
                                        _loading = true;
                                      });
                                    }
                                  },
                                  onPageFinished: (url) {
                                    setState(() {
                                      _webvisible = true;
                                    });
                                  },
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

// ===========================
class GetStreamData extends StatefulWidget {
  final String type;
  final _callback; // callback reference holder
  //you will pass the callback here in constructor

  @override
  _GetStreamDataState createState() => _GetStreamDataState();
  GetStreamData(this.type, {@required void swtichCategory(data)})
      : _callback = swtichCategory;
}

class _GetStreamDataState extends State<GetStreamData> {
  String type;
  Stream<QuerySnapshot> _usersStream;
  final MyAppState a = new MyAppState();
  @override
  void initState() {
    _usersStream =
        FirebaseFirestore.instance.collection(widget.type).snapshots();
    type = widget.type;
    super.initState();
  }

  void launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return GridView.count(
          primary: false,
          padding:
              const EdgeInsets.only(top: 20, bottom: 20, right: 6, left: 6),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: (140 / 200),
          crossAxisCount: 2,
          shrinkWrap: true,
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                if (data['link'].toString().contains("http"))
                  launchURL(data['link']);
                else
                  widget?._callback(data['link']);
                //
              },
              child: Container(
                  height: 200,
                  width: 140,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 5.0,
                          spreadRadius: 1.5,
                          color: Colors.grey,
                        )
                      ],
                      image: DecorationImage(
                          image: new NetworkImage(data['image'])))),
            );
          }).toList(),
        );
      },
    );
  }
}

class LoadingGif extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/images/reloading.gif", height: 80, width: 80);
  }
}
