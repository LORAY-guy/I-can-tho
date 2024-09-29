package states.rooms;

/**Not very accurate to Afton's OG room but I tried my best.**/
class RoomAfton extends BaseRoom
{
    var wallTop:FlxSprite;
    var wallLeft:FlxSprite;
    var wallRight:FlxSprite;
    var wallBottomLeft:FlxSprite;
    var wallBottomLeft2:FlxSprite;
    var wallBottomRight:FlxSprite;
    var wallBottomRight2:FlxSprite;

    public var exit:Exit;

    //Cutscene stuff
    var afton:FlxSprite;
    var aftonCorpse:FlxSprite;
    var bloodPool:FlxSprite;

    var fakeChilds:Array<FlxSprite> = [];
    var child1:FlxSprite;
    var child2:FlxSprite;
    var child3:FlxSprite;
    var child4:FlxSprite;

    override function create() 
    {
        super.create();
    
        createFloor();

        wallTop = createWall(FlxG.width, 80);
        wallLeft = createWall(100, FlxG.height);
        wallRight = createWall(100, FlxG.height, FlxG.width - 100);
        wallBottomLeft = createWall(360, 80, 0, FlxG.height - 80);
        wallBottomLeft2 = createWall(100, 200, 0, FlxG.height - 200);
        wallBottomRight = createWall(360, 80, FlxG.width - 360, FlxG.height - 80);
        wallBottomRight2 = createWall(100, 200, FlxG.width - 100, FlxG.height - 200);

        var stain1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/inkStain'));
        stain1.scale.set(1.1, 1.1);
        stain1.updateHitbox();
        stain1.setPosition(wallRight.x - stain1.width - 25, FlxG.height - stain1.height - 175);
        add(stain1);

        var stain2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/inkStain'));
        stain2.scale.set(1.1, 1.1);
        stain2.updateHitbox();
        stain2.setPosition(stain1.x - stain2.width - 50, FlxG.height - stain2.height - 175);
        add(stain2);

        var stain3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/inkStain'));
        stain3.scale.set(1.1, 1.1);
        stain3.updateHitbox();
        stain3.setPosition(stain2.x, stain2.y - stain3.height - 5);
        add(stain3);

        var arcade1:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/arcade'));
        arcade1.setPosition(wallLeft.width + 40, wallTop.height + 25);
        props.push(arcade1);
        onTopOfOurple.add(arcade1);
        arcade1.immovable = true;
        add(arcade1);

        var arcade2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/arcade'));
        arcade2.setPosition(arcade1.x + arcade2.width + 40, wallTop.height + 25);
        props.push(arcade2);
        onTopOfOurple.add(arcade2);
        arcade2.immovable = true;
        add(arcade2);

        var arcade3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('map/arcade'));
        arcade3.setPosition(arcade2.x + arcade3.width + 40, wallTop.height + 25);
        props.push(arcade3);
        onTopOfOurple.add(arcade3);
        arcade3.immovable = true;
        add(arcade3);

        bloodPool = new FlxSprite(919.5, 535).loadGraphic(Paths.image('blood'));
        bloodPool.immovable = true;
        bloodPool.visible = false;
        onTopOfOurple.add(bloodPool);
        props.push(bloodPool);
        add(bloodPool);

        aftonCorpse = new FlxSprite(952, 416).loadGraphic(Paths.image('characters/AftonDead'));
        aftonCorpse.immovable = true;
        aftonCorpse.visible = false;
        onTopOfOurple.add(aftonCorpse);
        props.push(aftonCorpse);
        add(aftonCorpse);

        afton = new FlxSprite(220, 280);
        afton.frames = Paths.getSparrowAtlas('characters/Afton');
        afton.animation.addByPrefix('Idle', 'Idle', 1, false);
        afton.animation.addByPrefix('Running', 'Running', 14, true);
        afton.animation.addByPrefix('Laughing', 'Laughing', 2, true);
        afton.animation.addByPrefix('Dying', 'Dying0', 12, true);
        afton.animation.addByPrefix('DyingMore', 'DyingMore', 8, true);
        afton.animation.addByPrefix('DyingEvenMore', 'DyingEvenMore', 6, true);
        afton.animation.addByPrefix('HeDeadChat', 'HeDeadChat', 1, false);
        add(afton);

        child1 = createFakeChild(145, 350);
        fakeChilds.push(child1);
        child2 = createFakeChild(145, 480);
        fakeChilds.push(child2);
        child3 = createFakeChild(240, 350);
        fakeChilds.push(child3);
        child4 = createFakeChild(240, 480);
        fakeChilds.push(child4);

