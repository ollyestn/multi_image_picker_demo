import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'image_provider.dart';

class ImageSelectorPage extends StatefulWidget {
  @override
  _ImageSelectorPageState createState() => _ImageSelectorPageState();
}

class _ImageSelectorPageState extends State<ImageSelectorPage> {
  List<AssetEntity> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      List<AssetEntity> images = await albums[0].getAssetListRange(
        start: 0,
        end: 100,
      );
      setState(() {
        _images = images;
      });
    } else {
      // no permissions
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      Provider.of<SelectedImagesProvider>(context, listen: false).addImage(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Image Picker'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: _pickImageFromCamera,
            child: Text("Pick image from camera"),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return ImageGridItem(
                  asset: _images[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGridItem extends StatelessWidget {
  final AssetEntity asset;

  ImageGridItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: asset.file,
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          final file = snapshot.data!;
          return GestureDetector(
            onTap: () {
              final selectedImagesProvider = Provider.of<SelectedImagesProvider>(context, listen: false);
              if (selectedImagesProvider.selectedImages.contains(file)) {
                selectedImagesProvider.removeImage(file);
              } else if (selectedImagesProvider.selectedImages.length < 9) {
                selectedImagesProvider.addImage(file);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("You can select up to 9 images only")),
                );
              }
            },
            child: Stack(
              children: [
                Image.file(file, fit: BoxFit.cover),
                Consumer<SelectedImagesProvider>(
                  builder: (context, selectedImagesProvider, child) {
                    bool isSelected = selectedImagesProvider.selectedImages.contains(file);
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.transparent,
                        child: isSelected
                            ? CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Text(
                            selectedImagesProvider.getImageIndex(file).toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                            : Container(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
        return Container(color: Colors.grey[200]);
      },
    );
  }
}
