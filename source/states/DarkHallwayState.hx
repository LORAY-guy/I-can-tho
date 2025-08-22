package states;

import flixel.addons.ui.FlxUIState;
import openfl.geom.Rectangle;

@:structInit class RaycastResult {
    public var wallDistance:Float;
    public var drawStart:Int;
    public var drawEnd:Int;
    public var side:Int;
}

/**
 * DARK HALLWAY STATE
 * 
 * The ending phase of the game REMASTERED.
 * Features a first-person perspective with raycasting rendering.
 */
class DarkHallwayState extends FlxUIState
{
    // ===========================================================
    // Constants and Configuration
    // ===========================================================
    
    // Colors
    private static inline var WALL_COLOR:FlxColor = 0xFF2B2B5F;
    private static inline var CEILING_COLOR:FlxColor = 0xFF101010;
    
    // Lighting settings
    private static inline var MAX_VISIBILITY:Float = 8.0;     // Maximum clear visibility distance
    private static inline var DARKNESS_FACTOR:Float = 0.6;    // Darkness falloff rate
    private static inline var AMBIENT_LIGHT:Float = 0.05;     // Minimum light level
    private static inline var HORIZON_DARKNESS:Float = 0.675; // Extra darkness at horizon
    
    // Movement
    private static inline var MOVE_SPEED:Float = 2;
    private static inline var ROTATION_SPEED:Float = 2;

    // Special floor image placement
    private static inline var SPECIAL_FLOOR_X:Float = 3.0;    // Center X position of special floor image
    private static inline var SPECIAL_FLOOR_Z:Float = 25.0;   // Center Z position of special floor image
    private static inline var SPECIAL_FLOOR_SIZE:Float = 7.0; // Size of the special floor area
    private static inline var SPECIAL_FLOOR_ASPECT_RATIO:Float = 3.3333333;

    // ===========================================================
    // Controls Access
    // ===========================================================
    
    public var controls(get, never):Controls;
    private function get_controls() return Controls.instance;
    
    // ===========================================================
    // Game Objects
    // ===========================================================
    
    private var renderSurface:FlxSprite;    // Main rendering surface
    private var floorTexture:FlxSprite;     // Floor tile texture
    private var vignetteSprite:FlxSprite;   // Vignette effect overlay
    private var specialFloorTexture:FlxSprite; // Special floor image
    
    // Player state
    private var playerPos:FlxPoint;         // Player position (x,y)
    private var playerDir:FlxPoint;         // Player direction vector
    private var cameraPlane:FlxPoint;       // Camera plane (for FOV)
    
    // Map data
    private var mapData:Array<Array<Int>>;

    // Lighting table (for precomputed lighting)
    private var lightingTable:Array<Float>;

    // Beginning Transition
    private var transBlock:FlxSprite;

    // Lure sound
    private var lureSound:FlxSound;

    // Game timer (for cutscene)
    private var timer:Float = 0.0;


    override public function new(timer:Float = 0.0):Void
    {
        super();

        this.timer = timer;
    }

    override public function create():Void
    {
        super.create();

        UserPrefs.loadPrefs();

        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        #if !mobile
        if (Main.fpsVar != null)
            Main.fpsVar.visible = false;
        #end

        // Bruteforce lower fps to give that old school vibe (and cuz the raycaster sucks ass and is laggy af)
        FlxG.drawFramerate = FlxG.updateFramerate = 10;

        loadMapData("assets/data/finale.map");

        initializeLightingTable();
        initializePlayer();
        initializeRendering();
        initializeSound();
        createEffects();
        
        FlxG.stage.window.mouseLock = true;
    }

