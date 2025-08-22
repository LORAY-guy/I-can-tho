package states;

import flixel.addons.ui.FlxUIState;
import flixel.effects.particles.FlxEmitter;

class MainMenuState extends FlxUIState
{
    // Constants
    private static final TITLE_TEXT:String = "I can, tho...";
    private static final TYPING_SPEED:Float = 0.08;
    private static final MIN_FLICKER_DELAY:Float = 0.2;
    private static final MAX_FLICKER_DELAY:Float = 3.0;
    
    // Visual elements
    private var glitchBg:FlxSprite;
    private var greenStatic:FlxSprite;
    private var titleTxt:FlxText;
    private var scanLines:FlxSprite;
    private var screenFlicker:FlxSprite;
    private var crtEdge:FlxSprite;
    
    // Boot sequence
    private var bootOverlay:FlxSprite;
    private var bootText:FlxText;
    private var bootState:Int = 0;
    private var bootTimer:Float = 0;
    private var bootComplete:Bool = false;
    
    // Menu
    private var menuButtons:FlxTypedGroup<MainMenuButton>;
    private static var selectedIndex:Int = 0;
    private var menuActive:Bool = false;
    private var optionsCamera:FlxSprite;
    
    // Title animation
    private var typingTitle:Bool = true;
    private var currentTitleText:String = "";
    private var titleTimer:Float = 0;
    private var titleIndex:Int = 0;
    
    // Screen effects
    private var flickerTimer:Float = 0;
    private var nextFlicker:Float = 0;

    private var skipIntro:Bool = false;
    
    // Controls
    public var controls(get, never):Controls;
    inline private function get_controls() return Controls.instance;

    override public function new(skipIntro:Bool = false):Void
    {
        super();

        this.skipIntro = skipIntro;
    }

    override public function create():Void
    {
        UserPrefs.loadPrefs();

        if (FlxG.save.data != null && FlxG.save.data.fullscreen != null) {
            FlxG.fullscreen = FlxG.save.data.fullscreen;
        }

        FlxG.drawFramerate = UserPrefs.data.framerate;
        FlxG.updateFramerate = UserPrefs.data.framerate;

        if (PlayState.instance != null) {
            PlayState.instance.destroy();
            PlayState.instance = null;
        }

        super.create();

        createBackground();
        createTitle();
        createMenuButtons();

        if (!skipIntro)
            startBootSequence();
        else
            bootComplete = true;

        createScreenEffects();
        setMenuActive(skipIntro);
    }

    private function createBackground():Void
    {
        // Glitch background
        glitchBg = new FlxSprite();
        glitchBg.frames = Paths.getSparrowAtlas('bufferOverlay');
        glitchBg.animation.addByPrefix('Idle', 'Idle', 2);
        glitchBg.animation.play('Idle');
        glitchBg.setGraphicSize(FlxG.width, FlxG.height);
        glitchBg.updateHitbox();
        glitchBg.screenCenter();
        glitchBg.alpha = FlxG.random.float(0, 0.1);
        add(glitchBg);
        
        new FlxTimer().start(0.075, function(tmr:FlxTimer) {
            glitchBg.alpha = FlxG.random.bool(75) ? FlxG.random.float(0, 0.1) : 0;
        }, 0);

        // Green static
        greenStatic = new FlxSprite();
        greenStatic.frames = Paths.getSparrowAtlas('static');
        greenStatic.animation.addByPrefix('Idle', 'Idle', 2);
        greenStatic.animation.play('Idle');
        greenStatic.setGraphicSize(FlxG.width, FlxG.height);
        greenStatic.updateHitbox();
        greenStatic.screenCenter();
        greenStatic.alpha = 0.1;
        add(greenStatic);

        // Particles
        var particles = createParticles();
        add(particles);
        setupParticleTimer(particles);
    }

    private function createParticles():FlxEmitter
    {
        var particles = new FlxEmitter(0, -10, 100);
        particles.makeParticles(4, 4, FlxColor.GREEN, 100);
        particles.width = FlxG.width;
        particles.height = 10;
        particles.alpha.set(0.4, 0.8);
        particles.speed.set(0, 50, 20, 100);
        particles.lifespan.set(20, 20);
        particles.acceleration.set(0, 15, 5, 25, 5, 25, 0, 15);
        particles.start(false, 0.1);
        return particles;
    }

    private function setupParticleTimer(particles:FlxEmitter):Void
    {
        new FlxTimer().start(FlxG.random.float(3, 8), function(tmr:FlxTimer) {
            particles.emitParticle();
            tmr.reset(FlxG.random.float(3, 8));
        });
    }

    private function createTitle():Void
    {
        titleTxt = new FlxText(0, 75, 0, "");
        titleTxt.setFormat(Paths.font("fnaf3.ttf"), 64, FlxColor.WHITE, CENTER, OUTLINE);
        titleTxt.updateHitbox();
        titleTxt.screenCenter(X);
        add(titleTxt);
    }

