package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.text.FlxText;
import haxe.Timer;
import towsterFlxUtil.TowPaths;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import PlayState.Rank;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class SongFinishedSubState extends FlxSubState
{
	var blackScreen:FlxSprite;
	var rankList:Array<Rank>;
	var rankings = [15, 25, 40, 100];
	var accuracy:Float;

	var noteText:FlxText;

	var mainMessage:FlxText;
	var dialogueSound:FlxSound;
	var loadedTextPointer:Int = 0;
	var ratingSprite:FlxText;

	public function new(rankList:Array<Rank>)
	{
		this.rankList = rankList;
		super(0x00000000);
	}

	override function create()
	{
		super.create();

		blackScreen = new FlxSprite(0, 0).loadGraphic(TowPaths.getFilePath("blackScreen", PNG));
		blackScreen.alpha = 0;
		add(blackScreen);

		FlxTween.tween(blackScreen, {alpha: 0.95}, 1.5, {ease: FlxEase.sineOut});

		// Calculate the accuracy
		for (rank in rankList)
		{
			var rankNum = getRank(rank.difference);
			switch (rankNum)
			{
				case 0:
					accuracy += 100;
				case 1:
					accuracy += 90;
				case 2:
					accuracy += 80;
				case 3:
					accuracy += 50;
			}
		}
		accuracy /= rankList.length;

		var mainMessageText:String = '';
		var finalRating:String = '';

		if (accuracy >= 100)
		{
			mainMessageText = "WOAH!!! I didn't even think that was possible";
			finalRating = "S";
		}
		else if (accuracy > 95)
		{
			mainMessageText = "Bob will be gracefully sleeping";
			finalRating = "A+";
		}
		else if (accuracy > 90)
		{
			mainMessageText = "You're really good at this!";
			finalRating = "A";
		}
		else if (accuracy > 80)
		{
			mainMessageText = "Good! but bob's starting to wake up...";
			finalRating = "B";
		}
		else if (accuracy > 70)
		{
			mainMessageText = "Alright, you might want to try again";
			finalRating = "C";
		}
		else if (accuracy > 60)
		{
			mainMessageText = "Try Again Please so Bob is happy";
			finalRating = "D";
		}
		else if (accuracy > 50)
		{
			mainMessageText = "Just get good c'mon";
			finalRating = "F";
		}
		else
		{
			mainMessageText = "How??????";
			finalRating = "F-";
		}

		dialogueSound = TowPaths.getFile('dialogue', OGG);

		ratingSprite = new FlxText(0, 100, 0, finalRating, 100);
		ratingSprite.screenCenter(X);
		ratingSprite.alpha = 0;
		ratingSprite.font = TowPaths.getFilePath('fonts/Pangolin-Regular.ttf');
		add(ratingSprite);

		noteText = new FlxText(0, 300, 0, 'NOTE:', 60);
		noteText.alpha = 0;
		noteText.font = TowPaths.getFilePath('fonts/Pangolin-Regular.ttf');
		noteText.screenCenter(X);
		add(noteText);

		mainMessage = new FlxText(0, 400, 0, mainMessageText.charAt(0), 50);
		mainMessage.font = TowPaths.getFilePath('fonts/Pangolin-Regular.ttf');
		mainMessage.screenCenter(X);
		add(mainMessage);

		// Rating Animations
		var ratingTimer = new Timer(1000);
		ratingTimer.run = () ->
		{
			ratingSprite.alpha = 1;
			var expandTimer = new Timer(100);
			expandTimer.run = () ->
			{
				ratingSprite.scale.set(1.1, 1.1);
				ratingSprite.updateHitbox();
			}
		}

		var noteTimer = new Timer(2000);
		noteTimer.run = () ->
		{
			FlxTween.tween(noteText, {alpha: 1}, 1);
		}

		// Message Animations
		var mmStartTimer = new Timer(4000);
		mmStartTimer.run = () ->
		{
			var mainMessageTimer = new FlxTimer().start(0.05, (timer) ->
			{
				var lastWidth = mainMessage.width;
				mainMessage.text += mainMessageText.charAt(loadedTextPointer + 1);
				loadedTextPointer++;
				var curWidth = mainMessage.width;
				mainMessage.x -= (curWidth - lastWidth) / 2;
				dialogueSound.play();
			}, mainMessageText.length);
		}
	}

	function getRank(difference:Int)
	{
		for (index => rank in rankings)
		{
			if (difference < rank)
				return index;
		}
		return rankings.length;
	}
}
