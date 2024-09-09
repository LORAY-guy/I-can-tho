package objects;

/**
 * ### Crying Child
 *
 * Basically the same IA as `Animatronic` but instead of chasing player, they run for an exit.
 * (And they can't kill you).
 *
 * They have cool sound design tho
 */
class CryingChild extends FlxSprite
{
    private var walkSpeed:Int = 120;
    private var escapeSpeed:Int = 165;
    private var viewDistance:Float = 1000;
    private var reactionTime:Float = 0.5;
    private var timeToChangeDirection:Float = 2;

    public var isFacingPlayer:Bool = false;
    public var escaping:Bool = false;
    public var stunned:Bool = false;

    public var currentRoom:BaseRoom;
    private var player:Ourple;
    private var playerLastRoom:BaseRoom;
    private var closestExit:Exit;

    public var trickTimer:FlxTimer = new FlxTimer();
    public var changeFacingDirectionTimer:FlxTimer = new FlxTimer();
    private var randomDirectionTimer:FlxTimer = new FlxTimer();

    private var exclamation:FlxText;

    public var runningSound:FlxSound;

    public function new():Void
    {
        super();

        frames = Paths.getSparrowAtlas("characters/CryingChild");
        animation.addByPrefix("Idle", "Idle", 1);
        animation.addByPrefix("Up", "Up", 1);
        animation.addByPrefix("Down", "Down", 1);
        animation.addByPrefix("Left", "Left", 1);
        animation.addByPrefix("Right", "Right", 1);
        animation.play("Idle");
        scale.set(1.25, 1.25);
        updateHitbox();

        player = PlayState.instance.ourple;

        exclamation = new FlxText(0, 0, 50, '!', 16);
        exclamation.setFormat(Paths.font('fnaf.ttf'), 72, FlxColor.WHITE, CENTER);
        exclamation.visible = false;

        runningSound = new FlxSound();
        runningSound.loadEmbedded(Paths.sound('cryingChildRun'));
        runningSound.volume = 0.8;
    }

