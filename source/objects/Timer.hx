package objects;

class Timer extends FlxText
{
    private var elapsedTime:Float = 0;

    public function new(x:Float, y:Float, font:String, size:Int, color:Int)
    {
        super(x, y, 0, "00:00.00");
        setFormat(font, size, color, CENTER);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        elapsedTime += elapsed;
        var hours:Int = Math.floor(elapsedTime / 3600);
        var minutes:Int = Math.floor(elapsedTime / 60);
        var seconds:Int = Math.floor(elapsedTime % 60);
        var milliseconds:Int = Math.floor((elapsedTime % 1) * 100);
        text = (hours >= 1 ? StringTools.lpad(Std.string(hours), "0", 2) + ":" : "") +
               StringTools.lpad(Std.string(minutes), "0", 2) + ":" +
               StringTools.lpad(Std.string(seconds), "0", 2) + "." +
               StringTools.lpad(Std.string(milliseconds), "0", 2);
    }

    public function resetTimer():Void // Just in case...
    {
        elapsedTime = 0;
        text = "00:00.00";
    }

    inline public function getTimeElapsed():Float return elapsedTime;
}