package objects;

/**
 * ### Mouse
 * Creates a mouse to make rooms feel more... alive...
 * Technically, my first character "IA".
 */
class Mouse extends FlxSprite
{
    private var direction:Int = 0;
    private var changeDirectionTimer:FlxTimer;
    private var updateDelay:FlxTimer;

    public function new() 
    {
        super(Math.floor(FlxG.random.int(400, 750) / 10) * 10, Math.floor(FlxG.random.int(235, 605) / 35) * 35);

        constrainToBounds();
        CoolUtil.handlePropCollision(this);

        loadGraphic(Paths.image('mouse'));
        flipX = FlxG.random.bool();

        changeDirectionTimer = new FlxTimer();
        changeDirectionTimer.start(FlxG.random.float(0.75, 3), changeDirection);

        updateDelay = new FlxTimer();
        updateDelay.start(0.03, mouseUpdate, 0);
    }

    private function mouseUpdate(timer:FlxTimer):Void
    {
        if (!PlayState.instance.paused)
        {
            if (direction - this.x <= 10 && direction - this.x >= -10) return;

            if (direction - this.x > 0) {
                this.x += 10;
                flipX = false;
            } else if (direction - this.x < 0) {
                this.x -= 10;
                flipX = true;
            }
    
            constrainToBounds();
        }
    }

    private function constrainToBounds():Void
    {
        if (x < 0) x = 0;
        if (x > FlxG.width - width) x = FlxG.width - width;

        for (wall in PlayState.instance.currentRoom.walls) {
            FlxG.collide(this, wall);
        }
    }

    private function changeDirection(timer:FlxTimer):Void
    {
        direction = Math.floor(FlxG.random.int(100, 1040) / 10) * 10;
        changeDirectionTimer.start(FlxG.random.float(0.75, 3), changeDirection);
    }
}