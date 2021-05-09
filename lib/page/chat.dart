import 'package:bimbingan_app/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PageChat extends StatelessWidget {
  final ModelInfo info;
  final ModelUser user;

  const PageChat({required this.info, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: StreamBuilder<List<ModelChat>>(
          stream: FirebaseFirestore.instance
              .collection('skripsi')
              .doc(info.skripsi.id)
              .collection('chat')
              .orderBy('timestamp', descending: false)
              .snapshots()
              .map((query) => query.docs
                  .map((e) => ModelChat.fromDocumentSnapshot(e))
                  .toList()),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.active) {
              final data = snap.data;
              if (data != null) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, i) => Container(
                          alignment: data[i].getAligment(user),
                          child: Card(
                            color: data[i].getColors(user),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text(data[i].sendByName(info)),
                                ),
                                ListTile(
                                  title: Text(data[i].message),
                                  subtitle: Text(data[i].timetext),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _CreateChat(
                      collection: "skripsi/${info.skripsi.id}/chat",
                      idUser: user.id,
                    ),
                  ],
                );
              }
            }
            return Container(
              child: LinearProgressIndicator(),
            );
          }),
    );
  }
}

class _CreateChat extends StatefulWidget {
  final String collection;
  final String idUser;

  const _CreateChat({required this.collection, required this.idUser});
  @override
  __CreateChatState createState() => __CreateChatState();
}

class __CreateChatState extends State<_CreateChat> {
  final TextEditingController controller = TextEditingController();

  void send() async {
    try {
      if (controller.text.isNotEmpty) {
        final message = controller.text;
        controller.clear();
        final ref =
            FirebaseFirestore.instance.collection(widget.collection).doc();
        await ref.set({
          "id": ref.id,
          "from": widget.idUser,
          "message": message,
          "timestamp": DateTime.now().millisecondsSinceEpoch
        });
      }
      return;
    } catch (e) {
      Get.snackbar("Failed", e.toString());
      return;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Buat Pesan ...',
        suffixIcon: IconButton(icon: Icon(Icons.send), onPressed: () => send()),
      ),
    );
  }
}
