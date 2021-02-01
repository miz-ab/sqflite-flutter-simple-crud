import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'UserList.dart';
import 'UserModel.dart';
import 'DataBaseHelper.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  //for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _validateInputsStatus = false;

  List<UserModel> userModelList = new List();
  File _image;
  //Uint8List _bytesImage;
  String base64Image;

  //method for add image

  _imgFromCamera() async {
    PickedFile selectedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxHeight: 854.0,
        maxWidth: 854.0);
    File selectedImage = File(selectedFile.path);

    //File image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = selectedImage;
    });
  }

  _imgFromGallery() async {
    PickedFile selectedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    File selectedImage = File(selectedFile.path);
    List<int> imagebytes = selectedImage.readAsBytesSync();

    img.Image imageResized = img.decodeImage(imagebytes);
    img.Image thumbnail = img.copyResize(imageResized, width: 850, height: 850);

    var thumb = img.encodePng(thumbnail);

    print('image bytes ' + imagebytes.toString());
    base64Image = base64Encode(thumb);
    print('string in base 64 ...');
    print(base64Image);
    //_bytesImage = Base64Decoder().convert(base64Image);
    print('selected file path ' + selectedFile.path);

    File resizedFile = await File(selectedFile.path).writeAsBytes(thumb);

    setState(() {
      _image = resizedFile;
      //print('file after compressed');
      //print(croppedFile.lengthSync());
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //validate user input
  void validateInputs() {
    print('validate inputs');
    if (_formKey.currentState.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState.save();
      _validateInputsStatus = true;
    } else {
      //If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
        _validateInputsStatus = false;
      });
    }
  }

  //method for add new user
  void _addToDb() async {
    String firstName = firstnameController.text;
    String lastName = lastnameController.text;
    String phoneNo = phoneController.text;
    String email = emailController.text;
    String image = base64Image;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phoneNo.isEmpty ||
        email.isEmpty) {
      //show_toast("PLS Fill The data",duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    } else {
      var id = await DataBaseHelper.instance.insert(UserModel(
          firstName: firstName,
          lastName: lastName,
          phoneNo: phoneNo,
          email: email,
          image: image));
      setState(() {
        userModelList.insert(
            0,
            UserModel(
                id: id,
                firstName: firstName,
                lastName: lastName,
                phoneNo: phoneNo,
                email: email,
                image: image));
      });
      if (id != null) {
        print('data in');
      }
      show_toast('Data Inserted !',
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } //else
  }

  //clear db
  void _clearDb() async {
    await DataBaseHelper.instance.clearTable();
    //setState(() {
    //taskList.removeWhere((element) => element.id == id);
    //});
  }

  // ignore: non_constant_identifier_names
  void show_toast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void handleClick(String value) {
    switch (value) {
      case 'User Lists':
        print('user list');
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => UserList(),
          ),
        );
        break;
      case 'Clear Data':
        _clearDb();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    print('init state...');
    //_getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'User Lists', 'Clear Data'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: new Form(
            key: _formKey,
            autovalidate: _autoValidate,
            //autovalidateMode: AutovalidateMode.always,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 10.0),
                Card(
                  margin: const EdgeInsets.all(0.1),
                  color: Colors.blue,
                  elevation: 0.0,
                  child: SizedBox(
                    height: 50.0,
                    child: InkWell(
                      splashColor: Colors.lightBlue,
                      onTap: () {},
                      child: Row(
                        children: const <Widget>[
                          Expanded(
                            child: Text(
                              'Registration Form',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xffFDCF09),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.file(
                                _image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your First Name',
                      labelText: 'First Name',
                    ),
                    maxLines: 1,
                    controller: firstnameController,
                    validator: validateName,
                    onSaved: (String str) {
                      firstnameController.text = str;
                      //fname = val;
                    }),
                const SizedBox(height: 10.0),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Your Last Name',
                    labelText: 'Last Name',
                  ),
                  maxLines: 1,
                  controller: lastnameController,
                  validator: validateName,
                  onSaved: (String str) {
                    lastnameController.text = str;
                  },
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Phone No',
                      labelText: 'Enter Phone',
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    controller: phoneController,
                    validator: validatePhoneNo,
                    onSaved: (String str) {
                      phoneController.text = str;
                    }),
                const SizedBox(height: 10.0),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Email Address',
                    labelText: 'Enter Email',
                  ),
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: validateEmail,
                  onSaved: (String str) {
                    emailController.text = str;
                  },
                ),
                const SizedBox(height: 10.0),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                        width: double.maxFinite,
                        child: RaisedButton(
                          onPressed: () => {
                            validateInputs(),
                            if (_validateInputsStatus)
                              {
                                _addToDb(),
                              },
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          color: Colors.blue,
                          textColor: Colors.white,
                          padding: const EdgeInsets.all(0.1),
                          elevation: 5.0,
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String validateName(String str) {
    RegExp nameRegExp = RegExp('[a-zA-Z]');
    if (str.length < 3) {
      return 'Name must be more than 2 charater';
    } else if (!(nameRegExp.hasMatch(str)) && (str.length > 2)) {
      return 'Name must be alphabet charater';
    } else {
      return null;
    }
  }

  String validatePhoneNo(String phoneNo) {
    if (phoneNo.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String validateEmail(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    if (!regex.hasMatch(email))
      return 'Enter Valid Email';
    else
      return null;
  }
} //end of homeScreen
