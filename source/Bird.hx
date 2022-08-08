package;

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
	var hasRanked:Bool = false;

	var bpm:Float = 120;
	var isBop:Bool = false;
	var shouldSquawk:Bool = true;

	public function new(id:String, time:Int, bpm:Float)
	{
		this.bpm = bpm;
		this.time = time;

		var fileName = '';
		var jsonFileName = '';
		switch (id)
		{
			case 'bird 1':
				fileName = 'bird_assets';
				jsonFileName = 'bird';
				beats = [-16, 16, 32, 48];
			case 'bird 2':
				fileName = 'twitter_bird_assets';
				jsonFileName = 'twitter-bird';
				beats = [-8, 8, 16, 24];
				flipX = true;
			case 'bird 3':
				fileName = 'bird_assets';
				jsonFileName = 'bird';
				beats = [-16, 8, 16, 24];
		}
		super(1300, 50, 'distractions/' + fileName);
		scale.set(0.5, 0.5);
		updateHitbox();
		loadAnimations('characters/' + jsonFileName);
	}

	public function actionTime(index:Int):Int
	{
		if (index > beats.length - 1)
			trace("don't try to access beats that don't exist");
		return Math.floor(6000 / bpm * beats[index]);
	}

	public function comeIn(time:Int):Void
	{
		if (hasFlownIn)
			return;
		playAnim('flying');
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
		FlxTween.tween(this, {x: -160, y: 300}, time / 1000, {
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
	}

	public function rank()
	{
		if (hasRanked)
			return;
		hasRanked = true;
		if (shouldSquawk)
		{
			playAnim('squawk');
		}
	}
}
