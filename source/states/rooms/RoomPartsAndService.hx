package states.rooms;

class RoomPartsAndService extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottom:FlxSprite;
    var wallLeft:FlxSprite;

    var flickeringLight:FlxSprite;
    var lightSound:FlxSound;

    override function create():Void
    {
        super.create();

        flickeringLight = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
        flickeringLight.makeGraphic(FlxG.width, FlxG.height);
        flickeringLight.screenCenter();
        flickeringLight.alpha = 0;
        flickeringLight.blend = ADD;
        add(flickeringLight);
        flashingLight();

        lightSound = new FlxSound().loadEmbedded(Paths.sound('flickeringMono'), true);
        lightSound.proximity(flickeringLight.getGraphicMidpoint().x, flickeringLight.getGraphicMidpoint().y, flickeringLight, 120);
        FlxG.sound.defaultSoundGroup.add(lightSound);
        lightSound.volume = 0;
        lightSound.play();
        sounds.push(lightSound);

        var stain1:FlxSprite = new FlxSprite(180, 440).loadGraphic(Paths.image('map/inkStain'));
        stain1.flipX = true;
        add(stain1);

        var stain2:FlxSprite = new FlxSprite(290, 140).loadGraphic(Paths.image('map/inkStain'));
        stain2.scale.set(1.2, 1.2);
        stain2.flipX = true;
        add(stain2);

        var stain3:FlxSprite = new FlxSprite(400, 325).loadGraphic(Paths.image('map/inkStain'));
        stain3.flipY = true;
        add(stain3);

        wallTop = createWall(FlxG.width, 80);
        wallTopRight = createWall(100, 200, FlxG.width - 100);
        wallBottomRight = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallLeft = createWall(100, FlxG.height);

        var table:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/maintenanceTable'));
        table.scale.set(1.1, 1.1);
        table.updateHitbox();
        table.screenCenter(Y);
        table.x = wallLeft.width + 85;
        table.immovable = true;
        add(table);
        props.push(table);
        onTopOfOurple.add(table);

        var exit:Exit = new Exit('Room9', FlxG.width - 2, wallTopRight.height, 1, Std.int(FlxG.height - (wallTopRight.height + wallBottomRight.height)), new FlxPoint(2, -1)); //Right Exit
        add(exit);
        exits.push(exit);
    }

    private function flashingLight():Void 
    {
        new FlxTimer().start(0.2, function(tmr:FlxTimer) {
            flickeringLight.alpha = FlxG.random.float(0.005, 0.080);
            flashingLight();
        }, 1);
    }
}