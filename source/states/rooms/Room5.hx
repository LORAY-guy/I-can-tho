package states.rooms;

class Room5 extends BaseRoom
{
    var wallTopRight:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallLeft:FlxSprite;
    var wallTopLeft2:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomRight2:FlxSprite;

    override function create() 
    {
        super.create();
    
        createFloor();

        var trash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/trash'));
        trash.setPosition(69, 420); //heheheheheh
        trash.flipY = true;
        add(trash);

        wallTopRight = createWall(360, 80, FlxG.width - 360);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallLeft = createWall(200, FlxG.height);
        wallTopLeft2 = createWall(360, 80);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var table2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table4'));
        table2.offset.y = 34;
        table2.y = FlxG.height - wallBottom.height - table2.height - 25 + table2.offset.y;
        table2.screenCenter(X);
        table2.x += 40;
        table2.immovable = true;
        table2.flipX = true;
        add(table2);
        props.push(table2);
        onTopOfOurple.add(table2);

        var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table4'));
        table.offset.y = 34;
        table.setPosition(table2.x - table.width - 40, table2.y);
        table.immovable = true;
        add(table);
        props.push(table);
        onTopOfOurple.add(table);

        var table3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table4'));
        table3.offset.y = 34;
        table3.setPosition(table2.x + table3.width + 40, table2.y);
        table3.immovable = true;
        table3.flipX = true;
        add(table3);
        props.push(table3);
        onTopOfOurple.add(table3);

        var exit1:Exit = new Exit('Room3', wallTopRight.width, 0, Std.int(FlxG.width - (wallTopRight.width * 2)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('Room4', FlxG.width - 2, wallTopRight2.height, 1, Std.int(FlxG.height - (wallTopRight2.height + wallTopRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit2);
        exits.push(exit2);
    }
}