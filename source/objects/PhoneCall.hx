package objects;

@:structInit class PhoneVariables {
    public var pickedUp:Bool = false;
    public var tutorialPart1:Bool = false;
    public var tutorialPart2:Bool = false;
    public var tutorialPart3:Bool = false;
    public var tutorialPart4:Bool = false;
    public var tutorialPart5:Bool = false;
    public var tutorialPart6:Bool = false;
	public var freddyIntro:Bool = false;
    public var bonnieIntro:Bool = false;
    public var chicaIntro:Bool = false;
    public var foxyIntro:Bool = false;
    public var room8entrance:Bool = false;
    public var killedAllAnimatronics:Bool = false;
    public var endCutscene:Bool = false;
    public var caseOhMove:Bool = false;
    public var foundKey:Bool = false;
    public var losingSignal:Bool = false;
}

class PhoneCall extends FlxSprite
{
    public static var data:PhoneVariables = {};

    public var player:FlxSound = new FlxSound();
    private var phoneVibration:FlxSound = new FlxSound();

    public var muteButton:FlxSprite;

    private var game:PlayState = PlayState.instance;
    private var ringing:Bool = false;

    public var curPlayed:String;

    public function new():Void 
    {
        super();
        frames = Paths.getSparrowAtlas('phone');
        animation.addByPrefix('BlackScreen', 'BlackScreen', 1, false);
        animation.addByPrefix('Calling', 'Calling', 1, false);
        animation.addByPrefix('Call', 'Call0', 1, false);
        animation.play((data.pickedUp ? 'Call' : 'BlackScreen'));
        scale.set(0.25, 0.25);
        updateHitbox();
        setPosition(FlxG.width - width - 20, 45);
        visible = false;

        muteButton = new FlxSprite(15, 15).loadGraphic(Paths.image('mute'));
        muteButton.visible = false;
        muteButton.alpha = 0.6;
        muteButton.cameras = [game.camHUD];
        game.insert(game.members.indexOf(this) + 1, muteButton);

        player.loadEmbedded(Paths.sound('loray/tutorialPart1'));
        FlxG.sound.defaultSoundGroup.add(player);

        if (!data.pickedUp) {
            new FlxTimer().start(3, function(tmr:FlxTimer) {
                ring();
            });
        }
    }

    private function ring():Void
    {
        ringing = visible = true;
        animation.play('Calling');
        phoneVibration.loadEmbedded(Paths.sound('phoneVibration'), true);
        phoneVibration.play();

        //In case the player doesn't understand that you have a pick up the phone by clicking
        new FlxTimer().start(6, function(tmr:FlxTimer) {
            if (ringing) pickUp();
        });
    }

    private function pickUp():Void
    {
        ringing = false;
        data.pickedUp = true;
        animation.play('Call');

        //Don't need those anymore
        phoneVibration.stop();
        phoneVibration.destroy();
        phoneVibration = null;
        playMessage('tutorialPart1');
    }

    public function playMessage(name:String, showMute:Bool = true, prioritize:Bool = false):Void
    {
        if ((prioritize || !player.playing) && !Reflect.getProperty(data, name)) { 
            Reflect.setField(data, name, true);
            player.loadEmbedded(Paths.sound('loray/$name'));

            if (game.ambienceManager.playingMusic) {
                game.ambienceManager.adjustMusicVolume(0.5);
            }

            player.onComplete = function() {
                getCallbackFromName(name);
            };
            
            player.play();
            curPlayed = name;
            visible = true;
            muteButton.visible = showMute;
        }
    }

    private var checkForTutorialControls:Void->Bool = null;
    private var keyFunction:Void->Void = null;
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (animation.curAnim.name == 'Call' && FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed) FlxG.sound.play(Paths.sound('error'), 0.7);
        if (ringing && FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed) pickUp(); 
        if (muteButton.visible && FlxG.mouse.overlaps(muteButton) && FlxG.mouse.justPressed) muteCall();

