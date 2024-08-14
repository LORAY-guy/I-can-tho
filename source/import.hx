#if !macro
//Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import backend.UserPrefs;
import backend.Paths;
import backend.Controls;
import backend.CoolUtil;

import objects.*;
import options.*;
import states.*;
import states.rooms.*;

//Flixel
import flixel.sound.FlxSound;
import flixel.addons.ui.FlxUIState;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.system.FlxAssets;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUISlider;
import flixel.sound.FlxSoundGroup;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.util.FlxCollision;

//OpenFL
import openfl.Lib;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.*;

using StringTools;
#end
