package states;

/**
 * ### PlayState
 * Main state of the game.
 * Handles :
 * - Game elements creation.
 * - Update.
 * - Controls.
 * - Room transition.
 */
class PlayState extends FlxUIState
{
    public var controls(get, never):Controls;
    private function get_controls() return Controls.instance;

    public static var instance:PlayState;

    //CAMERAS
    public var camHUD:FlxCamera;
	public var camPause:FlxCamera;

    //PLAYER SHIT
    public var ourple:Ourple;
    public var staminaBar:FlxBar;
    private var fadeSpeed:Float = 2.5;

    //HUD SHIT
	private var hudAssets:FlxSpriteGroup;
    private var bufferOverlay:FlxSprite;
    private var glitchLine:FlxSprite;
    public var tutorialControls:FlxText;

    private var bufferOverlayTimer:FlxTimer = new FlxTimer();

    //ROOMS SHIT
    public var rooms:Array<BaseRoom> = [];
    public var roomsFinale:Array<BaseRoom> = [];
    public var currentRoom:BaseRoom;
    
    public var room1:Room1;
    public var room2:Room2;
    public var room3:Room3;
    public var room4:Room4;
    public var room5:Room5;
    public var room6:Room6;
    public var room7:Room7;
    public var room8:Room8;
    public var room9:Room9;
    public var roomAfton:RoomAfton;
    public var roomFoxyCurtain:RoomFoxyCurtain;
    public var roomCorridorLeft:RoomCorridorLeft;
    public var roomCorridorRight:RoomCorridorRight;
    public var roomPartsAndService:RoomPartsAndService;
    public var roomSupplyCloset:RoomSupplyCloset;
    public var roomCornerLeft:RoomCornerLeft;
    public var roomCornerRight:RoomCornerRight;
    public var office:Office;
    public var roomFinale1:RoomFinale1;
    public var roomFinale2:RoomFinale2;

    //OPTIONS SHIT
    public var cameraID:FlxSprite;
    public var pauseCamera:FlxSprite;

    //MORE SHIT
    public var flicker:FlxSprite;

    public var stormSound:FlxSound = new FlxSound();
    public var allAnimatronics:Array<Animatronic> = [];
    public var allChilds:Array<CryingChild> = [];

    public var phone:PhoneCall;
    public var ambienceManager:AmbienceManager = new AmbienceManager();
    public var timer:Timer;

    public var inCutscene:Bool = false;
    public var aftonCutscene:Bool = false;
    public var cryingChildMode:Bool = false;

    public var creepyFilter:FlxSprite;

    public var vintage:FlxSprite;

