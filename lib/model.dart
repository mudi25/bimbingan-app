import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

const BaseImage =
    "https://storage.googleapis.com/bimbimngan-skripsi-terpadu.appspot.com/";

@immutable
class ModelUser {
  final String id;
  final String username;
  final String password;
  final String nama;
  final String alamat;
  final String nomorHp;
  final String jurusan;
  final String fakultas;
  final String roles;
  final String? fcmToken;
  final String imageUrl;
  final int timestamp;

  ModelUser({
    required this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.alamat,
    required this.nomorHp,
    required this.jurusan,
    required this.fakultas,
    required this.roles,
    required this.imageUrl,
    required this.fcmToken,
    required this.timestamp,
  });

  factory ModelUser.fromDocumentSnapshot(DocumentSnapshot doc) => ModelUser(
        id: doc.id,
        nama: doc.get('nama'),
        alamat: doc.get('alamat'),
        fakultas: doc.get('fakultas'),
        fcmToken: doc.get('fcmToken'),
        jurusan: doc.get('jurusan'),
        nomorHp: doc.get('nomorHp'),
        password: doc.get('password'),
        imageUrl: doc.get('imageUrl'),
        roles: doc.get('roles'),
        timestamp: doc.get('timestamp'),
        username: doc.get('username'),
      );
}

@immutable
class ModelJadwal {
  final String id;
  final String idSkripsi;
  final String pembimbing;
  final String mahasiswa;
  final List<String> query;
  final int timestamp;
  final String keterangan;

  String namaPembimbing(ModelInfo info) {
    if (info.pembimbing1.id == pembimbing) return info.pembimbing1.nama;
    return info.pembimbing2.nama;
  }

  String get timestampText => DateFormat('dd-MM-yyyy HH:mm')
      .format(DateTime.fromMillisecondsSinceEpoch(this.timestamp));

  ModelJadwal({
    required this.id,
    required this.idSkripsi,
    required this.timestamp,
    required this.mahasiswa,
    required this.pembimbing,
    required this.query,
    required this.keterangan,
  });
  factory ModelJadwal.fromDocumentSnapshot(DocumentSnapshot doc) => ModelJadwal(
        id: doc.id,
        idSkripsi: doc.get('idSkripsi'),
        timestamp: doc.get('timestamp'),
        mahasiswa: doc.get('mahasiswa'),
        pembimbing: doc.get('pembimbing'),
        query: List.from(doc.get('query')).map((e) => e.toString()).toList(),
        keterangan: doc.get('keterangan'),
      );
}

@immutable
class ModelChat {
  final String id;
  final String from;
  final String message;
  final int timestamp;
  get timetext => timeago.format(DateTime.now().subtract(DateTime.now()
      .difference(DateTime.fromMillisecondsSinceEpoch(timestamp))));

  String sendByName(ModelInfo info) {
    if (this.from == info.mahasiswa.id)
      return info.mahasiswa.nama;
    else if (this.from == info.pembimbing1.id) return info.pembimbing1.nama;
    return info.pembimbing2.nama;
  }

  Alignment getAligment(ModelUser user) {
    if (this.from == user.id) return Alignment.centerRight;
    return Alignment.centerLeft;
  }

  Color getColors(ModelUser user) {
    if (this.from == user.id) return Colors.greenAccent;
    return Colors.blueAccent;
  }

  ModelChat({
    required this.id,
    required this.from,
    required this.message,
    required this.timestamp,
  });

  factory ModelChat.fromDocumentSnapshot(DocumentSnapshot doc) => ModelChat(
        id: doc.id,
        from: doc.get('from'),
        message: doc.get('message'),
        timestamp: doc.get('timestamp'),
      );
}

@immutable
class ModelSkripsi {
  final String id;
  final String judul;
  final String pembimbing1;
  final String pembimbing2;
  final String mahasiswa;
  final List<String> query;
  final int timestamp;

  ModelSkripsi({
    required this.id,
    required this.judul,
    required this.pembimbing1,
    required this.pembimbing2,
    required this.mahasiswa,
    required this.query,
    required this.timestamp,
  });
  factory ModelSkripsi.fromDocumentSnapshot(DocumentSnapshot doc) =>
      ModelSkripsi(
        id: doc.id,
        judul: doc.get('judul'),
        mahasiswa: doc.get('mahasiswa'),
        pembimbing1: doc.get('pembimbing1'),
        pembimbing2: doc.get('pembimbing2'),
        query: List.of(doc.get('query')).map((e) => e.toString()).toList(),
        timestamp: doc.get('timestamp'),
      );
}

class ModelInfo {
  final ModelSkripsi skripsi;
  final ModelUser mahasiswa;
  final ModelUser pembimbing1;
  final ModelUser pembimbing2;

  ModelInfo(this.skripsi, this.mahasiswa, this.pembimbing1, this.pembimbing2);
}
