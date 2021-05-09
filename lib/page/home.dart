import 'dart:developer';

import 'package:bimbingan_app/model.dart';
import 'package:bimbingan_app/page/chat.dart';
import 'package:bimbingan_app/page/jadwal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageHome extends StatelessWidget {
  final User firebaseUser;

  const PageHome({required this.firebaseUser});
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
        body: StreamBuilder<ModelUser?>(
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
        ));
  }
}

class _HomeContent extends StatelessWidget {
  final ModelUser user;

  const _HomeContent({required this.user});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [Text(user.nama), Text(user.nomorHp)],
                ),
              ),
            )),
        Flexible(
          flex: 3,
          child: _SkripsiContent(
            modelUser: this.user,
          ),
        ),
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
