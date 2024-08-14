package objects;

/**
 * ### Exit
 * Exit area of a room.
 * 
 * @param destination       The room the exit should lead the player to in `String`.
 * @param x                 X position of the exit area.
 * @param y                 Y position of the exit area.
 * @param width             Width of the exit area.
 * @param height            Height of the exit area.
 * @param nextOurplePos     New position of the player in the destination room as a `FlxPoint`.
 * @param locked            (Optional) If the access to the room should be locked.
 */
class Exit extends FlxSprite
{
    public var destination:String;
    public var nextOurplePos:FlxPoint;
    public var locked:Bool;
    public var requirementFunction:Void->Bool = null;
    public var callback:Void->Void = null;

    var err:FlxSprite;
    var errTimer:FlxTimer;
    var errAdded:Bool = false;

    public function new(destination:String, x:Float, y:Float, width:Int, height:Int, nextOurplePos:FlxPoint, ?locked:Bool = false, ?requirementFunction:Void->Bool = null)
    {
        super(x, y);
        makeGraphic(width, height, #if debug 0xFF00FF00 #else 0x0000FF00 #end);

        this.destination = destination;
        this.nextOurplePos = nextOurplePos;
        this.locked = locked;
        this.requirementFunction = requirementFunction;

        err = new FlxSprite().loadGraphic(Paths.image('err'));
        err.setPosition(10, FlxG.height - err.height - 10);

        errTimer = new FlxTimer();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (PlayState.instance.ourple.overlaps(this))
        {
            if (!locked && (requirementFunction == null || requirementFunction())) {
                if (callback != null) callback();
                PlayState.instance.onExitRoom();
                if (errAdded) {
                    PlayState.instance.remove(err, true);
                    errAdded = false;
                }
                if (err != null) err.destroy();
                if (errTimer != null) errTimer.destroy();
                PlayState.instance.loadRoom(destination, nextOurplePos.x, nextOurplePos.y);
            } else {
                if (width > 2) {
                    if (y > height) {
                        PlayState.instance.ourple.y -= 10;
                    } else {
                        PlayState.instance.ourple.y += 10;
                    }
                } else if (height > 2) {
                    if (x > width) {
                        PlayState.instance.ourple.x -= 10;
                    } else {
                        PlayState.instance.ourple.x += 10;
                    }
                }

                if (!errAdded) {
                    err.cameras = [PlayState.instance.camHUD];
                    PlayState.instance.add(err);
                    errAdded = true;
                }

                errTimer.cancel();
                errTimer.start(4, function(tmr:FlxTimer) {
                    if (errAdded) {
                        PlayState.instance.remove(err, true);
                        errAdded = false;
                    }
                });
            }
        }

        #if debug
        makeGraphic(Std.int(this.width), Std.int(this.height), (locked ? 0xFFFF0000 : 0xFF00FF00));
        #end
    }

    override public function destroy():Void
    {
        if (err != null) err.destroy();
        if (errTimer != null) errTimer.destroy();
        super.destroy();
    }
}