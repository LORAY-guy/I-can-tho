package states.rooms;

class Room1 extends BaseRoom
{
    var exit:Exit;

    override function create():Void
    {
        super.create();

        createFloor();

        var trash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/trash'));
        trash.setPosition(200, 420);
        add(trash);

        var topWall:FlxSprite = createWall(FlxG.width, 210);

        var exitDoor:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/exitDoor'));
        exitDoor.setPosition(0, topWall.height - exitDoor.height);
        exitDoor.screenCenter(X);
        add(exitDoor);

        var rightWall:FlxSprite = createWall(290, FlxG.height, FlxG.width - 290);
        var leftWall:FlxSprite = createWall(290, FlxG.height);

        var window1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/windowMoon'));
        window1.setPosition(leftWall.width + window1.width / 2, window1.height / 16);
        window1.immovable = true;
        add(window1);

        var window2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/window'));
        window2.setPosition(rightWall.x - window2.width * 1.5, window2.height / 16);
        window2.immovable = true;
        add(window2);

        exit = new Exit('Room2', leftWall.width, FlxG.height - 1, Std.int(FlxG.width - (leftWall.width + rightWall.width)), 1, new FlxPoint(-1, 2));
        add(exit);
        //exit.locked = true;
        exits.push(exit);
    }
}