    override public function update(elapsed:Float):Void
    {
        if (player.dead || currentRoom != PlayState.instance.currentRoom) {
            if (visible) visible = false;
            return;
        }

        visible = true;

        if (exclamation.visible) 
            exclamation.x = this.x + (this.width / 2) - 12;

        if (!stunned) {
            if (!escaping) {
                if (canSeePlayer()) {
                    if (!isFacingPlayer) startTrickTimer();
                } else if (!changeFacingDirectionTimer.active) {
                    changeFacingDirectionTimer.start(timeToChangeDirection, faceRandomDirection);
                }
            } else {
                escapePlayer();
                updateRunningSoundPan();
            }
        } else if (!velocity.isZero()) {
            velocity.zero();
        }

        super.update(elapsed); //Can't remember why I putted that here of all places, but, it seems important, so I don't wanna move it.

        if (stunned && player.animation.curAnim.name == "Grab" && player.animation.curAnim.curFrame == 12) {
            eatChild();
        }

        if (!isFacingPlayer)
        {
            for (exit in currentRoom.exits)
            {
                if (this.overlaps(exit)) {
                    repositionToNewRoom();
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
        var dw:Float = player.width - this.width * 2;
        var dh:Float = player.height - this.height * 2;

        var distanceToPlayer:Float = Math.sqrt((dx * dx) + (dy * dy) + (dw * dw) + (dh * dh));
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

        var angleDifference:Float = Math.abs(angleToPlayer - currentFacingAngle);
        angleDifference = CoolUtil.wrapAngle(angleDifference);
        
        return angleDifference <= 90;
    }

    private function startTrickTimer():Void
    {
        faceDirection(true);
        changeFacingDirectionTimer.cancel();
        velocity.zero();
    
        exclamation.visible = true;
        exclamation.y = this.y - 50;
        PlayState.instance.currentRoom.insert(PlayState.instance.currentRoom.members.indexOf(this) + 10, exclamation);
        FlxTween.tween(exclamation, {y: exclamation.y - 10}, 0.4, {ease: FlxEase.cubeOut});
        new FlxTimer().start(0.5, function(tmr:FlxTimer) { //Move this here cuz it won't disappear
            if (exclamation.visible) {
                PlayState.instance.currentRoom.remove(exclamation);
                exclamation.visible = false;
            }
        });
    
        FlxG.sound.play(Paths.sound('childSpotted'), 0.7) #if FLX_PITCH .pitch = FlxG.random.float(0.8, 1.2); #end

        PlayState.instance.ambienceManager.adjustMusicVolume(0.5);
    
        trickTimer.start(this.reactionTime, function(tmr:FlxTimer) {
            determineClosestExit();
            trickCallback();
        });
    }

    private function determineClosestExit():Exit
    {
        var minDistance:Float = Math.POSITIVE_INFINITY;
    
        for (exit in PlayState.instance.currentRoom.exits)
        {
            var distance:Float = FlxMath.distanceBetween(this, exit);
            
            if (distance < minDistance) {
                minDistance = distance;
                closestExit = exit;
            }
        }

        return closestExit;
    }

    private function trickCallback():Void
    {
        if (!player.dead)
        {
            isFacingPlayer = false;
            escaping = true;
            runningSound.play();
            PlayState.instance.ambienceManager.pause();
        }
    }

    public function faceDirection(facePlayer:Bool):Void
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
        if (!isFacingPlayer || !escaping) {
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

    private function escapePlayer():Void
    {
        var directionX:Float = ((closestExit.x + (closestExit.width / 2)) - (this.width / 2) >= this.x) ? 1 : -1;
        var directionY:Float = ((closestExit.y + (closestExit.height / 2)) - (this.height / 2) >= this.y) ? 1 : -1;
        velocity.set(directionX * escapeSpeed, directionY * escapeSpeed);
        updateChildAnimation();
    }

    public function stopEscaping():Void
    {
        trickTimer.cancel();
        if (runningSound != null && runningSound.playing) runningSound.stop();
        isFacingPlayer = false; //Actually necessary lol
        escaping = false;
        if (velocity != null && !velocity.isZero()) velocity.zero();
        PlayState.instance.ambienceManager.resume();
        PlayState.instance.ambienceManager.resetMusicVolume();
    }

    public function repositionToNewRoom(playFootstep:Bool = true):Void
    {
        if (currentRoom != null) {
            currentRoom.removeChild(this);

            if (currentRoom.members.contains(exclamation)) {
                currentRoom.remove(exclamation);
                exclamation.visible = false;
            }
        }

        stopEscaping();
        faceRandomDirection();

        var playerRoom:BaseRoom = PlayState.instance.currentRoom;

        var validRooms:Array<BaseRoom> = PlayState.instance.rooms;
        if (validRooms.length == 0) return;

        // Filter rooms that do not exceed max animatronics limit and are not the player's current room
        validRooms = validRooms.filter(room -> room != playerRoom && room.members.filter(child -> Std.isOfType(child, CryingChild)).length < 1);
        if (validRooms.length == 0) return;

        var newRoom:BaseRoom = validRooms[FlxG.random.int(0, validRooms.length - 1)];
        if (playFootstep) playTauntSound(newRoom);
        this.currentRoom = newRoom;

        currentRoom.addChild(this);

        this.screenCenter(XY);

        if (currentRoom.animatronicSpawnOffset != null)
            this.setPosition(this.x + currentRoom.animatronicSpawnOffset.x, this.y + currentRoom.animatronicSpawnOffset.y);

        CoolUtil.handlePropCollision(this);

        visible = false;
    } 

    private function playTauntSound(newRoom:BaseRoom):Void
    {
        if (currentRoom != null && currentRoom.leftRooms != null)
        {
            var direction:Int = 1;
            for (leftRoom in currentRoom.leftRooms)
            {
                if (leftRoom == newRoom)
                {
                    direction = -1;
                    break;
                }
            }
    
            var tauntSound:FlxSound = new FlxSound();
            tauntSound.loadEmbedded(Paths.soundRandom("taunt", 1, 3));
            tauntSound.volume = FlxG.random.float(0.6, 0.8);
            tauntSound.pan = direction;
            tauntSound.onComplete = function() {tauntSound.destroy();};
            tauntSound.play();
        }
    }

    public function placeChild(roomName:String, x:Float, y:Float):Void
    {
        if (roomName != PlayState.instance.currentRoom.roomName)
        {
            if (currentRoom != null) {
                currentRoom.removeChild(this);

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
            
            currentRoom.addChild(this);

            if (escaping) stopEscaping();

            this.x = x;
            this.y = y;
        }
    }

    private function eatChild():Void
    {
        escaping = false;
        visible = false;
        velocity.set(0, 0);

        PlayState.instance.remove(this);
        PlayState.instance.allChilds.remove(this);
        PlayState.instance.currentRoom.removeChild(this);
        PlayState.instance.ambienceManager.resume();
        PlayState.instance.ambienceManager.resetMusicVolume();

        if (PlayState.instance.allChilds.length == 0 && PlayState.instance.cryingChildMode)
        {
            PlayState.instance.cryingChildMode = false;
            PlayState.instance.currentRoom.add(new Key(this.x + this.width / 2, this.y + this.height / 2));
        }

        destroy();
    }

    private function updateChildAnimation():Void
    {
        if (escaping)
        {
            if (velocity.isZero()) {
                animation.play("Idle");
            } else {
                if (Math.abs(velocity.x) > Math.abs(velocity.y)) {
                    if (velocity.x >= 0) animation.play("Right");
                    else if (velocity.x < 0) animation.play("Left");
                } else {
                    if (velocity.y >= 0) animation.play("Down");
                    else if (velocity.y < 0) animation.play("Up");
                }
            }
        }
    }

    override function destroy():Void
    {
        super.destroy();

        if (runningSound != null && runningSound.playing) runningSound.stop();
        runningSound.destroy();

        randomDirectionTimer.cancel();
        trickTimer.cancel();
        changeFacingDirectionTimer.cancel();
    }
}