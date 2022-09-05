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
	var beatCheckBPM:BPMJson;

	public function pastBeat():Bool
	{
		var bpmNow:BPMJson = getBPM();
		if (nextBeatCheck > bpmNow.time && beatCheckBPM != bpmNow)
		{
			nextBeatCheck = bpmNow.time;
			beatCheckBPM = bpmNow;
		}

		if (getMil() > nextBeatCheck)
		{
			nextBeatCheck += (60000 / getBPM().bpm);
			return true;
		}
		return false;
	}

	public function pause():Void
	{
		if (isPause)
			return;
		isPause = true;
		pauseStartTime = getRawMil();
	}

	public function unPause():Void
	{
		if (!isPause)
			return;
		isPause = false;
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
