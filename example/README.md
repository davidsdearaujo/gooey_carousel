## pubspec.yaml
```yaml
name: example
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.1.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  gooey_carousel: ## It is recommended that you put the latest version
  cupertino_icons: ^0.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

## main.dart
```dart
import 'package:flutter/material.dart';
import 'package:gooey_carousel/gooey_carrousel.dart';

import 'demo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gooey Carousel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: GooeyEdgeDemo(),
      home: Material(
        child: GooeyCarousel(
          children: <Widget>[
            Container(color: Colors.red),
            Container(color: Colors.blue),
            Container(color: Colors.green),
          ],
        ),
      ),
    );
  }
}
```



