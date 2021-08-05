import 'package:flame/components.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  final mySquareGame = MySquareGame();
  final myVampireGame = MyVampireGame();

  runApp(
    Column(
      children: [
        Expanded(
          child: Container(
            height: 200,
            child: GameWidget(
              game: myVampireGame,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 200,
            child: GameWidget(
              game: mySquareGame,
            ),
          ),
        ),
      ],
    ),
  );
}

class MyVampireGame extends Game with TapDetector {
  late SpriteAnimation runningRobot;
  static const int robotSpeed = 250;
  late Vector2 robotPosition;
  final robotSize = Vector2(48, 60);
  int robotDirection = 1;

  late Sprite pressedButton;
  late Sprite unpressedButton;
  late Vector2 buttonPosition;
  final buttonSize = Vector2(120, 30);
  bool isPressed = false;
  bool clickedInRobot = false;

  late TextPainter textPainter;
  List baloonText = [
    "Ouch... I Will tell \nJorge Silva about this",
    "I warned you...",
    "Next time i will punch\n you",
    "THAT'S IT!!",
    "BYE"
  ];
  int robotTouchesCounter = 0;

  @override
  Future<void> onLoad() async {
    robotPosition = Vector2(0, size.y - 60);
    buttonPosition = Vector2(size.x / 2, size.y / 2);
    runningRobot = await loadSpriteAnimation(
        'robot.png',
        SpriteAnimationData.sequenced(
            amount: 8, stepTime: 0.09, textureSize: Vector2(16, 18)));

    unpressedButton = await loadSprite(
      'buttons.png',
      srcPosition: Vector2.zero(),
      srcSize: Vector2(60, 20),
    );

    pressedButton = await loadSprite(
      'buttons.png',
      srcPosition: Vector2(0, 20),
      srcSize: Vector2(60, 20),
    );

    textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: baloonText[0].toString(),
      style: TextStyle(
        color: Colors.black,
        fontSize: 10.0,
      ),
    );
  }

  @override
  void update(double dt) {
    if (isPressed) {
      runningRobot.update(dt);
      robotPosition = Vector2(
          (robotSpeed * robotDirection * dt) + robotPosition.x, size.y - 60);
      if (robotDirection == 1 && robotPosition.x > size.x) {
        robotPosition = Vector2(-60, size.y - 60);
      } else if (robotDirection == -1 && robotPosition.x <= 0) {
        robotDirection = 1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (robotTouchesCounter < 4)
      runningRobot
          .getSprite()
          .render(canvas, position: robotPosition, size: robotSize);

    final button = isPressed ? pressedButton : unpressedButton;
    button.render(canvas, position: buttonPosition, size: buttonSize);

    final squarePaint = BasicPalette.white.paint();

    Rect squarePos =
        Rect.fromLTWH(robotPosition.x + 50, robotPosition.y - 25, 100, 25);

    Offset textPosition = Offset(robotPosition.x + 50, robotPosition.y - 25);

    if (clickedInRobot && robotTouchesCounter < 4) {
      textPainter.text = TextSpan(
        text: baloonText[robotTouchesCounter].toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 10.0,
        ),
      );

      textPainter.layout();
      canvas.drawRect(squarePos, squarePaint);
      textPainter.paint(canvas, textPosition);
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF222222);

  @override
  void onTapDown(TapDownInfo info) {
    // Transforming ours position and size
    // vectors into a dart:ui Rect by using the `&` operator, and
    // with that rect we can use its `contains` method which checks
    // if a point (Offset) is inside that rect
    final buttonArea = buttonPosition & buttonSize;
    isPressed = buttonArea.contains(info.eventPosition.game.toOffset());

    final robotArea = robotPosition & robotSize;
    if (robotArea.contains(info.eventPosition.game.toOffset())) {
      if (clickedInRobot) robotTouchesCounter++;
      clickedInRobot = !clickedInRobot;
    }
  }

  @override
  void onTapUp(TapUpInfo event) {
    isPressed = false;
  }

  @override
  void onTapCancel() {
    isPressed = false;
  }
}

class MySquareGame extends Game {
  static const int squareSpeed = 250;
  static final squarePaint = BasicPalette.white.paint();
  late Rect squarePos;
  int squareDirection = 1;
  int squareYDirection = 0;
  late TextSpan span;
  late TextPainter tp;
  late Offset textOffset;
  String title = "Jorge's Game";

  @override
  Future<void> onLoad() async {
    squarePos = Rect.fromLTWH(0, 0, 100, 100);
    span = new TextSpan(
        style: new TextStyle(color: Colors.grey[600]), text: title);
    tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
  }

  @override
  void update(double dt) {
    squarePos = squarePos.translate(
        squareSpeed * squareDirection * dt, //x direction
        squareSpeed * squareYDirection * dt); //y direction
    textOffset = Offset((size.x / 2) - (title.length * 3), size.y / 2);

    print("squareDirection: " + squareDirection.toString());
    print("squarePos.right: " + squarePos.right.toString());
    print("squarePos.right: " + squarePos.right.toString());
    print("squarePos.left: " + squarePos.left.toString());
    print("squarePos.top: " + squarePos.top.toString());
    print("squarePos.bottom: " + squarePos.bottom.toString());
    print("size.x: " + size.x.toString());
    print("size.y: " + size.y.toString());

    if (squareDirection == 1 && squarePos.right > size.x) {
      squareYDirection = 1;
      squareDirection = 0;
    } else if (squareDirection == 0 &&
        squarePos.right > size.x &&
        squarePos.bottom > size.y) {
      squareYDirection = 0;
      squareDirection = -1;
    } else if (squareDirection == -1 &&
        squarePos.left < 0 &&
        squarePos.bottom > size.y) {
      squareYDirection = -1;
      squareDirection = 0;
    } else if (squareDirection == 0 &&
        squarePos.top < 0 &&
        squareYDirection == -1) {
      squareYDirection = 0;
      squareDirection = 1;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(squarePos, squarePaint);
    tp.paint(canvas, textOffset);
  }
}
