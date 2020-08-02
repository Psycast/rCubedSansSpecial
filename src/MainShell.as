package {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MainShell extends Sprite {
		[Embed(source="../bin/Game.swf",mimeType="application/octet-stream")]
		private static const game:Class;
		
		public function MainShell() {
			if (stage)
				gameInit();
			else
				this.addEventListener(Event.ADDED_TO_STAGE, gameInit);
		}
		
		private function gameInit(e:Event = null):void {
			if (e != null)
				removeEventListener(Event.ADDED_TO_STAGE, gameInit);
			
			// Add Game to Stage
			Loader(addChild(new Loader())).loadBytes(new game());
		}
	}
}