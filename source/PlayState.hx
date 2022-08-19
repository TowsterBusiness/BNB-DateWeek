package;

import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import JsonTypes;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import towsterFlxUtil.TowPaths;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import towsterFlxUtil.TowSprite;

class PlayState extends FlxState
{
	var cameraHUD:FlxCamera;

	var conductor:Conductor;
	var firstUpdate:Bool = true;

	var inputKeys:Array<FlxKey> = ['SPACE'];

	var songInst:FlxSound;

	var throwSound:FlxSound;

	var bob:TowSprite;
	var bosip:TowSprite;
	var BG:Background;

	var birdList:FlxTypedSpriteGroup<Bird>;

	var songJson:SongJson;
	var songPath = 'LoveBirds';

	var weirdOffset:Int = 0;
	// Sick, Good, Ok, Bad, Shit
	var rankings = [8, 15, 25, 40, 80];

	/*
		TODO: Add end-screen
		TODO: Credits
		TODO: Freeplay
		TODO: Options

	 */
	override public function create()
	{
		super.create();

		songPath = StaticVar.nextSong;
		songJson = TowPaths.getFile('songs/' + songPath + '/chart', JSON, false);

		songInst = FlxG.sound.load(TowPaths.getFilePath('songs/' + songPath + '/Inst', OGG, false));
		throwSound = FlxG.sound.load('assets/sounds/toss.wav');

		BG = new Background('day');
		add(BG);

		bob = new TowSprite(675, 190, 'characters/bob_assets');
		bob.loadAnimations('characters/bob');
		bob.scale.set(0.5, 0.5);
		bob.playAnim('idle');
		bob.updateHitbox();

		bosip = new TowSprite(500, 150, 'characters/bosip_assets');
		bosip.loadAnimations('characters/bosip');
		bosip.scale.set(0.5, 0.5);
		bosip.playAnim('idle');
		bosip.updateHitbox();

		add(bob);
		add(bosip);

		birdList = new FlxTypedSpriteGroup(0, 0, 999);
		add(birdList);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (firstUpdate)
		{
			conductor = new Conductor(songJson.bpmList, 0);
			songInst.play();
			songInst.time = conductor.getMil();
			firstUpdate = false;
		}

		organizeNotes();

		if (FlxG.keys.justPressed.F1)
		{
			FlxG.switchState(new PlayState());
		}

		birdList.forEachAlive(function(bird)
		{
			if (conductor.getMil() > bird.time + bird.actionTime(0))
			{
				// bruh lmao
				bird.comeIn(Math.floor(Math.abs(bird.actionTime(0))));
			}
			if (conductor.getMil() > bird.time + bird.actionTime(1))
			{
				bird.peck();
			}
			if (conductor.getMil() > bird.time + bird.actionTime(2))
			{
				bird.rank();
			}
			if (conductor.getMil() > bird.time + bird.actionTime(3))
			{
				bird.goOut(bird.actionTime(3));
			}
		});

		if (conductor.pastBeat())
		{
			bob.playAnim('idle');
			if (bosip.animation.finished || bosip.animation.curAnim.name == 'idle')
			{
				bosip.playAnim('idle');
			}
		}

		if (FlxG.keys.anyJustPressed(inputKeys))
		{
			bosip.playAnim('throw');
			throwSound.play(true);

			var closestTimedBird:Bird = null;
			birdList.forEachAlive(function(bird)
			{
				if (getRank(bird.time) == rankings.length)
					return;
				if (closestTimedBird == null)
					closestTimedBird = bird;
				if (Math.abs(conductor.getMil() - bird.time) < Math.abs(conductor.getMil() - closestTimedBird.time))
					closestTimedBird = bird;
			});

			if (closestTimedBird != null)
			{
				trace(getRank(closestTimedBird.time));
				closestTimedBird.shouldRank = false;
			}
		}
	}

	var preBeats = 4;

	function organizeNotes()
	{
		var noteList = songJson.chart;

		var usedTimeList = [];

		birdList.forEachAlive(function(bird)
		{
			usedTimeList.push(bird.time);
		});

		for (note in noteList)
		{
			if (!usedTimeList.contains(note.time) && conductor.getMil() < note.time)
			{
				birdList.add(new Bird(note.id, note.time, conductor.getBPM().bpm));
			}
		}
	}

	function getRank(time:Int)
	{
		var difference = Math.abs(conductor.getMil() - time);

		for (index => rank in rankings)
		{
			if (difference < rank)
				return index;
		}
		return rankings.length;
	}

	function addRankSprite(rankNum:Int) {}

	override function onFocusLost()
	{
		conductor.pause();
		super.onFocusLost();
	}

	override function onFocus()
	{
		conductor.unPause();
		songInst.time = conductor.getMil() - weirdOffset;
		super.onFocus();
	}
}
