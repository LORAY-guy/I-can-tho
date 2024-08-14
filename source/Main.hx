package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;

#if linux
import lime.graphics.Image;
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if !mobile
import debug.FPSCounter;
#end

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: StaticState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;
	
	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null) {
            init();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
	}

    private function init(?e:Event):Void {
        if (hasEventListener(Event.ADDED_TO_STAGE)) {
            removeEventListener(Event.ADDED_TO_STAGE, init);
        }
        setupGame();
    }

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
	
		Controls.instance = new Controls();
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsVar = new FPSCounter();
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = UserPrefs.data.showFPS;
		}
		#end

		#if linux
		var icon = Image.fromFile("art/iconOG.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		FlxG.autoPause = false;
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;

		// shader coords fix
        FlxG.signals.gameResized.add(function(w, h) {
            if (FlxG.cameras != null) {
                for (cam in FlxG.cameras.list) {
                    if (cam != null && cam.filters != null) {
                        resetSpriteCache(cam.flashSprite);
                    }
                }
            }
            if (FlxG.game != null) {
                resetSpriteCache(FlxG.game);
            }

			fpsVar.y = Lib.application.window.height - 25;
        });
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
    #if CRASH_HANDLER
    function onCrash(e:UncaughtErrorEvent):Void {
        var errMsg:String = "";
        var path:String;
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
        var dateNow:String = Date.now().toString();

        dateNow = dateNow.replace(" ", "_").replace(":", "'");

        path = "./crash/" + "ICanTho_" + dateNow + ".txt";

        for (stackItem in callStack) {
            switch (stackItem) {
                case FilePos(s, file, line, column):
                    errMsg += file + " (line " + line + ")\n";
                default:
                    Sys.println(stackItem);
            }
        }

        errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/LORAY-guy/Lore-Origins or contact LORAY directly on Discord (loray_man) or on Twitter (https://x.com/@LORAY_man)\n\n> Crash Handler written by: sqirra-rng";

        if (!FileSystem.exists("./crash/")) {
            FileSystem.createDirectory("./crash/");
        }

        File.saveContent(path, errMsg + "\n");

        Sys.println(errMsg);
        Sys.println("Crash dump saved in " + Path.normalize(path));

        Application.current.window.alert(errMsg, "Error!");
        #if DISCORD_ALLOWED
        DiscordClient.shutdown();
        #end
        Sys.exit(1);
    }
    #end
}
