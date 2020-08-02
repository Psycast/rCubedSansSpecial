package scripts 
{
	import flash.display.Sprite;
	
	public class SansGasterBlastBeam extends Sprite 
	{
		public var BlastTime:Number = 0;
		public var Timer:Number = 0;
		public var BaseSize:Number = 0;
		public var SineSize:Number = 0;
		
		public function SansGasterBlastBeam(w:Number, h:Number, color:uint = 0xFFFFFF) 
		{
			this.graphics.beginFill(color, 1);
			this.graphics.drawRect(0, -(h / 2), w, h);
			this.graphics.endFill();
			
			this.visible = false;
		}
		
		public function DrawBeam():void 
		{
		}
		
	}

}