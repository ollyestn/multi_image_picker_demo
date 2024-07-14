import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'image_provider.dart';
import 'image_selector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedImagesProvider()),
      ],
      child: MaterialApp(
        title: 'Multi Image Picker Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ImageSelectorPage(),
      ),
    );
  }
}
