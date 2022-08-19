package;

import haxe.Timer;
import flixel.text.FlxText;

class DialogueText extends FlxText
{
	var finText:String = '';

	public function new()
	{
		super(358, 506, 0, '', 20);
		var timer:Timer = new Timer(20);
		timer.run = function()
		{
			if (text < finText)
			{
				text += finText.charAt(text.length);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function nextText(text:String)
	{
		super.text = '';
		finText = text;
	}

	public function finish():Void
	{
		super.text = finText;
	}

	public function isFinished():Bool
	{
		return text >= finText;
	}
}
