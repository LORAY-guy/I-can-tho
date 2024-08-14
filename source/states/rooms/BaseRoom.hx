package states.rooms;

/**
 * ### Base Room
 * The base group to manage rooms and makes them easier to create.
 *
 * @param roomName 			Pretty self-explanatory 
 */
class BaseRoom extends FlxTypedGroup<FlxBasic>
{
	private var game(default, set):PlayState = PlayState.instance;
	
	public var paused(get, never):Bool;
	public var canPause(get, set):Bool;
	public var currentRoom(get, never):BaseRoom;

	private var tutorialMode(get, set):Bool;
	private var inCutscene(get, set):Bool;

	public var ourple(get, never):Ourple;

	public var mouses:Array<Mouse> = [];
	public var walls:Array<FlxSprite> = [];
	public var exits:Array<Exit> = []; //For animatronics
	public var props:Array<FlxSprite> = []; // Basically, same as walls, but doesn't stop mouses to make it feel like they sneak under them.
	public var animatronics:Array<Animatronic> = [];
	public var childs:Array<CryingChild> = [];
	public var waterDrops:FlxTypedGroup<WaterDrop> = new FlxTypedGroup<WaterDrop>();
	public var onTopOfOurple:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public var goldenFreddy:GoldenFreddy = null;

    public var leftRooms:Array<BaseRoom> = [];

	public var sounds:Array<FlxSound> = [];
	public var ambienceManager(get, never):AmbienceManager;

	public var floor:FlxSprite = null;

	public var roomName:String;
	public var animatronicSpawnOffset:FlxPoint = null; //I'm so tired of animatronic spawning in walls/furnitures

    public function new(roomName:String):Void
	{
		super();
		if(this.game == null) {
			FlxG.log.warn('Invalid state for the stage added!');
			destroy();
		} else {
			create();
		}

		this.roomName = roomName;

		new FlxTimer().start(2, function(tmr:FlxTimer) {
			if (FlxG.random.bool(0.75)) {
				waterDrops.add(new WaterDrop(this));
			}
		}, 0);
	}

	public var camHUD(get, never):FlxCamera;
	public var camPause(get, never):FlxCamera;

	public function create():Void {}
	public function onLoad():Void {}

	public function openSubState(SubState:FlxSubState):Void {}
	public function closeSubState():Void {}
	
	public function addBehindOurple(obj:FlxBasic):Void insert(members.indexOf(game.ourple), obj);
	public function addOnTopOfOurple(obj:FlxBasic):Void insert(members.indexOf(game.ourple) + 1, obj);

	public function addLeftRooms(rooms:Array<BaseRoom>):Void
	{
		for (room in rooms)
		{
			if (this.leftRooms.indexOf(room) == -1)
			{
				this.leftRooms.push(room);
				room.addLeftRooms(rooms); // Recursively add rooms on the left from that room's list
			}
		}
	}

	public function addAnimatronic(animatronic:Animatronic):Void
	{
		animatronics.push(animatronic);
		add(animatronic);
	}

	public function removeAnimatronic(animatronic:Animatronic):Void
	{
		if (animatronics.contains(animatronic)) {
			animatronics.remove(animatronic);
			remove(animatronic);
		}
	}

	public function addChild(child:CryingChild):Void
	{
		childs.push(child);
		add(child);
	}

	public function removeChild(child:CryingChild):Void
	{
		if (childs.contains(child)) {
			childs.remove(child);
			remove(child);
		}
	}

	inline private function get_paused():Bool return game.paused;
	inline private function get_canPause():Bool return game.canPause;
	inline private function set_canPause(value:Bool):Bool
	{
		game.canPause = value;
		return value;
	}
	
	inline private function get_tutorialMode():Bool return CoolUtil.tutorialMode;
	inline private function set_tutorialMode(value:Bool):Bool 
	{
		CoolUtil.tutorialMode = value;
		return value;
	}

	inline private function get_inCutscene():Bool return game.inCutscene;
	inline private function set_inCutscene(value:Bool):Bool 
	{
		game.inCutscene = value;
		return value;
	}

	inline private function get_currentRoom():BaseRoom return game.currentRoom; 

	inline private function set_game(value:PlayState):PlayState
	{
		game = value;
		return value;
	}

	inline private function get_ourple():Ourple return game.ourple;

	inline private function get_camHUD():FlxCamera return game.camHUD;
	inline private function get_camPause():FlxCamera return game.camPause;

	inline private function get_ambienceManager():AmbienceManager return game.ambienceManager;

	public function createMouses():Void
	{
		if (currentRoom.roomName != 'RoomAfton') //They would get on top of the characters everytime, I'm sure no one will notice that they are missing.
		{
			var mouseAmount:Int = FlxG.random.int(0, 3); //Accurate amount of mouses in a room
			for (i in 0...mouseAmount) {
				var mouse:Mouse = new Mouse();
				add(mouse);
				mouses.push(mouse);
			}
		}
	}

	public function checkForGoldenFreddy():Void
	{
		if (!tutorialMode && !inCutscene && currentRoom.roomName != 'RoomAfton' && animatronics.length == 0 && childs.length == 0 && !Std.isOfType(currentRoom, Room1) && goldenFreddy == null && FlxG.random.bool(1)) {
			goldenFreddy = new GoldenFreddy();
			add(goldenFreddy);
		}
	}

	private function createFloor():Void
	{
		if (floor == null)
		{
			floor = new FlxSprite().loadGraphic(Paths.image('floorDark'));
			floor.screenCenter();
			add(floor);
		}
	}

	private function createWall(width:Int, height:Int, ?x:Float = 0, ?y:Float = 0, ?topOfOurple:Bool = false):FlxSprite
	{
        var wall = new FlxSprite().makeGraphic(width, height, 0xFF2B2B5F);
        wall.setPosition(x, y);
        wall.immovable = true;

		if (topOfOurple) onTopOfOurple.add(wall);
		add(wall);
        walls.push(wall);

		return wall;
	}

	public function floorFlash():Void
	{
		if (floor != null)
		{
			new FlxTimer().start(0.25, function(tmr:FlxTimer) {
				if (tmr.elapsedLoops % 2 == 0) {
					floor.loadGraphic(Paths.image('floorDark'));
				} else {
					floor.loadGraphic(Paths.image('floorLight'));
				}
			}, 4);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		ourpleCollision();

		if (PlayState.instance.cryingChildMode) childCollision();
		else animatronicCollision();
	}

	private function ourpleCollision():Void
	{
		if (currentRoom == this)
		{
			for (wall in walls) {
				FlxG.collide(ourple, wall);
			}

			for (prop in props) {
				FlxG.collide(ourple, prop);
			}
		}
	}

	private function animatronicCollision():Void
	{
		if (currentRoom == this)
		{
			for (animatronic in animatronics)
			{
				if (!animatronic.tutorialMode && !animatronic.dead) {
					for (wall in walls) {
						FlxG.collide(animatronic, wall);
					}
		
					for (prop in props) {
						FlxG.collide(animatronic, prop);
					}
				}
			}
		}
	}

	private function childCollision():Void
	{
		if (currentRoom == this)
		{
			for (child in childs)
			{
				for (wall in walls) {
					FlxG.collide(child, wall);
				}
	
				for (prop in props) {
					FlxG.collide(child, prop);
				}
			}
		}
	}
}