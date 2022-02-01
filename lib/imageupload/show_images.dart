import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ShowUpload extends StatefulWidget {
  String? userId;
  ShowUpload({Key? key, this.userId}) : super(key: key);

  @override
  _ShowUploadState createState() => _ShowUploadState();
}

class _ShowUploadState extends State<ShowUpload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your images"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("images")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text("no Image Uploded"),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    String url = snapshot.data!.docs[index]['DowloadUrl'];
                    return Image.network(
                      url,
                      height: 300,
                      fit: BoxFit.contain,
                    );
                  });
            }
          }),
    );
  }
}
