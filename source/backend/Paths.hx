package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;

import lime.utils.Assets;
import flash.media.Sound;

/**
 * ### Paths
 *
 * Manages assets and file locations.
 *
 * Again, ~~stolen~~ *borrowed* from Psych Engine and modified.
 */
class Paths {
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

    public static var localTrackedAssets:Array<String> = [];
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];

    public static function clearUnusedMemory() {
        for (key in currentTrackedAssets.keys()) {
            if (!localTrackedAssets.contains(key)) {
                var obj = currentTrackedAssets.get(key);
				@:privateAccess
                if (obj != null) {
                    FlxG.bitmap._cache.remove(key);
                    openfl.Assets.cache.removeBitmapData(key);
                    currentTrackedAssets.remove(key);
                    obj.persist = false;
                    obj.destroyOnNoUse = true;
                    obj.destroy();
                }
            }
        }
        System.gc();
    }

    public static function clearStoredMemory() {
		@:privateAccess
        for (key in FlxG.bitmap._cache.keys()) {
            var obj = FlxG.bitmap._cache.get(key);
            if (obj != null && !currentTrackedAssets.exists(key)) {
                openfl.Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                obj.destroy();
            }
        }

        for (key => asset in currentTrackedSounds) {
            if (!localTrackedAssets.contains(key) && asset != null) {
                Assets.cache.clear(key);
                currentTrackedSounds.remove(key);
            }
        }
        localTrackedAssets = [];
    }

    public static function getPath(file:String, ?type:AssetType = TEXT):String {
        var newFile:String = 'assets/' + file;
        if (OpenFlAssets.exists(newFile, type)) return newFile;
        return null;
    }

    inline static public function txt(key:String) {
        return getPath('${key}.txt', TEXT);
    }

    inline static public function xml(key:String) {
        return getPath('${key}.xml', TEXT);
    }

    inline static public function json(key:String) {
        return getPath('${key}.json', TEXT);
    }

    static public function sound(key:String):Sound {
        return returnSound('sounds', key);
    }

    inline static public function soundRandom(key:String, min:Int, max:Int) {
        return sound(key + FlxG.random.int(min, max));
    }

    inline static public function music(key:String):Sound {
        return returnSound('music', key);
    }

    static public function image(key:String = null, ?allowGPU:Bool = true):FlxGraphic {
        var bitmap:BitmapData = null;
        var file:String = getPath('images/${key}.png', IMAGE);

        if (currentTrackedAssets.exists(file)) {
            localTrackedAssets.push(file);
            return currentTrackedAssets.get(file);
        } else if (OpenFlAssets.exists(file, IMAGE)) {
            bitmap = OpenFlAssets.getBitmapData(file);
            if (bitmap != null) {
                var retVal = cacheBitmap(file, bitmap, allowGPU);
                if (retVal != null) return retVal;
            }
        }
        return null;
    }

    inline static public function imageRandom(key:String, min:Int, max:Int) {
        return image(key + FlxG.random.int(min, max));
    }

    static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true):FlxGraphic {
        if (bitmap == null) {
            if (OpenFlAssets.exists(file, IMAGE))
                bitmap = OpenFlAssets.getBitmapData(file);

            if (bitmap == null) return null;
        }

        localTrackedAssets.push(file);
        var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
        newGraphic.destroyOnNoUse = false;
        currentTrackedAssets.set(file, newGraphic);
        return newGraphic;
    }

    static public function getTextFromFile(key:String):String {
        #if sys
        if (FileSystem.exists(getPath(key)))
            return File.getContent(getPath(key));
        #end
        if (OpenFlAssets.exists(key, TEXT)) return Assets.getText(key);
        return null;
    }

    inline static public function font(key:String) {
        return 'assets/fonts/${key}';
    }

    public static function fileExists(key:String, type:AssetType):Bool {
        return OpenFlAssets.exists(getPath(key, type));
    }

    inline static public function getSparrowAtlas(key:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
        var imageLoaded:FlxGraphic = image(key, allowGPU);
        return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/${key}.xml'));
    }

    public static function returnSound(path:Null<String>, key:String) {
        var gottenPath:String = '${key}.${SOUND_EXT}';
        if (path != null) gottenPath = '${path}/${gottenPath}';
        gottenPath = getPath(gottenPath, SOUND);
        if (!currentTrackedSounds.exists(gottenPath)) {
            var retKey:String = (path != null) ? '${path}/${key}' : key;
            retKey = getPath('${retKey}.${SOUND_EXT}', SOUND);
            if (OpenFlAssets.exists(retKey, SOUND)) {
                currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(retKey));
            }
        }
        localTrackedAssets.push(gottenPath);
        return currentTrackedSounds.get(gottenPath);
    }

    public static function listSoundsInSubfolder(subfolder:String):Array<String> {
        var path:String = 'assets/sounds/' + subfolder;
        var soundFiles:Array<String> = [];
    
        // Listing files in the directory
        #if sys
        if (FileSystem.exists(path)) {
            for (file in FileSystem.readDirectory(path)) {
                if (file.endsWith('.' + SOUND_EXT)) {
                    soundFiles.push(subfolder + '/' + file);
                }
            }
        } else {
            trace('Subfolder $subfolder not found.');
        }
        #end
    
        return soundFiles;
    }

    public static function playRandomSoundFromSubfolder(subfolder:String):Void {
        var soundFiles:Array<String> = listSoundsInSubfolder(subfolder);
    
        if (soundFiles.length > 0) {
            var randomIndex:Int = FlxG.random.int(0, soundFiles.length - 1);
            var randomSoundPath:String = soundFiles[randomIndex];
            var sound:Sound = Paths.sound(randomSoundPath);
            FlxG.sound.play(sound);
        } else {
            trace('No sound files found in subfolder: $subfolder');
        }
    }

    public static function cacheAllAssets():Void {
        cacheAssetsInDirectory('assets/images', 'png', 'image');
        cacheAssetsInDirectory('assets/music', SOUND_EXT, 'music');
        cacheAssetsInDirectory('assets/sounds', SOUND_EXT, 'sound');
    }

    public static function cacheAssetsInDirectory(path:String, extension:String, type:String):Void {
        var files:Array<String> = FileSystem.readDirectory(path);
        for (file in files)
        {
            var fullPath:String = path + '/' + file;
            if (FileSystem.isDirectory(fullPath)) {
                cacheAssetsInDirectory(fullPath, extension, type);
            } else if (file.endsWith('.' + extension)) {
                var key:String = fullPath.split('/').slice(2).join('/').split('.').shift();
                switch (type.toLowerCase()) {
                    case 'image':
                        image(key);
                    case 'sound':
                        sound(key);
                    case 'music':
                        music(key);
                }
            }
        }
    }
}