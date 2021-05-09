import 'package:bimbingan_app/model.dart';
import 'package:bimbingan_app/page/manipulasiJadwal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PageJadwal extends StatelessWidget {
  final ModelInfo info;
  final ModelUser user;

  const PageJadwal({required this.info, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                if (user.roles == "MAHASISWA") {
                  await Get.bottomSheet(
                    Wrap(
                      children: [
                        Card(
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(info.pembimbing1.nama),
                                subtitle: Text("pembimbing 1"),
                                onTap: () async {
                                  Get.back();
                                  await Get.to(
                                    () => PageManipulasiJadwal(
                                      jadwal: ModelJadwal(
                                          id: FirebaseFirestore.instance
                                              .collection('jadwal')
                                              .doc()
                                              .id,
                                          idSkripsi: info.skripsi.id,
                                          timestamp: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          mahasiswa: info.mahasiswa.id,
                                          pembimbing: info.pembimbing1.id,
                                          query: [
                                            info.mahasiswa.id,
                                            info.pembimbing1.id
                                          ].toList(),
                                          keterangan: '-'),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(info.pembimbing2.nama),
                                subtitle: Text("pembimbing 2"),
                                onTap: () async {
                                  Get.back();

                                  await Get.to(
                                    () => PageManipulasiJadwal(
                                      jadwal: ModelJadwal(
                                          id: FirebaseFirestore.instance
                                              .collection('jadwal')
                                              .doc()
                                              .id,
                                          idSkripsi: info.skripsi.id,
                                          timestamp: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          mahasiswa: info.mahasiswa.id,
                                          pembimbing: info.pembimbing2.id,
                                          query: [
                                            info.mahasiswa.id,
                                            info.pembimbing2.id
                                          ].toList(),
                                          keterangan: '-'),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
              }),
        ],
      ),
      body: StreamBuilder<List<ModelJadwal>>(
        stream: FirebaseFirestore.instance
            .collection('jadwal')
            .where('query', arrayContains: user.id)
            .snapshots()
            .map((event) => event.docs
                .map((e) => ModelJadwal.fromDocumentSnapshot(e))
                .toList()),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final list = snapshot.data;
            if (list != null) {
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () async {
                    await Get.to(
                      () => PageManipulasiJadwal(
                        jadwal: list[i],
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list[i].timestampText,
                            style: TextStyle(fontSize: 20),
                          ),
                          Divider(
                            height: 5,
                            color: Colors.black54,
                          ),
                          Text(list[i].keterangan),
                          Divider(
                            height: 5,
                            color: Colors.black54,
                          ),
                          Text(
                            "Pembimbing " + list[i].namaPembimbing(info),
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "Mahasiswa " + info.mahasiswa.nama,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return LinearProgressIndicator();
        },
      ),
    );
  }
}
