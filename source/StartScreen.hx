package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Timer;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import towsterFlxUtil.TowSprite;
import towsterFlxUtil.TowUtils;
import towsterFlxUtil.TowPaths;
import flixel.FlxSprite;
import flixel.FlxState;

class StartScreen extends FlxState
{
	var conductor:Conductor;
	var song:FlxSound;

	var blackBG:FlxSprite;
	var BG:FlxSprite;
	var bench:FlxSprite;
	var bushes:FlxSprite;
	var logoBumpin:TowSprite;
	var mainChar:FlxSprite;

	var beatNum = 0;

	override function create()
	{
		super.create();

		song = FlxG.sound.load(TowPaths.getFilePath('sounds/menu/neg_bnb_menu_music_maybe_.wav'));

		// blackBG = new FlxSprite(0, 0, AssetPaths.blackScreen__png);

		BG = new FlxSprite(0, 0).loadGraphic(TowPaths.getFilePath('start screen/sky', PNG));
		BG.scale.set(0.7, 0.7);
		BG.updateHitbox();
		add(BG);

		bushes = new FlxSprite(-245, 230).loadGraphic(TowPaths.getFilePath('start screen/bushes', PNG));
		bushes.scale.set(0.7, 0.7);
		bushes.updateHitbox();
		bushes.antialiasing = true;
		add(bushes);

		bench = new FlxSprite(465, 475).loadGraphic(TowPaths.getFilePath('start screen/bench', PNG));
		bench.scale.set(0.7, 0.7);
		bench.updateHitbox();
		add(bench);

		logoBumpin = new TowSprite(75, 65, 'start screen/logoBumpin', true);
		logoBumpin.scale.set(0.7, 0.7);
		logoBumpin.updateHitbox();
		logoBumpin.playAnim('idle');
		logoBumpin.antialiasing = true;
		add(logoBumpin);

		mainChar = new FlxSprite(765, 160);
		mainChar.frames = TowPaths.getAnimation('start screen/bob_bosip_dance_title');
		mainChar.animation.addByIndices("right", "bob and bosip bop0", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], '', 24, false);
		mainChar.animation.addByIndices("left", "bob and bosip bop0", [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], '', 24, false);
		mainChar.scale.set(0.6, 0.6);
		mainChar.updateHitbox();
		mainChar.antialiasing = true;
		add(mainChar);
	}

	var first = 0;

	var last:Float = 0;

	var right:Bool = true;

	override function update(elapsed:Float)
	{
		if (first == 0)
		{
			conductor = new Conductor([{"bpm": 115, "time": 0}]);
			song.play();
			first = -1;
		}

		BG.y = -50 * (Math.sin(2 * Timer.stamp() * 3.1415) / 2 + 0.5);

		if (conductor.pastBeat())
		{
			if (right)
			{
				mainChar.animation.play('right');
				logoBumpin.playAnim('idle');
				// FlxTween.tween(BG, {y: -50}, 60 / conductor.getBPM(), {
				// 	ease: (t) -> {
				// 		 return (-4 * t) * (t - 1);
				// 	},
				// 	onComplete: (x) -> {
				// 		 BG.y = 0;
				// 	}
				// });
			}
			else
				mainChar.animation.play('left');
			right = !right;

			TowUtils.debug(bushes);

			beatNum++;
			trace(beatNum);
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			var stamp = Timer.stamp();
			trace(stamp - last);
			last = stamp;
		}
		super.update(elapsed);
	}

	override function onFocusLost()
	{
		conductor.pause();
		super.onFocusLost();
	}

	override function onFocus()
	{
		conductor.unPause();
		song.time = conductor.getMil();
		super.onFocus();
	}
}
