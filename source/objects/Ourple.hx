package objects;

/**
 * ### Ourple
 * The funny Ourple Man.
 *
 * Handles player inputs.
 */
class Ourple extends FlxSprite
{
    public var MOVE_SPEED:Float = 160;
    public var SPRINT_SPEED:Float = 270;
    public var MAX_STAMINA:Float = 100;
    public var currentStamina:Float = 100;

    public var staminaBar:FlxBar;
    public var staminaRegenRate:Float = 10;
    public var staminaDepleteRate:Float = 10;

    public var maskOn:Bool = false;
    public var isMoving:Bool = false;
    public var allowSprint:Bool = true;
    public var dead:Bool = false;
    public var hasKey:Bool = false;

    public var lockedControls:Bool = false;
    public var caseOhMode:Bool = false;

    public var breathing:FlxSound = new FlxSound();

    public function new()
    {
        super();

        frames = Paths.getSparrowAtlas('characters/Ourple');
        animation.addByPrefix("Idle", "Idle", 20);
        animation.addByPrefix("Up", "Up", 20);
        animation.addByPrefix("Down", "Down", 20);
        animation.addByPrefix("MaskOn", "MaskOn", 20);
        animation.addByPrefix("Stab", "Stab", 30, false);
        animation.addByPrefix("Grab", "Grab", 12, false);
        animation.play("Idle");
        scale.set(1.2, 1.2);
        updateHitbox();

        breathing.loadEmbedded(Paths.sound('deepbreaths'), true);
        breathing.volume = 0;
    }

    public function handleInput():Void
    {
        if (!lockedControls)
        {
            if (!maskOn)
            {
                if (animation.curAnim.name != 'Stab')
                {
                    velocity.set(0, 0);
                    var speed:Float = MOVE_SPEED;
            
                    isMoving = false;
            
                    if (PlayState.instance.controls.LEFT) {
                        velocity.x = -speed;
                        flipX = true;
                        isMoving = true;
                    } else if (PlayState.instance.controls.RIGHT) {
                        velocity.x = speed;
                        flipX = false;
                        isMoving = true;
                    }
            
                    if (PlayState.instance.controls.UP) {
                        velocity.y = -speed;
                        animation.play("Up");
                        isMoving = true;
                    } else if (PlayState.instance.controls.DOWN) {
                        velocity.y = speed;
                        animation.play("Down");
                        isMoving = true;
                    }
            
                    if (allowSprint && PlayState.instance.controls.SPRINT && isMoving && currentStamina > 0) {
                        velocity.x *= SPRINT_SPEED / MOVE_SPEED;
                        velocity.y *= SPRINT_SPEED / MOVE_SPEED;
                        currentStamina -= staminaDepleteRate * FlxG.elapsed;
                    }
            
                    if (velocity.y == 0 && !PlayState.instance.controls.STAB_P) {
                        animation.play("Idle");
                    } else if (PlayState.instance.tutorialControls != null && (velocity.x != 0 || velocity.y != 0)) {
                        PlayState.instance.tutorialControls.destroy();
                        PlayState.instance.tutorialControls = null;
                    }
        
                    if (PlayState.instance.controls.STAB_P) {
                        if (caseOhMode) {
                            confirmGrab();
                        } else {
                            performStab();
                        }
                    }
                }
            } else {
                if (PlayState.instance.controls.LEFT) {
                    flipX = true;
                } else if (PlayState.instance.controls.RIGHT) {
                    flipX = false;
                }
            }
        
            if (PlayState.instance.controls.MASK && !maskOn && animation.curAnim.name != "Stab") {
                toggleMaskOn();
            } else if (PlayState.instance.controls.MASK_R && maskOn && animation.curAnim.name != "Stab") {
                toggleMaskOn(false);
            }
        } else if (!velocity.isZero()) {
            velocity.zero();
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        handleInput();
        updateStamina(elapsed);
    }

    public function toggleMaskOn(on:Bool = true):Void
    {
        maskOn = on;
        if (on) {
            animation.play("MaskOn");
            breathing.play();
            breathing.fadeIn(1, 0, 0.7);
            FlxG.sound.play(Paths.sound('maskon'), 0.6);
            velocity.set(0, 0);
        } else {
            animation.play("Idle");
            breathing.stop();
            breathing.volume = 0;
            FlxG.sound.play(Paths.sound('maskoff'), 0.6);
        }
    }

    private function confirmGrab():Void
    {
        if (caseOhMode && PlayState.instance.cryingChildMode) 
        {
            for (child in PlayState.instance.currentRoom.childs) 
            {
                if (FlxMath.distanceBetween(this, child) < 110) 
                {
                    child.stunned = true;
                    child.changeFacingDirectionTimer.cancel();
                    child.trickTimer.cancel();
                    child.faceDirection(true);
                    performGrab();
                    break;
                }
            }
        }
    }

    public function performStab():Void
    {
        if (animation.curAnim.name != "Stab") 
        {
            animation.play("Stab");
            if (flipX) offset.x = 26.75;
            velocity.set(0, 0);
            maskOn = false;
            lockedControls = false;
            FlxG.sound.play(Paths.sound('stab'), 0.5);

            animation.finishCallback = animationCallback;
        }
    }

    public function performGrab():Void
    {
        if (animation.curAnim.name != "Grab")
        {
            var index:Int = PlayState.instance.members.indexOf(this);
            animation.play("Grab");
            velocity.set(0, 0);
            maskOn = false;
            lockedControls = true;
            FlxG.sound.play(Paths.sound('grab'), 0.75);
            PlayState.instance.remove(this, true);
            PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.currentRoom.onTopOfOurple) + 1, this);

            animation.callback = function(name:String, frame:Int, frameIndex:Int) {
                if (flipX) {
                    if (frame == 1) {
                        offset.x = 89;
                    } else if (frame == 38) {
                        PlayState.instance.remove(this, true);
                        PlayState.instance.insert(index, this);
                        offset.x = -7;
                    } 
                }
            };
            animation.finishCallback = animationCallback;
        }
    }

    private function animationCallback(name:String):Void
    {
        if (name == "Stab" || name == "Grab") 
        {
            animation.play("Idle");
            offset.x = -7;
            lockedControls = false;
            animation.finishCallback = null;
            animation.callback = null;
        }
    }

    public function updateStamina(elapsed:Float):Void
    {
        if (allowSprint) {
            if (!PlayState.instance.controls.SPRINT || velocity.isZero()) {
                currentStamina += staminaRegenRate * (maskOn ? 1.5 : 1) * elapsed;
            }
    
            currentStamina = Math.max(0, Math.min(currentStamina, MAX_STAMINA));
        }
    }
}