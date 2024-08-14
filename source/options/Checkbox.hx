package options;

class Checkbox extends FlxSpriteGroup
{
    private var isChecked:Bool;
    private var checkedImage:String;
    private var uncheckedImage:String;
    private var varName:String;

    public var callback:Void->Void = null;

    var checkboxSprite:FlxSprite;
    var optionName:FlxText;

    public function new(x:Float, y:Float, name:String, varName:String, isChecked:Bool = true)
    {
        super(x, y);
        this.isChecked = isChecked;
        this.varName = varName;

        checkboxSprite = new FlxSprite(0, -10);
        checkboxSprite.loadGraphic(Paths.image('pause/check'));
        checkboxSprite.scale.set(0.7, 0.7);
        checkboxSprite.updateHitbox();
        checkboxSprite.visible = isChecked;
        checkboxSprite.antialiasing = true;
        add(checkboxSprite);

        optionName = new FlxText(30, 0, 0, name);
        optionName.setFormat(Paths.font('fnaf3.ttf'), 24, FlxColor.WHITE, LEFT);
        add(optionName);

        checkboxSprite.x = optionName.x + optionName.width + 10;
    }

    public function toggle():Void
    {
        FlxG.sound.play(Paths.sound('select'));
        isChecked = !isChecked;
        checkboxSprite.visible = isChecked;
        Reflect.setField(UserPrefs.data, varName, isChecked);
        if (callback != null) callback();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this)) {
            optionName.color = FlxColor.GREEN;
            if (FlxG.mouse.justPressed) toggle();
        } else {
            optionName.color = FlxColor.WHITE;
        }
    }
}