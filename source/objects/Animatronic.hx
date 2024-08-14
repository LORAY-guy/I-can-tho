package objects;

/**
 * ### Animatronic
 * Creates an animatronic "IA" (prob the worst IA you've ever seen).
 */
class Animatronic extends FlxSprite
{
    private var name:String;
    private var walkSpeed:Int;
    private var chaseSpeed:Int;
    private var viewDistance:Float;
    private var reactionTime:Float;
    private var timeToChangeDirection:Float;
    private var allowedRooms:Array<String>;
    private var canBeTricked:Bool;

    public var chasing:Bool = false;
    public var dead:Bool = false;
    public var isFacingPlayer:Bool = false;
    public var tutorialMode:Bool = true;

    public var currentRoom:BaseRoom;
    private var player:Ourple;
    private var playerLastRoom:BaseRoom;

    private var trickTimer:FlxTimer = new FlxTimer();
    private var changeFacingDirectionTimer:FlxTimer = new FlxTimer();
    private var randomDirectionTimer:FlxTimer = new FlxTimer();

    public var corpseImage:FlxSprite;
    private var exclamation:FlxText;

    public var runningSound:FlxSound;

    /**
     * It stats can vary, to give it special abilities.
     *
     * @param	name	                The name of the animatronic as a `String`.
     * @param	walkSpeed               The wandering speed of the animatronic.
     * @param	chaseSpeed              The chase speed of the animatronic.
     * @param	viewDistance            How far away can the animatronic spot the player.
     * @param	reactionTime            How much time it takes for the animatronic to realise that the player is, in fact, not an animatronic.
     * @param	timeToChangeDirection   Time the animatronic takes to change wandering direction.
     * @param	allowedRooms            List of rooms the aniamtronic is allowed to spawn to.
     * @param	canBeTricked            If the animatronic can be fooled by the Freddy mask (commonly used for Foxy).
     */
    public function new(name:String, walkSpeed:Int, chaseSpeed:Int, viewDistance:Float, reactionTime:Float, timeToChangeDirection:Float, allowedRooms:Array<String>, canBeTricked:Bool = true):Void
    {
        super();

        frames = Paths.getSparrowAtlas("characters/" + name);
        animation.addByPrefix("Idle", "Idle", 1);
        animation.addByPrefix("Up", "Up", 1);
        animation.addByPrefix("Down", "Down", 1);
        animation.addByPrefix("Left", "Left", 1);
        animation.addByPrefix("Right", "Right", 1);
        animation.play("Idle");
        updateHitbox();

        this.name = name;
        this.walkSpeed = walkSpeed;
        this.chaseSpeed = chaseSpeed;
        this.viewDistance = viewDistance;
        this.reactionTime = reactionTime;
        this.timeToChangeDirection = timeToChangeDirection;
        this.allowedRooms = allowedRooms;
        this.canBeTricked = canBeTricked;

        player = PlayState.instance.ourple;

        exclamation = new FlxText(0, 0, 50, '!', 16);
        exclamation.setFormat(Paths.font('fnaf.ttf'), 72, FlxColor.WHITE, CENTER);
        exclamation.visible = false;

        runningSound = new FlxSound();
        runningSound.loadEmbedded(Paths.sound('foxyRunMono'));
        runningSound.volume = 0.8;
        FlxG.sound.defaultSoundGroup.add(runningSound);
    }

    override public function update(elapsed:Float):Void
    {
        if (dead || player.dead || currentRoom != PlayState.instance.currentRoom) {
            if (visible) visible = false;
            return;
        }

        if (tutorialMode) return;

        visible = true;

        if (exclamation.visible) 
            exclamation.x = this.x + (this.width / 2) - 12;

        if (!chasing) {
            if (canSeePlayer() && (!canBeTricked || !player.maskOn)) {
                if (!isFacingPlayer) startTrickTimer();
            } else if (!changeFacingDirectionTimer.active) {
                changeFacingDirectionTimer.start(timeToChangeDirection, faceRandomDirection);
            }
        } else {
            chasePlayer();
            updateRunningSoundPan();
        }

        super.update(elapsed); //Can't remember why I putted that here of all places, but, it seems important, so I don't wanna move it.

        checkKillPlayer();

        if (playerSneakingUp() && !isFacingPlayer && !chasing && player.animation.curAnim.name == "Stab" && player.animation.curAnim.curFrame == 4) {
            killAnimatronic();
        }

        if (!this.isFacingPlayer && !this.chasing)
        {
            for (exit in currentRoom.exits)
            {
                if (this.overlaps(exit)) {
                    this.repositionToNewRoom();
                }
            }
        }
    }

