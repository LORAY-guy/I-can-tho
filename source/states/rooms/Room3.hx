package states.rooms;

class Room3 extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopLeft:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomLeft2:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    var exit1:Exit;
    var exit2:Exit;
    var exit3:Exit;

    public var seenAnimatronicsOnStage:Bool = false;

    override function create():Void
    {
        super.create();

        createFloor();
        
        var trash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/trash'));
        trash.setPosition(100, 170);
        trash.flipX = true;
        add(trash);

        wallTop = createWall(FlxG.width, 80);
        wallTopLeft = createWall(100, 200);
        wallTopRight = createWall(100, 200, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomLeft2 = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var stage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/stage'));
        stage.setPosition(0, wallTop.height + 75);
        stage.screenCenter(X);
        add(stage);

        exit1 = new Exit('Room5', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width + wallBottomRight.width)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit1);
        exit1.locked = tutorialMode;
        exits.push(exit1);

        exit2 = new Exit('RoomFoxyCurtain', 0, wallBottomLeft2.height, 1, Std.int(FlxG.height - (wallBottomLeft2.height + wallBottomRight2.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit2);
        exit2.locked = tutorialMode;
        exits.push(exit2);

        exit3 = new Exit('Room2', FlxG.width - 2, wallBottomRight2.height, 1, Std.int(FlxG.height - (wallBottomLeft2.height + wallBottomRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit3);
        exit3.locked = tutorialMode;
        exits.push(exit3);
    }

    override function onLoad():Void
    {
        super.onLoad();

        if (!seenAnimatronicsOnStage)
        {
            var flickeringSound:FlxSound = new FlxSound();
            flickeringSound.loadEmbedded(Paths.sound('flickeringMono'), false);
            flickeringSound.volume = 0.7;

            new FlxTimer().start(2, function(tmr:FlxTimer) {
                flickeringSound.play();
                ourple.lockedControls = true;
                FlxFlicker.flicker(PlayState.instance.flicker, 1, 0.25, true, false, function(flick:FlxFlicker) {
                    CoolUtil.tutorialMode = false;
                    PlayState.instance.enableAnimatronics();
                    new FlxTimer().start(1, function(tmr:FlxTimer) {
                        unlockTutorialExits();
                        FlxTween.tween(PlayState.instance.flicker, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
                            PlayState.instance.flicker.destroy();
                            flickeringSound.destroy();
                            ourple.lockedControls = false;
                        }});
                    });
                }, function(flick:FlxFlicker) {
                    if (!PlayState.instance.flicker.visible) flickeringSound.volume = 0;
                    else flickeringSound.volume = 0.7;
                });
            });
            seenAnimatronicsOnStage = true;
        }
    }

    public function unlockTutorialExits():Void
    {
        forEachOfType(Exit, function(exit:Exit) {
            exit.locked = false;
        });
    }
}