package states;

import flixel.input.gamepad.FlxGamepad;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;

class LorayState extends FlxSubState
{
    /**
        @param App_Name String
        @param Scale Float
        @param X_Offset Int/Float
        @param Link String
    **/
    public static var appCats:Array<Array<Dynamic>> = [
        ['Youtube', 0.45,  0,    'https://youtube.com/@LORAY_'],
        ['Twitter', 0.45,  45,   'https://twitter.com/LORAY_man'],
        ['Discord', 0.45,  0,    'https://discordapp.com/users/507896425024192512'],
        ['Paypal',  0.16,  0,    'https://paypal.me/LORAYman'],
    ];

    public var controls(get, never):Controls;
    private function get_controls() return Controls.instance;

    var menuItems:FlxTypedGroup<FlxSprite>;
    var lorays:FlxTypedGroup<Loray>;
    var danceTimer:FlxTimer;
    var camFollow:FlxObject;
    
    // Animated background
    var animatedBackdrop:AnimatedBackdrop;

    public var appName:FlxText;
    private var bg:FlxBackdrop;

	public static var curSelected:Int = 0;

    private var canClick:Bool = true;
    private var usingMouse:Bool = false;
    private var quitting:Bool = false;
    
    override public function create():Void
    {        
        Paths.clearUnusedMemory();

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
        
        // Create animated backdrop
        animatedBackdrop = new AnimatedBackdrop(FlxG.width, FlxG.height);
        add(animatedBackdrop);
        
        menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

        lorays = new FlxTypedGroup<Loray>();
		add(lorays);

        var lettabox:FlxBackdrop = new FlxBackdrop(Paths.image('credits/lettabox'), X, 0, 0);
        lettabox.scrollFactor.set(0, 0);
        lettabox.velocity.set(20, 0);
        add(lettabox);

        var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('credits/lettabox'), X, 0, 0);
        lettabox2.y = FlxG.height - lettabox2.height;
        lettabox2.scrollFactor.set(0, 0);
        lettabox2.velocity.set(-20, 0);
        lettabox2.flipY = true;
        add(lettabox2);
        
		for (i in 0...appCats.length)
        {
            var offset:Float = (Math.max(appCats.length, 4) - 4) * 75;
            var appItem:FlxSprite = new FlxSprite((i * 410 - (i * 5)) + offset, 120);
            var scaleItem:Float = appCats[i][1];
            appItem.x += 80 + appCats[i][2];
            appItem.frames = Paths.getSparrowAtlas('credits/loray_' + appCats[i][0].toLowerCase());
			appItem.animation.addByPrefix('idle', appCats[i][0].toLowerCase(), 24);
			appItem.animation.play('idle');
            appItem.scale.set(scaleItem, scaleItem);
            appItem.updateHitbox();
			appItem.ID = i;
			menuItems.add(appItem);
			appItem.scrollFactor.set(1, 0);
        }

        lorays.add(new Loray(180));
        lorays.add(new Loray(935));

        var bpm:Int = 64;
        var crochet:Float = (60 / bpm);

        danceTimer = new FlxTimer().start(crochet, function(tmr: FlxTimer) {
            lorays.forEachAlive(function(spr:Loray) {
                spr.dance();
            });
        }, 0);

        appName = new FlxText(20, (FlxG.height / 2) + 220, 0, appCats[curSelected][0].toLowerCase());
        appName.setFormat(Paths.font('fnaf3.ttf'), 32, FlxColor.WHITE, CENTER, 0xFF000000);
		appName.screenCenter(X);
        appName.scrollFactor.set();
		add(appName);

        changeSelection(0, false, false);

        super.create();

