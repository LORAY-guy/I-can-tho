package states.rooms;

class RoomCorridorRight extends BaseRoom
{
    var wallTopLeft:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallRight1:FlxSprite;
    var wallRight2:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomRight:FlxSprite;

    override function create() 
    {
        super.create();
    
        createFloor();

        wallTopLeft = createWall(360, 200);
        wallTopRight = createWall(360, 80, FlxG.width - 360);
        wallRight1 = createWall(120, FlxG.height, FlxG.width - 360);
        wallRight2 = createWall(120, FlxG.height, FlxG.width - 120);
        wallBottomLeft = createWall(360, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);

        var exit1:Exit = new Exit('Room8', wallTopLeft.width, 0, Std.int(FlxG.width - (360 * 2)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('RoomCornerRight', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width * 2)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit2);
        exits.push(exit2);

        var exit3:Exit = new Exit('Room7', 0, wallBottomLeft.height, 1, Std.int(FlxG.height - (wallBottomLeft.height + wallBottomLeft.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit3);
        exits.push(exit3);
    }
}