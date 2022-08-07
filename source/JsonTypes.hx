typedef BPMJson =
{
	bpm:Float,
	time:Int
}

typedef NoteJson =
{
	id:String,
	time:Int
}

typedef ChartJSON =
{
	bpmList:Array<BPMJson>,
	chart:Array<NoteJson>
}

class JsonTypes {}