        // Why does it fucking select the element when you enter the state more than once?
        if (controls.controllerMode && canClick) {
            canClick = false;
            new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                canClick = true;
            }, 1);
        }

        FlxG.camera.follow(camFollow, null, 9);
        camFollow.x = menuItems.members[curSelected].getGraphicMidpoint().x;

        if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
    }

    var cameraTargetX:Float = FlxG.camera.scroll.x;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (animatedBackdrop != null)
            animatedBackdrop.updateScroll(elapsed);
        
        if (controls.UP_P || controls.DOWN_P)
            usingMouse = false;
        else if (FlxG.mouse.visible && (FlxG.mouse.overlaps(menuItems) || FlxG.mouse.overlaps(lorays)))
            usingMouse = true;

        menuItems.forEachAlive(function(spr:FlxSprite) {
            if (usingMouse && FlxG.mouse.overlaps(spr) && curSelected != spr.ID)
                changeSelection(spr.ID, true);
        });

        if (controls.LEFT_P)
            changeSelection(-1);
        if (controls.RIGHT_P)
            changeSelection(1);

        if (usingMouse && FlxG.mouse.wheel != 0) changeSelection(-FlxG.mouse.wheel);

        if (canClick && !quitting) {
            if (controls.ACCEPT || FlxG.keys.justPressed.ENTER || (usingMouse && FlxG.mouse.justPressed && (FlxG.mouse.overlaps(menuItems)))) {
                canClick = false;
                lorays.forEachAlive(function(spr:Loray) {spr.beHappy();});
                FlxG.camera.zoom += 0.06;
                FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker) {
                    CoolUtil.browserLoad(appCats[curSelected][3]);
                    canClick = true;
                });
            } else if (controls.BACK) {
                canClick = false;
                quitting = true;
                close();
            }
    
            lorays.forEachAlive(function(spr:Loray) {
                if (usingMouse && FlxG.mouse.overlaps(spr) && FlxG.mouse.justPressed) 
                    spr.beHappy();
            });
        }

        if (FlxG.gamepads.firstActive != null) {
            if (FlxG.gamepads.firstActive.anyJustPressed([FlxGamepadInputID.LEFT_TRIGGER]))
                lorays.members[0].beHappy();
            if (FlxG.gamepads.firstActive.anyJustPressed([FlxGamepadInputID.RIGHT_TRIGGER]))
                lorays.members[1].beHappy();
        }

        if (controls.controllerMode)
            controls.controllerMode = !(FlxG.mouse.justPressed || FlxG.mouse.justReleased || FlxG.mouse.justMoved);
        FlxG.mouse.visible = !controls.controllerMode || FlxG.mouse.justMoved;

        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
        camFollow.x = FlxMath.lerp(cameraTargetX, camFollow.x, Math.exp(-elapsed * 6.25));
    }

    private function changeSelection(change:Int = 0, ?goTo:Bool = false, ?playSound:Bool = true)
    {
        FlxG.camera.zoom += 0.03;
        if (!goTo) curSelected += change; else curSelected = change;
        if (playSound) FlxG.sound.play(Paths.sound('run'), 0.5) #if FLX_PITCH .pitch = FlxG.random.float(0.9, 1.1) #end ;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected) {
                spr.scale.set(appCats[curSelected][1] * 1.2, appCats[curSelected][1] * 1.2);
			} else {
                spr.scale.set(appCats[spr.ID][1], appCats[spr.ID][1]);
            }
            spr.centerOffsets();
            spr.updateHitbox();
        });

        appName.text = appCats[curSelected][0];
        cameraTargetX = menuItems.members[curSelected].getGraphicMidpoint().x;
    }

    override public function close():Void
    {
        if (danceTimer != null) {
            danceTimer.cancel();
            danceTimer = null;
        }

        FlxTimer.globalManager.clear();

        if (animatedBackdrop != null) {
            animatedBackdrop.destroy();
            animatedBackdrop = null;
        }
        
        lorays.forEachAlive(function(loray:Loray) {
            FlxTween.cancelTweensOf(loray);
            loray.destroy();
            loray = null;
            lorays.remove(loray);
        });
        
        Loray.lorays = [];

        FlxG.camera.follow(null);
        
        super.close();
    }
}

class Loray extends FlxSprite
{
    public static var lorays:Array<Loray> = [];

    public var happy:Bool = false;
    public var originX:Float = 0;
    public var originY:Float = 460;

    private var happyTimer:FlxTimer;

    public function new(x:Float = 0)
    {
        super(x, originY);
        
        frames = Paths.getSparrowAtlas('credits/OURPLE_LORAAAAAAAAAAY');
        animation.addByPrefix('idle', 'Idle', 24, false, false, false);
        animation.addByPrefix('happy', 'Up', 24, false, false, false);
        animation.play('idle', false, false, 0);
        scale.x = 3;
        scale.y = 3;
        ID = lorays.length;
        flipX = (ID % 2 == 0) ? true : false;
        scrollFactor.set();
        lorays.push(this);

        this.originX = x;
    }

