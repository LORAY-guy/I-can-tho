package states.rooms;

class RoomFinale2 extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallTopRight:FlxSprite;
    var wallBottom:FlxSprite;
    var wallBottomRight:FlxSprite;

    override function create():Void
    {
        super.create();
    
        createFloor();

        var stain1:FlxSprite = new FlxSprite(490, 320).loadGraphic(Paths.image('map/inkStain'));
        add(stain1);

        var stain2:FlxSprite = new FlxSprite(900, 470).loadGraphic(Paths.image('map/inkStain'));
        stain2.scale.set(0.8, 0.8);
        stain2.flipX = true;
        add(stain2);

        var stain3:FlxSprite = new FlxSprite(180, 200).loadGraphic(Paths.image('map/inkStain'));
        stain3.scale.set(1.2, 1.2);
        stain3.flipX = true;
        stain3.flipY = true;
        add(stain3);

        var stain4:FlxSprite = new FlxSprite(340, 290).loadGraphic(Paths.image('map/inkStain'));
        stain4.scale.set(0.8, 0.8);
        stain4.flipY = true;
        add(stain4);


        var papers:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/papers2'));
        papers.setGraphicSize(1920, papers.height - 160);
        papers.updateHitbox();
        papers.screenCenter(Y);
        add(papers);

        wallTop = createWall(FlxG.width, 80);
        wallTopRight = createWall(100, 200, FlxG.width - 100);
        wallBottom = createWall(FlxG.width, 80, 0, FlxG.height - 80);
        wallBottomRight = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var exit:Exit = new Exit('RoomFinale1', 0, 80, 1, Std.int(FlxG.height - (wallTop.height + wallBottom.height)), new FlxPoint(FlxG.width - ourple.width - 2, -1), false); //Left Exit
        exits.push(exit);
        add(exit);

        var exit2:Exit = new Exit('RoomFinale3', FlxG.width - 2, wallTopRight.height, 1, Std.int(FlxG.height - (wallBottomRight.height * 2)), new FlxPoint(2, -1)); //Right Exit
        add(exit2);
        exits.push(exit2);
    }

    override function onLoad():Void
    {
        super.onLoad();
        ambienceManager.updateCrumblingDreams(0.4, 0.7);
    }
}