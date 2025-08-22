package options;

class Slider extends FlxSpriteGroup
{
    private var track:FlxSprite;
    private var thumb:FlxSprite;
    private var valueText:FlxText;
    private var nameLabel:FlxText;
    private var hoverHighlight:FlxSprite;

    public var minValue:Float;
    public var maxValue:Float;
    public var value(default, set):Float;
    
    public var callback:Float->Void = null;
    
    private var targetObject:Dynamic;
    private var targetVarName:String;
    
    private var isDragging:Bool = false;
    
    private var showValueAsPercent:Bool = false;
    private var valuePrefix:String = "";
    private var valueSuffix:String = "";
    
    private var trackWidth:Float;
    private var trackHeight:Float = 8;
    
    private var keyboardSpeed:Float = 0.05;
    private var isFocused:Bool = false;
    
    /**
    * Create a new RetroSlider
    * 
    * @param x X position
    * @param y Y position
    * @param label The name label for the slider
    * @param width Width of the slider track
    * @param min Minimum value
    * @param max Maximum value
    * @param initialValue Starting value
    * @param targetObject Optional object to update (usually UserPrefs.data)
    * @param targetVarName Variable name to update on targetObject
    * @param showPercent Show value as percentage
    */
    public function new(x:Float, y:Float, label:String, width:Float = 400, 
        min:Float = 0, max:Float = 1, initialValue:Float = 0,
        targetObject:Dynamic = null, targetVarName:String = null,
        showPercent:Bool = false)
    {
        super(x, y);
        
        this.minValue = min;
        this.maxValue = max;
        this.targetObject = targetObject;
        this.targetVarName = targetVarName;
        this.showValueAsPercent = showPercent;
        this.trackWidth = width;

        nameLabel = new FlxText(0, 0, Std.int(trackWidth), label);
        nameLabel.setFormat(Paths.font('fnaf3.ttf'), 20, FlxColor.WHITE, CENTER);
        add(nameLabel);
        
        track = new FlxSprite(0, nameLabel.height + 8);
        track.makeGraphic(Std.int(trackWidth), Std.int(trackHeight), FlxColor.GRAY);
        add(track);

        nameLabel.width = track.width;
        nameLabel.screenCenter(X);
        
        thumb = new FlxSprite();
        thumb.makeGraphic(16, 20, FlxColor.GREEN);
        thumb.y = track.y - 106;
        add(thumb);
        
        valueText = new FlxText(track.x + track.width + 10, track.y - 78, "");
        valueText.setFormat(Paths.font('fnaf3.ttf'), 16, FlxColor.WHITE, LEFT);
        add(valueText);
        
        var highlightWidth = trackWidth + 25;
        var highlightHeight = nameLabel.height + track.height + valueText.height + 32;
        hoverHighlight = new FlxSprite().makeGraphic(Std.int(highlightWidth), Std.int(highlightHeight), FlxColor.GREEN);
        hoverHighlight.alpha = 0.1;
        hoverHighlight.visible = false;
        insert(0, hoverHighlight);
        
        hoverHighlight.setPosition(
            nameLabel.x - 16,
            nameLabel.y - 8
        );
        
        this.value = initialValue;
        this.width = track.width + 20;
        this.height = nameLabel.height + track.height + 16;
        
        track.updateHitbox();
        thumb.updateHitbox();
        valueText.updateHitbox();
        hoverHighlight.updateHitbox();
    }
    
    private function set_value(newValue:Float):Float
    {
        newValue = FlxMath.bound(newValue, minValue, maxValue);
        value = newValue;
           
        updateThumbPosition();
        updateValueText();

        if (targetObject != null && targetVarName != null)
            Reflect.setField(targetObject, targetVarName, value);
        if (callback != null)
            callback(value);

        return value;
    }

    private function updateThumbPosition():Void
    {
        var trackFillPercent = (value - minValue) / (maxValue - minValue);
        var maxThumbX = track.x + trackWidth - thumb.width;
        
        thumb.x = track.x + (trackWidth - thumb.width) * trackFillPercent;
        thumb.x = FlxMath.bound(thumb.x, track.x, maxThumbX);
    }
    
    private function updateValueText():Void
    {
        var displayValue:String = "";
        
        if (showValueAsPercent) {
            var percent = Math.round((value - minValue) / (maxValue - minValue) * 100);
            displayValue = valuePrefix + percent + "%" + valueSuffix;
        } else if (Math.abs(maxValue - minValue) > 10) {
            displayValue = valuePrefix + Std.string(Math.round(value)) + valueSuffix;
        } else {
            displayValue = valuePrefix + Std.string(Math.round(value * 100) / 100) + valueSuffix;
        }
        
        valueText.text = displayValue;
        valueText.updateHitbox();
        valueText.screenCenter(X);
    }
    
    public function setPrefix(prefix:String):Slider
    {
        this.valuePrefix = prefix;
        updateValueText();
        return this;
    }

    public function setSuffix(suffix:String):Slider
    {
        this.valueSuffix = suffix;
        updateValueText();
        return this;
    }
    
    public function setFocus(focused:Bool):Void
    {
        isFocused = focused;
        if (focused) {
            hoverHighlight.visible = true;
            nameLabel.color = FlxColor.GREEN;
            valueText.color = FlxColor.GREEN;
            thumb.color = FlxColor.YELLOW;
        } else {
            hoverHighlight.visible = false;
            nameLabel.color = FlxColor.WHITE;
            valueText.color = FlxColor.WHITE;
            thumb.color = FlxColor.GREEN;
        }
    }
    
    private function isMouseOverlapping():Bool return FlxG.mouse.overlaps(hoverHighlight);

    private function isMouseOverTrack():Bool return FlxG.mouse.overlaps(track);

    private function isMouseOverThumb():Bool return FlxG.mouse.overlaps(thumb);
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        var mouseOverlapping = isMouseOverlapping();
        var mouseJustPressed = FlxG.mouse.justPressed;
        var mousePressed = FlxG.mouse.pressed;

        if (!isDragging) {
            this.setFocus(mouseOverlapping);
            if (mouseOverlapping && mouseJustPressed) {
                isDragging = true;
                thumb.color = FlxColor.YELLOW;
                
                if (isMouseOverTrack() || !isMouseOverThumb()) {
                    var relativeX = FlxG.mouse.x - track.x;
                    var percent = FlxMath.bound(relativeX / trackWidth, 0, 1);
                    value = minValue + percent * (maxValue - minValue);
                }
            }
        } else {
            if (mousePressed) {
                var relativeX = FlxG.mouse.x - track.x;
                var percent = FlxMath.bound(relativeX / trackWidth, 0, 1);
                value = minValue + percent * (maxValue - minValue);
            } else {
                // Mouse released
                isDragging = false;
                thumb.color = mouseOverlapping ? FlxColor.YELLOW : FlxColor.GREEN;
            }
        }
        
        if (isFocused) {
            var step = (maxValue - minValue) * keyboardSpeed;
            
            if (Controls.instance.LEFT_P) {
                value -= (FlxG.keys.pressed.SHIFT) ? step / 5 : step;
            }
            if (Controls.instance.RIGHT_P) {
                value += (FlxG.keys.pressed.SHIFT) ? step / 5 : step;
            }
        }
    }
}