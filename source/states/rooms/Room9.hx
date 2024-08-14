package states.rooms;

class Room9 extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopLeft:FlxSprite;
    var wallRight:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomLeft2:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    override function create() 
    {
        super.create();
    
        createFloor();
    
        var trash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/trash'));
        trash.setPosition(170, 430);
        trash.scale.set(1.1, 1.1);
        add(trash);

        wallTop = createWall(FlxG.width, 80);
        wallTopLeft = createWall(100, 200);
        wallRight = createWall(100, FlxG.height, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomLeft2 = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var exit1:Exit = new Exit('RoomFoxyCurtain', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width + wallBottomRight.width)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('RoomPartsAndService', 0, wallBottomLeft2.height, 1, Std.int(FlxG.height - (wallBottomLeft2.height + wallBottomLeft2.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit2);
        exits.push(exit2);
    }
}