    public function beHappy() 
    {
        happy = true;
        FlxG.camera.zoom += 0.06;
        FlxG.sound.play(Paths.soundRandom('credits/ourple', 1, 10), 0.4);
        FlxTween.cancelTweensOf(this, ['y']);
        animation.play('happy', true, false, 0);
        x = originX - 45;
        y = 380;
        flipX = (ID % 2 == 0) ? false : true;
        
        if (happyTimer != null)
            happyTimer.cancel();
        
        happyTimer = new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            happy = false;
            x = originX;
            y = originY;
            flipX = (ID % 2 == 0) ? false : true;
            dance();
        });
    }

    public function dance()
    {
        if (!happy)
        {
            animation.play('idle', true, false, 0);
            y = (y + 20);
            flipX = !flipX;
            FlxTween.tween(this, {y: originY}, 0.15, {ease: FlxEase.cubeOut});
        }
    }

    override function destroy():Void
    {
        if (happyTimer != null) {
            happyTimer.cancel();
            happyTimer = null;
        }

        FlxTween.cancelTweensOf(this);

        var index = lorays.indexOf(this);
        if (index != -1) {
            lorays.splice(index, 1);
        }

        super.destroy();
    }
}

class AnimatedBackdrop extends FlxTypedGroup<FlxSprite>
{
    public static inline var TILE_WIDTH:Int = 96;
    public static inline var TILE_HEIGHT:Int = 108;
    
    private var columns:Int;
    private var rows:Int;
    
    private var blueFrames:Array<String>;
    private var redFrames:Array<String>;
    private var frameCount:Int;
    
    private var animTimer:FlxTimer;
    private var currentFrame:Int = 0;
    
    private var tileColors:Array<Bool> = [];
    
    public function new(width:Float, height:Float)
    {
        super();
        
        columns = Math.ceil(width / TILE_WIDTH) + 1;
        rows = Math.ceil(height / TILE_HEIGHT) + 1;
        
        blueFrames = [];
        redFrames = [];
        
        for (i in 1...13) {
            blueFrames.push('credits/frames/b${i}');
            redFrames.push('credits/frames/r${i}');
        }
        frameCount = blueFrames.length;
        
        createTileGrid();
        modifyTiles();
        
        animTimer = new FlxTimer().start(0.075, function(tmr:FlxTimer) {
            currentFrame = (currentFrame + 1) % frameCount;
            if (currentFrame == 0)
                modifyTiles();
            updateTileFrames();
        }, 0);
    }
    
    private function createTileGrid():Void
    {
        for (row in 0...rows) {
            for (col in 0...columns) {
                var x:Float = col * TILE_WIDTH;
                var y:Float = row * TILE_HEIGHT;

                var isBlue:Bool = FlxG.random.bool(50);
                tileColors.push(isBlue);

                var tile:FlxSprite = new FlxSprite(x, y);
                tile.loadGraphic(Paths.image(isBlue ? blueFrames[0] : redFrames[0]));
                tile.scrollFactor.set(0, 0);
                tile.velocity.set(-20, 10);
                add(tile);
            }
        }
    }
    
    private function modifyTiles():Void
    {
        forEachAlive(function(tile:FlxSprite) {
            tile.alpha = FlxG.random.float(0.2, 1);
            tileColors[this.members.indexOf(tile)] = FlxG.random.bool(50);
        });
    }

    private function updateTileFrames():Void
    {
        var i:Int = 0;

        forEachAlive(function(tile:FlxSprite) {
            var isBlue:Bool = tileColors[i];
            var framePath:String = isBlue ? blueFrames[currentFrame] : redFrames[currentFrame];
            tile.loadGraphic(Paths.image(framePath));
            i++;
        });
    }
    
    public function updateScroll(elapsed:Float):Void
    {
        forEachAlive(function(tile:FlxSprite) {
            if (tile.x < -TILE_WIDTH)
                tile.x += columns * TILE_WIDTH;
            if (tile.y > FlxG.height)
                tile.y -= rows * TILE_HEIGHT;
        });
    }
    
    override public function destroy():Void
    {
        if (animTimer != null) {
            animTimer.cancel();
            animTimer = null;
        }
        
        super.destroy();
    }
}