    private function loadMapData(path:String):Void
    {
        var content:String = Paths.getTextFromFile(path);
        var lines:Array<String> = [];
        var row:Array<Int>;
        var values:Array<String>;
        mapData = [];

        lines = content.split("\n");
        for (line in lines) {
            line = StringTools.trim(line);
            if (line == "")
                continue;
            if (line.endsWith(","))
                line = line.substr(0, line.length - 1);

            row = [];
            values = line.split(",");
            for (value in values)
                row.push(Std.parseInt(StringTools.trim(value)));
            mapData.push(row);
        }
        trace('Successfully loaded map with dimensions: ${mapData[0].length}x${mapData.length}');
    }

    private function initializeLightingTable():Void
    {
        lightingTable = [];
        for (i in 0...FlxG.height) {
            var currentDist = FlxG.height / (2.0 * i - FlxG.height);
            var floorDarkness = Math.pow(currentDist / MAX_VISIBILITY, DARKNESS_FACTOR);
            lightingTable.push(AMBIENT_LIGHT + (1.0 - floorDarkness) * (1.0 - AMBIENT_LIGHT));
        }
    }

    private function initializePlayer():Void
    {
        playerPos = FlxPoint.get(3, 2);      // Starting position
        playerDir = FlxPoint.get(0, 1);
        cameraPlane = FlxPoint.get(1, 0);    // Camera plane (for FOV)
    }

    private function initializeRendering():Void
    {
        // Main render surface
        renderSurface = new FlxSprite();
        renderSurface.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        add(renderSurface);
        
        floorTexture = new FlxSprite();
        floorTexture.loadGraphic("assets/images/floorSmall.png", true);
        floorTexture.animation.add("tile", [0], 1, true);
        floorTexture.animation.play("tile");
        floorTexture.visible = false;
        add(floorTexture);
        
        specialFloorTexture = new FlxSprite();
        specialFloorTexture.loadGraphic("assets/images/map/papers.png", true);
        specialFloorTexture.visible = false;
        specialFloorTexture.flipX = true;
        add(specialFloorTexture);
    }

    private function createEffects():Void
    {
        // Scanlines
        var scanlineSprite = new FlxSprite().loadGraphic(Paths.image("scanline"));
        scanlineSprite.setGraphicSize(FlxG.width, FlxG.height);
        scanlineSprite.updateHitbox();
        scanlineSprite.screenCenter();
        scanlineSprite.antialiasing = false;
        add(scanlineSprite);

        // Beginning transition
        transBlock = new FlxSprite();
        transBlock.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, false);
        transBlock.updateHitbox();
        add(transBlock);

