import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';

void main() async {
  // Create an instance of the game
  final brainPunk = BrainPunk();

  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(GameWidget(game: brainPunk));
}

class BrainPunk extends FlameGame with HasTappables, KeyboardEvents {
  late Map jsonData;
  late dynamic dataArray;
  final double tc = 0.005;
  late SpriteComponent background;
  NextButton nextButton = NextButton();
  late MyTextBox prompt;
  late MyTextBox instruction;
  final Vector2 buttonSize = Vector2(125.0, 45.0);
  bool musicPlaying = false;
  int currentScene = 0;
  String input = "";
  bool hasInput = false;

  TextPaint answerTextPaint = TextPaint(style: _bigTextStyle);

  @override
  Future<void> onLoad() async {
    final screenWidth = size[0];
    final screenHeight = size[1];

    // initialize flame audio background music
    FlameAudio.bgm.initialize();

    Sprite bg = await loadSprite('story/$currentScene.png');
    background = SpriteComponent()
      ..sprite = bg
      ..size = Vector2(bg.srcSize.x, screenHeight);

    add(background);

    jsonData = await assets.readJson('data/story.json');
    dataArray = jsonData["data"];
    String text = dataArray[currentScene]["q"];
    prompt = MyTextBox(
      text,
      timePerChar: tc,
    )
      ..anchor = Anchor.topRight
      ..x = size.x - 32.0;
    add(prompt);

    instruction = MyTextBox(
      "Use Keyboard to Type",
      timePerChar: 0.0,
      renderer: _lil,
    );

    nextButton
      ..sprite = await loadSprite('buttons/next.png')
      ..size = buttonSize
      ..position = Vector2(
          screenWidth - buttonSize[0] - 20, screenHeight - buttonSize[1] - 20);
    Future.delayed(Duration(seconds: (tc * text.length).round()), () {
      add(nextButton);
    });
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
    if (!musicPlaying) {
      FlameAudio.bgm.play('music.ogg');
      musicPlaying = true;
    }
    if (nextButton.storyLevel != currentScene) {
      currentScene = nextButton.storyLevel;
      hasInput = (dataArray[currentScene]["a"] != null) ? true : false;
      //print("$currentScene : $hasInput");
      input = "";
      Sprite bg = await loadSprite('story/$currentScene.png');

      if (contains(nextButton)) remove(nextButton);
      if (contains(prompt)) remove(prompt);
      if (contains(instruction)) remove(instruction);

      background = SpriteComponent()
        ..sprite = bg
        ..size = Vector2(bg.srcSize.x, size[1]);
      if (contains(background)) remove(background);
      add(background);

      String text = dataArray[currentScene]["q"];
      prompt = MyTextBox(
        text,
        timePerChar: tc,
      )
        ..anchor = Anchor.topRight
        ..x = size.x - 32.0;
      add(prompt);

      if (!hasInput && dataArray[currentScene]["id"] != null) {
        Future.delayed(Duration(seconds: (tc * text.length).round()), () {
          add(nextButton);
        });
      } else if (hasInput) {
        instruction = MyTextBox(
          "Use Keyboard to Type",
          timePerChar: 0.0,
          renderer: _lil,
        )
          ..x = prompt.x - prompt.width
          ..y = 10 + prompt.height;
        Future.delayed(Duration(seconds: (tc * text.length).round()), () {
          add(instruction);
        });
      }
    }

    if (hasInput) {
      if (input != "") {
        answerTextPaint.render(canvas, input,
            Vector2(prompt.x - prompt.width + 25, 100 + prompt.height));
      }
      if (dataArray[currentScene]["a"] == input) {
        if (!contains(nextButton)) add(nextButton);
      } else {
        if (contains(nextButton)) remove(nextButton);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.digit0) {
      input += isKeyDown ? "0" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
      input += isKeyDown ? "1" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
      input += isKeyDown ? "2" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
      input += isKeyDown ? "3" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
      input += isKeyDown ? "4" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
      input += isKeyDown ? "5" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
      input += isKeyDown ? "6" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
      input += isKeyDown ? "7" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
      input += isKeyDown ? "8" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
      input += isKeyDown ? "9" : "";
    } else if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      input = (isKeyDown && input != "")
          ? input.substring(0, input.length - 1)
          : input;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}

class NextButton extends SpriteComponent with Tappable {
  int storyLevel = 0;
  @override
  bool onTapDown(dynamic info) {
    try {
      storyLevel++;
      return true;
    } catch (error) {
      return false;
    }
  }
}

final _regularTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 18,
  letterSpacing: 2.0,
  color: BasicPalette.white.color,
);
final _bigTextStyle = _regularTextStyle.copyWith(fontSize: 36);
final _lilTextStyle = _regularTextStyle.copyWith(fontSize: 14);
final _regular = TextPaint(style: _regularTextStyle);
final _lil = TextPaint(style: _lilTextStyle);

class MyTextBox extends TextBoxComponent {
  MyTextBox(String text,
      {super.align,
      super.size,
      double? timePerChar,
      double? margins,
      TextRenderer? renderer})
      : super(
          text: text,
          textRenderer: renderer ?? _regular,
          boxConfig: TextBoxConfig(
            maxWidth: 300,
            timePerChar: timePerChar ?? 0.05,
            growingBox: false,
            margins: EdgeInsets.all(margins ?? 25),
          ),
        );

  @override
  void render(Canvas c) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = Colors.black);
    super.render(c);
  }
}
