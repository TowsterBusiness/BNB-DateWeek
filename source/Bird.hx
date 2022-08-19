package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import towsterFlxUtil.TowSprite;
import flixel.FlxSprite;

class Bird extends TowSprite
{
	public var time = 0;

	// pre, peck, rate, post
	public var beats:Array<Int> = [0, 0, 0];

	var hasFlownIn:Bool = false;
	var hasFlownOut:Bool = false;
	var hasPecked:Bool = false;

	public var shouldRank:Bool = true;

	var bpm:Float = 120;
	var isBop:Bool = false;

	var peckSound:FlxSound;
	var flyInSound:FlxSound;
	var throwSound:FlxSound;
	var squawkSound:FlxSound;

	public function new(id:String, time:Int, bpm:Float)
	{
		this.bpm = bpm;
		this.time = time;

		peckSound = FlxG.sound.load('assets/sounds/cromch.wav');
		flyInSound = FlxG.sound.load('assets/sounds/swoop.wav');

		var fileName = '';
		var jsonFileName = '';
		switch (id)
		{
			case 'bird 1':
				fileName = 'bird_assets';
				jsonFileName = 'bird';
				beats = [-4, 4, 8, 12];
			case 'bird 2':
				fileName = 'twitter_bird_assets';
				jsonFileName = 'twitter-bird';
				beats = [-2, 2, 4, 6];
			case 'bird 3':
				fileName = 'bird_assets';
				jsonFileName = 'bird';
				beats = [-4, 2, 4, 6];
		}
		super(-160, 300, 'distractions/' + fileName);
		scale.set(0.5, 0.5);
		updateHitbox();
		loadAnimations('characters/' + jsonFileName);
	}

	public function actionTime(index:Int):Int
	{
		if (index > beats.length - 1)
			trace("don't try to access beats that don't exist");
		return Math.floor(60000 / bpm * beats[index] / 4);
	}

	public function comeIn(time:Int):Void
	{
		if (hasFlownIn)
			return;
		playAnim('flying');
		flyInSound.play();
		hasFlownIn = true;
		FlxTween.tween(this, {x: 170, y: 540}, time / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: (tween) ->
			{
				isBop = true;
				playAnim('landing');
			}
		});
	}

	public function goOut(time:Int):Void
	{
		if (hasFlownOut)
			return;
		playAnim('flying');
		isBop = false;
		hasFlownOut = true;
		FlxTween.tween(this, {x: 1300, y: 50}, time / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: (tween) ->
			{
				kill();
			}
		});
	}

	public function peck()
	{
		if (hasPecked)
			return;
		hasPecked = true;
		playAnim('eat');
		peckSound.play();
	}

	public function rank()
	{
		if (!shouldRank)
			return;
		shouldRank = false;
		playAnim('squawk');
	}
}
