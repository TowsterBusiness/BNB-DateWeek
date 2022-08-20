package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import haxe.Json;
import towsterFlxUtil.TowPaths;
import flixel.FlxSprite;
import flixel.FlxState;
import openfl.utils.Assets as FileSystem;

typedef SongListJson =
{
	songList:Array<String>
}

class FreeplayState extends FlxState
{
	var BG:FlxSprite;

	var songList:FlxTypedSpriteGroup<FlxText>;
	var textSpacing = 30;
	var selectedText = 0;

	override function create()
	{
		super.create();

		BG = new FlxSprite(0, 0).loadGraphic(TowPaths.getFilePath('menus/enuBGBlue', PNG));
		add(BG);

		var songNameList:Array<String> = Json.parse(FileSystem.getText('assets/songs/songList.json')).songList;
		// ! Change this when you get home dip shit
		//* <REMEMBER: to remove the json import>

		songList = new FlxTypedSpriteGroup(30, 30, 999);
		var textOffset = 0;
		for (songName in songNameList)
		{
			var tempText = new FlxText(0, textOffset, 0, songName, 20);
			tempText.borderColor = 0x000000;
			songList.add(tempText);

			textOffset += textSpacing;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			selectedText++;
			updateSongList();
		}
	}

	function updateSongList()
	{
		songList.y = textSpacing * selectedText + 30;
		songList.forEachAlive((text) ->
		{
			text.scale.set(1, 1);
		});
		songList.members[selectedText].scale.set(1.2, 1.2);
	}
}
