import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tip_app/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoged = true;
  final TextEditingController loginRegisterController = TextEditingController();
  final TextEditingController passwordRegisterController =
      TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String email = '';
  String password = '';
  String registerEmail = '';
  String registerPassword = '';
  String name = '';
  XFile? image;
  String? url;
  String urlPath = '';

  String? loginErrorMessage;
  String? passwordErrorMessage;
  @override
  Widget build(BuildContext context) {
    if (isLoged == true) {
      String? errorMessage = context.watch<AuthService>().errorMessage;

      return Scaffold(
        body: Container(
          color: Colors.black,
          child: Column(children: [
            Container(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'Войти в аккаунт',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.black.withOpacity(0.8),
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        controller: loginController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          errorText: errorMessage,
                          hintText: 'Введите логин',
                          prefixIcon: Icon(Icons.supervised_user_circle),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      controller: passwordController,
                      obscureText: true,
                      decoration:
                          getDecoration(null, Icons.password, 'Введите пароль'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Нет аккаунта:',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLoged = false;
                            });
                          },
                          child: Text(
                            'Регистрация',
                            style: TextStyle(
                              color: Color.fromRGBO(236, 111, 14, 1),
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: Text(
                              'Войти',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              if (email.isNotEmpty && password.isNotEmpty) {
                                onSingInButtonTap(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Ошибка'),
                                      content: Container(
                                          width: 200,
                                          height: 50,
                                          child: Text(
                                            'Введите логин и пароль',
                                            style: TextStyle(color: Colors.red),
                                          )),
                                    );
                                  },
                                );
                              }
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
    } else {
      String? errorRegisterMessage =
          context.watch<AuthService>().errorRegisterMessage;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              Container(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Регистрация',
                      style: TextStyle(
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            registerEmail = value;
                          });
                        },
                        controller: loginRegisterController,
                        decoration: getDecoration(
                            loginErrorMessage, Icons.mail, 'Введите email'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            registerPassword = value;
                          });
                        },
                        controller: passwordRegisterController,
                        obscureText: true,
                        decoration: getDecoration(passwordErrorMessage,
                            Icons.password, 'Введите пароль'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Уже есть аккаунт?',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLoged = true;
                              });
                            },
                            child: Text(
                              'Вход',
                              style: TextStyle(
                                color: Color.fromRGBO(236, 111, 14, 1),
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Введите имя:',
                            style: TextStyle(
                                color: Color.fromRGBO(7, 212, 220, 1)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                              controller: nameController,
                              decoration: getDecoration(
                                  null, Icons.face, 'Введите имя'),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.3,
                            child: CircleAvatar(
                              foregroundImage: image == null
                                  ? AssetImage('assets/images/download.png')
                                  : FileImage(File(image!.path))
                                      as ImageProvider,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Выберите аватар:',
                                style: TextStyle(
                                    color: Color.fromRGBO(7, 212, 220, 1)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  int uniqueUrl =
                                      DateTime.now().millisecondsSinceEpoch;

                                  var images = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  setState(() {
                                    image = images;
                                  });
                                  if (image != null) {
                                    try {
                                      Reference ref = FirebaseStorage.instance
                                          .ref()
                                          .child('images')
                                          .child('$uniqueUrl');

                                      await ref.putFile(File(image!.path));

                                      await ref.getDownloadURL().then((value) {
                                        setState(() {
                                          urlPath = value;
                                        });
                                      });
                                    } catch (e) {}
                                  } else
                                    return;
                                },
                                child: Text(
                                  'Выбрать',
                                  style: TextStyle(
                                      color: Color.fromRGBO(236, 111, 14, 1)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Зарегистрироваться',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: urlPath.length > 1
                                  ? () {
                                      if (registerEmail.isNotEmpty &&
                                          registerPassword.isNotEmpty &&
                                          name.isNotEmpty &&
                                          urlPath.length > 1) {
                                        if (registerEmail
                                                    .trim()
                                                    .isValidEmail() ==
                                                true &&
                                            registerPassword.length > 7) {
                                          onRegisterButtonTap(context);
                                          create(name, registerEmail.trim());
                                          createUrl(
                                              urlPath, registerEmail.trim());
                                        } else {
                                          if (registerEmail
                                                  .trim()
                                                  .isValidEmail() ==
                                              false) {
                                            setState(() {
                                              loginErrorMessage =
                                                  'Неправильный формат почты';
                                            });
                                            if (registerPassword.length < 7) {
                                              setState(() {
                                                passwordErrorMessage =
                                                    'Длинна пароля должна быть больше 7 символов';
                                              });
                                            }
                                          }
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Ошибка'),
                                              content: Container(
                                                  width: 200,
                                                  height: 50,
                                                  child: Text(
                                                    'Введены не все данные',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )),
                                            );
                                          },
                                        );
                                      }
                                    }
                                  : null),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
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

  create(
    String name,
    String email,
  ) async {
    int tipsCount = 0;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc('${email.trim()}st')
        .set({
      'name': name,
      'email': email,
      'points': tipsCount,
    });
  }

  void onSingInButtonTap(
    BuildContext context,
  ) async {
    final model = Provider.of<AuthService>(context, listen: false);
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    try {
      await model.singInInWithEmail(
          email: loginController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {}
  }

  void onRegisterButtonTap(BuildContext context) async {
    final model = Provider.of<AuthService>(context, listen: false);
    if (registerEmail.isEmpty || registerPassword.isEmpty) {
      return;
    }

    try {
      await model.registerInWithEmail(
          email: loginRegisterController.text.trim(),
          password: passwordRegisterController.text.trim());
    } on FirebaseAuthException catch (e) {}
  }
}

getDecoration(String? error, IconData icon, String title) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
    ),
    errorText: error,
    hintText: title,
    prefixIcon: Icon(icon),
  );
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
