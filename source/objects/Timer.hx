package objects;

class Timer extends FlxText
{
    private var elapsedTime:Float = 0;
    private var timeStop:Bool = false;

    public function new(x:Float, y:Float, font:String, size:Int, color:Int)
    {
        super(x, y, 0, "00:00.00");
        setFormat(font, size, color, CENTER);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!timeStop)
        {
            elapsedTime += elapsed;
            text = CoolUtil.elapsedToDisplay(elapsedTime);
        }
    }

    public function stopTimer():Bool
    {
        timeStop = true;
        color = FlxColor.BLUE;
        return timeStop;
    }

    public function resetTimer():Int // Just in case...
    {
        elapsedTime = 0;
        text = "00:00.00";
        return 0;
    }

    inline public function getTimeElapsed():Float return elapsedTime;
}