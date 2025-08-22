package options;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.FlxSubState;

enum PanelType {
    GAMEPLAY;
    CONTROLS;
    GRAPHICS;
}

/**
 * Options menu state that allows users to customize gameplay, controls and graphics settings
 */
class OptionsState extends FlxSubState
{
    // Constants for layout
    private static inline var PANEL_TITLE_SIZE:Int = 28;
    private static inline var OPTION_TEXT_SIZE:Int = 16;
    private static inline var OPTION_SPACING:Int = 50;
    private static inline var PANEL_MARGIN:Int = 5;
    private static inline var TAB_SPACING:Int = 20;
    private static inline var EXIT_BUTTON_MARGIN:Int = 20;
    
    // Controls instance
    public var controls(get, never):Controls;
    private function get_controls() return Controls.instance;

    // Visual elements
    private var bufferOverlay:FlxSprite;
    private var glitchLine:FlxSprite;
    private var greenStatic:FlxSprite;

    // Panel management
    private var panels:Map<PanelType, FlxSpriteGroup>;
    private var tabTexts:Map<PanelType, FlxText>;
    private var currentPanelType:PanelType;
    
    // Gameplay settings
    private var musicVolumeSlider:Slider;
    private var resetButtonCheckBox:Checkbox;
    private var showTimerCheckBox:Checkbox;
    private var showFPSCheckBox:Checkbox = null;
    private var endlessModeCheckBox:Checkbox;
    
    // Graphics settings
    private var framerateSlider:Slider;
    private var gpuCacheCheck:Checkbox;
    
    // Exit buttons
    private var exitToMenuButton:FlxText;
    private var exitToDesktopButton:FlxText;

    private var exiting:Bool = false;

    override function create():Void
    {
        Paths.clearUnusedMemory();
        super.create();
        
        createBackground();
        initializePanels();

        createTabs();

        createGameplayPanel();
        createControlsPanel();
        
        #if !html5
        createGraphicsPanel();
        #end
        
        createExitButtons();
        
        switchPanel(PanelType.CONTROLS);
        
        if (PlayState.instance != null)
            cameras = [PlayState.instance.camPause];
    }
    
    private function createBackground():Void
    {
        // Create black background
        var void:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(void);

        // Add static effect
        greenStatic = new FlxSprite();
        greenStatic.frames = Paths.getSparrowAtlas('static');
        greenStatic.animation.addByPrefix('Idle', 'Idle', 2);
        greenStatic.animation.play('Idle');
        greenStatic.setGraphicSize(FlxG.width, FlxG.height);
        greenStatic.updateHitbox();
        greenStatic.screenCenter();
        greenStatic.alpha = 0.1;
        add(greenStatic);

        // Add buffer overlay effect
        bufferOverlay = new FlxSprite();
        bufferOverlay.frames = Paths.getSparrowAtlas('bufferOverlay');
        bufferOverlay.animation.addByPrefix('Idle', 'Idle', 30);
        bufferOverlay.animation.play('Idle');
        bufferOverlay.setGraphicSize(FlxG.width, FlxG.height);
        bufferOverlay.updateHitbox();
        bufferOverlay.screenCenter();
        bufferOverlay.alpha = 0.075;
        add(bufferOverlay);

        // Add moving glitch line effect
        glitchLine = new FlxSprite().makeGraphic(FlxG.width, 100);
        glitchLine.y = -glitchLine.height;
        glitchLine.alpha = 0.075;
        glitchLine.velocity.y = 22.5;
        add(glitchLine);
    }
    
    private function initializePanels():Void
    {
        panels = new Map<PanelType, FlxSpriteGroup>();
        panels.set(PanelType.GAMEPLAY, new FlxSpriteGroup());
        panels.set(PanelType.CONTROLS, new FlxSpriteGroup());
        
        #if !html5
        panels.set(PanelType.GRAPHICS, new FlxSpriteGroup());
        #end
    }
    
