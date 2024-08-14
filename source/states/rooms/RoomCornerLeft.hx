package states.rooms;

class RoomCornerLeft extends BaseRoom
{
    var wallTopRight:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallLeft:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomRight2:FlxSprite;

    override function create() 
    {
        super.create();

        wallTopRight = createWall(360, 80, FlxG.width - 360);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallLeft = createWall(360, FlxG.height);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var exit1:Exit = new Exit('RoomCorridorLeft', wallLeft.width, 0, Std.int(FlxG.width - (wallLeft.width + wallTopRight.width)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('Office', FlxG.width - 2, wallTopRight2.height, 1, Std.int(FlxG.height - (wallTopRight2.height + wallTopRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit2);
        exits.push(exit2);
    }
}