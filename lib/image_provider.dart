import 'package:flutter/material.dart';
import 'dart:io';

class SelectedImagesProvider with ChangeNotifier {
  List<File> _selectedImages = [];

  List<File> get selectedImages => _selectedImages;

  void addImage(File image) {
    if (_selectedImages.length < 9) {
      _selectedImages.add(image);
      notifyListeners();
    } else {
      // Handle the case where more than 9 images are selected
      print("Cannot select more than 9 images");
    }
  }

  void removeImage(File image) {
    _selectedImages.remove(image);
    notifyListeners();
  }

  int getImageIndex(File image) {
    return _selectedImages.indexOf(image) + 1;
  }
}
