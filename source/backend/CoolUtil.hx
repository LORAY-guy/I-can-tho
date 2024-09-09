package backend;

/**
 * ### CoolUtil
 *
 * Some very cool utils for sure.
 */
class CoolUtil 
{
	public static var tutorialMode:Bool = true;
	public static var deathCounter:Int = 0;

    @:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	inline public static function radiansToDegrees(radians:Float):Float
	{
		return radians * (180 / Math.PI);
	}
	
	inline public static function wrapAngle(degrees:Float):Float
	{
		var wrapped:Float = degrees % 360;
		if (wrapped < 0) wrapped += 360;
		return wrapped;
	}

	inline public static function handlePropCollision(obj:FlxSprite):Void
	{
		for (wall in PlayState.instance.currentRoom.walls)
		{
			if (FlxCollision.pixelPerfectCheck(obj, wall))
			{
				var overlapX:Float = (obj.width + wall.width) / 2 - Math.abs(obj.x + obj.width / 2 - wall.x - wall.width / 2);
				var overlapY:Float = (obj.height + wall.height) / 2 - Math.abs(obj.y + obj.height / 2 - wall.y - wall.height / 2);

				if (overlapX < overlapY)
				{
					if (obj.x < wall.x)
						obj.x -= overlapX;
					else
						obj.x += overlapX;
				}
				else
				{
					if (obj.y < wall.y)
						obj.y -= overlapY;
					else
						obj.y += overlapY;
				}
			}
		}

		for (prop in PlayState.instance.currentRoom.props)
		{
			if (FlxCollision.pixelPerfectCheck(obj, prop))
			{
				var overlapX:Float = (obj.width + prop.width) / 2 - Math.abs(obj.x + obj.width / 2 - prop.x - prop.width / 2);
				var overlapY:Float = (obj.height + prop.height) / 2 - Math.abs(obj.y + obj.height / 2 - prop.y - prop.height / 2);

				if (overlapX < overlapY)
				{
					if (obj.x < prop.x)
						obj.x -= overlapX;
					else
						obj.x += overlapX;
				}
				else
				{
					if (obj.y < prop.y)
						obj.y -= overlapY;
					else
						obj.y += overlapY;
				}
			}
		}
	}

	inline public static function collidesWithProps(animatronic:Animatronic):Bool
	{
		for (prop in PlayState.instance.currentRoom.props) {
			if (FlxCollision.pixelPerfectCheck(animatronic, prop)) {
				return true;
			}
		}
		return false;
	}
	
	inline public static function collidesWithWalls(animatronic:Animatronic):Bool
	{
		for (wall in PlayState.instance.currentRoom.walls) {
			if (FlxCollision.pixelPerfectCheck(animatronic, wall)) {
				return true;
			}
		}
		return false;
	}

	public static function elapsedToDisplay(elapsedTime:Float):String
	{
		var hours:Int = Math.floor(elapsedTime / 3600);
		var minutes:Int = Math.floor(elapsedTime / 60) - (60 * hours);
		var seconds:Int = Math.floor(elapsedTime % 60);
		var milliseconds:Int = Math.floor((elapsedTime % 1) * 100);
		return (hours >= 1 ? StringTools.lpad(Std.string(hours), "0", 2) + ":" : "") +
				StringTools.lpad(Std.string(minutes), "0", 2) + ":" +
				StringTools.lpad(Std.string(seconds), "0", 2) +
				(hours < 1 ? "." + StringTools.lpad(Std.string(milliseconds), "0", 2) : "");
	}

	public static function exitGame():Void
	{
		#if windows
		Sys.exit(0);
		#elseif html5
		js.Browser.window.close();
		#elseif linux
		Sys.command("pkill Lore Origins");
		#elseif mac
		Sys.command("pkill -f Lore Origins");
		#end
	}
}