    private function createTabs():Void
    {
        tabTexts = new Map<PanelType, FlxText>();
        
        var xPos:Float = 25;
        
        // Gameplay tab
        var gameplayText = new FlxText(xPos, 20, 0, "Gameplay");
        gameplayText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.WHITE, LEFT);
        gameplayText.borderColor = FlxColor.LIME;
        add(gameplayText);
        tabTexts.set(PanelType.GAMEPLAY, gameplayText);
        
        xPos += gameplayText.width + TAB_SPACING;
        
        // Controls tab
        var controlsText = new FlxText(xPos, 20, 0, "Controls");
        controlsText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.WHITE, LEFT);
        controlsText.borderColor = FlxColor.LIME;
        add(controlsText);
        tabTexts.set(PanelType.CONTROLS, controlsText);
        
        #if !html5
        xPos += controlsText.width + TAB_SPACING;
        
        // Graphics tab
        var graphicsText = new FlxText(xPos, 20, 0, "Graphics");
        graphicsText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.WHITE, LEFT);
        graphicsText.borderColor = FlxColor.LIME;
        add(graphicsText);
        tabTexts.set(PanelType.GRAPHICS, graphicsText);
        #end
    }
    
    private function createExitButtons():Void
    {
        // Exit to Menu button
        exitToMenuButton = new FlxText(0, FlxG.height - EXIT_BUTTON_MARGIN - 100, 0, "EXIT TO MENU");
        exitToMenuButton.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.RED, CENTER);
        exitToMenuButton.alpha = 0.8;
        exitToMenuButton.screenCenter(X);
        exitToMenuButton.x -= 150; // Position to the left
        add(exitToMenuButton);
        
        // Exit to Desktop button
        exitToDesktopButton = new FlxText(0, FlxG.height - EXIT_BUTTON_MARGIN - 100, 0, "EXIT TO DESKTOP");
        exitToDesktopButton.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.RED, CENTER);
        exitToDesktopButton.alpha = 0.8;
        exitToDesktopButton.screenCenter(X);
        exitToDesktopButton.x += 150; // Position to the right
        add(exitToDesktopButton);
    }
    
    private function createGameplayPanel():Void
    {
        var panel = panels.get(PanelType.GAMEPLAY);
        
        // Panel title
        var gameplayTitle = new FlxText(0, 0, 0, "Gameplay Settings");
        gameplayTitle.setFormat(Paths.font('fnaf3.ttf'), PANEL_TITLE_SIZE, FlxColor.WHITE, LEFT);
        gameplayTitle.setPosition(FlxG.width - gameplayTitle.width - PANEL_MARGIN, 10);
        panel.add(gameplayTitle);

        // Music volume slider
        musicVolumeSlider = new Slider(
            434, 100, "Music Volume", 400,
            0, 1, UserPrefs.data.musicVolume,
            UserPrefs.data, "musicVolume",
            true
        );
        musicVolumeSlider.callback = function(value:Float) {
            UserPrefs.data.musicVolume = value;
            if (PlayState.instance != null)
                PlayState.instance.ambienceManager.resetMusicVolume();
            
            if (FlxG.sound.music.playing) {
                if (value > FlxG.sound.music.volume)
                    FlxG.sound.music.fadeIn(0.5, value);
                else
                    FlxG.sound.music.fadeOut(0.5, value);
            }
        };
        panel.add(musicVolumeSlider);

        var yPos:Float = 220;
        
        // Reset button checkbox
        resetButtonCheckBox = new Checkbox(
            0, yPos, 
            'Disable Reset Button', 
            'disableReset', 
            UserPrefs.data.disableReset
        );
        resetButtonCheckBox.screenCenter(X);
        panel.add(resetButtonCheckBox);

        yPos += OPTION_SPACING;
        
        // Show timer checkbox
        showTimerCheckBox = new Checkbox(
            0, yPos, 
            'Show Ingame Timer', 
            'showTimer', 
            UserPrefs.data.showTimer
        );
        showTimerCheckBox.screenCenter(X);
        showTimerCheckBox.callback = function() {
            if (PlayState.instance != null)
                PlayState.instance.timer.visible = UserPrefs.data.showTimer;
        };
        panel.add(showTimerCheckBox);

        yPos += OPTION_SPACING;
        
        #if !mobile
        // FPS counter checkbox
        showFPSCheckBox = new Checkbox(
            0, yPos, 
            'FPS Counter', 
            'showFPS', 
            UserPrefs.data.showFPS
        );
        showFPSCheckBox.screenCenter(X);
        showFPSCheckBox.callback = function() {
            if(Main.fpsVar != null) 
                Main.fpsVar.visible = UserPrefs.data.showFPS;
        };
        panel.add(showFPSCheckBox);
        
        yPos += OPTION_SPACING;
        #end

        // Endless mode checkbox (in case I actualy add it)
        if (UserPrefs.data.unlockedEndless)
        {
            yPos += OPTION_SPACING;
            endlessModeCheckBox = new Checkbox(
                0, yPos, 
                'Endless Mode', 
                'endlessMode', 
                UserPrefs.data.endlessMode
            );
            endlessModeCheckBox.screenCenter(X);
            panel.add(endlessModeCheckBox);
        }
    }
    
    private function createControlsPanel():Void
    {
        var panel = panels.get(PanelType.CONTROLS);
        
        // Panel title
        var controlsTitle = new FlxText(0, 0, 0, "Controls");
        controlsTitle.setFormat(Paths.font('fnaf3.ttf'), PANEL_TITLE_SIZE, FlxColor.WHITE, LEFT);
        controlsTitle.setPosition(FlxG.width - controlsTitle.width - PANEL_MARGIN, 10);
        panel.add(controlsTitle);

        displayControls(panel);
    }
    
    #if !html5
    private function createGraphicsPanel():Void
    {
        var panel = panels.get(PanelType.GRAPHICS);
        
        // Panel title
        var graphicsTitle = new FlxText(0, 0, 0, "Graphics Settings");
        graphicsTitle.setFormat(Paths.font('fnaf3.ttf'), PANEL_TITLE_SIZE, FlxColor.WHITE, LEFT);
        graphicsTitle.setPosition(FlxG.width - graphicsTitle.width - PANEL_MARGIN, 10);
        panel.add(graphicsTitle);

        // Framerate slider
        framerateSlider = new Slider(
            434, 100, "Framerate", 400,
            30, 240, UserPrefs.data.framerate,
            UserPrefs.data, "framerate"
        );
        framerateSlider.callback = function(value:Float) {
            if (value >= 30 && value <= 240) {
                var newFramerate:Int = Std.int(value);
                UserPrefs.data.framerate = newFramerate;
                FlxG.updateFramerate = newFramerate;
                FlxG.drawFramerate = newFramerate;
            }
        };
        panel.add(framerateSlider);

        // GPU caching checkbox
        gpuCacheCheck = new Checkbox(
            0, framerateSlider.y + 120, 
            'GPU Caching', 
            'cacheOnGPU', 
            UserPrefs.data.cacheOnGPU
        );
        gpuCacheCheck.screenCenter(X);
        panel.add(gpuCacheCheck);
    }
    #end
    
    private function displayControls(panel:FlxSpriteGroup):Void
    {
        var yOffset:Int = 110;
        var xLeft:Int = 50;
        var xRight:Int = Std.int(FlxG.width / 2 + 25);
        var orderedKeys:Array<String> = ['up', 'left', 'down', 'right', 'sprint', 'mask', 'stab', 'interact', 'mute'];
    
        var keyboardHeader = new FlxText(xLeft, yOffset - 30, 0, "KEYBOARD CONTROLS");
        keyboardHeader.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.YELLOW, LEFT);
        panel.add(keyboardHeader);
        
        var gamepadHeader = new FlxText(xRight, yOffset - 30, 0, "GAMEPAD CONTROLS");
        gamepadHeader.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.YELLOW, LEFT);
        panel.add(gamepadHeader);
    
        for (key in orderedKeys)
        {
            if (UserPrefs.keyBinds.exists(key))
            {
                var text:String = key.toUpperCase() + ': ';
                var keys:Array<FlxKey> = UserPrefs.keyBinds.get(key);
                var keyText:String = formatKeyBinds(keys);
    
                var controlText = new FlxText(xLeft, yOffset, 0, text);
                controlText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.GREEN, LEFT);
                panel.add(controlText);
    
                var keyBindText = new FlxText(controlText.x + controlText.width, yOffset, 0, keyText);
                keyBindText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.WHITE, LEFT);
                panel.add(keyBindText);
    
                yOffset += 30;
            }
        }
    
        yOffset = 110;

        for (button in orderedKeys)
        {
            if (UserPrefs.gamepadBinds.exists(button))
            {
                var buttonText:String = button.toUpperCase() + ': ';
                var buttons:Array<FlxGamepadInputID> = UserPrefs.gamepadBinds.get(button);
                var buttonBindText:String = formatGamepadBinds(buttons);
    
                var gamepadText = new FlxText(xRight, yOffset, 0, buttonText);
                gamepadText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.BLUE, LEFT);
                panel.add(gamepadText);
    
                var buttonBindText = new FlxText(gamepadText.x + gamepadText.width, yOffset, 0, buttonBindText);
                buttonBindText.setFormat(Paths.font('fnaf3.ttf'), OPTION_TEXT_SIZE, FlxColor.WHITE, LEFT);
                panel.add(buttonBindText);
    
                yOffset += 30;
            }
        }
    }
    
    private function formatKeyBinds(keys:Array<FlxKey>):String {
        var keyText:String = '';
        for (i in 0...keys.length)
        {
            keyText += keys[i].toString();
            if (i < keys.length - 1)
                keyText += ', ';
        }
        return keyText;
    }
    
    private function formatGamepadBinds(buttons:Array<FlxGamepadInputID>):String {
        var buttonBindText:String = '';
        for (j in 0...buttons.length)
        {
            buttonBindText += buttons[j].toString();
            if (j < buttons.length - 1)
                buttonBindText += ', ';
        }
        return buttonBindText;
    }

    private function switchPanel(panelType:PanelType):Void
    {
        UserPrefs.saveSettings();
        
        if (currentPanelType != panelType) {
            if (currentPanelType != null) {
                remove(panels.get(currentPanelType));
            }
            
            currentPanelType = panelType;
            add(panels.get(currentPanelType));
        }
        
        for (type in tabTexts.keys()) {
            var text = tabTexts.get(type);
            if (type == currentPanelType) {
                text.color = FlxColor.GREEN;
                text.borderStyle = OUTLINE;
                text.underline = false;
                text.borderSize = 1;
            } else {
                text.color = FlxColor.WHITE;
                text.borderStyle = NONE;
            }
        }
        
        UserPrefs.loadPrefs();
    }
    
    private var canSwitchTabs:Bool = true;
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (controls.controllerMode)
            canSwitchTabs = true;

        for (type in tabTexts.keys())
            handleTabInteraction(tabTexts.get(type), type);

        if (FlxG.mouse.visible)
            handleExitButtonInteractions();

        if (glitchLine != null && glitchLine.y > FlxG.height + glitchLine.height * 1.75)
            glitchLine.y = -glitchLine.height;
        
        if (!exiting) {
            if ((PlayState.instance != null && (FlxG.mouse.overlaps(PlayState.instance.cameraID) && FlxG.mouse.justMoved)) ||
                controls.PAUSE || controls.BACK) {
                close();
            }
        }

        if (controls.controllerMode)
            controls.controllerMode = !(FlxG.mouse.justPressed || FlxG.mouse.justReleased || FlxG.mouse.justMoved);
        FlxG.mouse.visible = !controls.controllerMode || FlxG.mouse.justMoved;
    }

    private function handleTabInteraction(text:FlxText, panelType:PanelType):Void
    {
        if (FlxG.mouse.visible) {
            var isHovered:Bool = FlxG.mouse.overlaps(text);
        
            if (isHovered && currentPanelType != panelType) {
                text.color = FlxColor.GREEN;
                text.underline = true;
            } else if (currentPanelType != panelType) {
                text.color = FlxColor.WHITE;
                text.underline = false;
            }
        
            if (isHovered && FlxG.mouse.justPressed) {
                FlxG.sound.play(Paths.sound('run'), 0.5) #if FLX_PITCH .pitch = FlxG.random.float(0.9, 1.1) #end ;
                switchPanel(panelType);
            }
        }

        if (FlxG.gamepads.firstActive != null)
            handleControllerTabInteractions();
    }

    private function handleControllerTabInteractions():Void
    {
        var panelTypes:Array<PanelType> = getVisiblePanelTypesInOrder();
        var currentIndex = panelTypes.indexOf(currentPanelType);
        if (currentIndex == -1) return;
    
        var gamepad = FlxG.gamepads.firstActive;
        if (gamepad == null) return;

        if (gamepad.anyJustPressed([FlxGamepadInputID.LEFT_SHOULDER]) && canSwitchTabs) {
            canSwitchTabs = false;
            var newIndex = (currentIndex - 1 + panelTypes.length) % panelTypes.length;
            FlxG.sound.play(Paths.sound('run'), 0.5) #if FLX_PITCH .pitch = FlxG.random.float(0.9, 1.1) #end ;
            switchPanel(panelTypes[newIndex]);
        }
        else if (gamepad.anyJustPressed([FlxGamepadInputID.RIGHT_SHOULDER]) && canSwitchTabs) {
            canSwitchTabs = false;
            var newIndex = (currentIndex + 1) % panelTypes.length;
            FlxG.sound.play(Paths.sound('run'), 0.5) #if FLX_PITCH .pitch = FlxG.random.float(0.9, 1.1) #end ;
            switchPanel(panelTypes[newIndex]);
        }
        else if (!gamepad.anyPressed([FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.RIGHT_SHOULDER])) {
            canSwitchTabs = true;
        }
    }
    
    private function getVisiblePanelTypesInOrder():Array<PanelType>
    {
        var orderedTypes:Array<PanelType> = [];

        orderedTypes.push(PanelType.GAMEPLAY);
        orderedTypes.push(PanelType.CONTROLS);
        #if !html5
        orderedTypes.push(PanelType.GRAPHICS);
        #end
        return orderedTypes;
    }

    private function handleExitButtonInteractions():Void
    {
        var menuButtonHovered:Bool = FlxG.mouse.overlaps(exitToMenuButton);
        if (menuButtonHovered) {
            exitToMenuButton.alpha = 1.0;
            exitToMenuButton.underline = true;
            
            if (FlxG.mouse.justPressed) {
                if (PlayState.instance != null) {
                    exiting = true;
                    PlayState.instance.disableEverything();
                    PlayState.instance.camPause.fade(FlxColor.BLACK, 1, false, function() {
                        close();
                        PlayState.instance = null;
                        FlxG.switchState(new MainMenuState(true));
                    });
                } else {
                    close();
                }
            }
        } else {
            exitToMenuButton.alpha = 0.8;
            exitToMenuButton.underline = false;
        }
        
        var desktopButtonHovered:Bool = FlxG.mouse.overlaps(exitToDesktopButton);
        if (desktopButtonHovered) {
            exitToDesktopButton.alpha = 1.0;
            exitToDesktopButton.underline = true;
            
            if (FlxG.mouse.justPressed)
                CoolUtil.exitGame();
        } else {
            exitToDesktopButton.alpha = 0.8;
            exitToDesktopButton.underline = false;
        }
    }

    override function close():Void
    {
        UserPrefs.saveSettings();
        UserPrefs.loadPrefs();
        super.close();
    }
}