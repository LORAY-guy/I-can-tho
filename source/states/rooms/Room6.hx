package states.rooms;

class Room6 extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopLeft:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomLeft2:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    var flickeringLight:FlxSprite;
    var flickeringSound:FlxSprite;

    override function create()
    {
        super.create();

        createFloor();

        wallTop = createWall(FlxG.width, 80);
        wallTopLeft = createWall(100, 200);
        wallTopRight = createWall(100, 200, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomLeft2 = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table3'));
        table.setPosition(510 - table.width - 75, wallTop.height + 25);
        table.immovable = true;
        add(table);
        props.push(table);
        onTopOfOurple.add(table);

        var table2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table4'));
        table2.setPosition(510 + table2.width + 75, wallTop.height + 25);
        table2.immovable = true;
        table2.flipX = true;
        add(table2);
        props.push(table2);
        onTopOfOurple.add(table2);

        var exit1:Exit = new Exit('Room7', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width + wallBottomRight.width)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('Room2', 0, wallBottomLeft2.height, 1, Std.int(FlxG.height - (wallBottomLeft2.height + wallBottomRight2.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit2);
        exits.push(exit2);

        var exit3:Exit = new Exit('Room8', FlxG.width - 2, wallBottomRight2.height, 1, Std.int(FlxG.height - (wallBottomLeft2.height + wallBottomRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit3);
        exits.push(exit3);
    }
}