    private function createMenuButtons():Void
    {
        menuButtons = new FlxTypedGroup<MainMenuButton>();
        
        addButton("Start", function() launchGame(), 0);
        addButton("Options", function() launchOptions(), 1);
        addButton("Credits", function() launchCredits(), 2);
        addButton("Exit", CoolUtil.exitGame, 3);

        optionsCamera = new FlxSprite();
        optionsCamera.frames = Paths.getSparrowAtlas('pause/cameraFlip');
        optionsCamera.animation.addByPrefix('Idle', 'Idle', 30, false);
        optionsCamera.visible = false;

        optionsCamera.animation.finishCallback = function(name:String) {
            if (optionsCamera.animation.curAnim.reversed) {
                optionsCamera.visible = false;
            } else {
                persistentDraw = false;
                openSubState(new options.OptionsState());
            }
        };

        add(menuButtons);
    }

    private function addButton(label:String, callback:Void->Void, buttonId:Int):Void
    {
        var buttonY:Float = 250;
        var buttonSpacing:Float = 80;
        var y:Float = buttonY + buttonId * buttonSpacing;
        var button = new MainMenuButton(0, y, buttonId, label, callback);

        button.screenCenter(X);
        button.originX = button.x;
        menuButtons.add(button);
    }

    private function createScreenEffects():Void
    {
        // Scanlines
        var scanLines = new FlxSprite(0, 0);
        scanLines.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
        var lineData:BitmapData = scanLines.pixels;
        var lineSpacing:Int = 2;
        
        for (y in 0...FlxG.height) {
            if (y % lineSpacing != 0) {
                continue;
            }
            for (x in 0...FlxG.width) {
                lineData.setPixel32(x, y, FlxColor.BLACK);
            }
        }
        scanLines.pixels = lineData;
        add(scanLines);

        // Screen flicker
        screenFlicker = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        screenFlicker.alpha = 0;
        add(screenFlicker);

        // CRT edge
        crtEdge = new FlxSprite();
        crtEdge.loadGraphic(Paths.image("crtEdge"));
        crtEdge.setGraphicSize(FlxG.width, FlxG.height);
        crtEdge.updateHitbox();
        crtEdge.screenCenter();
        crtEdge.alpha = 0.5;
        add(crtEdge);
    }

    private function startBootSequence():Void
    {
        bootOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bootOverlay);