    override public function create():Void
    {
        super.create();

        instance = this;

        ourple = new Ourple();
		insert(5, ourple);

        //MAKE SURE TO ADD THE ROOMS HERE!!!!
        createRooms();

        camHUD = new FlxCamera();
        camPause = new FlxCamera();
        camHUD.bgColor.alpha = 0;
        camPause.bgColor.alpha = 0;

        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.add(camPause, false);
        FlxG.cameras.setDefaultDrawTarget(FlxG.camera, true);

        loadRoom("Room1", 600, 225);

        //MAKE SURE TO ADD THE ANIMATRONICS HERE!!!!
        createEnemies();

        staminaBar = new FlxBar(FlxG.width - 235, FlxG.height - 25, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 10, ourple, "currentStamina", 0, ourple.MAX_STAMINA, true);
        staminaBar.createFilledBar(0xFF000000, 0xFFA357AB);
        staminaBar.cameras = [camHUD];
        staminaBar.scrollFactor.set();
        add(staminaBar);

        tutorialControls = new FlxText(0, ourple.y + ourple.height + 25, 0);
        tutorialControls.setFormat(Paths.font('fnaf.ttf'), 72, FlxColor.WHITE, CENTER);
        tutorialControls.text = 
            UserPrefs.keyBinds.get('up')[0].toString() + '\n' +
            UserPrefs.keyBinds.get('left')[0].toString() + '  ' +
            UserPrefs.keyBinds.get('right')[0].toString() + '\n' +
            UserPrefs.keyBinds.get('down')[0].toString();
        tutorialControls.screenCenter(X);
        tutorialControls.visible = false;
        add(tutorialControls);

        hudAssets = new FlxSpriteGroup();
		hudAssets.cameras = [camHUD];

        bufferOverlay = new FlxSprite();
        bufferOverlay.frames = Paths.getSparrowAtlas('bufferOverlay');
        bufferOverlay.animation.addByPrefix('Idle', 'Idle', 2);
        bufferOverlay.animation.play('Idle');
        bufferOverlay.setGraphicSize(FlxG.width, FlxG.height);
        bufferOverlay.updateHitbox();
        bufferOverlay.screenCenter();
        bufferOverlay.alpha = FlxG.random.float(0, 0.1);
        hudAssets.add(bufferOverlay);

        bufferOverlayTimer.start(0.075, function(tmr:FlxTimer) {
            if (FlxG.random.bool(75)) {
                bufferOverlay.alpha = FlxG.random.float(0, 0.1);
            } else {
                bufferOverlay.alpha = 0;
            }
        }, 0);

        var scanline:FlxSprite = new FlxSprite().loadGraphic(Paths.image('scanline'));
        scanline.setGraphicSize(FlxG.width, FlxG.height);
        scanline.updateHitbox();
        scanline.screenCenter();
        hudAssets.add(scanline);

        glitchLine = new FlxSprite().makeGraphic(FlxG.width, 100);
        glitchLine.y = -glitchLine.height;
        glitchLine.alpha = 0.075;
        glitchLine.velocity.y = 22.5;
        hudAssets.add(glitchLine);

        flicker = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        flicker.visible = false;
        hudAssets.add(flicker);

        creepyFilter = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        creepyFilter.alpha = 0.5;
        creepyFilter.visible = false;
        hudAssets.add(creepyFilter);

        timer = new Timer(FlxG.width - 172, 10, Paths.font('fnaf3.ttf'), 24, FlxColor.WHITE);
        timer.visible = UserPrefs.data.showTimer;
        hudAssets.add(timer);

        cameraID = new FlxSprite().loadGraphic(Paths.image('cameraId'));
        cameraID.cameras = [camPause];
        cameraID.screenCenter(X);
        cameraID.y = FlxG.height - cameraID.height - 10;
        cameraID.alpha = 0;
        hudAssets.add(cameraID);

        phone = new PhoneCall();
        phone.cameras = [camHUD];
        add(phone);

        pauseCamera = new FlxSprite();
        pauseCamera.cameras = [camPause];
        pauseCamera.frames = Paths.getSparrowAtlas('pause/cameraFlip');
        pauseCamera.animation.addByPrefix('Idle', 'Idle', 30, false);
        pauseCamera.visible = false;
        hudAssets.add(pauseCamera);

        pauseCamera.animation.finishCallback = function(name:String) {
            if (pauseCamera.animation.curAnim.reversed) {
                pauseCamera.visible = false;
                canPause = true;
            } else {
                paused = true;
                persistentDraw = false;
                FlxG.sound.defaultSoundGroup.pause();
                openSubState(new options.OptionsState());
            }
        };

        add(hudAssets);

        vintage = new FlxSprite();
        vintage.frames = Paths.getSparrowAtlas('vintage');
        vintage.animation.addByPrefix('idle', 'idle');
        vintage.animation.play('idle');
        vintage.setGraphicSize(FlxG.width, FlxG.height);
        vintage.updateHitbox();
        vintage.screenCenter();
        vintage.alpha = 0.5;
        vintage.visible = false;
        add(vintage);

        stormSound.loadEmbedded(Paths.sound('rainstorm'), true);
        FlxG.sound.defaultSoundGroup.add(stormSound);
        stormSound.play();
    }

    private function createEnemies():Void
    {
        var freddy:Animatronic = new Animatronic('Freddy', 155, 270, 750, 1, 2, 
            ["Room2", "Room3", "Room4", "Room5", "Room6", "Room7", "Room8", "RoomCorridorRight", "RoomCornerRight", "Office"]
        ); //Very fast (ref to FNAF Free Roam)
        allAnimatronics.push(freddy);

        var bonnie:Animatronic = new Animatronic('Bonnie', 90, 190, Math.POSITIVE_INFINITY, 0.8, 2, 
            ["Room2", "Room3", "Room4", "Room5", "Room6", "Room7", "Room9", "RoomPartsAndService", "RoomSupplyCloset", "RoomFoxyCurtain", "RoomCorridorLeft", "RoomCornerLeft", "Office"]
        ); //Very good eyesight
        allAnimatronics.push(bonnie);

        var chica:Animatronic = new Animatronic('Chica', 40, 170, 900, 0.45, 1.5, 
            ["Room2", "Room3", "Room4", "Room5", "Room6", "Room7", "Room8", "RoomCorridorRight", "RoomCornerRight", "Office"]
        ); //Quick reaction time (but slow chase speed)
        allAnimatronics.push(chica);

        var foxy:Animatronic = new Animatronic('Foxy', 70, 220, 800, 1.75, 2.5, 
            ["Room9", "RoomFoxyCurtain", "RoomPartsAndService", "RoomCorridorLeft", "RoomCornerLeft", "Office"]
        , false); //Can't be fooled by the mask (but very slow reaction time)
        allAnimatronics.push(foxy);

        if (CoolUtil.tutorialMode) {
            bonnie.placeAnimatronic("Room3", 375, 150);
            freddy.placeAnimatronic("Room3", 582, 165);
            chica.placeAnimatronic("Room3", 775, 160);
            ourple.caseOhMode = true;
            ourple.lockedControls = true;
        } else {
            room3.seenAnimatronicsOnStage = true;
            new FlxTimer().start(0.75, function(tmr:FlxTimer) {
                enableAnimatronics();
                ambienceManager.playMusic();
            });
        }

        for (i in 0...4) {
            var child:CryingChild = new CryingChild();
            allChilds.push(child);
        }
    }