    private function updateRunningSoundPan():Void
    {
        if (runningSound != null && runningSound.playing)
        {
            var relativePosition:Float = ((this.x + (this.width / 2)) - (player.x + (player.width / 2))) / FlxG.width;

            // Normalize to -1 to 1 (required for correct panning)
            var pan:Float = relativePosition * 2;
            pan = Math.max(-1, Math.min(1, pan));
            
            runningSound.pan = pan;
        }
    }

    private function playerInSameRoom():Bool {
        return currentRoom == PlayState.instance.currentRoom;
    }

    /**Oh brother...**/
    private function canSeePlayer():Bool
    {
        var dx:Float = player.x - this.x;
        var dy:Float = player.y - this.y;
    
        var distanceToPlayer:Float = Math.sqrt(dx * dx + dy * dy + ((player.height / 2) - (this.height / 2)) * ((player.height / 2) - (this.height / 2)));
        if (distanceToPlayer > viewDistance) return false;

        var angleToPlayer:Float = CoolUtil.radiansToDegrees(Math.atan2(dy, dx));

        var currentFacingAngle:Float = 90;
        switch (animation.curAnim.name) {
            case "Up":
                currentFacingAngle = -90;
            case "Down":
                currentFacingAngle = 90;
            case "Left":
                currentFacingAngle = 180;
            case "Right":
                currentFacingAngle = 0;
        }
    
        angleToPlayer = CoolUtil.wrapAngle(angleToPlayer);
        currentFacingAngle = CoolUtil.wrapAngle(currentFacingAngle);
        
        var angleThreshold:Float = (this.name == 'Bonnie' ? 87 : 60); //Larger FOV for Bonnie, since he's supposed to have an incredible vision.
        var angleDifference:Float = Math.abs(angleToPlayer - currentFacingAngle);
        angleDifference = CoolUtil.wrapAngle(angleDifference);
        
        return angleDifference <= angleThreshold;
    }

    private function playerSneakingUp():Bool
    {
        if (player != null && !player.dead && !canSeePlayer()) {
            return FlxMath.distanceBetween(this, player) < 132; // Basically, you have 32 pixels window to kill the animatronic. Get too close, and you fucking die.
        }
        return false;
    }

    private function startTrickTimer():Void
    {
        faceDirection(true);
        changeFacingDirectionTimer.cancel();
        velocity.zero();
    
        exclamation.visible = true;
        exclamation.x = this.x + (this.width / 2) - 12;
        exclamation.y = this.y - 50;
        PlayState.instance.currentRoom.insert(PlayState.instance.currentRoom.members.indexOf(this) + 10, exclamation);
        FlxTween.tween(exclamation, {y: exclamation.y - 10}, 0.4, {ease: FlxEase.cubeOut});
    
        FlxG.sound.play(Paths.sound('spotted'), 0.7) #if FLX_PITCH .pitch = FlxG.random.float(0.8, 1.2); #end

        PlayState.instance.ambienceManager.adjustMusicVolume(0.5);
    
        trickTimer.start(this.reactionTime, function(tmr:FlxTimer) {
            trickCallback();
            if (exclamation.visible) {
                PlayState.instance.currentRoom.remove(exclamation);
                exclamation.visible = false;
            }            
        });
    }        

    private function trickCallback():Void
    {
        if (!dead && !player.dead)
        {
            isFacingPlayer = false;
            if (!canBeTricked || (canBeTricked && !player.maskOn)) {
                chasing = true;
                runningSound.play();
                PlayState.instance.ambienceManager.pause();
            } else {
                faceDirection(false);
                PlayState.instance.ambienceManager.resetMusicVolume();
                changeFacingDirectionTimer.start(timeToChangeDirection, faceRandomDirection);
            }
        }
    }

