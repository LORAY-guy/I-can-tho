package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.input.gamepad.FlxGamepad;

/**
 * A virtual cursor that can be controlled using a gamepad
 * to simulate mouse movement in menu navigation
 */
class VirtualCursor extends FlxSprite
{
    // Configuration
    private static inline var CURSOR_SIZE:Int = 16;
    private static inline var BASE_SPEED:Float = 300;
    private static inline var ACCELERATION_FACTOR:Float = 2.5;
    private static inline var DEADZONE:Float = 0.2;
    private static inline var MAX_SPEED:Float = 800;
    
    // State tracking
    private var isLeftClick:Bool = false;
    private var wasLeftClick:Bool = false;
    private var moveSpeed:FlxPoint;
    
    public function new()
    {
        super();
        
        makeGraphic(CURSOR_SIZE, CURSOR_SIZE, FlxColor.TRANSPARENT);
        
        this.pixels.lock();
        for (i in 0...CURSOR_SIZE) {
            this.pixels.setPixel32(i, 0, FlxColor.WHITE);
            this.pixels.setPixel32(i, CURSOR_SIZE - 1, FlxColor.WHITE);
            this.pixels.setPixel32(0, i, FlxColor.WHITE);
            this.pixels.setPixel32(CURSOR_SIZE - 1, i, FlxColor.WHITE);
        }

        for (y in 1...CURSOR_SIZE - 1)
        {
            for (x in 1...CURSOR_SIZE - 1)
            {
                this.pixels.setPixel32(x, y, FlxColor.fromRGB(0, 255, 0, 180));
            }
        }
        this.pixels.unlock();
        
        moveSpeed = new FlxPoint();
        
        this.setPosition(FlxG.width / 2, FlxG.height / 2);
        
        if (PlayState.instance != null)
            this.cameras = [PlayState.instance.camPause];
        
        scrollFactor.set();
    }
    
    override public function update(elapsed:Float):Void
    {
        var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
        
        if (gamepad != null) {
            updateCursorPosition(gamepad, elapsed);
        } else {
            syncWithMousePosition();
        }
        
        this.x = FlxMath.bound(this.x, 0, FlxG.width - this.width);
        this.y = FlxMath.bound(this.y, 0, FlxG.height - this.height);
        
        FlxG.mouse.setGlobalScreenPositionUnsafe(Math.floor(this.x), Math.floor(this.y));
        
        super.update(elapsed);
    }
    
    private function updateCursorPosition(gamepad:FlxGamepad, elapsed:Float):Void
    {
        var leftX:Float = gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
        var leftY:Float = gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
        
        if (Math.abs(leftX) < DEADZONE) leftX = 0;
        if (Math.abs(leftY) < DEADZONE) leftY = 0;
        
        var moveFactorX:Float = 0;
        var moveFactorY:Float = 0;
        
        if (leftX != 0) {
            var absX:Float = Math.abs(leftX);
            moveFactorX = leftX * (BASE_SPEED + (MAX_SPEED - BASE_SPEED) * Math.pow(absX, ACCELERATION_FACTOR));
        }
        
        if (leftY != 0) {
            var absY:Float = Math.abs(leftY);
            moveFactorY = leftY * (BASE_SPEED + (MAX_SPEED - BASE_SPEED) * Math.pow(absY, ACCELERATION_FACTOR));
        }
        
        moveSpeed.set(moveFactorX, moveFactorY);
        this.x += moveSpeed.x * elapsed;
        this.y += moveSpeed.y * elapsed;
        
        if (gamepad.pressed.DPAD_LEFT)
            this.x -= BASE_SPEED * 0.5 * elapsed;
        if (gamepad.pressed.DPAD_RIGHT)
            this.x += BASE_SPEED * 0.5 * elapsed;
        if (gamepad.pressed.DPAD_UP)
            this.y -= BASE_SPEED * 0.5 * elapsed;
        if (gamepad.pressed.DPAD_DOWN)
            this.y += BASE_SPEED * 0.5 * elapsed;
    }
    
    private function syncWithMousePosition():Void
    {
        if (FlxG.mouse.justMoved)
            this.setPosition(FlxG.mouse.x, FlxG.mouse.y);
    }
}