    private function createRooms():Void
    {
        //Room creation
        room1 = new Room1("Room1");
        room2 = new Room2("Room2");
        room3 = new Room3("Room3");
        room4 = new Room4("Room4");
        room5 = new Room5("Room5");
        room6 = new Room6("Room6");
        room7 = new Room7("Room7");
        room8 = new Room8("Room8");
        room9 = new Room9("Room9");
        roomAfton = new RoomAfton("RoomAfton");
        roomFoxyCurtain = new RoomFoxyCurtain("RoomFoxyCurtain");
        roomCorridorLeft = new RoomCorridorLeft("RoomCorridorLeft");
        roomCorridorRight = new RoomCorridorRight("RoomCorridorRight");
        roomPartsAndService = new RoomPartsAndService("RoomPartsAndService");
        roomSupplyCloset = new RoomSupplyCloset("RoomSupplyCloset");
        roomCornerLeft = new RoomCornerLeft("RoomCornerLeft");
        roomCornerRight = new RoomCornerRight("RoomCornerRight");
        office = new Office("Office");
        roomFinale1 = new RoomFinale1("RoomFinale1");
        roomFinale2 = new RoomFinale2("RoomFinale2");

        rooms.push(room1);
        rooms.push(room2);
        rooms.push(room3);
        rooms.push(room4);
        rooms.push(room5);
        rooms.push(room6);
        rooms.push(room7);
        rooms.push(room8);
        rooms.push(room9);
        rooms.push(roomAfton);
        rooms.push(roomFoxyCurtain);
        rooms.push(roomCorridorLeft);
        rooms.push(roomCorridorRight);
        rooms.push(roomPartsAndService);
        rooms.push(roomSupplyCloset);
        rooms.push(roomCornerLeft);
        rooms.push(roomCornerRight);
        rooms.push(office);

        roomsFinale.push(roomFinale1);
        roomsFinale.push(roomFinale2);

        //Establishing neighbors (for footstep sound)
        //This is the best I can do with this "engine" for this mechanic
        room1.leftRooms = [room3, room5, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room2.leftRooms = [room1, room3, room5, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room3.leftRooms = [roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room4.leftRooms = [room1, room2, room3, room5, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room5.leftRooms = [room3, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room6.leftRooms = [room1, room2, room3, room4, room5, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room7.leftRooms = [room1, room2, room3, room4, room5, room6, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room8.leftRooms = [room1, room2, room3, room4, room5, room6, room7, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        room9.leftRooms = [roomPartsAndService];
        roomAfton.leftRooms = [room1, room2, room3, room4, room5, room6, room7, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        roomFoxyCurtain.leftRooms = [room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        roomCorridorLeft.leftRooms = [roomFoxyCurtain, room9, roomPartsAndService, roomSupplyCloset, roomCornerLeft, office];
        roomCorridorRight.leftRooms = [room1, room2, room3, room4, room5, room6, room7, room8, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        roomCornerLeft.leftRooms = [roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset];
        roomCornerRight.leftRooms = [room3, room5, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft, office];
        office.leftRooms = [room3, room5, roomFoxyCurtain, room9, roomPartsAndService, roomCorridorLeft, roomSupplyCloset, roomCornerLeft];

        //Animatronic spawn offsets (because I hate having fucking animatronics in the fucking walls)
        room4.animatronicSpawnOffset = new FlxPoint(0, -50);
        room5.animatronicSpawnOffset = new FlxPoint(0, -50);
        room7.animatronicSpawnOffset = new FlxPoint(0, -50);
        roomPartsAndService.animatronicSpawnOffset = new FlxPoint(140, 0);
        office.animatronicSpawnOffset = new FlxPoint(0, 50);

        new FlxTimer().start(1, function(tmr:FlxTimer) {
            if (FlxG.random.bool(2.5)) {
                for (room in rooms) {
                    room.floorFlash();
                }
            }
        }, 0);
    }

    public var paused:Bool = false;
    public var canPause:Bool = true;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!paused && !ourple.dead)
        {
            updateStaminaBarVisibility();

            if (cryingChildMode) updateChildLayers();
            else updateAnimatronicLayers();

            updateCameraIDVisibility();

            if (glitchLine != null && glitchLine.y > FlxG.height + glitchLine.height * 1.75) {
                glitchLine.y = -glitchLine.height;
            }

            if (canPause && ((FlxG.mouse.overlaps(cameraID) && FlxG.mouse.deltaScreenY > 0) || controls.PAUSE)) {
                canPause = false;
                FlxG.sound.play(Paths.sound('camera'), 0.7).endTime = 750;
                pauseCamera.visible = true;
                pauseCamera.animation.play('Idle');
            }

            if (!UserPrefs.data.disableReset && controls.RESET) {
                disableEverything();
                FlxG.switchState(new StaticState());
            }
        }
    }

    private function updateCameraIDVisibility():Void
    {
        if (FlxG.mouse.justMoved) {
            if (cameraID.alpha < 1) {
                cameraID.alpha += 0.01;
                if (cameraID.alpha > 1) {
                    cameraID.alpha = 1;
                }
            }
        } else {
            if (cameraID.alpha > 0) {
                cameraID.alpha -= 0.0025;
                if (cameraID.alpha < 0) {
                    cameraID.alpha = 0;
                }
            }
        }
    }

    private function updateAnimatronicLayers():Void
    {
        for (animatronic in currentRoom.animatronics)
        {
            if (!animatronic.dead && !animatronic.chasing)
            {
                remove(animatronic, true);
                if (animatronic.y < ourple.y) {
                    insert(members.indexOf(ourple), animatronic);
                } else {
                    insert(members.indexOf(ourple) + 1, animatronic);
                }
            }
        }
    }

    private function updateChildLayers():Void
    {
        for (child in currentRoom.childs)
        {
            if (!child.escaping)
            {
                remove(child, true);
                if (child.y < ourple.y) {
                    insert(members.indexOf(ourple), child);
                } else {
                    insert(members.indexOf(ourple) + 1, child);
                }
            }
        }
    }

    public function enableAnimatronics():Void
    {
        var playedSound:Bool = false;

        for (animatronic in allAnimatronics) {
            animatronic.tutorialMode = false;
            animatronic.repositionToNewRoom(playedSound ? false : playedSound = FlxG.random.bool(75));
        }

        room3.unlockTutorialExits();
    }

    public function enableCryingChilds():Void
    {
        for (child in allChilds) {
            child.repositionToNewRoom(false);
        }

        cryingChildMode = true;
    }

    public function loadRoom(roomName:String, x:Null<Float>, y:Null<Float>):Void
    {
        if (!ourple.dead)
        {
            if (currentRoom != null) {
    
                for (mouse in currentRoom.mouses) {
                    mouse.destroy();
                }
                currentRoom.mouses = [];

                if (currentRoom.goldenFreddy != null) {
                    currentRoom.goldenFreddy.destroy();
                }

                remove(currentRoom.onTopOfOurple, true);
                remove(currentRoom.waterDrops, true);

                for (sound in currentRoom.sounds) {
                    sound.volume = 0;
                }
    
                remove(currentRoom, true);
            }
    
            if (roomName.contains('Finale')) {
                for (room in roomsFinale)
                {
                    if (room.roomName == roomName) {
                        currentRoom = room;
                        break;
                    }
                }
            } else {
                for (room in rooms)
                {
                    if (room.roomName == roomName) {
                        currentRoom = room;
                        break;
                    }
                }
            }
    
            if (currentRoom != null) {
                insert(members.indexOf(ourple) - 1, currentRoom);
                ourple.setPosition((x == null || x < 0 ? ourple.x : x), (y == null || y < 0 ? ourple.y : y));
                CoolUtil.handlePropCollision(ourple);

                currentRoom.createMouses();
                currentRoom.onLoad();

                insert(members.indexOf(ourple) + 1, currentRoom.onTopOfOurple);
                insert(members.indexOf(ourple) + 2, currentRoom.waterDrops);

                for (animatronic in currentRoom.animatronics) {
                    if (!animatronic.tutorialMode) {
                        remove(animatronic, true);
                        insert(members.indexOf(ourple), animatronic);
                        phone.playMessage(animatronic.name.toLowerCase() + 'Intro', true, true);
                    }
                }

                currentRoom.checkForGoldenFreddy();

                for (sound in currentRoom.sounds) {
                   sound.volume = 0.25;
                }
            }
        }
    }

    public function onExitRoom():Void
    {
        if (!ourple.dead)
        {
            if (cryingChildMode) {
                if (currentRoom.childs.length > 0) {
                    for (child in allChilds) {
                        if (child.escaping || child.isFacingPlayer) {
                            child.repositionToNewRoom();
                        }
                    }
                }
            } else {
                if (currentRoom.animatronics.length > 0) {
                    for (animatronic in allAnimatronics) {
                        if (animatronic.chasing || animatronic.isFacingPlayer) {
                            animatronic.repositionToNewRoom();
                        }
                    }
                }
            }
        }
    }
    
    private function updateStaminaBarVisibility():Void
    {
        if ((ourple.velocity.isZero() || !controls.SPRINT) && ourple.currentStamina == ourple.MAX_STAMINA) {
            staminaBar.alpha -= fadeSpeed * FlxG.elapsed;
            if (staminaBar.alpha < 0) staminaBar.alpha = 0;
        } else {
            staminaBar.alpha += fadeSpeed * FlxG.elapsed;
            if (staminaBar.alpha > 1) staminaBar.alpha = 1;
        }
    }

    public function gameOver(goldenDeath:Bool = false):Void
    {
        if (!ourple.dead)
        {
            ourple.dead = true;
            CoolUtil.deathCounter++;
            ourple.lockedControls = true;
            ourple.setPosition(5000, 5000); // Doing like all 3D games do when they don't want something to be in a accessible area
            if (ourple.breathing.playing) {
                ourple.breathing.stop();
                ourple.breathing.volume = 0; //Just in case... Cuz it still plays sometimes
            }
    
            disableEverything();
            FlxG.switchState(new GameOverState(goldenDeath));
        }
    }

    public function disableEverything():Void
    {
        for (camera in FlxG.cameras.list) {
            camera.visible = false;
        }

        if (cryingChildMode) {
            for (child in allChilds) {
                if (child != null) {
                    child.destroy();
                    allChilds.remove(child);
                    currentRoom.childs.remove(child);
                    child = null;
                }
            }
        } else {
            for (animatronic in allAnimatronics) {
                if (animatronic != null) {
                    animatronic.destroy();
                    allAnimatronics.remove(animatronic);
                    currentRoom.animatronics.remove(animatronic);
                    animatronic = null;
                }
            }
        }

        for (sound in FlxG.sound.defaultSoundGroup.sounds) {
            if (sound != null) {
                if (sound.playing) sound.stop();
                FlxG.sound.defaultSoundGroup.remove(sound);
                sound.destroy();
                sound = null;
            }
        }

        for (room in rooms) //Necessary apparently
        {
            for (sound in room.sounds)
            {
                if (sound != null) {
                    if (sound.playing) sound.stop();
                    FlxG.sound.defaultSoundGroup.remove(sound);
                    sound.destroy();
                    sound = null;
                }
            }
        }

        ambienceManager.destroy();
        ambienceManager = null;

        stormSound.stop();
        FlxG.sound.defaultSoundGroup.remove(stormSound);
        stormSound.destroy();
        stormSound = null;
    }

    override function closeSubState():Void
    {
        super.closeSubState();

        paused = false;
        persistentDraw = true;
        FlxG.sound.defaultSoundGroup.resume();
        FlxG.sound.play(Paths.sound('camera'), 0.7).endTime = 750;
        pauseCamera.animation.play('Idle', false, true);
    }

    override function onFocusLost():Void
    {
        vintage.visible = true;

        FlxG.sound.defaultSoundGroup.pause();
        if (ambienceManager != null) ambienceManager.pause(true);

        paused = true;
        
        for (stuff in members) {
            if (stuff != vintage && Std.isOfType(stuff, FlxObject)) stuff.active = false;
        }

        super.onFocusLost();
    }

    override function onFocus():Void
    {
        vintage.visible = false;

        FlxG.sound.defaultSoundGroup.resume();
        ambienceManager.resume(true);

        paused = false;

        for (stuff in members) {
            if (stuff != vintage && Std.isOfType(stuff, FlxObject)) stuff.active = true;
        }

        super.onFocus();
    }
}