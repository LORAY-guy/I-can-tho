package states;

/**
 * ### StaticState
 * The "cutscene" state.
 * Just plays the static effect.
 *
 * This is the first loaded state when the game is launched.
 */
class StaticState extends FlxUIState
{
    public static var loaded:Bool = false;

    override public function create():Void
    {
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
            if (!loaded) loadAssets();
            else FlxG.switchState(new PlayState());
        });
    }

    private function loadAssets():Void
    {
        UserPrefs.loadPrefs();

        if(FlxG.save.data != null && FlxG.save.data.fullscreen) {
            FlxG.fullscreen = FlxG.save.data.fullscreen;
        }

        /**if (UserPrefs.data.preCache && !loaded) {
            Paths.cacheAllAssets();
            loaded = true;
        }**/

        #if !mobile
        Main.fpsVar.visible = UserPrefs.data.showFPS;
        #end

        FlxG.switchState(new PlayState());
    }
}