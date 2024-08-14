package objects;

/**
 * ### Water Drop
 * Don't need to explain that one, I guess.
 */
class WaterDrop extends FlxSprite
{
    private var room:BaseRoom;
    private var updateDelay:FlxTimer;

    public function new(room:BaseRoom):Void
    {
        super();
        
        makeGraphic(18, 32, 0xFF23475F);
        setPosition(FlxG.random.float(0, FlxG.width - width), -height);

        this.room = room;

        updateDelay = new FlxTimer();
        updateDelay.start(0.1, function(timer:FlxTimer) {
            if (!PlayState.instance.paused) {
                this.y += 10;
                if (this.y > 575) {
                    destroy();
                }
            }
        }, 0);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (PlayState.instance.paused && updateDelay.active) updateDelay.cancel();
        if (!PlayState.instance.paused && !updateDelay.active) updateDelay.start();
    }

    override function destroy():Void
    {
        updateDelay.cancel();
        room.waterDrops.remove(this, true);
        super.destroy();
    }
}