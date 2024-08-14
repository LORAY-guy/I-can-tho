package states.rooms;

class RoomCornerRight extends BaseRoom
{
    var wallTopLeft:FlxSprite;
    var wallTopLeft2:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallRight:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomRight:FlxSprite;

    override function create() 
    {
        super.create();

        wallTopLeft = createWall(360, 80);
        wallTopLeft2 = createWall(100, 200);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallRight = createWall(360, FlxG.height, FlxG.width - 360);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomLeft = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var exit1:Exit = new Exit('RoomCorridorRight', wallTopLeft.width, 0, Std.int(FlxG.width - (wallTopLeft.width + wallRight.width)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('Office', 0, wallTopLeft2.height, 1, Std.int(FlxG.height - (wallTopLeft2.height * 2)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit2);
        exits.push(exit2);
    }
}