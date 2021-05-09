import 'package:bimbingan_app/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PageManipulasiJadwal extends StatefulWidget {
  final ModelJadwal jadwal;

  const PageManipulasiJadwal({required this.jadwal});
  @override
  _PageManipulasiJadwalState createState() => _PageManipulasiJadwalState();
}

class _PageManipulasiJadwalState extends State<PageManipulasiJadwal> {
  final tanggalText = TextEditingController();
  final keteranga = TextEditingController();
  DateTime tanggal = DateTime.now();
  @override
  void initState() {
    super.initState();
    tanggalText.text = widget.jadwal.timestampText;
    keteranga.text = widget.jadwal.keterangan;
  }

  @override
  void dispose() {
    tanggalText.dispose();
    keteranga.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('jadwal')
                    .doc(widget.jadwal.id)
                    .set({
                  "id": widget.jadwal.id,
                  "idSkripsi": widget.jadwal.idSkripsi,
                  "timestamp": tanggal.millisecondsSinceEpoch,
                  "mahasiswa": widget.jadwal.mahasiswa,
                  "pembimbing": widget.jadwal.pembimbing,
                  "query": widget.jadwal.query,
                  "keterangan": keteranga.text,
                });
                Get.snackbar("Informasi", "Jadwal telah disimpan");
              } catch (e) {
                Get.snackbar("Gagal", e.toString());
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tanggalText,
                  enabled: false,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(90.0)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      hintText: 'Tanggal'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.date_range),
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime(2025, 6, 7), onConfirm: (date) {
                    setState(() => tanggal = date);
                    tanggalText.text =
                        DateFormat('dd-MM-yyyy HH:mm').format(date);
                  }, currentTime: DateTime.now(), locale: LocaleType.id);
                },
              )
            ],
          ),
          TextField(
            controller: keteranga,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.create),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(90.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                hintText: 'Keterangan'),
          )
        ],
      ),
    );
  }
}