        new FlxTimer().start(1, function(tmr:FlxTimer) {
            var value:Float = (1.0 / tmr.loops);
            transBlock.alpha -= value;
            FlxG.sound.play(Paths.sound("insuit"), (value * tmr.elapsedLoops) * 0.5);
            if (transBlock.alpha <= 0.1) {
                lureSound.play();
                transBlock.destroy();
                transBlock = null;
            }
        }, 5);
    }

    private function initializeSound():Void
    {
        lureSound = new FlxSound();
        lureSound.loadEmbedded(Paths.music("crumblingDreams"), true, false);
    }

    // ===========================================================
    // UPDATE
    // ===========================================================

    private var chunckyDelay:Float = 0;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        handleInput(elapsed);
        manageLureDirection();
        renderScene();

        if (playerPos.x > 2 && playerPos.x < 4 && playerPos.y > 30) {
            FlxG.camera.alpha = 0;
            lureSound.stop();
            new FlxTimer().start(1, function(tmr:FlxTimer) {
                FlxG.switchState(new FinalCutsceneState(timer));
            }, 1);
        }
    }
    
    // ===========================================================
    // Input Handling
    // ===========================================================
    
    private function handleInput(elapsed:Float):Void
    {
        var moveX:Float = 0;
        var moveY:Float = 0;
        var rotate:Float = 0;
        
        // Movement
        if (controls.UP) {
            moveX += playerDir.x * MOVE_SPEED * elapsed;
            moveY += playerDir.y * MOVE_SPEED * elapsed;
        }
        if (controls.DOWN) {
            moveX -= playerDir.x * MOVE_SPEED * elapsed;
            moveY -= playerDir.y * MOVE_SPEED * elapsed;
        }
        
        // Rotation
        if (controls.LEFT || FlxG.gamepads.anyPressed(RIGHT_STICK_DIGITAL_LEFT)) rotate = ROTATION_SPEED * elapsed;
        if (controls.RIGHT || FlxG.gamepads.anyPressed(RIGHT_STICK_DIGITAL_RIGHT)) rotate = -ROTATION_SPEED * elapsed;
        
        // Apply movement if valid
        var newX = playerPos.x + moveX;
        var newY = playerPos.y + moveY;
        
        if (isPositionValid(newX, playerPos.y)) playerPos.x = newX;
        if (isPositionValid(playerPos.x, newY)) playerPos.y = newY;
        
        // Apply rotation
        if (rotate != 0) {
            rotatePlayer(rotate);
        }
    }
    
    private function isPositionValid(x:Float, y:Float):Bool
    {
        return mapData[Std.int(x)][Std.int(y)] == 0;
    }
    
    private function rotatePlayer(amount:Float):Void
    {
        var oldDirX = playerDir.x;
        var oldPlaneX = cameraPlane.x;
        
        // Rotate direction vector
        playerDir.x = playerDir.x * Math.cos(amount) - playerDir.y * Math.sin(amount);
        playerDir.y = oldDirX * Math.sin(amount) + playerDir.y * Math.cos(amount);
        
        // Rotate camera plane
        cameraPlane.x = cameraPlane.x * Math.cos(amount) - cameraPlane.y * Math.sin(amount);
        cameraPlane.y = oldPlaneX * Math.sin(amount) + cameraPlane.y * Math.cos(amount);
    }
    
    // ===========================================================
    // Rendering Methods
    // ===========================================================
    
    private function renderScene():Void
    {
        var ray:RaycastResult;

        renderSurface.pixels.fillRect(renderSurface.pixels.rect, FlxColor.TRANSPARENT);
        renderSurface.pixels.lock();
        for (x in 0...FlxG.width) {
            ray = castRay(x);
            renderWallColumn(x, ray);
            renderFloorColumn(x, ray.drawEnd);
        }
        renderSurface.pixels.unlock();
    }

    private function castRay(screenX:Int):RaycastResult
    {
        var cameraX = 2 * screenX / FlxG.width - 1; // X in camera space (-1 to 1)
        var rayDirX = playerDir.x + cameraPlane.x * cameraX;
        var rayDirY = playerDir.y + cameraPlane.y * cameraX;
        
        var mapX = Std.int(playerPos.x);
        var mapY = Std.int(playerPos.y);
        
        // Calculate ray step and initial side distances
        var stepX:Int;
        var stepY:Int;
        var sideDistX:Float;
        var sideDistY:Float;
        
        var deltaDistX = Math.abs(1 / rayDirX);
        var deltaDistY = Math.abs(1 / rayDirY);
        
        if (rayDirX < 0) {
            stepX = -1;
            sideDistX = (playerPos.x - mapX) * deltaDistX;
        } else {
            stepX = 1;
            sideDistX = (mapX + 1.0 - playerPos.x) * deltaDistX;
        }
        
        if (rayDirY < 0) {
            stepY = -1;
            sideDistY = (playerPos.y - mapY) * deltaDistY;
        } else {
            stepY = 1;
            sideDistY = (mapY + 1.0 - playerPos.y) * deltaDistY;
        }
        
        // Perform DDA (Digital Differential Analysis)
        var hit = false;
        var side = 0;
        
        while (!hit) {
            if (sideDistX < sideDistY) {
                sideDistX += deltaDistX;
                mapX += stepX;
                side = 0;
            } else {
                sideDistY += deltaDistY;
                mapY += stepY;
                side = 1;
            }
            
            if (mapData[mapX][mapY] > 0)
                hit = true;
        }
        
        // Calculate distance to wall
        var wallDistance = (side == 0) ? (mapX - playerPos.x + (1 - stepX) / 2) / rayDirX
            : (mapY - playerPos.y + (1 - stepY) / 2) / rayDirY;
        
        // Calculate wall line height
        var lineHeight = Std.int(FlxG.height / wallDistance);
        var drawStart = Std.int(-lineHeight / 2 + FlxG.height / 2);
        var drawEnd = Std.int(lineHeight / 2 + FlxG.height / 2);
        
        // Clamp values to screen bounds
        drawStart = Std.int(FlxMath.bound(drawStart, 0, FlxG.height));
        drawEnd = Std.int(FlxMath.bound(drawEnd, 0, FlxG.height - 1));
        
        return {
            wallDistance: wallDistance,
            drawStart: drawStart,
            drawEnd: drawEnd,
            side: side
        };
    }
    
    private function renderWallColumn(x:Int, ray:RaycastResult):Void
    {
        // Calculate lighting based on distance
        var distanceFactor = Math.min(ray.wallDistance / MAX_VISIBILITY, 1.0);
        var darkness = Math.pow(distanceFactor, DARKNESS_FACTOR);
        var lightLevel = AMBIENT_LIGHT + (1.0 - darkness) * (1.0 - AMBIENT_LIGHT);
        lightLevel = FlxMath.bound(lightLevel, AMBIENT_LIGHT, 1.0);
        
        // Darken y-sides (north/south walls)
        if (ray.side == 1) lightLevel *= 0.7;
        
        // Apply lighting to wall color
        var wallColor = FlxColor.fromRGB(
            Std.int(WALL_COLOR.red * lightLevel),
            Std.int(WALL_COLOR.green * lightLevel),
            Std.int(WALL_COLOR.blue * lightLevel)
        );
        
        // Draw ceiling with horizon darkness
        var ceilingLight = lightLevel * (1.0 - ((ray.drawStart / (FlxG.height / 2.0)) * HORIZON_DARKNESS));
        var ceilingColor = FlxColor.fromRGB(
            Std.int(CEILING_COLOR.red * ceilingLight),
            Std.int(CEILING_COLOR.green * ceilingLight),
            Std.int(CEILING_COLOR.blue * ceilingLight)
        );
        
        // Draw to render surface
        renderSurface.pixels.fillRect(new Rectangle(x, 0, 1, ray.drawStart), ceilingColor);
        renderSurface.pixels.fillRect(new Rectangle(x, ray.drawStart, 1, ray.drawEnd - ray.drawStart + 1), wallColor);
    }
    
    private function renderFloorColumn(x:Int, wallBottom:Int):Void
    {
        if (wallBottom >= FlxG.height - 1)
            return;
    
        var cameraX = 2 * x / FlxG.width - 1;
        var rayDirX = playerDir.x + cameraPlane.x * cameraX;
        var rayDirY = playerDir.y + cameraPlane.y * cameraX;
    
        var floorTextureWidth = floorTexture.pixels.width;
        var floorTextureHeight = floorTexture.pixels.height;
        var specialTextureWidth = specialFloorTexture.pixels.width;
        var specialTextureHeight = specialFloorTexture.pixels.height;
    
        for (y in (wallBottom + 1)...FlxG.height)
        {
            var currentDist:Float = FlxG.height / (2.0 * y - FlxG.height);
            var floorX:Float = playerPos.x + rayDirX * currentDist;
            var floorY:Float = playerPos.y + rayDirY * currentDist;
            
            var texX:Int = Std.int((floorX % 1.0) * floorTextureWidth);
            var texY:Int = Std.int((floorY % 1.0) * floorTextureHeight);
            var floorColor:FlxColor = floorTexture.pixels.getPixel(texX, texY);
            
            if (isInSpecialFloorArea(floorX, floorY)) {
                var specialTexX:Int = Std.int(mapSpecialFloorCoordX(floorX) * specialTextureWidth);
                var specialTexY:Int = Std.int(mapSpecialFloorCoordY(floorY) * specialTextureHeight);
                
                specialTexX = Std.int(FlxMath.bound(specialTexX, 0, specialTextureWidth - 1));
                specialTexY = Std.int(FlxMath.bound(specialTexY, 0, specialTextureHeight - 1));
                
                var specialPixel:Int = specialFloorTexture.pixels.getPixel32(specialTexX, specialTexY);
                
                if ((specialPixel >> 24) & 0xFF > 0)
                    floorColor = specialPixel & 0x00FFFFFF;
            }
    
            var floorLight:Float = lightingTable[y];
    
            var finalColor:FlxColor = FlxColor.fromRGB(
                Std.int(floorColor.red * floorLight),
                Std.int(floorColor.green * floorLight),
                Std.int(floorColor.blue * floorLight)
            );
    
            renderSurface.pixels.setPixel32(x, y, finalColor);
        }
    }
    
    private function isInSpecialFloorArea(worldX:Float, worldY:Float):Bool
    {
        var halfSizeX = SPECIAL_FLOOR_SIZE / 2;
        var halfSizeY = (SPECIAL_FLOOR_SIZE * SPECIAL_FLOOR_ASPECT_RATIO) / 2;
        
        var distanceX = Math.abs(worldX - SPECIAL_FLOOR_X);
        var distanceZ = Math.abs(worldY - SPECIAL_FLOOR_Z);
        
        return (distanceX <= halfSizeX && distanceZ <= halfSizeY);
    }
    
    private function mapSpecialFloorCoordX(worldX:Float):Float
    {
        var relativeX = worldX - (SPECIAL_FLOOR_X - SPECIAL_FLOOR_SIZE / 2);

        return relativeX / SPECIAL_FLOOR_SIZE;
    }
    
    private function mapSpecialFloorCoordY(worldY:Float):Float
    {
        var heightSize = SPECIAL_FLOOR_SIZE * SPECIAL_FLOOR_ASPECT_RATIO;
        var relativeY = worldY - (SPECIAL_FLOOR_Z - heightSize / 2);
        
        return relativeY / heightSize;
    }

    // ===========================================================
    // Lure
    // ===========================================================

    private function manageLureDirection():Void
    {
        if (lureSound != null && lureSound.playing) {
            var lurePos = FlxPoint.get(3, 32);

            var dirToLureX = lurePos.x - playerPos.x;
            var dirToLureY = lurePos.y - playerPos.y;
            var distanceToLure = Math.sqrt(dirToLureX * dirToLureX + dirToLureY * dirToLureY);
            
            if (distanceToLure > 0) {
                dirToLureX /= distanceToLure;
                dirToLureY /= distanceToLure;
            }

            var dotProductFront = playerDir.x * dirToLureX + playerDir.y * dirToLureY;
            var dotProductSide = cameraPlane.x * dirToLureX + cameraPlane.y * dirToLureY;

            var maxDistance = 40.0;
            var volumeFactor = Math.max(0, 1.0 - (distanceToLure / maxDistance));
            volumeFactor = Math.pow(volumeFactor, 1.25);

            var directionFactor = (dotProductFront + 1.0) / 2.0;
            directionFactor = 0.5 + (directionFactor * 0.5);

            var finalVolume = 0.7 * volumeFactor * directionFactor;

            var panning = FlxMath.bound(dotProductSide * 0.8, -0.8, 0.8);

            lureSound.volume = finalVolume;
            lureSound.pan = panning;
            lurePos.put();
        }
    }

    // ===========================================================
    // DESTROY
    // ===========================================================

    override public function destroy():Void
    {
        super.destroy();
        FlxG.stage.window.mouseLock = false;
    }
}
