import 'dart:developer';
import 'dart:io';

import 'package:bimbingan_app/model.dart';
import 'package:bimbingan_app/page/chat.dart';
import 'package:bimbingan_app/page/jadwal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

final uuid = Uuid();

class PageHome extends StatelessWidget {
  final User firebaseUser;

  const PageHome({required this.firebaseUser});
  Future<void> setnotification() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(firebaseUser.uid)
            .update({'fcmToken': token});
        print(token);
      }
    } catch (e) {
      print(e.toString());
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Bimbingan"),
          actions: [
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () => {FirebaseAuth.instance.signOut()})
          ],
        ),
        body: FutureBuilder(
          future: setnotification(),
          builder: (_, __) => StreamBuilder<ModelUser?>(
            stream: FirebaseFirestore.instance
                .collection('user')
                .doc(firebaseUser.uid)
                .snapshots()
                .map((event) => event.exists == true
                    ? ModelUser.fromDocumentSnapshot(event)
                    : null),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final data = snapshot.data;
                log(data?.id ?? 'hello');
                if (data != null) {
                  return _HomeContent(user: data);
                }
              }
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ));
  }
}

class _HomeContent extends StatelessWidget {
  final ModelUser user;
  const _HomeContent({required this.user});
  Future getImage() async {
    try {
      final picker = ImagePicker();
      final storage = FirebaseStorage.instance;
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final path = pickedFile.path;
      final extension = p.extension(path);
      final uploadRef = "${uuid.v4()}.$extension";
      await storage.ref().child(uploadRef).putFile(File(path));
      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.id)
          .update({"imageUrl": BaseImage + uploadRef});
    } catch (e) {
      Get.snackbar("Failed", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Row(
              children: [
                InkWell(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.imageUrl),
                    maxRadius: 40,
                  ),
                  onTap: () => getImage(),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(user.nama),
                    ),
                    FittedBox(
                      child: Text(user.nomorHp),
                    )
                  ],
                ),
                // StreamBuilder<RemoteMessage?>(
                //     stream: FirebaseMessaging.onMessage,
                //     builder: (_, snap) {
                //       if (snap.connectionState == ConnectionState.active) {
                //         final notification = snap.data?.notification;
                //         final title = notification?.title;
                //         final body = notification?.body;
                //         if (title != null && body != null) {
                //           Get.snackbar(title, body);
                //         }
                //       }
                //       return Container();
                //     })
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: Get.mediaQuery.size.height,
            child: _SkripsiContent(modelUser: this.user),
          ),

          // SliverToBoxAdapter(
          //   child: _SkripsiContent(
          //     modelUser: this.user,
          //   ),
          // Column(
          //   children: [
          //     Flexible(
          //       flex: 1,
          //       child: Container(
          //         child: Card(
          //           child: Column(
          //             children: [Text(user.nama), Text(user.nomorHp)],
          //           ),
          //         ),
          //       ),
          //     ),
          //     Flexible(
          //       flex: 3,
          //       child: _SkripsiContent(
          //         modelUser: this.user,
          //       ),
          //     ),
          //   ],
          // ),
          // ),
        )
      ],
    );
  }
}

class _SkripsiContent extends StatelessWidget {
  final ModelUser modelUser;
  Future<ModelInfo> loadInfo(ModelSkripsi skripsi) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final result = await Future.wait([
        firestore.collection('user').doc(skripsi.mahasiswa).get(),
        firestore.collection('user').doc(skripsi.pembimbing1).get(),
        firestore.collection('user').doc(skripsi.pembimbing2).get()
      ]);
      final mahasiswa = ModelUser.fromDocumentSnapshot(result[0]);
      final pembimbing1 = ModelUser.fromDocumentSnapshot(result[1]);
      final pembimbing2 = ModelUser.fromDocumentSnapshot(result[2]);
      return ModelInfo(skripsi, mahasiswa, pembimbing1, pembimbing2);
    } catch (e) {
      throw new Exception(e.toString());
    }
  }

  void infoClick(ModelSkripsi skripsi) async {
    try {
      final result = await this.loadInfo(skripsi);
      await Get.bottomSheet(
        Wrap(children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text("Mahasiswa"),
                  subtitle: Text(result.mahasiswa.nama),
                ),
                ListTile(
                  title: Text("Pembimbing 1"),
                  subtitle: Text(result.pembimbing1.nama),
                ),
                ListTile(
                  title: Text("Pembimbing 2"),
                  subtitle: Text(result.pembimbing2.nama),
                )
              ],
            ),
          ),
        ]),
      );
      return;
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    }
  }

  void chatClick(ModelSkripsi skripsi) async {
    try {
      final result = await this.loadInfo(skripsi);
      await Get.to(() => PageChat(
            info: result,
            user: this.modelUser,
          ));
      return;
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    }
  }

  void jadwalClick(ModelSkripsi skripsi) async {
    try {
      final result = await this.loadInfo(skripsi);
      await Get.to(
        () => PageJadwal(
          info: result,
          user: this.modelUser,
        ),
      );
      return;
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    }
  }

  const _SkripsiContent({required this.modelUser});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ModelSkripsi>>(
        stream: FirebaseFirestore.instance
            .collection('skripsi')
            .where('query', arrayContains: modelUser.id)
            .snapshots()
            .map((event) => event.docs
                .map((e) => ModelSkripsi.fromDocumentSnapshot(e))
                .toList()),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final list = snapshot.data;
            if (list != null) {
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    title: Text(list[i].judul),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            icon: Icon(Icons.chat),
                            onPressed: () => chatClick(list[i])),
                        IconButton(
                            icon: Icon(Icons.schedule),
                            onPressed: () => jadwalClick(list[i])),
                        IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () => infoClick(list[i]))
                      ],
                    ),
                  ),
                ),
              );
            }
          }
          return LinearProgressIndicator();
        });
  }
}