        if (player.playing) {
            if (this.overlaps(game.ourple)) alpha = 0.5;
            else alpha = 1;
        }

        if (checkForTutorialControls != null && checkForTutorialControls()) {
            keyFunction();
        }
    }

    /**Not actually muting, just skipping, because it wouldn't trigger the callback of the end of the message that is being played.*/
    public function muteCall():Void
    {
        if (player.playing) {
            player.time = player.length - 1;
            muteButton.visible = false;
            visible = false;
        }
    }

    private function getCallbackFromName(name:String):Void 
    {
        switch (name)
        {
            case 'tutorialPart1':
                setupTutorial(
                    function() { 
                        playMessage('tutorialPart2'); 
                    },
                    function() { 
                        game.tutorialControls.visible = true;
                        game.ourple.lockedControls = false;
                        return !game.ourple.velocity.isZero(); 
                    }
                );
                
            case 'tutorialPart2':
                setupTutorial(
                    function() { 
                        playMessage('tutorialPart3'); 
                    },
                    function() { 
                        game.tutorialControls.text = UserPrefs.keyBinds.get('stab')[0].toString();
                        game.tutorialControls.screenCenter(X);
                        game.tutorialControls.visible = true;
                        game.ourple.caseOhMode = false;
                        return (game.ourple.animation.curAnim.name == 'Stab' && game.ourple.animation.curAnim.curFrame == 9);
                    }
                );
                
            case 'tutorialPart3':
                setupTutorial(
                    function() { 
                        //game.tutorialControls.destroy();
                        //game.tutorialControls = null;
                        playMessage('tutorialPart4'); 
                    },
                    function() { 
                        game.tutorialControls.text = UserPrefs.keyBinds.get('mask')[0].toString() + ' / ' + UserPrefs.gamepadBinds.get('mask')[0].toString();
                        game.tutorialControls.screenCenter(X);
                        game.tutorialControls.visible = true;
                        return game.ourple.animation.curAnim.name == 'MaskOn'; 
                    }
                );

            case 'tutorialPart4':
                game.room1.exit.locked = false;

            case 'tutorialPart5':
                game.room2.exit3.locked = false;
                
            case 'tutorialPart6':
                game.ourple.lockedControls = false;
                game.ambienceManager.playMusic();

            case 'endCutscene':
                game.roomAfton.exit.locked = false;
                game.ourple.caseOhMode = true;
                game.ourple.lockedControls = false;

                var knife:FlxSprite = new FlxSprite(game.ourple.x + game.ourple.width / 2, game.ourple.y + game.ourple.height / 2).loadGraphic(Paths.image('knife'));
                knife.scale.set(1.6, 1.6);
                game.currentRoom.add(knife);
                FlxG.sound.play(Paths.sound('land'), 0.9);

                game.ambienceManager.playMusic();
                game.ambienceManager.resetMusicVolume(0);
            
            case 'foundKey':
                setupTutorial(
                    null,
                    function() {
                        game.tutorialControls.text = UserPrefs.keyBinds.get('interact')[0].toString() + ' / ' + UserPrefs.gamepadBinds.get('interact')[0].toString();
                        game.tutorialControls.screenCenter();
                        game.tutorialControls.visible = true;
                        return game.ourple.hasKey;
                    }
                );
        }

        muteButton.visible = false;
        visible = false;

        if (game.ambienceManager.playingMusic && name != 'endCutscene')
            game.ambienceManager.resetMusicVolume();
    }
    
    private function setupTutorial(keyFunc:Void->Void, checkFunc:Void->Bool):Void
    {
        keyFunction = function() {
            game.tutorialControls.visible = false;
            checkForTutorialControls = null;
            if (keyFunc != null) keyFunc();
        };
        checkForTutorialControls = checkFunc;
    }

    override function destroy():Void
    {
        FlxG.sound.defaultSoundGroup.remove(player);
        player.stop();
        player.destroy();
        player = null;

        super.destroy();
    }
}