    private function faceDirection(facePlayer:Bool):Void
    {
        var dx:Float = player.x - this.x;
        var dy:Float = player.y - this.y;
    
        if (Math.abs(dx) > Math.abs(dy)) {
            if (dx > 0) {
                animation.play(facePlayer ? "Right" : "Left");
            } else {
                animation.play(facePlayer ? "Left" : "Right");
            }
        } else {
            if (dy > 0) {
                animation.play(facePlayer ? "Down" : "Up");
            } else {
                animation.play(facePlayer ? "Up" : "Down");
            }
        }
        isFacingPlayer = facePlayer;
    }

    var walkCounter:Int = 0;
    var directions:Array<String> = ['Right', 'Down', 'Left', 'Up'];
    private function faceRandomDirection(tmr:FlxTimer = null):Void
    {
        if (!isFacingPlayer || !chasing) {
            var randomDirection:String;

            do {
                randomDirection = directions[FlxG.random.int(0, directions.length - 1)];
            } while (randomDirection == this.animation.curAnim.name);
            animation.play(randomDirection);
    
            if (walkCounter == 2) {
                switch (randomDirection) {
                    case 'Right':
                        velocity.set(walkSpeed, 0);
                    case 'Down':
                        velocity.set(0, walkSpeed);
                    case 'Left':
                        velocity.set(-walkSpeed, 0);
                    case 'Up':
                        velocity.set(0, -walkSpeed);
                }

                randomDirectionTimer.start(FlxG.random.float(0.2, 0.75), function(tmr:FlxTimer) velocity.set(0, 0));
                walkCounter = 0;
            } else {
                velocity.zero();
                walkCounter++;
            }
        }
    }

    private function chasePlayer():Void
    {
        var directionX:Float = (player.x >= this.x) ? 1 : -1;
        var directionY:Float = (player.y >= this.y) ? 1 : -1;
        velocity.set(directionX * chaseSpeed, directionY * chaseSpeed);
        updateAnimatronicAnimation();
    }

    public function stopChasing():Void
    {
        trickTimer.cancel();
        if (runningSound != null && runningSound.playing) runningSound.stop();
        isFacingPlayer = false; //Actually necessary lol
        chasing = false;
        if (velocity != null && !velocity.isZero()) velocity.zero();
        PlayState.instance.ambienceManager.resume();
        PlayState.instance.ambienceManager.resetMusicVolume();
    }

    public function repositionToNewRoom(playFootstep:Bool = true):Void
    {
        if (!dead)
        {
            if (currentRoom != null) {
                currentRoom.removeAnimatronic(this);
    
                if (currentRoom.members.contains(exclamation)) {
                    currentRoom.remove(exclamation);
                    exclamation.visible = false;
                }
            }

            stopChasing();
            faceRandomDirection();

            var playerRoom:BaseRoom = PlayState.instance.currentRoom;

            var validRooms:Array<BaseRoom> = PlayState.instance.rooms.filter(room -> allowedRooms.indexOf(room.roomName) >= 0);
            if (validRooms.length == 0) return;
    
            // Filter rooms that do not exceed max animatronics limit and are not the player's current room
            validRooms = validRooms.filter(room -> room != playerRoom && room.members.filter(animatronic -> Std.isOfType(animatronic, Animatronic)).length < 1);
            if (validRooms.length == 0) return;
    
            var newRoom:BaseRoom = validRooms[FlxG.random.int(0, validRooms.length - 1)];
            if (playFootstep) playFootstepSound(newRoom);
            this.currentRoom = newRoom;
            trace('$name: ' + currentRoom.roomName);
    
            currentRoom.addAnimatronic(this);

            this.screenCenter(XY);

            if (currentRoom.animatronicSpawnOffset != null)
                this.setPosition(this.x + currentRoom.animatronicSpawnOffset.x, this.y + currentRoom.animatronicSpawnOffset.y);

            CoolUtil.handlePropCollision(this);

            visible = false;
        }
    } 

