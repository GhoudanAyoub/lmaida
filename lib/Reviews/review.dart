import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/models/category.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/utils/validation.dart';

import '../Reviews/costumimage.dart';

class Review extends StatefulWidget with NavigationStates {
  final idbooking;

  const Review({Key key, this.idbooking}) : super(key: key);
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  DocumentSnapshot user1;
  final picker = ImagePicker();
  double ratingG = 1;
  TextEditingController _reviewContoller = TextEditingController();
  TextEditingController _likeContoller = TextEditingController();
  TextEditingController _notLikeContoller = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String imgLink;
  File mediaUrl;
  File mediaUrl2;
  File mediaUrl3;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final String positiveTag = StringConst.URI_POSTAG;
  final String negativeTag = StringConst.URI_NEGTAG;

  List<Category> negativeList = [];
  List<Category> positiveList = [];

  List<Category> filteredNegativeList = [];
  List<Category> filteredPositiveList = [];

  int _activeTab = 0;
  int _activeTab2 = 0;

  String positiveTagString = '';
  String negativeTagString = '';

  bool sending = false;

  Future fetPositiveTag() async {
    var result = await http.get(positiveTag);
    return json.decode(result.body);
  }

  Future fetNegativeTag() async {
    var result = await http.get(negativeTag);
    return json.decode(result.body);
  }

  getData() async {
    var res = await fetPositiveTag();
    var res2 = await fetNegativeTag();
    for (var r in res) {
      positiveList.add(Category(id: r['id'], name: r['text']));
      filteredPositiveList.add(Category(id: r['id'], name: r['text']));
    }
    for (var r in res2) {
      negativeList.add(Category(id: r['id'], name: r['text']));
      filteredNegativeList.add(Category(id: r['id'], name: r['text']));
    }
  }

  searchPositive(String query) {
    if (query == "") {
      setState(() {
        filteredPositiveList = positiveList;
      });
    } else {
      List userSearch = positiveList.where((userSnap) {
        return userSnap.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredPositiveList = userSearch;
      });
    }
  }

  searchNegative(String query) {
    if (query == "") {
      filteredNegativeList = negativeList;
    } else {
      List userSearch = negativeList.where((userSnap) {
        return userSnap.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredNegativeList = userSearch;
      });
    }
  }

  getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) {
      user1 = snap;
    }
  }

  Future<dynamic> userLog(context) async {
    setState(() {
      sending = true;
    });
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/login';
    var data = {
      'email': firebaseAuth.currentUser.email,
      'password': user1.data()["password"],
    };
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    return getPorf(message["token"], context);
  }

  Future getPorf(Token, context) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    AddReviews(Token, message[0]["id"], context);
  }

  Future AddReviews(Token, userid, context) async {
    var dio = Dio();
    var options = Options(validateStatus: (status) => true,
        //followRedirects: false,
        headers: {
          "Authorization": "Bearer $Token",
        });
    var url = 'https://lmaida.com/api/review';
    FormState form = formKey.currentState;
    if (!form.validate()) {
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      var formData = FormData.fromMap({
        'idbooking':
            widget.idbooking != null ? widget.idbooking.toString() : "1",
        'iduser': userid.toString(),
        'reviews': ratingG.toString(),
        'texts': _reviewContoller.text,
        'positivtag': positiveTagString,
        'negativetag': negativeTagString,
        'image1':
            await MultipartFile.fromFile(mediaUrl.path, filename: 'upload.jpg'),
        'image2': await MultipartFile.fromFile(mediaUrl2.path,
            filename: 'upload2.jpg'),
        'image3': await MultipartFile.fromFile(mediaUrl3.path,
            filename: 'upload3.jpg'),
      });
      var response = await dio.post(url, data: formData, options: options);
      Fluttertoast.showToast(
          msg: response.data['message'].toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    getData();
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Color(0xfff2f3f7),
          body: Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  left: 100.0,
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      "assets/images/coffee2.png",
                      width: 150.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 200.0,
                  right: -180.0,
                  child: Image.asset(
                    "assets/images/square.png",
                  ),
                ),
                Positioned(
                  child: Image.asset(
                    "assets/images/drum.png",
                  ),
                  left: -70.0,
                  bottom: -40.0,
                ),
                Container(
                  height: SizeConfig.screenHeight,
                  padding: EdgeInsets.fromLTRB(30, 50, 30, 20),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Write a Review",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              CupertinoIcons.clear,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Tap To rate your experience ",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RatingBar.builder(
                        initialRating: 1,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        glowColor: Colors.white,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                          setState(() {
                            ratingG = rating;
                          });
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "what was not up to the mark 🥺 ",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormBuilder(
                            controller: _notLikeContoller,
                            prefix: Feather.inbox,
                            hintText: "Search or select from blow",
                            onChange: (q) {
                              searchNegative(q);
                            },
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _activeTab = index;
                                      negativeTagString +=
                                          "#${filteredNegativeList[index].name} ";
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 450),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _activeTab == index
                                          ? mainColor.withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        filteredNegativeList[index].name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _activeTab == index
                                              ? Colors.white
                                              : kTextColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 15.0,
                                );
                              },
                              itemCount: filteredNegativeList.length,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: Text(
                              negativeTagString,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "what did you like? 😊",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormBuilder(
                            controller: _likeContoller,
                            prefix: Feather.inbox,
                            hintText: "Search or select from blow",
                            onChange: (q) {
                              searchPositive(q);
                            },
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _activeTab2 = index;
                                      positiveTagString +=
                                          "#${filteredPositiveList[index].name} ";
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 450),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _activeTab2 == index
                                          ? mainColor.withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        filteredPositiveList[index].name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _activeTab2 == index
                                              ? Colors.white
                                              : kTextColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 15.0,
                                );
                              },
                              itemCount: filteredPositiveList.length,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: Text(
                              positiveTagString,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add pictures :",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                              Divider(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () => showImageChoices(context),
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[500],
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                        border: Border.all(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      child: imgLink != null
                                          ? CustomImage(
                                              imageUrl: imgLink,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  30,
                                              fit: BoxFit.cover,
                                            )
                                          : mediaUrl == null
                                              ? Center(
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Image.file(
                                                  mediaUrl,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      30,
                                                  fit: BoxFit.cover,
                                                ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () => showImageChoices2(context),
                                        child: Container(
                                          width: 120,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            border: Border.all(
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          ),
                                          child: imgLink != null
                                              ? CustomImage(
                                                  imageUrl: imgLink,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      30,
                                                  fit: BoxFit.cover,
                                                )
                                              : mediaUrl2 == null
                                                  ? Center(
                                                      child: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Image.file(
                                                      mediaUrl2,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              30,
                                                      fit: BoxFit.cover,
                                                    ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () => showImageChoices3(context),
                                        child: Container(
                                          width: 120,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5.0),
                                            ),
                                            border: Border.all(
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          ),
                                          child: imgLink != null
                                              ? CustomImage(
                                                  imageUrl: imgLink,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      30,
                                                  fit: BoxFit.cover,
                                                )
                                              : mediaUrl3 == null
                                                  ? Center(
                                                      child: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Image.file(
                                                      mediaUrl3,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              30,
                                                      fit: BoxFit.cover,
                                                    ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextFormBuilder(
                                prefix: Feather.file_text,
                                hintText: "Write your review",
                                controller: _reviewContoller,
                                validateFunction: Validations.validateReview,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      sending == false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                /* sending == false
                              ?*/
                                FloatingActionButton(
                                  shape: CircleBorder(),
                                  heroTag: 'Add Review',
                                  mini: true,
                                  onPressed: () {
                                    userLog(context);
                                  },
                                  backgroundColor: Colors.red[900],
                                  child: Icon(Icons.arrow_forward_ios,
                                      size: 25, color: Colors.white),
                                )
                                /* : Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator(),
                                )*/
                              ],
                            )
                          : Container(
                              height: 0,
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showImageChoices(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xfff2f3f7),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Feather.camera,
                  color: Colors.black,
                ),
                title: Text('Camera',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(camera: true);
                },
              ),
              ListTile(
                leading: Icon(
                  Feather.image,
                  color: Colors.black,
                ),
                title: Text('Gallery',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  showImageChoices2(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xfff2f3f7),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Feather.camera,
                  color: Colors.black,
                ),
                title: Text('Camera',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage2(camera: true);
                },
              ),
              ListTile(
                leading: Icon(
                  Feather.image,
                  color: Colors.black,
                ),
                title: Text('Gallery',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage2();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  showImageChoices3(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xfff2f3f7),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Feather.camera,
                  color: Colors.black,
                ),
                title: Text('Camera',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage3(camera: true);
                },
              ),
              ListTile(
                leading: Icon(
                  Feather.image,
                  color: Colors.black,
                ),
                title: Text('Gallery',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage3();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  pickImage({bool camera = false}) async {
    try {
      PickedFile pickedFile = await picker.getImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      setState(() {
        mediaUrl = File(croppedFile.path);
      });
    } catch (e) {
      showInSnackBar('Cancelled');
    }
  }

  pickImage2({bool camera = false}) async {
    try {
      PickedFile pickedFile = await picker.getImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      setState(() {
        mediaUrl2 = File(croppedFile.path);
      });
    } catch (e) {
      showInSnackBar('Cancelled');
    }
  }

  pickImage3({bool camera = false}) async {
    try {
      PickedFile pickedFile = await picker.getImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      setState(() {
        mediaUrl3 = File(croppedFile.path);
      });
    } catch (e) {
      showInSnackBar('Cancelled');
    }
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
