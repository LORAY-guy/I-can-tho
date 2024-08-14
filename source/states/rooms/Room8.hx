package states.rooms;

class Room8 extends BaseRoom
{
    var wallTopLeft:FlxSprite;
    var wallTopLeft2:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomLeft2:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    public var exit1:Exit;
    public var exit4:Exit;

    public var matpatDoor:FlxSprite;

    override public function create()
    {
        super.create();

        wallTopLeft = createWall(360, 80);
        wallTopLeft2 = createWall(100, 200);
        wallTopRight = createWall(360, 80, FlxG.width - 360);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomLeft2 = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var sealedDoor:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/sealedDoor'));
        sealedDoor.x = FlxG.width - sealedDoor.width;
        sealedDoor.screenCenter(Y);
        sealedDoor.immovable = true;
        props.push(sealedDoor);
        add(sealedDoor);

        var sealedDoorPlanks:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/sealedDoorPlanks'));
        sealedDoorPlanks.x = sealedDoor.x - sealedDoorPlanks.width - 25;
        sealedDoorPlanks.screenCenter(Y);
        add(sealedDoorPlanks);

        matpatDoor = new FlxSprite().loadGraphic(Paths.image('map/matpatDoor'));
        matpatDoor.scale.set(1.25, 1.25);
        matpatDoor.updateHitbox();
        matpatDoor.x = sealedDoor.x;
        matpatDoor.screenCenter(Y);
        add(matpatDoor);

        exit1 = new Exit('RoomAfton', wallTopLeft.width, 0, Std.int(FlxG.width - (wallTopLeft.width + wallTopRight.width)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2), true); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('RoomCorridorRight', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width + wallBottomRight.width)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit2);
        exits.push(exit2);

        var exit3:Exit = new Exit('Room6', 0, wallTopLeft2.height, 1, Std.int(FlxG.height - (wallTopLeft2.height + wallBottomLeft2.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit3);
        exits.push(exit3);

        exit4 = new Exit('RoomFinale1', matpatDoor.x, matpatDoor.y, 1, Std.int(matpatDoor.height), new FlxPoint(114, -1), function() {return ourple.hasKey;}); //Right Exit
        add(exit4);
        exits.push(exit4);
    }
}