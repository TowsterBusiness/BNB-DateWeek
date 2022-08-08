package;

import JsonTypes;
import haxe.Timer;

class Conductor
{
	var bpmJson:Array<BPMJson>;
	var startTime:Int;

	var pauseStartTime:Int = 0;
	var pauseCounter:Int = 0;
	var isPause:Bool = false;

	public function new(bpmJson:Array<BPMJson>, ?startDelay:Int = 0)
	{
		this.bpmJson = bpmJson;
		startTime = getRawMil() - startDelay;
	}

	public function getMil():Int
	{
		if (isPause)
			return getRawMil() - (startTime + pauseCounter + (getRawMil() - pauseStartTime));

		return getRawMil() - (startTime + pauseCounter);
	}

	public function getBPM():BPMJson
	{
		var returnBpm:BPMJson = {time: -1, bpm: 120};
		for (bpm in bpmJson)
		{
			if (getMil() > bpm.time && bpm.time > returnBpm.time)
			{
				returnBpm = bpm;
			}
		}
		return returnBpm;
	}

	var nextBeatCheck:Float = 0;

	public function pastBeat():Bool
	{
		if (nextBeatCheck > getBPM().time)
			nextBeatCheck = getBPM().time;

		if (getMil() > nextBeatCheck)
		{
			nextBeatCheck += (6000 / getBPM().bpm * 8);
			return true;
		}
		return false;
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
		trace(pauseCounter);
		trace(pauseStartTime);
		pauseCounter += getRawMil() - pauseStartTime;
		pauseStartTime = 0;
	}

	public function getRawMil():Int
	{
		return Math.floor(Timer.stamp() * 1000);
	}
}
