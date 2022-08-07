package;

import haxe.Timer;

class Conductor
{
	var startTime:Int;

	var pauseStartTime:Int = 0;
	var pauseCounter:Int = 0;
	var isPause:Bool = false;

	public function new(?startDelay:Int = 0)
	{
		startTime = getRawMil() - startDelay;
	}

	public function getMil():Int
	{
		return getRawMil() - startTime - pauseCounter - (getRawMil() - pauseStartTime);
	}

	public function pause():Void
	{
		if (isPause)
			return;
		pauseStartTime = getRawMil();
	}

	public function unPause():Void
	{
		if (!isPause)
			return;
		pauseCounter += getRawMil() - pauseStartTime;
	}

	public function getRawMil():Int
	{
		return Math.floor(Timer.stamp() * 1000);
	}
}
