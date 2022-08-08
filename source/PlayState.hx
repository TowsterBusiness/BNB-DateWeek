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

	var inputKeys:Array<FlxKey> = ['SPACE'];

	var songInst:FlxSound;
	var peckSound:FlxSound;
	var flyInSound:FlxSound;
	var thowSound:FlxSound;
	var squawkSound:FlxSound;

	var bob:TowSprite;
	var bosip:TowSprite;
	var BG1:FlxSprite;
	var BG2:FlxSprite;
	var BG3:FlxSprite;

	var birdList:FlxTypedSpriteGroup<Bird>;

	var songJson:SongJson;
	var songPath = 'LoveBirds';

	override public function create()
	{
		super.create();

		songJson = TowPaths.getFile('songs/' + songPath + '/chart', JSON, false);

		conductor = new Conductor(songJson.bpmList, -10);

		songInst = FlxG.sound.load(TowPaths.getFilePath('songs/' + songPath + '/' + songPath, OGG, false));
		songInst.play();
		songInst.time = conductor.getMil() - 10;

		// BG
		BG1 = new FlxSprite(0, -10).loadGraphic(TowPaths.getFilePath('bg/day/bg1', PNG));
		BG2 = new FlxSprite(0, -10).loadGraphic(TowPaths.getFilePath('bg/day/bg2', PNG));
		BG3 = new FlxSprite(0, -10).loadGraphic(TowPaths.getFilePath('bg/day/bg3', PNG));
		BG1.scale.set(0.67, 0.67);
		BG2.scale.set(0.67, 0.67);
		BG3.scale.set(0.67, 0.67);
		BG1.updateHitbox();
		BG2.updateHitbox();
		BG3.updateHitbox();
		add(BG1);
		add(BG2);
		add(BG3);

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
				bird.goOut(bird.actionTime(2));
			}
		});

		if (conductor.pastBeat())
		{
			bob.playAnim('idle');
			bosip.playAnim('idle');
		}

		if (FlxG.keys.anyJustPressed(inputKeys))
		{
			bosip.playAnim('throw');
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

	override function onFocusLost()
	{
		conductor.pause();
		super.onFocusLost();
	}

	override function onFocus()
	{
		conductor.unPause();
		songInst.time = conductor.getMil() - 10;
		super.onFocus();
	}
}