    private function playFootstepSound(room:BaseRoom):Void
    {
        if (currentRoom != null && currentRoom.leftRooms != null)
        {
            var direction:Int = 1;
            for (leftRoom in currentRoom.leftRooms)
            {
                if (leftRoom == room)
                {
                    direction = -1;
                    break;
                }
            }
    
            var footstepSound:FlxSound = new FlxSound();
            footstepSound.loadEmbedded(Paths.soundRandom("walk", 1, 5));
            footstepSound.volume = FlxG.random.float(0.6, 0.8);
            footstepSound.pan = direction;
            
            footstepSound.play();
        }
    }

    public function placeAnimatronic(roomName:String, x:Float, y:Float):Void
    {
        if (roomName != PlayState.instance.currentRoom.roomName)
        {
            if (currentRoom != null) {
                currentRoom.removeAnimatronic(this);

                if (currentRoom.members.contains(exclamation)) {
                    currentRoom.remove(exclamation);
                    exclamation.visible = false;
                }
            }

            for (room in PlayState.instance.rooms)
            {
                if (room.roomName == roomName)
                {
                    currentRoom = room;
                    break;
                }
            }
            
            currentRoom.addAnimatronic(this);

            if (chasing) stopChasing();

            this.x = x;
            this.y = y;
        }
    }

    private function checkKillPlayer():Void
    {
        if (!dead && (chasing || (!chasing && !player.maskOn)) && FlxMath.distanceBetween(this, player) < 100) {
            PlayState.instance.gameOver();
        }
    }

    private function killAnimatronic():Void
    {
        if (!dead)
        {
            dead = true;
            chasing = false;
            canBeTricked = false;
            visible = false;
            velocity.set(0, 0);

            corpseImage = new FlxSprite().loadGraphic(Paths.image(name.toLowerCase() + "Dead"));
            corpseImage.setPosition(this.x - 140, this.y + 85);
            currentRoom.add(corpseImage);
    
            if (FlxG.random.bool(2.5)) {
                var explosion:FlxSprite = new FlxSprite(corpseImage.x + 55, corpseImage.y - 65);
                explosion.frames = Paths.getSparrowAtlas("explosion");
                explosion.animation.addByPrefix("boom", "explosion idle", 20, false);
                explosion.animation.finishCallback = function(boom) {
                    explosion.destroy();
                    explosion = null;
                };
                explosion.animation.play("boom");
                explosion.scale.set(1.4, 1.4);
                explosion.updateHitbox();
                currentRoom.add(explosion);
    
                FlxG.sound.play(Paths.sound("explosion"), 0.6);
            } else {
                FlxG.sound.play(Paths.sound("killAnimatronic"), 0.5);
            }
    
            PlayState.instance.remove(this);
            PlayState.instance.allAnimatronics.remove(this);
            PlayState.instance.currentRoom.removeAnimatronic(this);

            if (PlayState.instance.allAnimatronics.length == 0 && !PlayState.instance.aftonCutscene)
            {
                PlayState.instance.aftonCutscene = true;
                if (PlayState.instance.room8 != null && PlayState.instance.room8.exit1 != null) {
                    PlayState.instance.room8.exit1.locked = false;
                }
            }

            if (UserPrefs.data.endlessMode) {
                new FlxTimer().start(10, function(tmr:FlxTimer) {
                    FlxTween.tween(this, {alpha: 0}, 2, {
                        ease: FlxEase.quadOut,
                        onComplete: function(twn:FlxTween) {
                            destroy();
                            //Respawn it for endless mode
                        }
                    });
                });
            } else {
                destroy();
            }
        }
    }

    private function updateAnimatronicAnimation():Void
    {
        if (chasing)
        {
            if (velocity.x == 0 && velocity.y == 0) {
                animation.play("Idle");
            } else {
                if (Math.abs(velocity.x) > Math.abs(velocity.y)) {
                    if (velocity.x > 0) animation.play("Right");
                    else animation.play("Left");
                } else {
                    if (velocity.y > 0) animation.play("Down");
                    else animation.play("Up");
                }
            }
        }
    }

    override function destroy():Void
    {
        if (runningSound != null) {
            if (runningSound.playing) runningSound.stop();
            runningSound.destroy();
            FlxG.sound.defaultSoundGroup.remove(runningSound);
            runningSound = null;
        } 

        randomDirectionTimer.cancel();
        trickTimer.cancel();
        changeFacingDirectionTimer.cancel();

        super.destroy();
    }
}