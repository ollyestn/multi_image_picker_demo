import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'image_provider.dart';
import 'image_preview.dart';

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

  void _completeSelection() {
    final selectedImagesProvider = Provider.of<SelectedImagesProvider>(context, listen: false);
    final selectedImages = selectedImagesProvider.selectedImages;
    Navigator.pop(context, selectedImages.map((file) => file.path).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Image Picker'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    // Add preview functionality
                  },
                  child: Text("预览"),
                ),
                TextButton(
                  onPressed: () {
                    // Add video creation functionality
                  },
                  child: Text("制作视频"),
                ),
                TextButton(
                  onPressed: _completeSelection,
                  child: Text("完成"),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImageFromCamera,
        child: Icon(Icons.camera_alt),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewPage(imageFile: file),
                ),
              );
            },
            child: Stack(
              children: [
                Image.file(file, fit: BoxFit.cover),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
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
                    child: Consumer<SelectedImagesProvider>(
                      builder: (context, selectedImagesProvider, child) {
                        bool isSelected = selectedImagesProvider.selectedImages.contains(file);
                        int index = selectedImagesProvider.getImageIndex(file);
                        return CircleAvatar(
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
                        );
                      },
                    ),
                  ),
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