        exit = new Exit('Room8', wallBottomLeft.width, FlxG.height - 1, Std.int(FlxG.width - (wallBottomLeft.width + wallBottomRight.width)), 1, new FlxPoint(-1, 2)); //Bottom Exit
        add(exit);
        exits.push(exit);
    }

    private function createFakeChild(x:Float, y:Float):FlxSprite
    {
        var child:FlxSprite = new FlxSprite(x, y);
        child.frames = Paths.getSparrowAtlas('characters/CryingChild');
        child.animation.addByPrefix('Idle', 'Idle', 2);
        child.animation.play('Idle');
        child.scale.set(1.4, 1.4);
        child.updateHitbox();
        add(child);
        return child;
    }

    override function onLoad():Void
    {
        super.onLoad();

        if (PlayState.instance.aftonCutscene)
        {
            exit.locked = true;
            ourple.lockedControls = true;

            afton.animation.play('Running');
            afton.animation.callback = function(name:String, frame:Int, frameIndex:Int)
            {
                if (name == 'Running') {
                    afton.x += 25;
                    FlxG.sound.play(Paths.sound('run'), 0.9);
                    if (afton.x == 920) {
                        startCutscene();
                    }
                }
            };

            if (phone.player.playing) phone.muteCall();
        }
    }

    private function startCutscene():Void 
    {
        afton.animation.callback = null;
        ambienceManager.stopMusic(2);
        afton.animation.play('Idle');
        new FlxTimer().start(2.5, function(tmr:FlxTimer) 
        {
            afton.animation.play('Laughing');
            afton.animation.callback = function(name:String, frame:Int, frameIndex:Int) 
            {
                if (frame == 1) {
                    FlxG.sound.play(Paths.sound('laugh'), 0.6);
                }
            };
            new FlxTimer().start(3, function(tmr:FlxTimer) 
            {
                afton.animation.callback = null;
                afton.animation.play('Dying');
                ambienceManager.playMusic('void');
                ambienceManager.adjustMusicVolume(1, 0);

                new FlxTimer().start(0.0625, function(tmr:FlxTimer) 
                {
                    var bloodParticle:FlxSprite = new FlxSprite().makeGraphic(25, 25, FlxColor.RED);
                    var bloodXPos:Float = afton.x + (afton.width / 2 - bloodParticle.width / 2);
                    var bloodYPos:Float = afton.y + (afton.height / 2 - bloodParticle.height / 2);
                    bloodParticle.x = bloodXPos + FlxG.random.float(-10, 10);
                    bloodParticle.y = bloodYPos + FlxG.random.float(-10, 10);
                    bloodParticle.velocity.set(FlxG.random.float(-200, 200), 100);
                    PlayState.instance.insert(99, bloodParticle);
                    new FlxTimer().start(0.75, function(tmr:FlxTimer) {
                        PlayState.instance.remove(bloodParticle, true);
                        bloodParticle.destroy();
                    });
                }, 32);

                FlxG.sound.play(Paths.sound('killAnimatronic'), 0.7);
                new FlxTimer().start(4, function(tmr:FlxTimer)
                {
                    afton.animation.play('DyingMore');
                    FlxG.sound.play(Paths.sound('insuit'), 0.7);
                    new FlxTimer().start(3, function(tmr:FlxTimer) {
                        afton.animation.play('DyingEvenMore');
                        FlxG.sound.play(Paths.sound('insuit'), 0.7);
                        new FlxTimer().start(3, function(tmr:FlxTimer) {
                            PlayState.instance.remove(afton, true);
                            afton.destroy();
                            aftonCorpse.visible = true;
                            bloodPool.visible = true;
                            FlxG.sound.play(Paths.sound('insuit'), 0.7);
                            new FlxTimer().start(2, function(tmr:FlxTimer) {
                                fadeCryingChilds();
                            });
                        });
                    });
                });
            });
        });
    }

    private function fadeCryingChilds():Void
    {
        new FlxTimer().start(0.75, function(tmr:FlxTimer) {
            for (child in fakeChilds) {
                child.alpha = 1 - 0.25 * tmr.elapsedLoops;
            }

            if (tmr.elapsedLoops == 5) 
            {
                for (child in fakeChilds) {
                    remove(child, true);
                    fakeChilds.remove(child);
                }

                PlayState.instance.aftonCutscene = false;
                PlayState.instance.enableCryingChilds();
                phone.playMessage('endCutscene');
            }
        }, 5);
    }
}