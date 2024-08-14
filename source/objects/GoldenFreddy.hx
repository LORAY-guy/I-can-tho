package objects;

class GoldenFreddy extends FlxSprite
{
    var aahSound:FlxSound = new FlxSound();
    var timeSeenGolden:Float = 0.0;

    public function new():Void
    {
        super();
        loadGraphic(Paths.image('characters/golden'));
        scale.set(0.8, 0.8);
        updateHitbox();
        screenCenter(XY);

        aahSound.loadEmbedded(Paths.sound('goldenAaaah'));
        aahSound.volume = 0.2;
        aahSound.play();
        aahSound.fadeIn(2, 0.2, 0.9, function(twn:FlxTween) {
            PlayState.instance.gameOver(true);
            destroy();
        });
    }

    override function update(elapsed:Float):Void
    {
        PlayState.instance.ambienceManager.musicPlayer.volume = 1 - aahSound.volume;
        timeSeenGolden += elapsed;
        if (timeSeenGolden >= 1.5 && timeSeenGolden <= 1.51) {
            loadGraphic(Paths.image('characters/goldenMad'));
        }

        super.update(elapsed);
    }

    override function destroy():Void
    {
        if (!aahSound.fadeTween.finished) {
            aahSound.fadeTween.cancel();
        }
        aahSound.destroy();

        if (!PlayState.instance.ourple.dead && PlayState.instance.ambienceManager.musicPlayer != null) {
            PlayState.instance.ambienceManager.resetMusicVolume();
        }

        PlayState.instance.currentRoom.goldenFreddy = null;

        super.destroy();
    }
}