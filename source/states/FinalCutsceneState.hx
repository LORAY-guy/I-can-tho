package states;

/**
 * ### Final Cutscene State
 *
 * State for the final cutscene video.
 */
class FinalCutsceneState extends FlxUIState
{
    private var camVideo:FlxCamera;
    private var video:VideoHandler;

    private var musicPlayer:FlxSound = new FlxSound();
    private var creditsText:FlxText;

    private var speedrunTimer:String;

    public function new(time:Float):Void
    {
        super();
        this.speedrunTimer = CoolUtil.elapsedToDisplay(time);
    }

    override function create():Void
    {
        FlxG.mouse.visible = false;
        FlxG.camera.visible = true;

        camVideo = new FlxCamera();
        camVideo.bgColor.alpha = 0;
        FlxG.cameras.add(camVideo, false);

        video = new VideoHandler();
        video.cameras = [camVideo];
		add(video);

        creditsText = new FlxText(0, 0, FlxG.width, "Minigame made by: LORAY", 52);
        creditsText.setFormat(Paths.font('fnaf3.ttf'), 52, FlxColor.WHITE, CENTER);
        creditsText.screenCenter();
        creditsText.visible = false;
        add(creditsText);

        musicPlayer.loadEmbedded(Paths.music('finale'));
        musicPlayer.play();

        playVideo('finale');
    }

    private function playVideo(path:String):Void
    {
		#if (hxCodec >= "3.0.0")
		video.play(Paths.video(path));
		video.bitmap.onEndReached.add(function() {
			video.destroy();
            startCredits();
            return;
		}, true);
		#else
		trace('Platform not supported!');
		return;
		#end
    }

    private var curBeat:Int = 0;
    private function startCredits():Void
    {
        var bpm:Int = 165;
        var crochet:Float = (60 / bpm) * 1000;
        var interval:Float = 4 * crochet;
    
        camVideo.visible = false;
    
        musicPlayer.stop();
        musicPlayer.loadEmbedded(Paths.music('end'));
        musicPlayer.volume = 0.6;
        musicPlayer.onComplete = function() {
            CoolUtil.exitGame();
        };
        musicPlayer.play();

        //If ever i actually make another update to the mode, I also want to add an endless mode to this game too.
        if (!UserPrefs.data.unlockedEndless) UserPrefs.data.unlockedEndless = true;
    
        var totalTime:Float = musicPlayer.length;
        new FlxTimer().start(0.75, function(tmr:FlxTimer) { //Song start delay
            creditsText.visible = true;
            new FlxTimer().start(interval / 1000, function(tmr:FlxTimer) {
                curBeat++;
                onCreditsUpdate();
            }, Std.int(totalTime / interval));
        });
    }

    private function onCreditsUpdate():Void
    {
        switch (curBeat) {
            case 1:
                creditsText.text = 'Made in 2 months for\nthe FNF mod Lore Origins';
                creditsText.screenCenter();

            case 2:
                creditsText.text = 'Thank you Serby for making\nthe ending cutscene';
                creditsText.screenCenter();

            case 3:
                creditsText.text = 'Ourple Guy belongs to\nheaddzo and LEX3X';
                creditsText.screenCenter();

            case 4:
                creditsText.text = 'Matpat belongs to...\nmatpat';
                creditsText.screenCenter();

            case 5:
                creditsText.text = 'Most of the assets used\ncome from various\nFive Nights at Freddy\'s games';
                creditsText.screenCenter();

            case 7:
                creditsText.text = 'Sorry for the terrible\nvoice acting...';
                creditsText.screenCenter();

            case 8:
                creditsText.text = '...And for the delay of the release';
                creditsText.screenCenter();

            case 9:
                creditsText.text = 'I am a one man crew';
                creditsText.screenCenter();

            case 10:
                creditsText.text = 'Hope you enjoyed!';
                creditsText.screenCenter();

            case 11:
                creditsText.text = 'This is my first game';
                creditsText.screenCenter();

            case 12:
                creditsText.text = 'You finished the game in:\n$speedrunTimer...';
                creditsText.screenCenter();

            case 14:
                if (CoolUtil.deathCounter > 0) {
                    creditsText.text = 'And you died\n' + CoolUtil.deathCounter + ' times';
                    creditsText.screenCenter();
                }

            case 16:
                creditsText.text = 'Thanks for playing!';
                creditsText.screenCenter();

            case 18:
                FlxTween.tween(creditsText, {alpha: 0}, 8);
                musicPlayer.fadeOut(8, 0, function(twn:FlxTween) {
                    new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                        CoolUtil.exitGame();
                    }); 
                });
        }
    }
}