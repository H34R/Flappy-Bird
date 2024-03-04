import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird_game/components/background.dart';
import 'package:flappy_bird_game/components/bird.dart';
import 'package:flappy_bird_game/components/ground.dart';
import 'package:flappy_bird_game/components/pipe_group.dart';
import 'package:flappy_bird_game/game/configuration.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  FlappyBirdGame();

  late Bird bird;
  Timer interval = Timer(Config.pipeInterval, repeat: true);
  bool isHit = false;
  late TextComponent score;

  // เพิ่มตัวแปร score ที่จะใช้เก็บคะแนน
  int scoreValue = 0;
  int highScore = 0; // เพิ่มตัวแปรสำหรับเก็บคะแนนสูงสุด
  final storage = const FlutterSecureStorage();

  Future<void> loadHighScore() async {
    String? highScoreString = await storage.read(key: '_highScore');
    highScore = int.parse(highScoreString ?? "0");
  }

  Future<void> saveHighScore() async {
    await storage.write(key: '_highScore', value: highScore.toString());
  }  

  @override
  Future<void> onLoad() async {
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
    ]);

    interval.onTick = () {
      add(PipeGroup());
      // อัปเดตคะแนนทุกครั้งที่เพิ่มท่อ
      score.text = 'Score: $scoreValue';
    };
    await loadHighScore();
  }

  TextComponent buildScore() {
    return TextComponent(
        position: Vector2(size.x / 2, size.y / 2 * 0.2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
              fontSize: 40, fontFamily: 'Game', fontWeight: FontWeight.bold),
        ));
  }

  @override
  void onTap() {
    bird.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
    // แสดงคะแนนในทุก frame
    score.text = 'Score: $scoreValue';
  }

  void resetScore() {
    scoreValue = 0;
    highScore = 0;
  }

  void updateHighScore() {
    if (scoreValue > highScore) {
      highScore = scoreValue;
      saveHighScore();
    }
  }

  void setPlayerName(String playerName) {}
}
