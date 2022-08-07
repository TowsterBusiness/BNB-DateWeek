package;

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

	var bob:TowSprite;
	var bosip:TowSprite;
	var BG1:FlxSprite;
	var BG2:FlxSprite;
	var BG3:FlxSprite;

	var birds:FlxTypedSpriteGroup<TowSprite>;

	override public function create()
	{
		super.create();

		conductor = new Conductor();

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

		bosip = new TowSprite(430, 145, 'characters/bosip_assets');
		bosip.scale.set(0.5, 0.5);
		bosip.updateHitbox();

		add(bob);
		add(bosip);

		birds = new FlxTypedSpriteGroup(0, 0, 999);
		add(birds);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE)
		{
			bob.playAnim('idle');
		}

		if (FlxG.keys.justPressed.F1)
		{
			FlxG.switchState(new PlayState());
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
		super.onFocus();
	}

	function debug(obj:FlxObject)
	{
		trace(obj.x + ' , ' + obj.y);
	}
}