        FlxG.sound.playMusic(Paths.sound("bootup"), 0.3, false);
        bootText = new FlxText(20, 20, FlxG.width - 40, "SYSTEM BOOT SEQUENCE INITIATED");
        bootText.setFormat(Paths.font("fnaf3.ttf"), 16, FlxColor.GREEN, LEFT);
        add(bootText);
    }

    public function launchGame():Void
    {
        FlxG.sound.music.stop();
        FlxG.switchState(new StaticState());
    }

    private function launchOptions():Void
    {
        FlxG.sound.play(Paths.sound('camera'), 0.7).endTime = 750;
        remove(optionsCamera);
        add(optionsCamera);
        optionsCamera.visible = true;
        optionsCamera.animation.play('Idle');
    }

    private function launchCredits():Void
    {
        persistentDraw = false;
        openSubState(new LorayState());
    }

    override public function update(elapsed:Float)
    {
        if (!bootComplete) {
            updateBootSequence(elapsed);
            if (controls.ACCEPT || FlxG.keys.justPressed.ENTER)
                completeBootSequence();
            return;
        }

        if (typingTitle)
            updateTitleAnimation(elapsed);

        updateScreenEffects(elapsed);

        if (FlxG.state.subState == null && menuActive)
            handleMenuNavigation();

        if (controls.controllerMode)
            controls.controllerMode = !(FlxG.mouse.justPressed || FlxG.mouse.justReleased || FlxG.mouse.justMoved);
        FlxG.mouse.visible = !controls.controllerMode || FlxG.mouse.justMoved;

        super.update(elapsed);
    }

    private function updateBootSequence(elapsed:Float):Void
    {
        bootTimer += elapsed;
        
        switch (bootState) {
            case 0 if (bootTimer > 1):
                updateBootText("Initializing memory...");
                
            case 1 if (bootTimer > 1.5):
                updateBootText("Loading system files...");
                
            case 2 if (bootTimer > 2):
                updateBootText("System ready.");
                
            case 3 if (bootTimer > 1):
                completeBootSequence();
        }
    }

    private function updateBootText(text:String):Void
    {
        bootText.text += "\n" + text;
        bootState++;
        bootTimer = 0;
        FlxG.sound.play(Paths.sound("wait"), 0.3);
    }

    private function completeBootSequence():Void
    {
        remove(bootText);
        setMenuActive(true);
        bootComplete = true;
        FlxTween.tween(bootOverlay, {alpha: 0}, 1, {
            onComplete: function(_) {
                remove(bootOverlay);
            }
        });
        bootState++;
    }

    private function setMenuActive(active:Bool):Void
    {
        menuActive = active;
        for (button in menuButtons) {
            button.active = active;
        }
        if (active) {
            updateButtonSelectionVisuals();
            FlxG.sound.playMusic(Paths.music('menu_theme'), UserPrefs.data.musicVolume, true);
        }
    }

    private function updateTitleAnimation(elapsed:Float):Void
    {
        titleTimer += elapsed;
        if (titleTimer > TYPING_SPEED) {
            titleTimer = 0;
            if (titleIndex < TITLE_TEXT.length) {
                currentTitleText += TITLE_TEXT.charAt(titleIndex++);
                titleTxt.text = currentTitleText;
                titleTxt.screenCenter(X);
                FlxG.sound.play(Paths.soundRandom("keyboard0", 1, 4), FlxG.random.float(0.6, 0.9)); // nice
            } else {
                typingTitle = false;
                FlxTween.tween(titleTxt, {alpha: 0.5}, 0.5, {type: PINGPONG});
            }
        }
    }

    private function updateScreenEffects(elapsed:Float):Void
    {
        flickerTimer += elapsed;
        if (flickerTimer >= nextFlicker) {
            if (FlxG.random.bool(5)) {
                screenFlicker.alpha = 0.3;
                FlxTween.tween(screenFlicker, {alpha: 0}, 0.1);
                nextFlicker = FlxG.random.float(MIN_FLICKER_DELAY, MAX_FLICKER_DELAY);
            } else {
                nextFlicker = FlxG.random.float(0.2, 0.6);
            }
            flickerTimer = 0;
        }
    }

    private function handleMenuNavigation():Void
    {
        if (controls.UP_P) {
            changeSelection(-1);
        } else if (controls.DOWN_P) {
            changeSelection(1);
        } else if (controls.ACCEPT || FlxG.keys.justPressed.ENTER) {
            menuButtons.members[selectedIndex].callback();
        } else if (FlxG.mouse.visible && !controls.controllerMode)
            handleMouseNavigation();
    }

    private function handleMouseNavigation():Void
    {
        var mouseOverAny = false;
        for (i in 0...menuButtons.length) {
            var button = menuButtons.members[i];
            if (FlxG.mouse.overlaps(button)) {
                mouseOverAny = true;
                if (selectedIndex != i) {
                    selectedIndex = i;
                    updateButtonSelectionVisuals();
                }
                
                if (FlxG.mouse.justPressed) {
                    button.callback();
                }
                break;
            }
        }

        if (!mouseOverAny) {
            for (button in menuButtons) {
                button.isHovered = false;
            }
        }
    }

    private function changeSelection(delta:Int):Void
    {
        selectedIndex = (selectedIndex + delta + menuButtons.length) % menuButtons.length;
        updateButtonSelectionVisuals();
        FlxG.sound.play(Paths.sound("select"), 0.4) #if FLX_PITCH .pitch = FlxG.random.float(0.9, 1.1) #end;
    }

    private function updateButtonSelectionVisuals():Void
    {
        var button:MainMenuButton;
        var isSelected:Bool = false;

        for (i in 0...menuButtons.length) {
            button = menuButtons.members[i];
            isSelected = i == selectedIndex;
            button.updateVisualState(isSelected, button.isHovered);
        }
    }

    override function closeSubState():Void
    {
        super.closeSubState();

        if (optionsCamera.visible) {
            FlxG.sound.play(Paths.sound('camera'), 0.7).endTime = 750;
            optionsCamera.animation.play('Idle', false, true);
        }
        FlxG.camera.zoom = 1;
        FlxG.camera.scroll.set(0, 0);
        FlxG.camera.setPosition(0, 0);
        persistentDraw = true;
    }

    override public function destroy():Void
    {
        super.destroy();
    }
}

class MainMenuButton extends FlxText
{
    public var callback:Void->Void;
    public var originX:Float;
    public var isSelected:Bool = false;
    public var isHovered:Bool = false;
    public var id:Int = 0;

    private var playSound:Bool = true;

    public function new(x:Float, y:Float, id:Int, text:String, callback:Void->Void)
    {
        super(x, y, 0, text);
        this.callback = callback;
        this.id = id;
        setFormat(Paths.font("fnaf3.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    
        if (active) {
            var wasHovered = isHovered;
            
            if (FlxG.mouse.overlaps(this)) {
                isHovered = true;
                updateVisualState(isSelected, true);
                
                if (!wasHovered && playSound) {
                    FlxG.sound.play(Paths.sound("select"), 0.4) #if FLX_PITCH .pitch = FlxG.random.float(0.9, 1.1) #end;
                    playSound = false;
                }
            } else if (isHovered) {
                isHovered = false;
                updateVisualState(isSelected, false);
            }
            
            if (isSelected || isHovered) {
                x = FlxG.random.float(originX - 1, originX + 1);
            } else {
                x = originX;
            }
        }
    }

    public function updateVisualState(selected:Bool, hovered:Bool):Void
    {
        isSelected = selected;
        isHovered = hovered;
        
        if (selected || hovered) {
            color = FlxColor.GREEN;
            borderColor = FlxColor.LIME;
            borderSize = 2;
        } else {
            color = FlxColor.WHITE;
            borderColor = FlxColor.BLACK;
            borderSize = 1.5;
            playSound = true;
        }
    }
}
