package states.rooms;

class Room7 extends BaseRoom
{
    var wallTopLeft:FlxSprite;
    var wallTopLeft2:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallTopRight2:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomRight:FlxSprite;

    override function create() 
    {
        super.create();
    
        createFloor();
    
        var trash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/trash'));
        trash.setPosition(10, 305);
        trash.flipX = true;
        add(trash);

        wallTopLeft = createWall(360, 80);
        wallTopLeft2 = createWall(100, 200);
        wallTopRight = createWall(360, 80, FlxG.width - 360);
        wallTopRight2 = createWall(100, 200, FlxG.width - 100);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomLeft = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var stain1:FlxSprite = new FlxSprite(575, 180).loadGraphic(Paths.image('map/inkStain'));
        add(stain1);

        var stain2:FlxSprite = new FlxSprite(170, 402).loadGraphic(Paths.image('map/inkStain'));
        stain2.scale.set(1.2, 1.2);
        stain2.flipY = true;
        add(stain2);

        var table2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/table1'));
        table2.y = FlxG.height - wallBottom.height - table2.height - 25;
        table2.screenCenter(X);
        table2.immovable = true;
        table2.flipX = true;
        add(table2);
        props.push(table2);
        onTopOfOurple.add(table2);

        var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/tableStain'));
        table.setPosition(table2.x - table.width - 75, table2.y);
        table.immovable = true;
        add(table);
        props.push(table);
        onTopOfOurple.add(table);

        var table3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/tableStain'));
        table3.setPosition(table2.x + table3.width + 75, table2.y);
        table3.immovable = true;
        table3.flipX = true;
        add(table3);
        props.push(table3);
        onTopOfOurple.add(table3);

        var exit1:Exit = new Exit('Room6', wallTopLeft.width, 0, Std.int(FlxG.width - (wallTopLeft.width + wallTopRight.width)), 1, new FlxPoint(-1, FlxG.height - ourple.height - 2)); //Top Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('Room4', 0, wallTopLeft2.height, 1, Std.int(FlxG.height - (wallTopLeft2.height + wallTopLeft2.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit2);
        exits.push(exit2);

        var exit3:Exit = new Exit('RoomCorridorRight', FlxG.width - 2, wallTopRight2.height, 1, Std.int(FlxG.height - (wallTopRight2.height + wallTopRight2.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit3);
        exits.push(exit3);
    }
}