import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'image_provider.dart';

class ImagePreviewPage extends StatefulWidget {
  final File imageFile;

  ImagePreviewPage({required this.imageFile});

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  bool _showAppBar = true;

  @override
  Widget build(BuildContext context) {
    final selectedImagesProvider = Provider.of<SelectedImagesProvider>(context);
    bool isSelected = selectedImagesProvider.selectedImages.contains(widget.imageFile);
    int index = selectedImagesProvider.getImageIndex(widget.imageFile);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showAppBar = !_showAppBar;
              });
            },
            child: Center(
              child: PhotoView(
                imageProvider: FileImage(widget.imageFile),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: _showAppBar ? 0 : -60,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: AppBar(
                title: Text(''),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        selectedImagesProvider.removeImage(widget.imageFile);
                      } else if (selectedImagesProvider.selectedImages.length < 9) {
                        selectedImagesProvider.addImage(widget.imageFile);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("You can select up to 9 images only")),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: isSelected ? Colors.blue : Colors.white,
                      child: isSelected
                          ? Text(
                        index.toString(),
                        style: TextStyle(color: Colors.white),
                      )
                          : Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
