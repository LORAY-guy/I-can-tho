package states;

class StaticState extends FlxUIState
{
    public static var loaded:Bool = false;

    override public function create():Void
    {
        Paths.clearStoredMemory();

        super.create();

        var spr:FlxSprite = new FlxSprite();
        spr.frames = Paths.getSparrowAtlas('static');
        spr.animation.addByPrefix('Idle', 'Idle', 2);
        spr.animation.randomFrame();
        spr.animation.play('Idle');
        spr.setGraphicSize(FlxG.width, FlxG.height);
        spr.updateHitbox();
        spr.screenCenter();
        add(spr);

        FlxG.sound.play(Paths.sound('glitch'), 1, false, FlxG.sound.defaultSoundGroup, true, function() {
            if (!loaded) {
                var loadingTxt:FlxText = new FlxText(0, 0, 0, 'Loading...', 16);
                loadingTxt.setFormat(Paths.font("fnaf3.ttf"), 16);
                loadingTxt.screenCenter();
                add(loadingTxt);

                loadAssets();
                #if html5 loaded = true; #end
            } else
                FlxG.switchState(new PlayState());
        });
    }

    private function loadAssets():Void
    {
        UserPrefs.loadPrefs();

        if(FlxG.save.data != null && FlxG.save.data.fullscreen) {
            FlxG.fullscreen = FlxG.save.data.fullscreen;
        }

        #if !html5
        if (UserPrefs.data.cacheOnGPU && !loaded) {
            Paths.cacheAllAssets();
            loaded = true;
        }
        #end

        #if !mobile
        Main.fpsVar.visible = UserPrefs.data.showFPS;
        #end

        FlxG.switchState(new PlayState());
    }
}