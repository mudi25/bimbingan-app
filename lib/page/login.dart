import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PageLogin extends StatefulWidget {
  @override
  _PageLoginState createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final username = TextEditingController();
  final password = TextEditingController();
  final client = http.Client();
  final auth = FirebaseAuth.instance;
  final radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  bool loading = false;
  void login() async {
    try {
      setState(() => loading = true);
      print(username.text);
      print(password.text);
      final result = await client.post(
          Uri.parse("https://bimbingan-api.herokuapp.com/login-android"),
          body: {"username": username.text, "password": password.text});
      if (result.statusCode >= 200 && result.statusCode <= 299) {
        await auth.signInWithCustomToken(jsonDecode(result.body)['token']);
        setState(() => loading = false);
        return;
      }
      throw new Exception("username atau password tidak ditemukan");
    } catch (e) {
      setState(() => loading = false);
      Get.snackbar("Gagal", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  Text("Bimbingan"),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: username,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(90.0)),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            hintText: 'Username'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(90.0)),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            hintText: 'Password'),
                      ),
                      OutlinedButton(
                        onPressed: () => login(),
                        child: Text("Login"),
                      )
                    ],
                  ),
                ),
                if (loading == true) LinearProgressIndicator()
              ],
            ),
          )
        ],
      ),
    );
  }
}
