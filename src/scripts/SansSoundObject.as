package scripts
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class SansSoundObject
	{
		private static var _extracted_sounds:Array = [];
		
		private var _playbackSpeed:Number = 1;
		
		private var _loadedMP3Samples:ByteArray;
		private var _dynamicSound:Sound;
		
		private var _phase:Number;
		private var _numSamples:int;
		private var _markStop:Boolean = false;

		public var isPlaying:Boolean = false;
		
		public function SansSoundObject(findClass:Class, sound:String, rate:Number)
		{
			_playbackSpeed = rate;
			
			if (_extracted_sounds[sound] == null)
			{
				var snd:Sound = new findClass();
				var bytes:ByteArray = new ByteArray();
				snd.extract(bytes, int(snd.length * 44.1));
				_extracted_sounds[sound] = bytes;
			}
			
			beginPlay(_extracted_sounds[sound] as ByteArray);
		}
		
		public function play():void
		{
			beginPlay(_loadedMP3Samples);
		}

		public function stop():void
		{
			isPlaying = false;
			if (_dynamicSound)
			{
				_dynamicSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_dynamicSound = null;
			}
		}

		public function pause():void
		{
			stop();
		}
		
		public function resume():void
		{
			if(_loadedMP3Samples == null || isPlaying)
				return;

			startAudio(_phase);
		}
		
		public function restart():void 
		{
			stop();	
			play();
		}
		
		private function beginPlay(bytes:ByteArray):void
		{
			stop();
			_loadedMP3Samples = bytes;
			_numSamples = bytes.length / 8;

			startAudio(0);
		}

		private function startAudio(phase:Number):void
		{
			isPlaying = true;
			_dynamicSound = new Sound();
			_dynamicSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			_phase = phase;
			_dynamicSound.play();
		}
		private function onSampleData(event:SampleDataEvent):void
		{
			var l:Number;
			var r:Number;
			
			var outputLength:int = 0;
			while (outputLength < 2048)
			{
				_loadedMP3Samples.position = int(_phase) * 8; // 4 bytes per float and two channels so the actual position in the ByteArray is a factor of 8 bigger than the phase
				
				l = _loadedMP3Samples.readFloat();
				r = _loadedMP3Samples.readFloat();
				
				event.data.writeFloat(l);
				event.data.writeFloat(r);
				
				outputLength++;
				
				_phase += _playbackSpeed;
				
				if (_phase >= _numSamples)
				{
					while (outputLength < 2048)
					{
						event.data.writeFloat(0);
						event.data.writeFloat(0);
						outputLength++;
					}
					_markStop = true;
				}
			}
			
			if (_markStop)
				stop();
		}
	}
}