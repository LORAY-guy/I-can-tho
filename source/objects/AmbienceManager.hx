package objects;

class AmbienceManager
{
    public var soundPlayer:FlxSound = new FlxSound();
    public var musicPlayer:FlxSound = new FlxSound();

    private var fadeTween:FlxTween;

    public var playingMusic:Bool = false;
    public var playingCrumblingDreams:Bool = false;

    private static var DEFAULT_VOLUME:Float = 0.5;
    public var factor:Float = 1;

    public function new():Void
    {
        musicPlayer.volume = 0;
        FlxG.sound.defaultMusicGroup.add(musicPlayer);

        soundPlayer.volume = DEFAULT_VOLUME;
        FlxG.sound.defaultSoundGroup.add(soundPlayer);

        new FlxTimer().start(5, function(tmr:FlxTimer) {
            if (soundPlayer != null && !soundPlayer.playing && FlxG.random.bool(15)) {
                playAmbienceSound();
            }
        }, 0);
    }

    public function playMusic(?name:String):Void
    {
        var selectedMusic:String;
        if (name != null) {
            selectedMusic = name;
        } else {
            var musicFolder:Array<String> = FileSystem.readDirectory('assets/music/game');
            musicFolder.remove('void.${Paths.SOUND_EXT}');
            selectedMusic = musicFolder[FlxG.random.int(0, musicFolder.length - 1)];
            selectedMusic = selectedMusic.split('.' + Paths.SOUND_EXT)[0];
        }
        musicPlayer.loadEmbedded(Paths.music('game/$selectedMusic'));
        musicPlayer.play();
        playingMusic = true;
        #if FLX_PITCH
        if (PlayState.instance.ourple.caseOhMode) musicPlayer.pitch = 0.75;
        #end
        musicPlayer.fadeIn(2, 0, (DEFAULT_VOLUME * UserPrefs.data.musicVolume) * factor);

        var fadeStart:Float = (musicPlayer.length / 1000) - 5;
        if (fadeStart > 0) {
            fadeTween = FlxTween.tween(musicPlayer, {volume: 0}, 5, {startDelay: fadeStart});
        }

        musicPlayer.onComplete = function()
        {
            if (playingMusic)
            {
                new FlxTimer().start(FlxG.random.float(10, 20), function(tmr:FlxTimer) {
                    if (playingMusic) { //rechecking just in case it changed mid way through the timer
                        playMusic();
                    }
                });
            }
        };
    }

    public function playCrumblingDreams():Void
    {
        if (musicPlayer.playing) 
        {
            playingMusic = false;
            fadeTween.cancel();
            musicPlayer.stop();
        }

        musicPlayer.loadEmbedded(Paths.music('crumblingDreams'), true);
        musicPlayer.pan = 0.75;
        musicPlayer.volume = 0.4;
        #if FLX_PITCH musicPlayer.pitch = 1; #end
        musicPlayer.onComplete = null;
        musicPlayer.play();
        musicPlayer.looped = true;
        playingCrumblingDreams = true;
    }

    public function updateCrumblingDreams(pan:Float, volume:Float):Void
    {
        musicPlayer.pan = pan;
        musicPlayer.volume = volume;
    }

    public function playAmbienceSound():Void
    {
        var ambienceFolder:Array<String> = FileSystem.readDirectory('assets/sounds/ambience');
        var selectedAmbience:String = ambienceFolder[FlxG.random.int(0, ambienceFolder.length - 1)];
        selectedAmbience = selectedAmbience.split('.' + Paths.SOUND_EXT)[0];
        soundPlayer.loadEmbedded(Paths.sound('ambience/$selectedAmbience'));
        soundPlayer.play();
    }

    public function pause(?all:Bool = false):Void
    {
        if (musicPlayer != null && musicPlayer.playing) {
            musicPlayer.pause();
        }

        if (all)
        {
            if (soundPlayer != null && soundPlayer.playing) {
                soundPlayer.pause();
            }
        }
    }

    public function resume(?all:Bool = false):Void
    {
        if (musicPlayer != null && !musicPlayer.playing) {
            musicPlayer.resume();
        }

        if (all)
        {
            if (soundPlayer != null && !soundPlayer.playing) {
                soundPlayer.resume();
            }
        }
    }

    public function stopMusic(?time:Float = 0):Void
    {
        if (musicPlayer != null && musicPlayer.playing) {
            if (time > 0) {
                musicPlayer.fadeOut(time, 0, function(twn:FlxTween) {
                    musicPlayer.onComplete = null;
                    musicPlayer.stop();
                    playingMusic = false;
                    fadeTween.cancel();
                });
            } else {
                musicPlayer.onComplete = null;
                musicPlayer.stop();
                playingMusic = false;
                fadeTween.cancel();
            }
        }
    }

    public function adjustMusicVolume(newFactor:Float, ?time:Float = 1):Void
    {
        if (musicPlayer != null && musicPlayer.playing) {
            factor = newFactor;
            musicPlayer.fadeOut(time, (DEFAULT_VOLUME * UserPrefs.data.musicVolume) * factor);
        }
    }

    public function resetMusicVolume(?time:Float = 1):Void
    {
        if (musicPlayer != null && musicPlayer.playing) {
            musicPlayer.fadeIn(time, musicPlayer.volume, (DEFAULT_VOLUME * UserPrefs.data.musicVolume) * factor);
            factor = 1;
        }
    }

    public function resetSoundVolume(?time:Float = 1):Void
    {
        if (soundPlayer != null) {
            soundPlayer.fadeOut(time, DEFAULT_VOLUME);
        }
    }

    public function destroy():Void
    {
        if (musicPlayer.playing) musicPlayer.stop();
        musicPlayer.destroy();
        musicPlayer = null;

        if (soundPlayer.playing) soundPlayer.stop();
        soundPlayer.destroy();
        soundPlayer = null;
    }
}