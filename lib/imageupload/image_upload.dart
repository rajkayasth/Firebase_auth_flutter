import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUpload extends StatefulWidget {
  //we need to user id to create image upload folder for each user
  String? userId;
  ImageUpload({Key? key, this.userId}) : super(key: key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  //Some intilizing code

  File? _image;
  final imagePicker = ImagePicker();
  String? downloadedUrl;

  //image picker
  Future imagePickerMethod() async {
    //picking file
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pick != null) {
        _image = File(pick.path);
      } else {
        //Showing Function for displaying error
        showSnakeBar("no file Selected", Duration(milliseconds: 4000));
      }
    });
  }

  //creating a snakebar

  showSnakeBar(String snakeText, Duration d) {
    final snackBar = SnackBar(
      content: Text(snakeText),
      duration: d,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //uploading the image ,then getting the download url and then
  //adding that downloaded url to our ColudFireStore

  Future uploadImage() async {
    final postID = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userId}/image")
        .child("post_$postID");
    await ref.putFile(_image!);
    downloadedUrl = await ref.getDownloadURL();
    //print(downloadedUrl);

    //uploading to cloud firestore
    await firebaseFirestore
        .collection("users")
        .doc(widget.userId)
        .collection("images")
        .add({"DowloadUrl": downloadedUrl}).whenComplete(() =>
            showSnakeBar("Image uploaded suceessFully", Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image upload"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          //for Rounded rectangular clip
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 550.0,
              width: double.infinity,
              child: Column(
                children: [
                  const Text("Upload Image"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: 300.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _image == null
                                  ? const Center(
                                      child: Text("NO image Selected"),
                                    )
                                  : Image.file(_image!),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                imagePickerMethod();
                              },
                              child: Text("Select Image"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_image != null) {
                                  uploadImage();
                                } else {
                                  showSnakeBar("Select image first",
                                      Duration(milliseconds: 400));
                                }
                              },
                              child: Text("Upload Image"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
