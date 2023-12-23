//@dart=2.9
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:upi_india/upi_india.dart';
import 'package:overlay_dialog/overlay_dialog.dart';
import 'Splash.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.orange,
          textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black))),
      home: SpalshScreen()));
}

class MyApp extends StatefulWidget {
  //MyApp({Key key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Payment Variables & Methods ===============================================

  UpiIndia _upiIndia = UpiIndia();

  UpiApp gpay = UpiApp.googlePay;
  UpiApp paytm = UpiApp.paytm;
  UpiApp phonepe = UpiApp.phonePe;
  UpiApp bhim = UpiApp.bhim;
  UpiApp mobikwik = UpiApp.mobikwik;
  UpiApp amazonPay = UpiApp.amazonPay;
  UpiApp freecharge = UpiApp.freecharge;
  UpiApp sbiPay = UpiApp.sbiPay;
  UpiApp miPayGlobal = UpiApp.miPayGlobal;

  bool showTransImage = false;

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    try {
      return _upiIndia.startTransaction(
        app: app,
        receiverUpiId: "geekysharma31@oksbi",
        receiverName: 'Abhishek Sharma',
        transactionRefId: '113218141132',
        transactionNote: 'For life time featuring on Social One',
        amount: int.parse(price(pricing)).toDouble(),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Row(children: <Widget>[
          //Icon widget of your choice HERE,
          Text(
            "This app is not detected on this device",
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

  XFile trnsImage;

  // ===========================================================================
  bool showImage = false;

  TextEditingController custName = new TextEditingController();

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
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
          channelKey: 'key1',
          channelName: 'Social One',
          channelDescription: 'Notification example',
          icon: 'resource://drawable/logo_notify',
          defaultColor: Colors.orange,
          ledColor: Colors.white,
          playSound: true,
          enableLights: true,
          enableVibration: true)
    ]);
    _TypesOfPost = getDropDownMenuItems();
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getDatabaseEssentials(context));
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
    notify();
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

  // Database Variables
  String imageSrc =
      "https://dl.dropboxusercontent.com/s/9ewf2wo5ky0dq4h/404.jpg ";
  bool isDiscount = false;
  var discount = 0;
  var pricing = 50;

  // App Bar
  bool refresh = false;
  bool reload = false;

  bool bg = true;

  bool _loading = false;
  bool _webvisible = false;
  bool _closeVisible = false;
  bool openedByClosed = false;
  bool sendButtonDisabled = true;

  // Text Controllers

  WebViewController webctrl;

  // Feedback Mail

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController feedbackCtrl = TextEditingController();

  // Stepper Variables & methods ======================================================
  bool imagePostedFeatured = false;
  String uploadButton = "Upload";
  XFile image;
  TextEditingController featuredPostLink = TextEditingController();
  var postTypeSelected = "Social Media account";

  var linkType = "Link";
  List types = [
    "Social Media/YouTube account",
    "Websites",
    "App",
    "Game",
    "Computer Software"
  ];
  List<DropdownMenuItem<String>> _TypesOfPost;
  int _currentStep = 0;

  void notify() async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: 'key1',
            title: "Feature Yourself",
            notificationLayout: NotificationLayout.BigPicture,
            bigPicture:
                "https://dl.dropboxusercontent.com/s/nl26w44waf5pm76/disc20.jpg?dl=0",
           //payload: '{  "notification": {    "body": "this is a body",    "title": "this is a title",  },  "data": {    "click_action": "FLUTTER_NOTIFICATION_CLICK",    "sound": "default",     "status": "done",    "screen": "screenA",  },  "to": "<FCM TOKEN>"}',
            body:
                "Promote your Social Media, Blog etc with lowest cost till now 😃",
            backgroundColor: Colors.grey));
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      if (featuredPostLink.text.isEmpty || !imagePostedFeatured) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.yellowAccent[700],
          content: Row(children: <Widget>[
            //Icon widget of your choice HERE,
            Text(
              "Fill out all the necessary details",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.warning,
              color: Colors.black,
            )
          ]),
        ));
      } else {
        showImage = false;
        showTransImage = false;
        featuredPostLink.clear();
        custName.clear();
        setState(() {});
        _currentStep = 0;
        DialogHelper().show(
          context,
          DialogWidget.custom(
              child: Center(
                  child: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                height: deviceHeight * 0.7,
                width: deviceWidth * 0.7,
                child: Column(
                  children: [
                    ClipRRect(
                      child: checkUrl(
                          "https://thumbs.dreamstime.com/b/beautiful-handwritten-greeting-lettering-congratulations-decoration-fireworks-vector-illustration-215223347.jpg"),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7)),
                    ), //
                    Container(
                        padding: EdgeInsets.all(15),
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                              text: "Your",
                              style: GoogleFonts.openSans(
                                color: Colors.grey[600],
                                height: 1.77,
                              ),
                              children: [
                                TextSpan(
                                    text: " Featured Post ",
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: "will be visible within",
                                ),
                                TextSpan(
                                    text: " 2 Hours.",
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: " If the submission is free of errors.",
                                ),
                                TextSpan(
                                  text:
                                      "\n       In case, if you wanna change your link in future, You may contact the developer at ",
                                ),
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final Email email = Email(
                                          body: " ",
                                          subject: " ",
                                          recipients: [
                                            "geekysharma31@gmail.com"
                                          ],
                                        );
                                        try {
                                          await FlutterEmailSender.send(email);
                                        } catch (error) {}
                                      },
                                    text: " geekysharma31@gmail.com",
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent)),
                                TextSpan(
                                  text:
                                      "\n      If you don't see your post on Social One after 2 hours then let the developer know about that. ",
                                ),
                                TextSpan(
                                  text: "\n      You can feature",
                                ),
                                TextSpan(
                                    text: " unlimited posts",
                                    style: GoogleFonts.openSans(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: " on Social One by paying each time.",
                                ),
                              ]),
                        )),
                  ],
                )),
          ))),
        );
      }
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in types) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(value: city, child: new Text(city)));
    }
    return items;
  }

