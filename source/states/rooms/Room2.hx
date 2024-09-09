package states.rooms;

class Room2 extends BaseRoom
{
    var wallTopLeft:FlxSprite;
    var wallTopLeft2:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomLeft2:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    var exit1:Exit;
    var exit2:Exit;
    public var exit3:Exit;
    var exit4:Exit;

    var unlockedExit:Bool = false;

    override public function create():Void
    {
        super.create();

        createFloor();

        var trash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/trash'));
        trash.setPosition(250, 510);
        add(trash);

        wallTopLeft = createWall(290, 80);
        wallTopLeft2 = createWall(100, 200);
        wallTopRight = createWall(290, 80, FlxG.width - 290);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomLeft2 = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        exit1 = new Exit('Room1', wallTopLeft.width, 0, Std.int(FlxG.width - (wallTopLeft.width + wallTopRight.width)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        exit2 = new Exit('Room4', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width + wallBottomRight.width)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit2);
        exit2.locked = tutorialMode;
        exits.push(exit2);

        exit3 = new Exit('Room3', 0, wallTopLeft2.height, 1, Std.int(FlxG.height - (wallTopLeft2.height + wallBottomLeft2.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit3);
        exit3.locked = tutorialMode;
        exits.push(exit3);

        exit4 = new Exit('Room6', FlxG.width - 2, wallBottomRight2.height, 1, Std.int(FlxG.height - (wallTopRight2.height + wallBottomRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit4);
        exit4.locked = tutorialMode;
        exits.push(exit4);
    }

    override function onLoad():Void
    {
        super.onLoad();

        phone.playMessage('tutorialPart5');

        if (!unlockedExit && !tutorialMode)
        {
            unlockedExit = true;
            forEachOfType(Exit, function(exit:Exit) {
                exit.locked = false;
            });
        }
    }
}