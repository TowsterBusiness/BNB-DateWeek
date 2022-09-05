package;

import flixel.tweens.FlxEase;
import towsterFlxUtil.TowUtils;
import flixel.ui.FlxBar;
import flixel.tweens.FlxTween;
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

typedef Rank =
{
	time:Int,
	difference:Int
}

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

	var offset:Int = 0;
	// Sick, Good, Ok, Bad, Shit
	var ratingSprite:FlxTypedSpriteGroup<RatingSprite>;
	//* I coppied this into SongFinishedSubState so be careful
	var rankings = [15, 25, 40, 100];
	var rankList:Array<Rank> = [];
	var rankNames = ["sick", "good", "Bad", "Shit"];

	var healthBar:FlxBar;
	var healthBG:FlxSprite;
	var healthP1:HealthIcon;
	var healthP2:HealthIcon;

	/*
		TODO: Add end-screen
		TODO: Credits
		TODO: Freeplay
		TODO: Clean up

	 */
	override public function create()
	{
		super.create();

		songPath = StaticVar.nextSong;
		songJson = TowPaths.getFile('songs/' + songPath + '/chart', JSON, false);

		songInst = FlxG.sound.load(TowPaths.getFilePath('songs/' + songPath + '/Inst', OGG, false));
		songInst.onComplete = () ->
		{
			openSubState(new SongFinishedSubState(rankList));
		};
		throwSound = FlxG.sound.load('assets/sounds/toss.wav');

		offset = 1000;

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

		ratingSprite = new FlxTypedSpriteGroup(100, 100, 99);
		add(ratingSprite);

		healthBG = new FlxSprite(0, 46).loadGraphic(TowPaths.getFilePath('healthBar', PNG));
		healthBG.screenCenter(X);
		add(healthBG);

		healthBar = new FlxBar(0, 50, LEFT_TO_RIGHT, 590, 11);
		healthBar.createFilledBar(0xFF859ac1, 0xFFfdd173);
		healthBar.screenCenter(X);
		healthBar.percent = 50;
		add(healthBar);

		healthP1 = new HealthIcon(550, 5, 'bosip', true);
		healthP2 = new HealthIcon(600, 5, 'bob-sleep', false);
		add(healthP2);
		add(healthP1);
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

			if (healthP1.angle != 5)
			{
				FlxTween.tween(healthP1, {angle: 5}, 0.3, {ease: FlxEase.expoOut});
				FlxTween.tween(healthP2, {angle: -5}, 0.3, {ease: FlxEase.expoOut});
			}
			else
			{
				FlxTween.tween(healthP1, {angle: -5}, 0.3, {ease: FlxEase.expoOut});
				FlxTween.tween(healthP2, {angle: 5}, 0.3, {ease: FlxEase.expoOut});
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
				var tempRank = getRank(closestTimedBird.time);
				ratingSprite.add(new RatingSprite(tempRank));
				rankList.push({time: closestTimedBird.time, difference: conductor.getMil() - closestTimedBird.time});
				closestTimedBird.shouldRank = false;
			}
		}

		// ! THIS IS DEBUG CODE
		if (FlxG.keys.justPressed.F2)
		{
			openSubState(new SongFinishedSubState(rankList));
		}
		if (FlxG.keys.justPressed.F1)
		{
			FlxG.switchState(new PlayState());
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

	override function onFocusLost()
	{
		conductor.pause();
		super.onFocusLost();
	}

	override function onFocus()
	{
		conductor.unPause();
		songInst.time = conductor.getMil();
		super.onFocus();
	}
}
