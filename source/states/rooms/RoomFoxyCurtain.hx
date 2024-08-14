package states.rooms;

class RoomFoxyCurtain extends BaseRoom
{
    var wallLeft:FlxSprite;
    var wallTopLeft:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    override function create()
    {
        super.create();

        createFloor();

        wallTopLeft = createWall(360, 80);
        wallLeft = createWall(100, FlxG.height);
        wallTopRight = createWall(360, 80, FlxG.width - 360);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table4'));
        table.offset.y = 34;
        table.setPosition(510 + table.width + 75, FlxG.height - wallBottomRight.height - table.height - 25 + table.offset.y);
        table.immovable = true;
        add(table);
        props.push(table);
        onTopOfOurple.add(table);

        var curtain:FlxSprite = new FlxSprite(-40).loadGraphic(Paths.image('map/curtain'));
        curtain.scale.set(1.1, 1.1);
        curtain.updateHitbox();
        curtain.screenCenter(Y);
        curtain.immovable = true;
        props.push(curtain);
        add(curtain);
        onTopOfOurple.add(curtain);

        var exit1:Exit = new Exit('Room9', 360, 0, Std.int(FlxG.width - (360 * 2)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('RoomCorridorLeft', 360, FlxG.height - 1, Std.int(FlxG.width - (360 * 2)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit2);
        exits.push(exit2);

        var exit3:Exit = new Exit('Room3', FlxG.width - 2, wallTopRight2.height, 1, Std.int(FlxG.height - (wallTopRight2.height + wallTopRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit3);
        exits.push(exit3);
    }
}