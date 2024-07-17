import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'multi_image_picker/image_selector.dart';
import 'multi_image_picker/image_provider.dart';

class HomePage extends StatelessWidget {
  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final selectedImagesProvider = Provider.of<SelectedImagesProvider>(context, listen: false);
    selectedImagesProvider.clear();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageSelectorPage()),
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected images: ${result.join(', ')}")));
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final selectedImagesProvider = Provider.of<SelectedImagesProvider>(context, listen: false);
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      selectedImagesProvider.addImage(file);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Picked image from camera: ${file.path}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _pickImageFromCamera(context),
              child: Text('Pick image from camera'),
            ),
            ElevatedButton(
              onPressed: () => _navigateAndDisplaySelection(context),
              child: Text('Pick image from album'),
            ),
          ],
        ),
      ),
    );
  }
}
