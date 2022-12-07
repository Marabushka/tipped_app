import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:tip_app/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  PageController _pageController = PageController();

  void onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        backgroundColor: Colors.black, // <-- This works for fixed
        selectedItemColor: Color.fromRGBO(7, 212, 220, 1),
        unselectedItemColor: Colors.grey,
        onTap: onTap,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad_outlined),
            label: 'Пользователи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Мой профиль',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      body: PageView(controller: _pageController, children: [
        ProfilePreview(),
        ProfileWidget(),
      ]),
    );
  }
}

class ProfilePreviewWidget extends StatefulWidget {
  String url;
  String name;
  int points;
  String email;
  bool enableButton;
  ProfilePreviewWidget(
      {Key? key,
      required this.name,
      required this.points,
      required this.email,
      required this.enableButton,
      required this.url})
      : super(key: key);

  @override
  State<ProfilePreviewWidget> createState() => _ProfilePreviewWidgetState();
}

class _ProfilePreviewWidgetState extends State<ProfilePreviewWidget> {
  @override
  bool canTip = true;
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Color.fromRGBO(180, 215, 216, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              bottomLeft: const Radius.circular(20.0),
            ), // BorderRadius
            child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.url,
                  fit: BoxFit.cover,
                )),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Имя: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.name}'),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Колличество очков: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.front_hand_sharp,
                    size: 15,
                  ),
                  Text(
                    " ${widget.points}",
                    style: TextStyle(color: Color.fromRGBO(236, 111, 14, 1)),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Ранг: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  getRang(widget.points),
                ],
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromRGBO(236, 111, 14, 1)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                onPressed: (canTip == true && widget.enableButton == true)
                    ? () {
                        AudioPlayer().play(AssetSource('audio/tipped.mp3'));
                        setState(() {
                          canTip = false;
                        });

                        Future.delayed(Duration(seconds: 3), () {
                          setState(() {
                            canTip = true;
                          });
                        });
                        incrementPoints(
                          email: widget.email,
                          points: widget.points,
                        );
                      }
                    : null,
                child: Text(
                  'Похвалить +50',
                  style: TextStyle(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  incrementPoints({
    required String email,
    required int points,
  }) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc('${email.trim()}st')
        .update(
      {
        'points': points += 50,
      },
    );
  }
}

class ProfileWidget extends StatefulWidget {
  ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  var name = AuthService().getCurrentUser?.email;
  String? nameUser;
  XFile? image;
  bool changeName = false;

  TextEditingController _controller = TextEditingController();

  var collection = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: collection.doc('${name}st').get(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');

        if (snapshot.hasData) {
          var output = snapshot.data!.data();

          return Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color.fromRGBO(7, 212, 220, 1),
                      Color.fromRGBO(90, 150, 230, 1),
                    ]),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ваш профиль:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Здравствуйте: ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            '${output!['name']}',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black.withOpacity(0.7)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: CircleAvatar(
                      foregroundImage: output['urlImage'] != null
                          ? output['urlImage'].toString().length > 2
                              ? NetworkImage(output['urlImage'])
                              : AssetImage('assets/images/no_product.jpg')
                                  as ImageProvider
                          : AssetImage('assets/images/no_product.jpg')
                              as ImageProvider,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    int uniqueUrl = DateTime.now().millisecondsSinceEpoch;
                    image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      try {
                        Reference ref = FirebaseStorage.instance
                            .ref()
                            .child('images')
                            .child('$uniqueUrl');

                        await ref.putFile(File(image!.path));

                        String url = await ref.getDownloadURL();
                        createUrl(url, '$name');
                        setState(() {});
                      } catch (e) {}
                    } else
                      return;
                  },
                  child: Text('Изменить аватар',
                      style: TextStyle(color: Color.fromRGBO(236, 111, 14, 1))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ваше имя: ',
                      style: TextStyle(
                          color: Color.fromRGBO(7, 212, 220, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      '${output['name']}',
                      style: TextStyle(
                          color: Color.fromRGBO(92, 156, 158, 1), fontSize: 20),
                    ),
                  ],
                ),
                changeName == false
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            changeName = true;
                          });
                        },
                        child: Text('Изменить имя',
                            style: TextStyle(
                                color: Color.fromRGBO(236, 111, 14, 1))),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    nameUser = value;
                                  });
                                },
                                controller: _controller,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  hintText: 'Введите имя',
                                  prefixIcon:
                                      Icon(Icons.supervised_user_circle),
                                )),
                          ),
                          ElevatedButton(
                            onPressed: _controller.text.isNotEmpty
                                ? () {
                                    createName(nameUser!, name!);
                                    setState(() {
                                      changeName = false;
                                    });
                                  }
                                : null,
                            child: Text('Изменить'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromRGBO(236, 111, 14, 1)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Колличество очков: ',
                      style: TextStyle(
                          color: Color.fromRGBO(7, 212, 220, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      '${output['points']}',
                      style: TextStyle(
                          color: Color.fromRGBO(92, 156, 158, 1), fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  createUrl(
    String url,
    String email,
  ) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc('${email.trim()}st')
        .update({
      'urlImage': url,
    });
  }

  createName(
    String name,
    String email,
  ) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc('${email.trim()}st')
        .update({
      'name': name,
    });
  }
}

Widget getRang(int points) {
  if (points > 2000) {
    return Row(
      children: [
        Text(
          'Безбашенный',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
      ],
    );
  } else if (points > 1000) {
    return Text(
      'Профессионал',
      style: TextStyle(color: Colors.red),
    );
  } else if (points > 300) {
    return Text(
      'Любитель',
      style: TextStyle(color: Colors.yellow),
    );
  }

  return Text(
    'Новичок',
    style: TextStyle(color: Colors.green),
  );
}

class ProfilePreview extends StatelessWidget {
  ProfilePreview({Key? key}) : super(key: key);
  var name = AuthService().getCurrentUser?.email;
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AuthService>(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          return Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: TextButton(
                    child: Text(
                      'Выйти',
                      style: TextStyle(
                        color: Color.fromRGBO(7, 212, 220, 1),
                      ),
                    ),
                    onPressed: (() => model.logOut()),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data();
                        if (data['email'] != name) {
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ProfilePreviewWidget(
                                name: data['name'],
                                points: data['points'],
                                email: data['email'],
                                url: data['urlImage'] != null
                                    ? data['urlImage'].toString().length > 2
                                        ? data['urlImage']
                                        : 'https://www.eurostroyhm.ru/upload/iblock/c6f/jj1as58n1j11otu4p1jo1ocwx14bbdhu.gif'
                                    : 'https://www.eurostroyhm.ru/upload/iblock/c6f/jj1as58n1j11otu4p1jo1ocwx14bbdhu.gif',
                                enableButton: true,
                              ));
                        } else {
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ProfilePreviewWidget(
                                name: data['name'],
                                points: data['points'],
                                email: data['email'],
                                url: data['urlImage'] != null
                                    ? data['urlImage'].toString().length > 2
                                        ? data['urlImage']
                                        : 'https://www.eurostroyhm.ru/upload/iblock/c6f/jj1as58n1j11otu4p1jo1ocwx14bbdhu.gif'
                                    : 'https://www.eurostroyhm.ru/upload/iblock/c6f/jj1as58n1j11otu4p1jo1ocwx14bbdhu.gif',
                                enableButton: false,
                              ));
                        }
                      }),
                ),
              ],
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
