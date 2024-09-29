package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables {
	public var unlockedEndless:Bool = false;
	public var endlessMode:Bool = false;
    public var framerate:Int = 60;
	public var showFPS:Bool = false;
	public var disableReset:Bool = true;
	public var showTimer:Bool = false;
	public var preCache:Bool = true;
	public var musicVolume:Float = 1;
	public var cacheOnGPU:Bool = true;
}

/**
 * ### UserPrefs
 * 
 * Manages controls and various game saves.
 * 
 * ~~stolen~~ *borrowed* from Psych Engine as well, sorry mate, your stuff is just way too useful to not use.
 */
class UserPrefs {
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'up'		    => [UP],
		'left'		    => [LEFT],
		'down'		    => [DOWN],
		'right'	        => [RIGHT],
        'interact'      => [SPACE],
        'mask'          => [CONTROL],
		'sprint'		=> [SHIFT],
		'stab'			=> [X],
		
		'accept'		=> [SPACE],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ESCAPE],
		'reset'			=> [R],
		
		'volume_mute'	=> [ZERO],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'up'		    => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'left'		    => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'down'		    => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'right'	        => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		'interact'      => [A],
        'mask'          => [LEFT_TRIGGER],
		'sprint'		=> [LEFT_STICK_CLICK],
		'stab'			=> [X],
		
		'accept'		=> [A, START],
		'back'			=> [B],
		'pause'			=> [START],
		'reset'			=> [BACK]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
	{
		if(controller != true)
			for (key in keyBinds.keys())
				if(defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());

		if(controller != false)
			for (button in gamepadBinds.keys())
				if(defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
	}

	public static function clearInvalidKeys(key:String)
	{
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
	}

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	public static function saveSettings(?showDance:Bool = true) {
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
	
		FlxG.save.flush();
	
		// Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	
		FlxG.updateFramerate = data.framerate;
		FlxG.drawFramerate = data.framerate;
	}

	public static function loadPrefs() {
		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		if(FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = (refreshRate > 30 ? Std.int(FlxMath.bound(refreshRate, 30, 240)) : 60);
		}

		if(data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls', CoolUtil.getSavePath());
		if(save != null)
		{
			if(save.data.keyboard != null)
			{
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls)
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
			}
			if(save.data.gamepad != null)
			{
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls)
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
			}
			reloadVolumeKeys();
		}
	}

	public static function reloadVolumeKeys()
	{
		muteKeys = keyBinds.get('volume_mute').copy();
		volumeDownKeys = keyBinds.get('volume_down').copy();
		volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}
	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		FlxG.sound.muteKeys = turnOn ? muteKeys : [];
		FlxG.sound.volumeDownKeys = turnOn ? volumeDownKeys : [];
		FlxG.sound.volumeUpKeys = turnOn ? volumeUpKeys : [];
	}
}