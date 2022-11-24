import 'package:flame/components.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:space_fortress/screens/settings_menu.dart';

class AudioPlayerComponent extends Component {
  late AudioPool fire;
  late AudioPool killPlayer;
  late AudioPool bonus;
  late AudioPool killFortress;

  @override
  Future<void>? onLoad() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      "laser.ogg",
      "laserSmall.ogg",
      "success_bell-6776.mp3",
      "medium-explosion-40472.mp3",
      // "SpaceInvaders.wav",
    ]);

    fire = await AudioPool.create("audio/laserSmall.ogg", maxPlayers: 9999999);
    killPlayer = await AudioPool.create("audio/laser.ogg", maxPlayers: 9999999);
    bonus = await AudioPool.create("audio/success_bell-6776.mp3", maxPlayers: 9999999);
    killFortress = await AudioPool.create("audio/medium-explosion-40472.mp3", maxPlayers: 9999999);

    return super.onLoad();
  }

  // void playBgm(String fileName) {
  //   if (settings.backgroundMusic) {
  //     FlameAudio.bgm.play(fileName);
  //   }
  // }

  void playSfx(String fileName) {
    if (settings.soundEffects) {
      // FlameAudio.play(fileName);
      switch (fileName) {
        case "laserSmall.ogg":
          fire.start();
          break;
        case "laser.ogg":
          killPlayer.start();
          break;
        case "success_bell-6776.mp3":
          bonus.start();
          break;
        case "medium-explosion-40472.mp3":
          killFortress.start();
          break;
        default:
      }
    }
  }

  // void stopBgm() {
  //   FlameAudio.bgm.stop();
  // }
}
