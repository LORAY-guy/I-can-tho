package objects;

class Key extends FlxSprite
{
    public function new(x:Float, y:Float):Void
    {
        super(x, y);
        loadGraphic(Paths.image('map/key'));
        scale.set(0.6, 0.6);
        updateHitbox();
    }

    override function update(elapsed:Float):Void
    {
        if (PlayState.instance.controls.INTERACT_P && FlxMath.distanceBetween(PlayState.instance.ourple, this) < 100) {
            PlayState.instance.ourple.hasKey = true;
            FlxG.sound.play(Paths.sound('collectKey'));
            destroy();
        }
    }

    override function destroy():Void
    {
        PlayState.instance.currentRoom.members.remove(this);
        super.destroy();
    }
}