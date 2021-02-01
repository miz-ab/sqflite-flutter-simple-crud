import 'dart:convert';
//import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'UserModel.dart';
import 'DataBaseHelper.dart';

class UserList extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserList> {
  List<UserModel> userModelList = new List();
  //Uint8List _bytesImage;
  String base64Image;

  @override
  void initState() {
    super.initState();
    print('init state of user list...');

    DataBaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((e) {
          userModelList.add(UserModel(
              id: e['id'],
              firstName: e['firstName'],
              lastName: e['lastName'],
              phoneNo: e['phoneNo'].toString(),
              email: e['email'],
              image: e['image']));
        });
      });
    }).catchError((error) {
      print(error);
    });
    userModelList.forEach((element) => print(element.firstName));
  }

  _deleteUser(int id) async {
    await DataBaseHelper.instance.delete(id);
    setState(() {
      userModelList.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User List'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: userModelList.isEmpty
                ? Container(
                    child: Center(
                    child: Text(
                      'No data Found',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ))
                : ListView.builder(itemBuilder: (context, index) {
                    if (index == userModelList.length) return null;
                    return Card(
                        elevation: 8.0,
                        child: ListTile(
                            leading: CircleAvatar(
                                child:
                                    //Text(userModelList[index].id.toString())),
                                    Image.memory(Base64Decoder()
                                        .convert(userModelList[index].image))),
                            title: Text(userModelList[index].firstName),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      //this right here
                                      child: Container(
                                        height: 380,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                                /*
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(8.0),
                                              ),
                                              */
                                                child: Image.memory(
                                                    Base64Decoder().convert(
                                                        userModelList[index]
                                                            .image))),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Center(
                                              child: Text(
                                                userModelList[index].firstName,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Center(
                                              child: Text(
                                                userModelList[index].email,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Center(
                                              child: Text(
                                                userModelList[index].phoneNo,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteUser(userModelList[index].id),
                            )));
                  }),
          ),
        ));
  }
}
