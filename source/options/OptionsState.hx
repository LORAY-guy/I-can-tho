package options;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class OptionsState extends FlxSubState
{
    var bufferOverlay:FlxSprite;
    var glitchLine:FlxSprite;
    var greenStatic:FlxSprite;

    private var gameplayPanel:FlxSpriteGroup;
    private var controlsPanel:FlxSpriteGroup;
    private var graphicsPanel:FlxSpriteGroup;

    public static var currentPanel:FlxSpriteGroup;

    private var gameplayText:FlxText;
    private var controlsText:FlxText;
    private var graphicsText:FlxText;

    private var musicVolumeSlider:FlxUISlider;
    private var endlessModeCheckBox:Checkbox;
    private var resetButtonCheckBox:Checkbox;
    private var showTimerCheckBox:Checkbox;
    private var showFPSCheckBox:Checkbox = null;
    private var framerateSlider:FlxUISlider;
    private var precacheCheck:Checkbox;

    override function create():Void
    {
        super.create();

        var void:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(void);

        greenStatic = new FlxSprite();
        greenStatic.frames = Paths.getSparrowAtlas('static');
        greenStatic.animation.addByPrefix('Idle', 'Idle', 2);
        greenStatic.animation.play('Idle');
        greenStatic.setGraphicSize(FlxG.width, FlxG.height);
        greenStatic.updateHitbox();
        greenStatic.screenCenter();
        greenStatic.alpha = 0.1;
        add(greenStatic);

        bufferOverlay = new FlxSprite();
        bufferOverlay.frames = Paths.getSparrowAtlas('bufferOverlay');
        bufferOverlay.animation.addByPrefix('Idle', 'Idle', 30);
        bufferOverlay.animation.play('Idle');
        bufferOverlay.setGraphicSize(FlxG.width, FlxG.height);
        bufferOverlay.updateHitbox();
        bufferOverlay.screenCenter();
        bufferOverlay.alpha = 0.075;
        add(bufferOverlay);

        glitchLine = new FlxSprite().makeGraphic(FlxG.width, 100);
        glitchLine.y = -glitchLine.height;
        glitchLine.alpha = 0.075;
        glitchLine.velocity.y = 22.5;
        add(glitchLine);

        cameras = [PlayState.instance.camPause];

        gameplayPanel = new FlxSpriteGroup();
        controlsPanel = new FlxSpriteGroup();
        #if !html5
        graphicsPanel = new FlxSpriteGroup();
        #end

        // GAMEPLAY
        var gameplayTitle = new FlxText(0, 0, 0, "Gameplay Settings");
        gameplayTitle.setFormat(Paths.font('fnaf3.ttf'), 28, FlxColor.WHITE, LEFT);
        gameplayTitle.setPosition(FlxG.width - gameplayTitle.width - 5, 10);
        gameplayPanel.add(gameplayTitle);

        musicVolumeSlider = new FlxUISlider(UserPrefs.data, 'musicVolume', 434, 100, 0, 1, 400, 40, 8, FlxColor.GRAY, FlxColor.WHITE);
        musicVolumeSlider.callback = function(value:Float) {
            UserPrefs.data.musicVolume = value;
            PlayState.instance.ambienceManager.resetMusicVolume();
        };
        musicVolumeSlider.nameLabel.text = 'Music Volume';
        musicVolumeSlider.nameLabel.size = 16;
        gameplayPanel.add(musicVolumeSlider);

        resetButtonCheckBox = new Checkbox(0, 200, 'Disable Reset Button', 'disableReset', UserPrefs.data.disableReset);
        resetButtonCheckBox.screenCenter(X);
        gameplayPanel.add(resetButtonCheckBox);

        showTimerCheckBox = new Checkbox(0, resetButtonCheckBox.y + 50, 'Show Ingame Timer', 'showTimer', UserPrefs.data.showTimer);
        showTimerCheckBox.screenCenter(X);
        gameplayPanel.add(showTimerCheckBox);
        showTimerCheckBox.callback = function() {
            PlayState.instance.timer.visible = UserPrefs.data.showTimer;
        };

        #if !mobile
        showFPSCheckBox = new Checkbox(0, showTimerCheckBox.y + 50, 'FPS Counter', 'showFPS', UserPrefs.data.showFPS);
        showFPSCheckBox.screenCenter(X);
        gameplayPanel.add(showFPSCheckBox);
        showFPSCheckBox.callback = function() {
            if(Main.fpsVar != null) 
                Main.fpsVar.visible = UserPrefs.data.showFPS;
        };
        #end

        if (UserPrefs.data.unlockedEndless)
        {
            endlessModeCheckBox = new Checkbox(0, (showFPSCheckBox != null ? showFPSCheckBox.y : showTimerCheckBox.y) + 100, 'Endless Mode', 'endlessMode', UserPrefs.data.endlessMode);
            endlessModeCheckBox.screenCenter(X);
            gameplayPanel.add(endlessModeCheckBox);
        }

        // CONTROLS
        var controlsTitle = new FlxText(0, 0, 0, "Controls");
        controlsTitle.setFormat(Paths.font('fnaf3.ttf'), 28, FlxColor.WHITE, LEFT);
        controlsTitle.setPosition(FlxG.width - controlsTitle.width - 5, 10);
        controlsPanel.add(controlsTitle);

        displayControls();
        
        #if !html5
        // GRAPHICS
        var graphicsTitle = new FlxText(0, 0, 0, "Graphics Settings");
        graphicsTitle.setFormat(Paths.font('fnaf3.ttf'), 28, FlxColor.WHITE, LEFT);
        graphicsTitle.setPosition(FlxG.width - graphicsTitle.width - 5, 10);
        graphicsPanel.add(graphicsTitle);

        framerateSlider = new FlxUISlider(UserPrefs.data, 'framerate', 434, 100, 15, 240, 400, 40, 8, FlxColor.GRAY, FlxColor.WHITE);
        framerateSlider.callback = function(value:Float) {
            if (value >= 15) {
                var newFramerate:Int = Std.int(value);
                UserPrefs.data.framerate = newFramerate;
                FlxG.updateFramerate = newFramerate;
                FlxG.drawFramerate = newFramerate;
            }
        };
        framerateSlider.nameLabel.text = 'Framerate';
        framerateSlider.nameLabel.size = 16;
        graphicsPanel.add(framerateSlider);

        /**precacheCheck = new Checkbox(0, framerateSlider.y + 100, 'Precache all assets when loading the game', 'preCache', UserPrefs.data.preCache);
        precacheCheck.screenCenter(X);
        graphicsPanel.add(precacheCheck);**/
        #end

        currentPanel = controlsPanel;
        add(currentPanel);

        gameplayText = new FlxText(25, 20, 0, "Gameplay");
        gameplayText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.WHITE, LEFT);
        gameplayText.borderColor = FlxColor.LIME;
        controlsText = new FlxText(gameplayText.x + gameplayText.width + 20, 20, 0, "Controls");
        controlsText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.WHITE, LEFT);
        controlsText.borderColor = FlxColor.LIME;
        #if !html5
        graphicsText = new FlxText(controlsText.x + controlsText.width + 20, 20, 0, "Graphics");
        graphicsText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.WHITE, LEFT);
        graphicsText.borderColor = FlxColor.LIME;
        #end

        add(gameplayText);
        add(controlsText);
        #if !html5 add(graphicsText); #end
    }

    private function switchPanel(panel:FlxSpriteGroup):Void
    {
        UserPrefs.saveSettings();
        if (currentPanel != panel)
        {
            remove(currentPanel);
            currentPanel = panel;
            add(currentPanel);
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        handleTextHoverAndClick(gameplayText, gameplayPanel);
        handleTextHoverAndClick(controlsText, controlsPanel);
        #if !html5 handleTextHoverAndClick(graphicsText, graphicsPanel); #end

        if (glitchLine != null && glitchLine.y > FlxG.height + glitchLine.height * 1.75) {
            glitchLine.y = -glitchLine.height;
        }

        if (PlayState.instance.controls.PAUSE || (FlxG.mouse.overlaps(PlayState.instance.cameraID) && FlxG.mouse.justMoved)) close();
    }

    private function handleTextHoverAndClick(text:FlxText, panel:FlxSpriteGroup):Void
    {
        var isHovered:Bool = FlxG.mouse.overlaps(text);
        
        if (isHovered) {
            text.color = FlxColor.GREEN;
            text.underline = true;
        } else {
            text.color = FlxColor.WHITE;
            text.underline = false;
        }

        if (isHovered && FlxG.mouse.justPressed) {
            switchPanel(panel);
        }
    }

    private function displayControls():Void
    {
        var yOffset:Int = 80;
        var xLeft:Int = 50;
        var xRight:Int = Std.int(FlxG.width / 2 + 25);
        var orderedKeys:Array<String> = ['up', 'left', 'down', 'right', 'sprint', 'mask', 'stab', 'interact'];
    
        // Display keyBinds (Keyboard Controls) on the left side
        for (key in orderedKeys)
        {
            if (UserPrefs.keyBinds.exists(key))
            {
                var text:String = key.toUpperCase() + ': ';
                var keys:Array<FlxKey> = UserPrefs.keyBinds.get(key);
                var keyText:String = '';
                for (i in 0...keys.length)
                {
                    keyText += keys[i].toString();
                    if (i < keys.length - 1)
                        keyText += ', ';
                }
    
                var controlText = new FlxText(xLeft, yOffset, 0, text);
                controlText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.GREEN, LEFT);
                controlsPanel.add(controlText);
    
                var keyBindText = new FlxText(controlText.x + controlText.width, yOffset, 0, keyText);
                keyBindText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.WHITE, LEFT);
                controlsPanel.add(keyBindText);
    
                yOffset += 30;
            }
        }
    
        yOffset = 80;
    
        // Display gamepadBinds (Controller Controls) on the right side
        for (button in orderedKeys)
        {
            if (UserPrefs.gamepadBinds.exists(button))
            {
                var buttonText:String = button.toUpperCase() + ': ';
                var buttons:Array<FlxGamepadInputID> = UserPrefs.gamepadBinds.get(button);
                var buttonBindText:String = '';
                for (j in 0...buttons.length)
                {
                    buttonBindText += buttons[j].toString();
                    if (j < buttons.length - 1)
                        buttonBindText += ', ';
                }
    
                var gamepadText = new FlxText(xRight, yOffset, 0, buttonText);
                gamepadText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.BLUE, LEFT);
                controlsPanel.add(gamepadText);
    
                var buttonBindText = new FlxText(gamepadText.x + gamepadText.width, yOffset, 0, buttonBindText);
                buttonBindText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.WHITE, LEFT);
                controlsPanel.add(buttonBindText);
    
                yOffset += 30;
            }
        }
    }

    override function close():Void
    {
        UserPrefs.saveSettings();
        super.close();
    }
}