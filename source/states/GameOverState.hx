package states;

/**
 * ### Game Over
 * Get gud, kid.
 *
 * Basically trying to replicate the FNAF 3 game over screen.
 */
class GameOverState extends FlxUIState
{
    var gameOver:FlxSprite;
    var gameOverCoolOverlay:FlxSprite;
    var bufferOverlay:FlxSprite;

    var sound:FlxSound;
    var timer:FlxTimer = new FlxTimer();

    var goldenDeath:Bool = false;

    public function new(goldenDeath:Bool = false):Void
    {
        super();
        this.goldenDeath = goldenDeath;
    }

    override function create():Void
    {
        super.create();

        var jumpscareSound = 'XSCREAM' + (goldenDeath ? 'GOLDEN' : '');
        FlxG.sound.play(Paths.sound(jumpscareSound), 0.7, false, FlxG.sound.defaultSoundGroup, true, function() {
            gameOver = new FlxSprite().loadGraphic(Paths.image('gameOver/gameOver'));
            add(gameOver);
            
            gameOverCoolOverlay = new FlxSprite();
            gameOverCoolOverlay.frames = Paths.getSparrowAtlas('gameOver/gameOverCoolOverlay');
            gameOverCoolOverlay.animation.addByIndices('Idle', 'Idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 0], "", 20, false);
            gameOverCoolOverlay.setGraphicSize(FlxG.width);
            gameOverCoolOverlay.updateHitbox();
            gameOverCoolOverlay.screenCenter();
            gameOverCoolOverlay.y -= 10;
            gameOverCoolOverlay.alpha = 0.8;
            gameOverCoolOverlay.blend = ADD;
            add(gameOverCoolOverlay);
    
            gameOverCoolOverlay.animation.finishCallback = function(name:String) {
                gameOverCoolOverlay.destroy();
                gameOverCoolOverlay = null;
            };
    
            bufferOverlay = new FlxSprite();
            bufferOverlay.frames = Paths.getSparrowAtlas('bufferOverlay');
            bufferOverlay.animation.addByPrefix('Idle', 'Idle', 30);
            bufferOverlay.animation.play('Idle');
            bufferOverlay.setGraphicSize(FlxG.width, FlxG.height);
            bufferOverlay.updateHitbox();
            bufferOverlay.screenCenter();
            add(bufferOverlay);
    
            FlxG.camera.flash(FlxColor.WHITE, 0.8);
            sound = new FlxSound().loadEmbedded(Paths.sound('stare')).play();
    
            timer.start(5, function(tmr:FlxTimer) {
                bufferOverlay.alpha = 0.05;
                gameOverCoolOverlay.animation.play('Idle');
    
                timer.start(5, function(tmr:FlxTimer) {
                    voidBeforeRestart();
                });
            });
        }).endTime = FlxG.random.float(2000, 3000);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (gameOverCoolOverlay == null && PlayState.instance.controls.ACCEPT) {
            timer.cancel();
            voidBeforeRestart();
        }
    }

    private function voidBeforeRestart():Void //To avoid making the transition unexpected and brutally thrown at the player's face
    {
        FlxG.camera.visible = false;
        sound.stop();
        sound.destroy();
        new FlxTimer().start(1, function(tmr:FlxTimer) {
            FlxG.switchState(new PlayState());
        });
    }
}