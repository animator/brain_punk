import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

void main() async {
  // Create an instance of the game
  final goldRush = TextExample();

  // Setup Flutter widgets and start the game in full screen portrait orientation
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();

  // Every is a widget in Flutter! So run the app passing the games widget here
  runApp(GameWidget(game: goldRush));
}

class TextExample extends FlameGame with HasTappables {
  late Map jsonData;
  late dynamic dataArray;
  DialogButton dialogButton = DialogButton();
  final Vector2 buttonSize = Vector2(50.0, 50.0);

  @override
  Future<void> onLoad() async {
    jsonData = await assets.readJson('data/story.json');
    dataArray = jsonData["data"];
    print(dataArray[0]["q"]);
    addAll([
      MyTextBox(
        dataArray[0]["q"],
      )
        ..anchor = Anchor.topRight
        ..x = size.x - 32.0,
    ]);
  }
}

final _regularTextStyle = TextStyle(
  fontSize: 18,
  color: BasicPalette.white.color,
);
final _regular = TextPaint(style: _regularTextStyle);
final _box = _regular.copyWith(
  (style) => style.copyWith(
    //color: Colors.lightGreenAccent,
    fontFamily: 'monospace',
    letterSpacing: 2.0,
  ),
);
/*
final _tiny = TextPaint(style: _regularTextStyle.copyWith(fontSize: 14.0));
final _shaded = TextPaint(
  style: TextStyle(
    color: BasicPalette.white.color,
    fontSize: 40.0,
    shadows: const [
      Shadow(color: Colors.red, offset: Offset(2, 2), blurRadius: 2),
      Shadow(color: Colors.yellow, offset: Offset(4, 4), blurRadius: 4),
    ],
  ),
);
*/

class MyTextBox extends TextBoxComponent {
  MyTextBox(
    String text, {
    super.align,
    super.size,
    double? timePerChar,
    double? margins,
  }) : super(
          text: text,
          textRenderer: _box,
          boxConfig: TextBoxConfig(
            maxWidth: 400,
            timePerChar: timePerChar ?? 0.05,
            growingBox: false,
            margins: EdgeInsets.all(margins ?? 25),
          ),
        );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, Paint()..color = Colors.white10);
    super.render(canvas);
  }
}

class DialogButton extends SpriteComponent with Tappable {
  int scene2Level = 0;
  @override
  bool onTapDown(dynamic event) {
    try {
      print('we will move to the next screen');
      scene2Level++;
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}
