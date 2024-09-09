package states.rooms;

class RoomFinale1 extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopLeft:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomLeft:FlxSprite;

    override function create():Void
    {
        super.create();
    
        createFloor();

        wallTop = createWall(FlxG.width, 80);
        wallTopLeft = createWall(100, 200);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomLeft = createWall(100, 200, 0, FlxG.height - 200);

        var sealedDoor:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/sealedDoor'));
        sealedDoor.flipX = true;
        sealedDoor.screenCenter(Y);
        sealedDoor.immovable = true;
        walls.push(sealedDoor);
        add(sealedDoor);

        var matpatDoor:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/matpatDoor'));
        matpatDoor.scale.set(1.25, 1.25);
        matpatDoor.updateHitbox();
        matpatDoor.x = 3;
        matpatDoor.screenCenter(Y);
        matpatDoor.immovable = true;
        add(matpatDoor);

        var stain1:FlxSprite = new FlxSprite(280, 185).loadGraphic(Paths.image('map/inkStain'));
        stain1.scale.set(0.9, 0.9);
        stain1.flipX = true;
        add(stain1);

        var stain2:FlxSprite = new FlxSprite(560, 100).loadGraphic(Paths.image('map/inkStain'));
        stain2.scale.set(0.7, 0.7);
        stain2.flipY = true;
        add(stain2);

        var stain3:FlxSprite = new FlxSprite(875, 380).loadGraphic(Paths.image('map/inkStain'));
        stain3.scale.set(1.1, 1.1);
        stain3.flipX = true;
        add(stain3);

        var papers:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/papers1'));
        papers.x = FlxG.width - papers.width - 50;
        papers.screenCenter(Y);
        add(papers);

        var exit:Exit = new Exit('RoomFinale2', FlxG.width - 2, 80, 1, Std.int(FlxG.height - (wallTop.height - wallBottom.height)), new FlxPoint(2, -1), false);
        exits.push(exit);
        add(exit);
    }

    override function onLoad():Void
    {
        super.onLoad();

        if (!ambienceManager.playingCrumblingDreams) {
            PlayState.instance.stormSound.volume = 0.7;
            FlxG.sound.play(Paths.sound('keyUnlock'), 0.4);
            PlayState.instance.ourple.allowSprint = false;
            PlayState.instance.staminaBar.visible = false;
            ambienceManager.playCrumblingDreams();
            PlayState.instance.creepyFilter.visible = true;
        } else {
            ambienceManager.updateCrumblingDreams(0.75, 0.4);
        }
    }
}