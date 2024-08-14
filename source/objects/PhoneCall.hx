package objects;

@:structInit class PhoneVariables {
	public var tutorialCompleted:Bool = false;
}

class PhoneCall 
{
    public static var data:PhoneVariables = {};

    public function new():Void {}
}