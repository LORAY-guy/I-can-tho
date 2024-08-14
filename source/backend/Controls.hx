package backend;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

/**
 * ### Controls
 * 
 * Manages inputs.
 *
 * Definitly not stolen from Psych Engine.
 */
class Controls
{
	public var UP_P(get, never):Bool;
	public var DOWN_P(get, never):Bool;
	public var LEFT_P(get, never):Bool;
	public var RIGHT_P(get, never):Bool;
	public var INTERACT_P(get, never):Bool;
    public var MASK_P(get, never):Bool;
	public var SPRINT_P(get, never):Bool;
	public var STAB_P(get, never):Bool;

	private function get_UP_P() return justPressed('up');
	private function get_DOWN_P() return justPressed('down');
	private function get_LEFT_P() return justPressed('left');
	private function get_RIGHT_P() return justPressed('right');
    private function get_INTERACT_P() return justPressed('interact');
	private function get_MASK_P() return justPressed('mask');
	private function get_SPRINT_P() return justPressed('sprint');
	private function get_STAB_P() return justPressed('stab');

	// Held buttons (directions)
	public var UP(get, never):Bool;
	public var DOWN(get, never):Bool;
	public var LEFT(get, never):Bool;
	public var RIGHT(get, never):Bool;
    public var INTERACT(get, never):Bool;
    public var MASK(get, never):Bool;
	public var SPRINT(get, never):Bool;
	public var STAB(get, never):Bool;
	private function get_UP() return pressed('up');
	private function get_DOWN() return pressed('down');
	private function get_LEFT() return pressed('left');
	private function get_RIGHT() return pressed('right');
    private function get_INTERACT() return pressed('interact');
	private function get_MASK() return pressed('mask');
	private function get_SPRINT() return pressed('sprint');
	private function get_STAB() return pressed('stab');

	// Released buttons (directions)
	public var UP_R(get, never):Bool;
	public var DOWN_R(get, never):Bool;
	public var LEFT_R(get, never):Bool;
	public var RIGHT_R(get, never):Bool;
    public var INTERACT_R(get, never):Bool;
    public var MASK_R(get, never):Bool;
	public var SPRINT_R(get, never):Bool;
	public var STAB_R(get, never):Bool;
	private function get_UP_R() return justReleased('up');
	private function get_DOWN_R() return justReleased('down');
	private function get_LEFT_R() return justReleased('left');
	private function get_RIGHT_R() return justReleased('right');
    private function get_INTERACT_R() return justReleased('interact');
	private function get_MASK_R() return justReleased('mask');
	private function get_SPRINT_R() return justReleased('sprint');
	private function get_STAB_R() return justReleased('stab');


	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	private function get_ACCEPT() return justPressed('accept');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_RESET() return justPressed('reset');

	//Gamepad & Keyboard stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;
	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true;
	}

	public var controllerMode:Bool = false;
	private function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	// IGNORE THESE
	public static var instance:Controls;
	public function new()
	{
		keyboardBinds = UserPrefs.keyBinds;
		gamepadBinds = UserPrefs.gamepadBinds;
	}
}