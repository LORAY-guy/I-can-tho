package states.rooms;

class Office extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopLeft:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomRight:FlxSprite;

    var office:FlxSprite;
    var officeSound:FlxSound;

    override function create() 
    {
        super.create();
    
        createFloor();

        var light:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
        light.makeGraphic(FlxG.width, FlxG.height);
        light.screenCenter();
        light.alpha = 0.05;
        light.blend = ADD;
        add(light);

        wallTop = createWall(FlxG.width, 80);
        wallTopLeft = createWall(100, 200);
        wallTopRight = createWall(100, 200, FlxG.width - 100);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomLeft = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        office = new FlxSprite().loadGraphic(Paths.image('map/desk'));
        office.screenCenter(X);
        office.y = wallTop.height - 40;
        office.immovable = true;
        props.push(office);
        onTopOfOurple.add(office);
        add(office);

        officeSound = new FlxSound().loadEmbedded(Paths.sound('fanMono'), true);
        officeSound.proximity(office.getGraphicMidpoint().x, office.getGraphicMidpoint().y, office, 120);
        FlxG.sound.defaultSoundGroup.add(officeSound);
        officeSound.volume = 0;
        officeSound.play();
        sounds.push(officeSound);

        var exit1:Exit = new Exit('RoomCornerLeft', 0, wallTopLeft.height, 1, Std.int(FlxG.height - (wallTopLeft.height * 2)), new FlxPoint(FlxG.width - ourple.width - 2, -1)); //Left Exit
        add(exit1);
        exits.push(exit1);

        var exit2:Exit = new Exit('RoomCornerRight', FlxG.width - 2, wallTopLeft.height, 1, Std.int(FlxG.height - (wallTopLeft.height * 2)), new FlxPoint(2, -1)); //Right Exit
        add(exit2);
        exits.push(exit2);
    }
}