//========================================================================

  void getDatabaseEssentials(context) async {
    var collection = FirebaseFirestore.instance.collection('initialize');
    var docSnapshot = await collection.doc('UruGtwHaxV6Ty7nYQNvV').get();

    Map<String, dynamic> data = docSnapshot.data();

    setState(() {
      imageSrc = data['featureImage'];
      isDiscount = data["isDiscount"];
      discount = data["discount"];
      pricing = data["pricing"];
    });
  }

  Future<void> send() async {
    final Email email = Email(
      body: "Post Image for " + postTypeSelected,
      subject: "Post Image",
      recipients: ["geekysharma31@gmail.com"],
      attachmentPaths: [image.path],
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;

    final snackBar = SnackBar(content: Text(platformResponse));

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> sendTrns() async {
    final Email email = Email(
      body: "Transaction Receipt",
      subject: "Payment processed by dear " + custName.text,
      recipients: ["geekysharma31@gmail.com"],
      attachmentPaths: [trnsImage.path],
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;

    final snackBar = SnackBar(content: Text(platformResponse));

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> sndFeedback() async {
    final Email email = Email(
      body: feedbackCtrl.text,
      subject: nameCtrl.text + " gave Feedback!",
      recipients: ["geekysharma31@gmail.com"],
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Row(children: <Widget>[
        //Icon widget of your choice HERE,
        Text(
          "Thanks for Feedback",
          style: TextStyle(fontSize: 17),
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.check,
          size: 24,
          color: Colors.white,
        )
      ]),
    ));
  }

// =======================================================================

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
                  )),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  "FEATURED",
                  style: GoogleFonts.openSans(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      letterSpacing: 3),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 14, right: 14),
                child: GetStreamData(type, swtichCategory: switchCategory),
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
    //notify();
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
          //someColumn.children.addAll();
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

  Widget checkUrl(String url) {
    try {
      return Image.network(url);
    } catch (e) {
      return Icon(Icons.image);
    }
  }

  String price(int pricing) {
    return isDiscount
        ? (pricing - pricing * discount / 100).round().toString()
        : pricing.toString();
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
          subtitle: isDiscount ? Text("$discount% Discount") : null,
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
          Row(
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
                        "https://dl.dropboxusercontent.com/s/awas0gqbnnfc1fc/facebook.jpeg ",
                        "https://www.facebook.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/j2tbs5itra91e4z/instagram.jpeg ",
                        "https://www.instagram.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/w9om48cgsv5n4vt/koo.jpeg ",
                        "https://www.kooapp.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/bqonjhcsd3sej8n/twitter.jpeg ",
                        "https://twitter.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/ikrwwklw3qlnvdj/youtube.jpeg ",
                        "https://www.youtube.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/e69kknwidlrx4og/sharechat.jpeg ",
                        "https://sharechat.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/s3qhdj9yond94o8/reddit.jpeg ",
                        "https://www.reddit.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/atucztcdghgnk8a/linkedin.jpeg ",
                        "https://www.linkedin.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/zmwe2uyrawo9q43/tumblr.jpeg ",
                        "https://www.tumblr.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/3chvnf8obg2adoa/pintrest.jpeg ",
                        "https://in.pinterest.com"
                      ],
                    ],
                    "SocialMediaFeatured"),
                /* News: Gaming */ appSection(
                    newsGaming,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/mdauimijr2p0np1/thelegions2.jpeg ",
                        "https://thelegionsgames.blogspot.com/search/label/games"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/5aeyk69wx1r8d7k/ps.jpeg ",
                        "https://blog.playstation.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/4rewnqn56lpphie/xbox.jpeg ",
                        "https://news.xbox.com/en-us/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/ir6fw0ddqf93wce/ign.jpeg ",
                        "https://in.ign.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/caw5qf70m8uizoj/gi.jpeg ",
                        "https://www.gameinformer.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/xw3aelhkzcaaol7/dualshockers.jpeg ",
                        "https://www.dualshockers.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/x2i1tcr7nb818dm/gamerheadlines.jpeg ",
                        "https://gamerheadlines.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/m5fdwnwg3drqpjn/ni.jpeg ",
                        "https://www.nintendolife.com/news"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/k3zaj60l30akxv4/gamespot.jpeg ",
                        "https://www.gamespot.com/news/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/u62ckz6h5l911ti/grplus.jpeg ",
                        "https://www.gamesradar.com/uk/"
                      ],
                    ],
                    "GamingNewsFeatured"),
                /* News: Tech */ appSection(
                    newsTech,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/vc3lhysqd5be1ts/amarujala.jpeg ",
                        "https://www.amarujala.com/technology"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/6894fwah7ppstul/jagran.jpeg ",
                        "https://www.jagran.com/technology-hindi.html"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/761coda4l7abniu/theverge.jpeg?dl=0",
                        "https://www.theverge.com/tech"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/sgb1rg0ch9i54te/bgr.jpeg?dl=0",
                        "https://bgr.com/tech/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/h9gx3yd4yie7882/gadgetsnow.jpeg?dl=0",
                        "https://www.gadgetsnow.com/tech-news"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/hkmcshras85edlf/cnet.jpeg?dl=0",
                        "https://www.cnet.com/news/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/515d047pmo7uxuq/axios.jpeg?dl=0",
                        "https://www.axios.com/technology/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/zsyiig41n8sh3mp/engadget.jpeg?dl=0",
                        "https://www.engadget.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/6f5ldtbx8080arl/gizmodo.jpeg?dl=0",
                        "https://gizmodo.com/tech"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/dar70rb485qzckv/bsn.jpeg?dl=0",
                        "https://brightsideofnews.com/tech-news/"
                      ],
                    ],
                    "TechNewsFeatured"),
                /* News: Financial */ appSection(
                    newsFinancial,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/sp7qayups8z0d60/nse.jpg?dl=0",
                        "https://www.nseindia.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/rkmt2r5u31yq8ah/bse.jpg?dl=0",
                        "https://www.bseindia.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/awfrsz83aw9ouhw/forbes.jpg?dl=0",
                        "https://www.forbes.com/?sh=3f15efbb2254"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/xd0cjc433d3szhn/reuters.jpg?dl=0",
                        "https://www.reuters.com/markets"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/19c243zwxyfj2lr/ft.jpg?dl=0",
                        "https://www.ft.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/t64e31x4sqowv0k/moneycontrol.jpg?dl=0",
                        "https://www.moneycontrol.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/livjdy0s8eq0fr4/investing.jpg?dl=0",
                        "https://in.investing.com/?ref=www"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/iomsyf0b77i4qu0/screener.jpg?dl=0",
                        "https://www.screener.in"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/prmipi6wpwgktci/mw.jpg?dl=0",
                        "https://www.marketwatch.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/2u56ahonoyf7bts/etm.jpg?dl=0",
                        "https://economictimes.indiatimes.com/markets"
                      ],
                    ],
                    "FinancialNewsFeatured"),
                /* News: Sports */ appSection(
                    newsSports,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/fmztuhlwql89yov/nbcsports.jpeg?dl=0",
                        "https://www.nbcsports.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/bl0jjfo9ycay0m7/cricbuzz.jpeg?dl=0",
                        "https://www.cricbuzz.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/gpomdu0qwo84y07/isn.jpeg?dl=0",
                        "http://www.indiansportsnews.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/lmk5jzqew9zwiql/wwe.jpeg?dl=0",
                        "https://www.wwe.com/shows/wwe-now"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/uunslehthgl7lu8/f1.jpeg?dl=0",
                        "https://www.formula1.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/0ev6gxlm9tr4r76/espn.jpeg?dl=0",
                        "https://www.espn.in"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/7n6i16p2h55jiox/247sports.jpeg?dl=0",
                        "https://247sports.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/6a641kx3w3f8x78/deadspin.jpeg?dl=0",
                        "https://deadspin.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/etbjcj1lpqhy9m6/bet365.jpeg?dl=0",
                        "https://www.bet365.com/#/AS/B3/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/s4dagmesscaswo2/sk.jpeg?dl=0",
                        "https://www.sportskeeda.com"
                      ],
                    ],
                    "SportsFeatured"),
                /* News: Local */ appSection(
                    newsLocal,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/uy9nefdep3pwg5i/ddnews.jpeg?dl=0",
                        "http://ddnews.gov.in/national"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/1b2174jtqtqcoq0/ani.jpeg?dl=0",
                        "https://aninews.in/category/national/general-news/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/siqevs51fpsudv6/ians.jpeg?dl=0",
                        "https://ians.in/index.php?param=category/139/139"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/5uq2aagdtz2eyxf/amarujala.jpeg?dl=0",
                        "https://www.amarujala.com/india-news?src=mainmenu"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/m9pvo7i02814qnx/jagran.jpeg?dl=0",
                        "https://www.jagran.com/news/national-news-hindi.html"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/0wuhmxht0zlzc4l/zeenews.jpeg?dl=0",
                        "https://zeenews.india.com/india"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/6s6xt7cwp820orn/hindustantimes.jpeg?dl=0",
                        "https://www.hindustantimes.com/india-news"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/wwug7o3aisyjiq5/dainikbhaskar.jpeg?dl=0",
                        "https://www.bhaskar.com/national/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/evb91qzkk0053u4/patrika.jpeg?dl=0",
                        "https://www.patrika.com/india-news/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/kn4lcutz712587p/india.jpeg?dl=0",
                        "https://www.india.com/news/india/"
                      ],
                    ],
                    "LocalFeatured"),
                /* News: Global */ appSection(
                    newsGlobal,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/gmdwz319xocnbh1/nyt.jpeg?dl=0",
                        "https://www.nytimes.com/international/section/world"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/00gy2h9dx5nytfe/cnn.jpeg?dl=0",
                        "https://edition.cnn.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/oxsrmhl0wrbayws/reuters.jpeg?dl=0",
                        "https://www.reuters.com/world/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/32jwttyu6jueq7r/cnbc.jpeg?dl=0",
                        "https://www.cnbc.com/world/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/kxgaf83f6eobpy4/buzzfeed.jpeg?dl=0",
                        "https://www.buzzfeednews.com/section/world"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/qv67j278sn77bma/defenseblog.jpeg?dl=0",
                        "https://defence-blog.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/68uux6gq7vx9opi/thecipherbrief.jpeg?dl=0",
                        "https://www.thecipherbrief.com"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/5u3bbafhw7ba6ep/euronews.jpeg?dl=0",
                        "https://www.euronews.com/news/international"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/8qnsvq8tw28zk47/dw.jpeg?dl=0",
                        "https://www.dw.com/en/top-stories/s-9097"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/5psdt4fqkllayrr/south.jpeg?dl=0",
                        "https://www.smh.com.au/world"
                      ],
                    ],
                    "GlobalFeatured"),
                /* Music */ appSection(
                    music,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/fad3xpeirog00d3/spotify.jpeg?dl=0",
                        "https://open.spotify.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/q12tcxfgaj6ulbp/applemusic.jpeg?dl=0",
                        "https://music.apple.com/us/browse"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/grdm14szqdgnvxu/soundcloud.jpeg?dl=0",
                        "https://soundcloud.com/discover"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/8mjq2ofadegz6i7/jiosaavn.jpeg?dl=0",
                        "https://www.jiosaavn.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/0rbbz25eboppthr/youtubemusic.jpeg?dl=0",
                        "https://music.youtube.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/couz0s88rjph2p0/hungama.jpeg?dl=0",
                        "https://www.hungama.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/wuskc29hpyxkt8b/wynk.jpeg?dl=0",
                        "https://wynk.in/music"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/ue9xrdxu4i4urpv/audiomack.jpeg?dl=0",
                        "https://audiomack.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/jiz9z4jcgm36b7i/gaana.jpeg?dl=0",
                        "https://gaana.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/f2mm8vwvjgks6kj/stream.jpeg?dl=0",
                        "https://streamplayer.io/"
                      ],
                    ],
                    "MusicFeatured",
                    size: 2),
                /* Games */ appSection(
                    games,
                    [
                      [
                        "https://dl.dropboxusercontent.com/s/9vi86pu6syp6cs6/callofwar.jpeg?dl=0",
                        "https://www.callofwar.com/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/ds1pod4dpgigivc/minigiants.jpeg?dl=0",
                        "https://minigiants.io/?v=1.6.53&play-game"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/0wva01dhyh9vup8/gartic.jpeg?dl=0",
                        "https://gartic.io"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/58tv29zsg1jyep1/catanuniverse.jpeg?dl=0",
                        "https://catanuniverse.com/en/game/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/8jn0a5ac1nv1wbq/starblast.jpeg?dl=0",
                        "https://starblast.io/#7132"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/jel8jkqd5byn7sw/krunker.jpeg?dl=0",
                        "https://krunker.io/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/9khppu2kgfxhaul/paper.jpeg?dl=0",
                        "https://paper-io.com/teams/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/w2h66bfybob4kfu/mope.jpeg?dl=0",
                        "https://mope.io/"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/g8lt1m68afdofwy/gobattle.jpeg?dl=0 ",
                        "https://www.gobattle.io/ "
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/qc3rdj9n7y1z37c/evowars.jpeg?dl=0",
                        "https://evowars.io/?v=1.8.1&play-game"
                      ],
                      [
                        "https://dl.dropboxusercontent.com/s/cfc74e1t1ilim0f/slitcher.jpeg?dl=0",
                        "https://slither.io/"
                      ],
                    ],
                    "GamesFeatured",
                    size: 2),
                /* Feature Yourself */ IgnorePointer(
                    ignoring: !featUrself,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: duration),
                      opacity: featUrself ? 1.0 : 0.0,
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //featureImage(),
                            Image(image: NetworkImage(imageSrc)),
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
                                              text: pricing.toString() + "rs",
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                            text: ") for ",
                                          ),
                                          TextSpan(
                                              text: "life time",
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold)),
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
                                            padding: EdgeInsets.only(left: 20),
                                            child: DropdownButtonFormField(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 17,
                                                          top: 16,
                                                          bottom: 16,
                                                          right: 10),
                                                  labelText: "Post Type",
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
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
                                                return DropdownMenuItem<String>(
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
                                              contentPadding:
                                                  EdgeInsets.only(left: 17),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
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
                                                text: "Abhishek Sharma ",
                                                style: GoogleFonts.openSans(
                                                    color: Colors.grey[700],
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                              TextSpan(
                                                  text:
                                                      "will create an attractive image for your post (",
                                                  style: GoogleFonts.openSans(
                                                    color: Colors.grey,
                                                  )),
                                              TextSpan(
                                                  text: "for free",
                                                  style: GoogleFonts.openSans(
                                                      color: Colors.blueAccent,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text: ") but you can ",
                                                  style: GoogleFonts.openSans(
                                                      color: Colors.grey)),
                                              TextSpan(
                                                  text: "optionally ",
                                                  style: GoogleFonts.openSans(
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                  text:
                                                      "upload your desired image of resolution 700 x 1000. ",
                                                  style: GoogleFonts.openSans(
                                                    color: Colors.grey,
                                                  )),
                                            ])),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        showImage
                                            ? IgnorePointer(
                                                ignoring: !showImage,
                                                child: AnimatedOpacity(
                                                  opacity:
                                                      showImage ? 1.0 : 0.0,
                                                  duration: Duration(
                                                      milliseconds: duration),
                                                  child: Container(
                                                      child: showImage
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Image.file(
                                                                File(
                                                                    image.path),
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 200,
                                                                width: 140,
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 0,
                                                            )),
                                                ),
                                              )
                                            : Container(height: 0, width: 0),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        showImage
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      send();
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.blueAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Center(
                                                          child: Text("Upload",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      color: Colors
                                                                          .white))),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      image = await ImagePicker()
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery,
                                                              imageQuality: 50);

                                                      setState(() {
                                                        uploadButton =
                                                            File(image.path)
                                                                .toString();
                                                        showImage = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .blueAccent,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Center(
                                                          child: Text("Change",
                                                              style: GoogleFonts.openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .blueAccent))),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        showImage = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .blueAccent,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Center(
                                                          child: Text("Remove",
                                                              style: GoogleFonts.openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .blueAccent))),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : GestureDetector(
                                                onTap: () async {
                                                  image = await ImagePicker()
                                                      .pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          imageQuality: 50);

                                                  setState(() {
                                                    uploadButton =
                                                        File(image.path)
                                                            .toString();
                                                    showImage = true;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.blueAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                      child: Text("Select",
                                                          style: GoogleFonts
                                                              .openSans(
                                                                  color: Colors
                                                                      .white))),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Step(
                                      title: Text("Payment"),
                                      isActive: _currentStep >= 0,
                                      state: _currentStep >= 2
                                          ? StepState.complete
                                          : StepState.disabled,
                                      content: Column(children: [
                                        isDiscount
                                            ? Container(
                                                width: 270,
                                                height: 37,
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      discount.toString() +
                                                          "% Discount applies here.",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      187,
                                                                      97,
                                                                      100))),
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Color.fromARGB(
                                                            100, 0, 255, 133)),
                                                    color: Color.fromARGB(
                                                        29, 0, 255, 133)))
                                            : Container(
                                                height: 0,
                                                width: 0,
                                              ),
                                        SizedBox(
                                          height: isDiscount ? 10 : 0,
                                        ),
                                        Text(
                                            "You can easily pay with any method. Here are some details about payment:",
                                            style: GoogleFonts.openSans(
                                                color: Color.fromRGBO(
                                                    67, 67, 67, 100))),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Transform.scale(
                                          scale: 0.98,
                                          child: TextField(
                                            controller: custName,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.only(left: 15),
                                                border: OutlineInputBorder(),
                                                labelText: "Your name"),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text: "Amount in (₹) ",
                                              style: GoogleFonts.openSans(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600]),
                                              children: [
                                                TextSpan(
                                                    text: "calculated ",
                                                    style: GoogleFonts.openSans(
                                                        color: Colors.grey[500],
                                                        fontWeight:
                                                            FontWeight.normal)),
                                                TextSpan(
                                                    text: isDiscount
                                                        ? "calculated after discount is "
                                                        : "is ",
                                                    style: GoogleFonts.openSans(
                                                        color: Colors.grey[500],
                                                        fontWeight:
                                                            FontWeight.normal)),
                                                TextSpan(
                                                    text: price(pricing) + "rs",
                                                    style: GoogleFonts.openSans(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.grey[600])),
                                                TextSpan(
                                                    text: ".",
                                                    style: GoogleFonts.openSans(
                                                        color: Colors.grey[500],
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              ]),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text("Pay via",
                                            style: GoogleFonts.openSans(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                myPayApp(bhim, 30,
                                                    "assets/images/apps/bhim.png"),
                                                myPayApp(gpay, 35,
                                                    "assets/images/apps/gpay.png"),
                                                myPayApp(paytm, 20,
                                                    "assets/images/apps/paytm.png"),
                                              ],
                                            ),
                                            Divider(
                                              height: 40,
                                              color: Colors.grey[400],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                myPayApp(amazonPay, 38,
                                                    "assets/images/apps/amazonpay.png"),
                                                myPayApp(phonepe, 42,
                                                    "assets/images/apps/phonepay.png"),
                                                myPayApp(sbiPay, 40,
                                                    "assets/images/apps/sbi.png"),
                                              ],
                                            ),
                                            Divider(
                                              height: 40,
                                              color: Colors.grey[400],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                myPayApp(miPayGlobal, 50,
                                                    "assets/images/apps/mipay.png"),
                                                myPayApp(mobikwik, 40,
                                                    "assets/images/apps/mobikwik.png"),
                                                myPayApp(freecharge, 42,
                                                    "assets/images/apps/freecharge.png"),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15,
                                            )
                                          ],
                                        ),
                                        Divider(),
                                        RichText(
                                            text: TextSpan(
                                                text: "Take Screenshot ",
                                                style: GoogleFonts.openSans(
                                                    color: Colors.grey[600],
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                              TextSpan(
                                                  text: "of ",
                                                  style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                              TextSpan(
                                                  text: "Transaction Reciept "),
                                              TextSpan(
                                                  text: "and ",
                                                  style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                              TextSpan(text: "Upload "),
                                              TextSpan(
                                                  text: "here:",
                                                  style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ])),
                                        SizedBox(height: 10),
                                        showTransImage
                                            ? IgnorePointer(
                                                ignoring: !showTransImage,
                                                child: AnimatedOpacity(
                                                  opacity: showTransImage
                                                      ? 1.0
                                                      : 0.0,
                                                  duration: Duration(
                                                      milliseconds: duration),
                                                  child: Container(
                                                      child: showTransImage
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Image.file(
                                                                File(trnsImage
                                                                    .path),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 0,
                                                            )),
                                                ),
                                              )
                                            : Container(height: 0, width: 0),
                                        SizedBox(height: 14),
                                        showTransImage
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (custName
                                                          .text.isEmpty) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          backgroundColor: Colors
                                                                  .yellowAccent[
                                                              700],
                                                          content:
                                                              Row(children: <
                                                                  Widget>[
                                                            //Icon widget of your choice HERE,
                                                            Text(
                                                              "Fill in Your Name",
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Icon(
                                                              Icons.warning,
                                                              color:
                                                                  Colors.black,
                                                            )
                                                          ]),
                                                        ));
                                                      } else {
                                                        sendTrns();
                                                        CollectionReference
                                                            data =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "Feature Requests");
                                                        data.add({
                                                          "name": custName.text,
                                                          "link":
                                                              featuredPostLink
                                                                  .text,
                                                          "post_type":
                                                              postTypeSelected
                                                        });
                                                        imagePostedFeatured =
                                                            true;
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.blueAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Center(
                                                          child: Text("Upload",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      color: Colors
                                                                          .white))),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      trnsImage =
                                                          await ImagePicker()
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .gallery,
                                                                  imageQuality:
                                                                      50);

                                                      setState(() {
                                                        showTransImage = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .blueAccent,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Center(
                                                          child: Text("Change",
                                                              style: GoogleFonts.openSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .blueAccent))),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : GestureDetector(
                                                onTap: () async {
                                                  trnsImage =
                                                      await ImagePicker()
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery,
                                                              imageQuality: 50);

                                                  setState(() {
                                                    showTransImage = true;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.blueAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                      child: Text("Select",
                                                          style: GoogleFonts
                                                              .openSans(
                                                                  color: Colors
                                                                      .white))),
                                                ),
                                              ),
                                      ]))
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
                                            sndFeedback();
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

  GestureDetector myPayApp(UpiApp app, int h, p) {
    return GestureDetector(
      onTap: () {
        initiateTransaction(app);
      },
      child: Container(
        height: h.toDouble(),
        child: Image.asset(p),
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
                        image: new NetworkImage(data['image']),
                      ))),
            );
          }).toList(),
        );
      },
    );
  }

  Widget checkUrl(String url) {
    try {
      return Image.network(url);
    } catch (e) {
      return Icon(Icons.image);
    }
  }
}

class LoadingGif extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/images/reloading.gif", height: 80, width: 80);
  }
}
